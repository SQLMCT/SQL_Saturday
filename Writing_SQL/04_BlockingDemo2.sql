USE AdventureWorks2019
GO

--Session 126
--Blocking Demo - Session 2
--Diane selects from Person.Person table

--Auto Commit Transaction
SELECT * FROM Person.Person --(NOLOCK)
WHERE BusinessEntityID = 18

EXEC sp_who2 73
EXEC sp_who2 74

--KILL 73

--Look at the locks
SELECT resource_type, resource_description, resource_lock_partition,
	request_mode, request_type, request_status
FROM sys.dm_tran_locks
WHERE request_session_id = @@SPID 
ORDER BY resource_type

-- Let's see the locks held when doing a Select operation
--SET TRANSACTION ISOLATION LEVEL REPEATABLE READ -- This is needed or else the locks would be release immediately after the operation
--BEGIN TRAN

SELECT * FROM Person.Person --(NOLOCK)
WHERE BusinessEntityID = 18

--COMMIT TRAN