--Run on SQL Server 2019 first, Then switch to SQL Server 2022
SELECT @@SERVERNAME AS SERVER, @@VERSION AS VERSION, DB_NAME() as DatabaseName

--Switch to the correct database
USE WideWorldImportersDW
GO

--Check Compatibility Level
SELECT Name, compatibility_level
FROM sys.databases
GO

--If you need to change Compatibility Level
ALTER DATABASE WideWorldImportersDW  
SET COMPATIBILITY_LEVEL = 150;  
GO

--Turn on Query Store
ALTER DATABASE WideWorldImportersDW 
SET QUERY_STORE = ON;
GO

--Create Procedure for demonstration
CREATE OR ALTER PROCEDURE jd_Get_Package
@Package varchar(30)
AS
SELECT TotalDryItems
FROM Fact.Sale
WHERE Package = @Package
ORDER BY TotalDryItems
GO

--HEY JOHN! Turn on Actual Execution Plan
--Hit F4 to view Properties!
--Repeat and alternate the following two Commands

--Requires small memory grant
EXEC jd_Get_Package 'nonexistent'

--Require large memory grant
EXEC jd_Get_Package 'each'


--Clean Up
ALTER DATABASE [WideWorldImportersDW ] SET QUERY_STORE CLEAR ALL
GO
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE  
GO
ALTER DATABASE WideWorldImportersDW 
SET QUERY_STORE = OFF;
GO
DROP PROCEDURE jd_Get_Package;
GO


