USE master;

--Build Database for Demo
DROP DATABASE IF EXISTS LockingDemo;
CREATE DATABASE LockingDemo ON
(NAME = LockingDemo,
 FILENAME = 'D:\DATA\LockingDemo.mdf',
	SIZE = 10,
    MAXSIZE = 50,
    FILEGROWTH = 5)
LOG ON
(NAME = Test_DB_Log,
 FILENAME = 'D:\DATA\LockingDemo.ldf',
	SIZE = 5MB,
    MAXSIZE = 25MB,
    FILEGROWTH = 5MB);
GO

USE LockingDemo;

-- Let's insert 1 record into the table and check the locks being generated
BEGIN TRANSACTION
INSERT INTO LockingTest VALUES (1, 'FirstRecord',getdate())

--John don't run the COMMIT yet!
SELECT resource_type, resource_description, resource_lock_partition,
	request_mode, request_type, request_status
FROM sys.dm_tran_locks
WHERE request_session_id = @@SPID

-- We should see 4 locks in this case 
-- 1 RID Lock (X), 2 IX locks (Object and Page) and 1 S lock on the DB
SELECT * FROM dbo.LockingTest

--John make sure to COMMIT
COMMIT

-- Rerun the sys.dm_tran_locks query 
SELECT resource_type, resource_description, resource_lock_partition,
	request_mode, request_type, request_status
FROM sys.dm_tran_locks
WHERE request_session_id = @@SPID

-- Now we should see only one lock

--- Let's insert a few more records in the table.
SET NOCOUNT ON
--DECLARE @count int = 2
DECLARE @count int
SET @count = 2
WHILE @count <=350
	BEGIN
		INSERT INTO LockingTest 
		VALUES(@count, 'Record '+ cast(@count as char(4)),getdate())
		SET @count += 1
	END

-- Let's see the locks held when doing a Select operation
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ -- This is needed or else the locks would be release immediately after the operation
BEGIN TRAN
SELECT * FROM LockingTest
-- 350 Records Returned

--- How many Locks would be seen?
SELECT resource_type, resource_description, resource_lock_partition,
	request_mode, request_type, request_status
FROM sys.dm_tran_locks
WHERE request_session_id = @@SPID --356 Records
ORDER BY resource_type
-- Why 356??
-- 350 for the RID (Shared Locks)
-- 1 Shared at DB Level 
-- 1 IS at Object Level
-- 4 IS at Page Level (the average record size for the table is 33 Bytes) 
-- and there are 4 partitions 

SELECT * FROM sys.partitions 
WHERE object_id = object_id('LockingTest')

--- Each partitition will have one page in this example -- hence 4 pages.
COMMIT
GO
-
/*
This Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment.  
THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.  
We grant You a nonexclusive, royalty-free right to use and modify the 
Sample Code and to reproduce and distribute the object code form of the Sample Code, provided that You agree: (i) to not use Our name, logo, or trademarks to market Your software product in which the Sample Code is embedded; 
(ii) to include a valid copyright notice on Your software product in which the Sample Code is 
embedded; and 
(iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against any claims or lawsuits, including attorneys’ fees, that arise or result from the use or distribution of the Sample Code.
Please note: None of the conditions outlined in the disclaimer above will supercede the terms and conditions contained within the Premier Customer Services Description.
*/