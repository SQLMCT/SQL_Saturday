USE AdventureWorks2019
GO

-- List the indexes
EXEC [sp_helpindex] 'Person.Address';

-- Turn STATISTICS IO ON
SET STATISTICS IO ON
-- Turn on Actual Execution Plan (CTRL + M)

--Show [IX_Address_AddressLine1_AddressLine2_City_StateProvinceID_PostalCode]
--SELECT * will need to find all columns
--.0073426
SELECT *
FROM Person.Address
WHERE AddressLine1 = '1970 Napa Ct.'
GO

--Show [IX_Address_AddressLine1_AddressLine2_City_StateProvinceID_PostalCode]
--Performs Index Seek
--.0032837
SELECT AddressLine1, City, StateProvinceID, PostalCode
FROM Person.Address
WHERE AddressLine1 = '1970 Napa Ct.'
GO

--Show for Column Order[IX_Address_AddressLine1_AddressLine2_City_StateProvinceID_PostalCode]
--WHERE PostalCode is not first in Index
--Performs Index Scan
--.180413
SELECT City, StateProvinceID, PostalCode
FROM Person.Address
WHERE PostalCode = '98011'
GO

--Create New Index in sargable order
CREATE NONCLUSTERED INDEX [IX_Postal_State_City]
	ON Person.Address(PostalCode, StateProvinceID, City)
GO

--Use new index and performs Index Seek.
--.0032955
SELECT City, StateProvinceID, PostalCode
FROM Person.Address
WHERE PostalCode = '98011'
GO

--Use new index and performs Index Seek.
--Search condition in same order as Index.
--.0032955
SELECT City, StateProvinceID, PostalCode
FROM Person.Address
WHERE PostalCode = '98011' AND StateProvinceID = 79
GO

--Use new index and performs Index Seek.
--Search condition in same order as Index.
--.0032955
SELECT City, StateProvinceID, PostalCode
FROM Person.Address
WHERE StateProvinceID = 79 AND PostalCode = '98011' 
GO

--Use new index and performs Index Scan.
--Search condition not in same order as Index.
--.110043
SELECT  City, StateProvinceID, PostalCode
FROM Person.Address
WHERE StateProvinceID = 79
GO

--Use new index and performs Index Scan.
--Search condition not in same order as Index.
--.110043
SELECT  City, StateProvinceID, PostalCode
FROM Person.Address
WHERE City = 'Bothell'
GO

-- Clean up demo by dropping the Index
DROP INDEX [IX_Postal_State_City] ON Person.Address

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