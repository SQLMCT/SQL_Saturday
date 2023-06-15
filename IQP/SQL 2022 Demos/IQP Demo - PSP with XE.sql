/*	
************************************************************************ --
Parameter Sensitive Plan (PSP) Optimization demo

Current Availability:
Azure SQL Database (2022 public preview)
SQL Server 2022 CTP 1.0

Demo uses "PropertyMLS" database which can be imported from BACPAC here:
https://github.com/microsoft/sql-server-samples/tree/master/samples/features/query-store

Email PSPFeedback@microsoft.com for questions\feedback
Documentation: https://docs.microsoft.com/en-us/sql/relational-databases/performance/parameter-sensitivity-plan-optimization?view=sql-server-ver16
************************************************************************ 
*/

--	Verify that the instance version is SQL Server 2022

SELECT @@VERSION
GO

--	Setup environment, using compatibility level 160 and enable Query Store.
--	This feature does not require Query Store, but is our preferred flight 
--	recorder for viewing performance and plan history

USE [master]
GO
ALTER DATABASE [PropertyMLS] SET COMPATIBILITY_LEVEL = 160;
GO
ALTER DATABASE [PropertyMLS] SET QUERY_STORE = ON
GO
ALTER DATABASE [PropertyMLS] SET QUERY_STORE 
	(OPERATION_MODE = READ_WRITE, 
	 DATA_FLUSH_INTERVAL_SECONDS = 60, 
	 INTERVAL_LENGTH_MINUTES = 1, 
	 QUERY_CAPTURE_MODE = ALL)
GO

--	Clear out the Query Store and the Procedure Cache
USE [PropertyMLS]
GO
ALTER DATABASE [PropertyMLS] SET QUERY_STORE CLEAR ALL
GO
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE  
GO

--	Verify there is no Query Store Hints in sys.query_store_query_hints, 
--	checking if any already exist (should be none).
--	https://docs.microsoft.com/en-us/sql/relational-databases/performance/query-store-hints?view=sql-server-ver16

SELECT	query_hint_id,
		query_id,
		query_hint_text,
		last_query_hint_failure_reason,
		last_query_hint_failure_reason_desc,
		query_hint_failure_count,
		source,
		source_desc
FROM sys.query_store_query_hints;
GO

-- Look at list of Database Scoped Configuration settings.
-- https://docs.microsoft.com/en-us/sql/t-sql/statements/alter-database-scoped-configuration-transact-sql?view=sql-server-ver16

SELECT * FROM sys.database_scoped_configurations

--	We are able to toggle PSP with the ALTER DATABASE SCOPED CONFIGURATION; 
--	PSP Optimization is on by default.

ALTER DATABASE SCOPED CONFIGURATION SET 
	PARAMETER_SENSITIVE_PLAN_OPTIMIZATION = ON
GO

--	Let's examine the PropertySearchByAgent stored procedure
--	Notice in this parameterized stored procedure, the @AgentId parameter 
--	which is used to retrieve the list of properties in this agent's portfolio 
--	reading from the dbo.Property table

EXEC sp_helptext PropertySearchByAgent
GO

--	Remember that PSP creates the variants by looking at the statistics 
--	histogram created for every column and we know that the AgentId 
--	statistic was created when this NCI was created.

--	The range_high_key is the Agent id parameters that are possible 
--	and the equality rows are the ones that match exactly.
--	We can see the is the data distribution is centered 
--	on Agent_Id 1 and 2

SELECT sh.* 
	FROM sys.stats AS s
	CROSS APPLY 
		sys.dm_db_stats_histogram(s.object_id, s.stats_id) AS sh
	WHERE name = 'NCI_Property_AgentId' 
		AND s.object_id = OBJECT_ID('dbo.Property')
GO

--	Let's set up an XE capture to capture our PSP behavior

IF EXISTS (SELECT * FROM sys.server_event_sessions WHERE name = 'PSP_XE')
DROP EVENT SESSION [PSP_XE] ON SERVER;
GO
CREATE EVENT SESSION [PSP_XE] ON SERVER 
ADD EVENT sqlserver.parameter_sensitive_plan_optimization(
    ACTION(sqlserver.query_hash_signed,
	sqlserver.query_plan_hash_signed,sqlserver.sql_text)),
ADD EVENT sqlserver.parameter_sensitive_plan_testing(
    ACTION(sqlserver.query_hash_signed,
	sqlserver.query_plan_hash_signed,sqlserver.sql_text)),
ADD EVENT query_with_parameter_sensitivity(
    ACTION(sqlserver.query_hash_signed,
	sqlserver.query_plan_hash_signed,sqlserver.sql_text)),
ADD EVENT sqlserver.parameter_sensitive_plan_optimization_skipped_reason(
    ACTION(sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.sql_text))
