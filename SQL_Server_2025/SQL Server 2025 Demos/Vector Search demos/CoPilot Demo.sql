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