
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
USE [AdventureWorks];
GO
WITH LargeDataSet AS (
    SELECT 
        p.ProductID, p.Name, p.ProductNumber, p.Color, 
        s.SalesOrderID, s.OrderQty, s.UnitPrice, s.LineTotal, 
        c.CustomerID, c.AccountNumber,
        (SELECT AVG(UnitPrice) FROM Sales.SalesOrderDetail WHERE ProductID = p.ProductID) AS AvgUnitPrice,
        (SELECT COUNT(*) FROM Sales.SalesOrderDetail WHERE ProductID = p.ProductID) AS OrderCount,
        (SELECT SUM(LineTotal) FROM Sales.SalesOrderDetail WHERE ProductID = p.ProductID) AS TotalSales,
        (SELECT MAX(OrderDate) FROM Sales.SalesOrderHeader WHERE CustomerID = c.CustomerID) AS LastOrderDate,
        r.ReviewCount
    FROM 
        Production.Product p
    JOIN 
        Sales.SalesOrderDetail s ON p.ProductID = s.ProductID
    JOIN 
        Sales.SalesOrderHeader h ON s.SalesOrderID = h.SalesOrderID
    JOIN 
        Sales.Customer c ON h.CustomerID = c.CustomerID
    JOIN 
        (SELECT 
             ProductID, COUNT(*) AS ReviewCount 
         FROM 
             Production.ProductReview 
         GROUP BY 
             ProductID) r ON p.ProductID = r.ProductID
     CROSS JOIN 
       (SELECT TOP 1000 * FROM Sales.SalesOrderDetail) s2
)
SELECT 
    ld.ProductID, ld.Name, ld.ProductNumber, ld.Color, 
    ld.SalesOrderID, ld.OrderQty, ld.UnitPrice, ld.LineTotal, 
    ld.CustomerID, ld.AccountNumber, ld.AvgUnitPrice, ld.OrderCount, ld.TotalSales, ld.LastOrderDate, ld.ReviewCount
FROM 
    LargeDataSet ld
ORDER BY 
    ld.OrderQty DESC, ld.ReviewCount ASC;
GO