WITH (MAX_MEMORY=4096KB,
	EVENT_RETENTION_MODE=NO_EVENT_LOSS,
	MAX_DISPATCH_LATENCY=1 SECONDS,MAX_EVENT_SIZE=0KB,
	MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,
	STARTUP_STATE=OFF)
GO

--5b. Start XE
ALTER EVENT SESSION [PSP_XE] 
ON SERVER STATE = START;
GO

--	5c. In SSMS, right-click 'PSP_XE' and select 'Watch Live Data'

--	6a. Run the first in a different session as it takes over a minute
--	as there are agents with millions of properties

--	Turn on the actual execution plan 
--	Copy to new query window. (This takes 2 minutes to run)
--	In this example with the parameter '2', about 5 million rows are returned. 
--	This plan is apporpriate with the clustered index scan as expected

EXEC [dbo].[PropertySearchByAgent] 2;
GO

--	Note that there is a spill to tempdb with the sort operation as can be seen
--	with the warning, note that Memory Grant Feedback (MGF) would learn from
--	this and would remove the spill on a subsequent execution

--	Let's look at agents with fewer properties.
--	If we were to run the following statements in previous versions of SQL
--	or lower compatibility levels we would reuse the previous plan 
--	with the clustered index scan.

EXEC [dbo].[PropertySearchByAgent] 4;
GO 3
EXEC [dbo].[PropertySearchByAgent] 8;
GO 3

--	But with PSP optimization, this runs very quickly with a completely
--	different plan that uses a key lookup, nested loops, 
--	and with an index seek because there are far fewer rows

--	By looking at the showplan XML properties we can see on the SELECT that
--	the Agent ID uses the plan for parameter 4 for both 4 and 8 plan executions
--	If you open up the XML you can see the <Dispatcher> element showing the low
--	and high boundaries for the plan's cardinality, so this plan will be used
--	between 100 rows and 1 million.

--	We can also see what statistics, ScalarOperator, and column reference 
--	that was used to create this plan we can also see the queryvariantid 
--	that was used as this is a query variant

--	7. You can get additional insights by using sys.dm_exec_query_stats to see
--	some performance differences between these two plans.
--	For the different execution counts we can see the difference between 
--	elapsed time, row counts, dop, and the memory grants

--	In the previous behavior if the most expensive was the only one in the 
--	cache, and being used, every execution would require 600MB of memory 
--	and a higher dop

SELECT qs.query_plan_hash,
	qs.query_hash,
	qs.execution_count,  
	qs.max_elapsed_time,
	qs.max_rows,
	qs.last_dop,
	qs.last_grant_kb,
	qs.last_worker_time,
	qp.query_plan, qt.text
FROM sys.dm_exec_query_stats AS qs   
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS qt
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) AS qp
WHERE qt.text like '%SELECT PropertyId%'  
ORDER BY qs.execution_count DESC; 
GO

--	8. You can get additional insights by using sys.dm_exec_query_stats to see
--	some performance differences between these two plan.

--	For the different execution counts we can see the difference between elapsed
--	time, row counts, dop, and the memory grants

--	In the previous behavior if the most expensive was the only one in the
--	cache, and being used, every execution would require 600MB of memory 
--	and a higher dop

SELECT Pl.query_id , qvr.query_variant_query_id,Txt.query_sql_text, Pl.plan_id,Pl.query_id ,qvr.parent_query_id,qvr.dispatcher_plan_id,
--OBJECT_NAME(Qry.object_id) as ObjectName,
convert(xml,Pl.query_plan)as ShowPlanXML, Qry.query_parameterization_type_desc,
Qry.initial_compile_start_time, Qry.last_compile_start_time, Qry.last_execution_time,Qry.query_hash, Qry.count_compiles
FROM sys.query_store_plan AS Pl
left outer join sys.query_store_query_variant qvr on Pl.query_id = qvr.query_variant_query_id
JOIN sys.query_store_query AS Qry
ON Pl.query_id = Qry.query_id
JOIN sys.query_store_query_text AS Txt
ON Qry.query_text_id = Txt.query_text_id
where (Pl.query_id in (select parent_query_id from sys.query_store_query_variant ) or qvr.parent_query_id is not null)
order by query_hash, Pl.query_id;

--	9. Check XE for the parameter_sensitive_plan_optimization_skipped_reason 
--	You can use this event to monitor the reason why parameter sensitive plan 
--	optimization is skipped.

--	Example will be auto parameterized
SELECT * FROM Property
WHERE Bedrooms > 12
AND Bathrooms > 4
AND ListingPrice < 750000.00

--	Example uses a local variable
DECLARE @Bedrooms INT   
SET @Bedrooms = 15

SELECT * FROM Property
WHERE Bedrooms > @Bedrooms

-- Stop XE
ALTER EVENT SESSION [PSP_XE] ON SERVER
STATE = STOP;
GO

DROP EVENT SESSION [PSP_XE] ON SERVER
GO






