--Set containment at the server level
EXEC sys.sp_configure N'contained database authentication', N'1'
GO
RECONFIGURE WITH OVERRIDE
GO

--Create MyContainedDatabase
CREATE DATABASE [MyContainedDatabase]
 CONTAINMENT = PARTIAL
 ON  PRIMARY 
( NAME = N'MyContainedDatabase', FILENAME = N'D:\Databases\MyContainedDatabase.mdf' , 
	SIZE = 8192KB , FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'MyContainedDatabase_log', FILENAME = N'D:\Databases\MyContainedDatabase_log.ldf' , 
	SIZE = 8192KB , FILEGROWTH = 65536KB )

--Set containment at the database level
ALTER DATABASE [MyContainedDatabase]
SET CONTAINMENT = PARTIAL
GO

--Create contained users
USE [MyContainedDatabase]
GO
CREATE USER [John] WITH PASSWORD = N'P@$$w0rd!'
	DEFAULT_SCHEMA = [dbo]
GO

--Identify uncontained objects
SELECT * FROM sys.dm_db_uncontained_entities

--Identify users accounts that are NOT contained
USE [MyContainedDatabase]
GO
 
SELECT sdp.name   
FROM sys.database_principals AS sdp  
	JOIN sys.server_principals AS ssp   
    ON sdp.sid = ssp.sid  
WHERE sdp.authentication_type = 1
AND ssp.is_disabled = 0 AND sdp.name <> 'dbo'
GO


--Migrate users to contained users
USE [MyContainedDatabase]
GO
EXEC sp_migrate_user_to_contained
    @username = N'dbuser1',
    @rename = N'keep_name',
    @disablelogin = N'do_not_disable_login';
GO