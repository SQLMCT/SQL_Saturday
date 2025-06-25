USE AdventureWorks2019
GO

--Never do this in production!!!!
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;

-- Turn STATISTICS IO ON
SET STATISTICS IO ON
-- Turn on Actual Execution Plan (CTRL + M)

-- Compare with using a Leading Wildcard
-- SARGable
SELECT LastName FROM Person.Person
WHERE LastName LIKE 'Adams%'
-- NON-SARGable
SELECT LastName FROM Person.Person
WHERE LastName LIKE '%Adams%'

--Let's start searching for character data and using a function.
-- SARGable
SELECT LastName FROM Person.Person
WHERE LastName = 'Adams'
-- NON-SARGable
SELECT LastName FROM Person.Person
WHERE UPPER(LastName) = 'Adams'

-- Let's take a look at a different table and discuss Seeks vs Scans
-- This statement will scan as there is no WHERE clause
SELECT * FROM Sales.SalesOrderDetail;

-- List the indexes
EXEC [sp_helpindex] 'Sales.SalesOrderDetail';

--Create a searchable index
CREATE NONCLUSTERED INDEX IX_LineTotal_Qty 
ON Sales.SalesOrderDetail (LineTotal,OrderQty)

--Let's start searching for number based data and using a function.
--Check the cardinality estimation for Seek plan and Scan plan
-- SARGable
SELECT LineTotal FROM Sales.SalesOrderDetail
WHERE LineTotal > 23000
-- NON-SARGable because of the function
SELECT LineTotal FROM Sales.SalesOrderDetail
WHERE ABS(LineTotal) > 23000

--Now let's sort the records and observe
--Check the warning on the SELECT operator in the scan plan (Excessive Memory Grant)
--Check the cardinality estimation for Seek plan and Scan plan
-- SARGable
SELECT linetotal FROM Sales.SalesOrderDetail
WHERE LineTotal > 23000
ORDER BY OrderQty DESC
-- NON-SARGable
SELECT LineTotal FROM Sales.SalesOrderDetail
WHERE ABS(LineTotal) > 23000
ORDER BY OrderQty DESC

-- Are Seeks ALWAYS better than Scans? Depends on selectivity
-- The above query was greater than 23000, this query is greater than 2.3.
SELECT linetotal FROM Sales.SalesOrderDetail
WHERE LineTotal > 2.3
-- NON-SARGable because of the function
SELECT linetotal FROM Sales.SalesOrderDetail
WHERE ABS(LineTotal) > 2.3

-- Clean up demo by dropping the Index
DROP INDEX IX_LineTotal_Qty ON Sales.SalesOrderDetail
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