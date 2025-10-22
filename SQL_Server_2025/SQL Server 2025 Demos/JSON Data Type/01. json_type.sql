
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
 
 --Step 1 - create a new database to keep things simple
USE master;
GO
DROP DATABASE IF EXISTS orders;
GO
CREATE DATABASE orders;
GO
USE orders;
GO
DROP TABLE IF EXISTS dbo.Orders;
GO
CREATE TABLE dbo.Orders(
order_id int NOT NULL IDENTITY,
order_info json NOT NULL    -- NOTE: Native Data Type!
);
GO

--Step 2 - INSERT JSON documents directly into the JSON type
INSERT INTO dbo.Orders (order_info)
VALUES
(
'{
"OrderNumber": "S043659",
"Date": "2024-05-24T08:01:00",
"AccountNumber": "AW29825",
"Price": 59.99,
"Quantity": 1
}'
),
(
'{
"OrderNumber": "S043661",
"Date": "2024-05-20T12:20:00",
"AccountNumber": "AW7365",
"Price": 24.99,
"Quantity": 3
}'
);

--Step 3 -  Find a specific JSON value
-- Syntax JSON_VALUE ( expression , path )

SELECT o.order_id, JSON_VALUE(o.order_info, '$.AccountNumber') AS
account_number
FROM dbo.Orders o;
GO

--Step 4 -  Dump out all JSON values
SELECT o.order_info
FROM dbo.Orders o;
GO

--Step 5 - Produce an array of JSON values from all rows in the table
-- Syntax JSON_ARRAYAGG (value_expression [ order_by_clause ] [ json_null_clause ] )
--json_null_clause ::=  NULL ON NULL | ABSENT ON NULL
--order_by_clause ::= ORDER BY <column_list>

SELECT JSON_ARRAYAGG(o.order_info)
FROM dbo.Orders o;
GO

-- Step 6 
-- Product a set of key/value pairs
--Syntax - JSON_OBJECTAGG ( json_key_value [ json_null_clause ] )
--json_key_value ::= <json_name> : <value_expression>
--json_null_clause ::= NULL ON NULL | ABSENT ON NULL

SELECT JSON_OBJECTAGG(o.order_id:o.order_info)
FROM dbo.Orders o;
GO

--Step 7 
-- Modify a value inline
-- Syntax JSON_VALUE ( expression , path )

SELECT o.order_id, JSON_VALUE(o.order_info, '$.Quantity') AS Quantity
FROM dbo.Orders o;
GO
UPDATE dbo.Orders
   SET order_info.modify('$.Quantity', 2)
WHERE order_id = 1;
GO
SELECT o.order_id, JSON_VALUE(o.order_info, '$.Quantity') AS Quantity
FROM dbo.Orders o;
GO






















