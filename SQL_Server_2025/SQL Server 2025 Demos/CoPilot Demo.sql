-- Need:
-- I need to retrieve the total sales per sales person by quarter. How can I do this?
-- Created by Copilot in SSMS - review carefully before executing
SELECT 
    sp.BusinessEntityID AS SalesPersonID,
    DATEPART(QUARTER, soh.OrderDate) AS Quarter,
    SUM(soh.TotalDue) AS TotalSales
FROM 
    Sales.SalesOrderHeader AS soh
JOIN 
    Sales.SalesPerson AS sp ON soh.SalesPersonID = sp.BusinessEntityID
GROUP BY 
    sp.BusinessEntityID, DATEPART(QUARTER, soh.OrderDate)
ORDER BY 
    sp.BusinessEntityID, Quarter;

-- I also need the yearly total for the above query (include as part of the prompt
-- Created by Copilot in SSMS - review carefully before executing
SELECT 
    sp.BusinessEntityID AS SalesPersonID,
    YEAR(soh.OrderDate) AS Year,
    SUM(soh.TotalDue) AS TotalSales
FROM 
    Sales.SalesOrderHeader AS soh
JOIN 
    Sales.SalesPerson AS sp ON soh.SalesPersonID = sp.BusinessEntityID
GROUP BY 
    sp.BusinessEntityID, YEAR(soh.OrderDate)
ORDER BY 
    sp.BusinessEntityID, Year;