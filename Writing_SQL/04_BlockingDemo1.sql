USE AdventureWorks2019
GO

--Session 73
--Blocking Demo - Session 1
--Jack updates the Person.Person table

--Explicit Transaction
BEGIN TRAN
UPDATE Person.Person
SET FirstName = 'Jack', LastName = 'Frost'
WHERE BusinessEntityID = 18
--ROLLBACK
--COMMIT


--Look at the locks
SELECT resource_type, resource_description, resource_lock_partition,
	request_mode, request_type, request_status
FROM sys.dm_tran_locks
WHERE request_session_id = @@SPID 
ORDER BY resource_type


DBCC OPENTRAN()










