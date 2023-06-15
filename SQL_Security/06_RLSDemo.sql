--Prepare for the Demo
USE MASTER
GO
DROP DATABASE IF EXISTS RLS_DEMO
GO
CREATE DATABASE RLS_DEMO
GO
USE RLS_DEMO
GO

--CREATE Self-contained Database Users without Logins
CREATE USER Jack WITHOUT LOGIN
CREATE USER Diane WITHOUT LOGIN
CREATE USER Manager WITHOUT LOGIN
GO

--Create Customer Table
CREATE TABLE dbo.Customer
(CustID tinyint IDENTITY,
 CustomerName varchar(30),
 CustomerEmail varchar(30),
 SalesPersonName varchar(5))
GO

--Grant SELECT permissions
GRANT SELECT, UPDATE ON dbo.Customer 
	to Jack, Diane, Manager
GO

--INSERT Data into Customer Table
INSERT INTO dbo.CUSTOMER VALUES
('Stephen Jiang', 'Stephen.Jiang@adworks.com', 'Jack'),
('Michael Blythe', 'Michael@contoso.com', 'Jack'),
('Linda Mitchell', 'Linda@VolcanoCoffee.org', 'Jack'),
('Jilian Carson', 'JilianC@Northwind.net', 'Jack'),
('Garret Vargas', 'Garret@WorldWideImporters.com', 'Diane'),
('Shu Ito', 'Shu@BlueYonder.com', 'Diane'),
('Sahana Reiter', 'Sahana@CohoVines.com', 'Diane'),
('Syed Abbas','Syed@AlpineSki.com', 'Diane')
GO


--Select records Before implementing Row-Level Security
--Execute as Manager, Jack, and Diane
--They should be able to read all the records
EXECUTE AS USER = 'Manager'
SELECT CustomerName, CustomerEmail, SalesPersonName
FROM dbo.Customer
REVERT
GO

--Use a Function to Create the Row-Level Filter
CREATE FUNCTION fn_RowLevelSecurity
(@FilterName sysname)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN SELECT 1 as fn_SecureCustomerData
WHERE @FilterName = user_name() or USER_NAME() = 'Manager'
GO

--Apply the Row-Level Filter with a Security Policy
CREATE SECURITY POLICY FilterCustomer
ADD FILTER PREDICATE dbo.fn_RowLevelSecurity(SalesPersonName)
ON dbo.Customer
WITH (State = ON)
GO

--Test Row-Level Security again
--Execute as Manager, Jack, and Diane
--Jack and Diane should only see their customers.
--Manager can still see all records.
EXECUTE AS USER = 'Jack'
SELECT CustID, CustomerEmail, SalesPersonName
FROM dbo.Customer
REVERT
GO

--Test Row-Level Security for Updates
--Execute as Manager, Jack, and Diane
EXECUTE AS USER = 'Diane'
UPDATE dbo.CUSTOMER
SET SalesPersonName = 'Jack'
WHERE CustID = 8
REVERT
GO



