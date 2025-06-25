USE AdventureWorks2019
GO

--Never do this in production!!!!
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;

-- Turn STATISTICS IO ON
SET STATISTICS IO ON
-- Turn on Actual Execution Plan (CTRL + M)

-- Create Common Table Expression (CTE)
-- This object will be stored in memory
WITH Total_Sales_Orders AS 
(SELECT SOH.SalesOrderID, SOH.CustomerID,
	OrderQty, UnitPrice, P.Name
FROM Sales.SalesOrderHeader AS SOH
	JOIN Sales.SalesOrderDetail AS SOD 
		ON SOH.SalesOrderID = SOD.SalesOrderID
	JOIN Production.Product AS P
		ON P.ProductID = SOD.ProductID)

-- Select Data from Common Table Expresssion (CTE)
SELECT SalesOrderID, SUM(OrderQTY) as TotalQTY, SUM(UnitPrice) as OrderTotal
FROM Total_Sales_Orders AS TSO
GROUP BY TSO.SalesOrderID
ORDER BY TotalQTY DESC

-- Add a WHERE statement to seek out records.
-- Unable to reuse CTE as memory is released once query completes.
-- Comment out previous query and try again.
--SELECT SalesOrderID, SUM(OrderQTY) as TotalQTY, SUM(UnitPrice) as OrderTotal
--FROM Total_Sales_Orders AS TSO
--WHERE SalesOrderID = 43659
--GROUP BY TSO.SalesOrderID
--ORDER BY TotalQTY DESC

-- Create Temp Table 
-- This will create an object in the tempdb and is stored to disk.
CREATE TABLE #Total_Sales_Orders 
(SalesOrderID int, CustomerID int, OrderQty smallint, UnitPrice money, Name nvarchar(50));
	INSERT INTO #Total_Sales_Orders
	SELECT SOH.SalesOrderID, SOH.CustomerID,
		OrderQty, UnitPrice, P.Name
	FROM Sales.SalesOrderHeader AS SOH
		JOIN Sales.SalesOrderDetail AS SOD 
			ON SOH.SalesOrderID = SOD.SalesOrderID
		JOIN Production.Product AS P
			ON P.ProductID = SOD.ProductID

--Select Data from the Temp Table
SELECT SalesOrderID, SUM(OrderQTY) as TotalQTY, SUM(UnitPrice) as OrderTotal
FROM #Total_Sales_Orders AS TSO
WHERE SalesOrderID = 43659
GROUP BY TSO.SalesOrderID
ORDER BY TotalQTY DESC

-- The Temp Table persists for the entire session
SELECT CustomerID, SUM(OrderQTY) as TotalQTY, SUM(UnitPrice) as OrderTotal
FROM #Total_Sales_Orders  AS TSO
GROUP BY TSO.CustomerID
ORDER BY TotalQTY DESC

-- Create an Index on a Temp Table
CREATE NONCLUSTERED INDEX [IX_SalesOrderID]
	ON #Total_Sales_Orders(SalesOrderID)
GO

--Can improve performance by seeking index
SELECT SalesOrderID, SUM(OrderQTY) as TotalQTY, SUM(UnitPrice) as OrderTotal
FROM #Total_Sales_Orders AS TSO
--WHERE SalesOrderID = 43659
GROUP BY TSO.SalesOrderID
ORDER BY TotalQTY DESC

-- Make sure to delete Temp Table
DROP TABLE #Total_Sales_Orders 