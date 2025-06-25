USE AdventureWorks2019
GO

--Never do this in production!!!!
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;

-- Turn STATISTICS IO ON
SET STATISTICS IO ON
-- Turn on Actual Execution Plan (CTRL + M)

-- List the indexes
EXEC [sp_helpindex] 'Sales.SalesOrderHeader'

-- -- This statement will be a Clustered Index Scan as there is no WHERE clause
SELECT OrderDate FROM Sales.SalesOrderHeader

-- Create Index on OrderDate
CREATE NONCLUSTERED INDEX IX_OrderDate
ON Sales.SalesOrderHeader (OrderDate)

-- Let's start searching on datetime data and using a function.
-- SARGable
SELECT OrderDate FROM Sales.SalesOrderHeader
WHERE OrderDate Between '2014/01/01' AND '2014/12/31'
-- NON-SARGable
SELECT OrderDate FROM Sales.SalesOrderHeader
WHERE YEAR(OrderDate) = 2014

-- What about datetime conversion. Avoid converting dates to characters.
-- NON-SARGable
SELECT OrderDate FROM Sales.SalesOrderHeader
WHERE CONVERT(CHAR(10), OrderDate, 110) = '01-01-2014'
-- SARGable
SELECT OrderDate FROM Sales.SalesOrderHeader
WHERE CONVERT(date, OrderDate, 110) = '01-01-2014'
-- SARGable
SELECT OrderDate FROM Sales.SalesOrderHeader
WHERE CAST(OrderDate as date) = '01-01-2014'

-- Make direct comparisons to improve SARGability 
-- (Move converstion to right of operator)
-- SARGable
SELECT OrderDate FROM Sales.SalesOrderHeader
WHERE OrderDate < DATEADD(YEAR, -1, '01-01-2014')

-- NON-SARGable
SELECT OrderDate FROM Sales.SalesOrderHeader
WHERE DATEADD(YEAR, 1,OrderDate) < '01-01-2014'

-- Clean up demo by dropping the Index
DROP INDEX IX_OrderDate ON Sales.SalesOrderHeader
-- Turn STATISTICS IO OFF
SET STATISTICS IO OFF


/* This Sample Code is provided for the purpose of illustration only and is not intended 
to be used in a production environment.  THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE 
PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT
NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR 
PURPOSE.  We grant You a nonexclusive, royalty-free right to use and modify the Sample Code
and to reproduce and distribute the object code form of the Sample Code, provided that You 
agree: (i) to not use Our name, logo, or trademarks to market Your software product in which
the Sample Code is embedded; (ii) to include a valid copyright notice on Your software product
in which the Sample Code is embedded; and (iii) to indemnify, hold harmless, and defend Us and
Our suppliers from and against any claims or lawsuits, including attorneys’ fees, that arise or 
result from the use or distribution of the Sample Code.
*/