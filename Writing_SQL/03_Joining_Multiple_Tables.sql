USE AdventureWorks2019
GO

-- Turn on Actual Execution Plan (CTRL + M)

--Use Tables that are included with the AdventureWorks database
--Joining Muliple Tables
SELECT SOH.SalesOrderID, SOH.CustomerID,
	OrderQty, UnitPrice, P.Name
FROM Sales.SalesOrderHeader AS SOH
	JOIN Sales.SalesOrderDetail AS SOD
		ON SOH.SalesOrderID = SOD.SalesOrderID
	JOIN Production.Product AS P
		ON P.ProductID = SOD.ProductID

--Run 03_Create_Join_Demo_Tables.sql script 

--Review data in individual tables
SELECT CustomerID, First_Name, Last_Name, Club FROM Demo.Customers -- 5 Customers
SELECT OrderID, CustID, ProductID, Qty, OrderDate FROM Demo.Orders -- 9 Orders
SELECT ProductID, ProductName, Price FROM Demo.Products -- 8 Products


--SELECT using an Inner Join
SELECT CustomerID, Last_Name, Qty
FROM Demo.Customers AS C
INNER JOIN Demo.Orders AS O
ON C.CustomerID = O.CustID

--SELECT using a Left Outer Join
SELECT CustomerID, Last_Name, Qty
FROM Demo.Customers AS C
LEFT OUTER JOIN Demo.Orders AS O
ON C.CustomerID = O.CustID
--WHERE O.Qty IS NULL --To only records from Parent table.

--SELECT using a RIGHT Outer Join
SELECT CustomerID, Last_Name, Qty
FROM Demo.Customers AS C
RIGHT OUTER JOIN Demo.Orders AS O
ON C.CustomerID = O.CustID
--WHERE Last_Name IS NULL --To only see records from Child table.

--SELECT using a FULL Outer Join
SELECT CustomerID, Last_Name, Qty
FROM Demo.Customers AS C
FULL OUTER JOIN Demo.Orders AS O
ON C.CustomerID = O.CustID

--SELECT using a FULL Outer Join
SELECT Last_Name, ProductName
FROM Demo.Customers AS C
CROSS JOIN Demo.Products AS P


-- Clean up demonstration
DROP TABLE IF EXISTS Demo.Orders
DROP TABLE IF EXISTS Demo.Customers
DROP TABLE IF EXISTS Demo.Products
DROP SCHEMA IF EXISTS Demo
GO



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