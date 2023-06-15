SELECT @@VERSION
GO

--Demonstration Setup
USE WideWorldImporters;
GO

ALTER DATABASE WideWorldImporters
SET QUERY_STORE = ON ( 
	OPERATION_MODE = READ_WRITE,
	DATA_FLUSH_INTERVAL_SECONDS = 300,
	MAX_STORAGE_SIZE_MB = 100,		
	INTERVAL_LENGTH_MINUTES = 5,		
	QUERY_CAPTURE_MODE = ALL,
	MAX_PLANS_PER_QUERY = 20 
	);
GO	

SELECT * FROM sys.database_scoped_configurations

--	We are able to toggle PSP with the ALTER DATABASE SCOPED CONFIGURATION; 
--	PSP Optimization is on by default.
USE WideWorldImporters;
GO
ALTER DATABASE SCOPED CONFIGURATION SET 
	OPTIMIZED_PLAN_FORCING = ON
GO

--Clear the Procedure Cache and Flush Query Store
USE WideWorldImporters;
GO
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO
EXEC sys.sp_query_store_flush_db;
GO
SET STATISTICS TIME OFF;
GO

--Execute the code for large multiple join statement.
--This will take 20 seconds to complete.
SET STATISTICS TIME ON;
GO
SELECT o.OrderID, ol.OrderLineID, c.CustomerName, cc.CustomerCategoryName, p.FullName, city.CityName, sp.StateProvinceName, country.CountryName, si.StockItemName
FROM Sales.Orders o
JOIN Sales.Customers c
ON o.CustomerID = c.CustomerID
JOIN Sales.CustomerCategories cc
ON c.CustomerCategoryID = cc.CustomerCategoryID
JOIN Application.People p
ON o.ContactPersonID = p.PersonID
JOIN Application.Cities city
ON city.CityID = c.DeliveryCityID
JOIN Application.StateProvinces sp
ON city.StateProvinceID = sp.StateProvinceID
JOIN Application.Countries country
ON sp.CountryID = country.CountryID
JOIN Sales.OrderLines ol
ON ol.OrderID = o.OrderID
JOIN Warehouse.StockItems si
ON ol.StockItemID = si.StockItemID
JOIN Warehouse.StockItemStockGroups sisg
ON si.StockItemID = sisg.StockItemID
UNION ALL
SELECT o.OrderID, ol.OrderLineID, c.CustomerName, cc.CustomerCategoryName, p.FullName, city.CityName, sp.StateProvinceName, country.CountryName, si.StockItemName
FROM Sales.Orders o
JOIN Sales.Customers c
ON o.CustomerID = c.CustomerID
JOIN Sales.CustomerCategories cc
ON c.CustomerCategoryID = cc.CustomerCategoryID
JOIN Application.People p
ON o.ContactPersonID = p.PersonID
JOIN Application.Cities city
ON city.CityID = c.DeliveryCityID
JOIN Application.StateProvinces sp
ON city.StateProvinceID = sp.StateProvinceID
JOIN Application.Countries country
ON sp.CountryID = country.CountryID
JOIN Sales.OrderLines ol
ON ol.OrderID = o.OrderID
JOIN Warehouse.StockItems si
ON ol.StockItemID = si.StockItemID
JOIN Warehouse.StockItemStockGroups sisg
ON si.StockItemID = sisg.StockItemID
ORDER BY OrderID;
GO
SET STATISTICS TIME OFF;
GO

/* Paste Statistic information here
SQL Server parse and compile time: 
   CPU time = 94 ms, elapsed time = 103 ms.

(916540 rows affected)

 SQL Server Execution Times:
   CPU time = 2437 ms,  elapsed time = 37695 ms.
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 0 ms.

Completion time: 2022-08-02T10:16:31.0022701-04:00
*/

SELECT qsp.query_id, qsp.plan_id, 
	qsp.avg_compile_duration/1000 as avg_compile_ms, 
	qsp.last_compile_duration/1000 as last_compile_ms,
	qsp.has_compile_replay_script, 
	qst.query_sql_text,
cast(query_plan as xml) query_plan_xml
FROM sys.query_store_plan AS qsp
JOIN sys.query_store_query as qsq
ON	qsp.query_id = qsq.query_id
JOIN sys.query_store_query_text as qst
ON	qsq.query_text_id = qst.query_text_id
WHERE query_sql_text LIKE '%Sales.Customers%'
GO

--Force Query Plan
EXEC sp_query_store_force_plan @query_id = 42011, @plan_id = 710;
GO

--Clear the Procedure Cache and Flush Query Store
USE WideWorldImporters;
GO
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO
EXEC sys.sp_query_store_flush_db;
GO
SET STATISTICS TIME OFF;
GO

--Rerun SQL Query with a lot of Joins

--Unforce Query Plan
EXEC sp_query_store_unforce_plan @query_id = 42011, @plan_id = 710;
GO
--Clear Plan from cache
EXEC sp_query_store_remove_plan @plan_id = 710
GO

