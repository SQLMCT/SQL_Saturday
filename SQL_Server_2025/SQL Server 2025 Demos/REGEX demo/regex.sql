
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
 
USE master;
GO

DROP DATABASE IF EXISTS hr;
GO

CREATE DATABASE hr;
GO

USE hr;
GO
-- be sure we are at 2025 compat_level
ALTER DATABASE hr SET COMPATIBILITY_LEVEL = 170;

-- Create an employees table with checks for valid email addresses
-- For Phone Numbers you must enforce this format type of format 
-- which cannot be done with LIKE such as (123) 456-7890
DROP TABLE IF EXISTS EMPLOYEES;
GO
CREATE TABLE EMPLOYEES (  
    ID INT IDENTITY(101,1),  
    [Name] VARCHAR(150),  
    Email VARCHAR(320)  
    CHECK (REGEXP_LIKE(Email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')),  
    Phone_Number NVARCHAR(20)  
    CHECK (REGEXP_LIKE(Phone_Number, '^\(\d{3}\) \d{3}-\d{4}$'))  
);
GO

-- Valid INSERT
INSERT INTO EMPLOYEES ([Name], Email, Phone_Number)
VALUES ('Dak Prescott', 'dak.prescott@example.com', '(123) 456-7890');
GO

-- Invalid INSERT
INSERT INTO EMPLOYEES ([Name], Email, Phone_Number)
VALUES ('Jerry Jones', 'jerry.jones@example.com', '123-456-7890');
GO


INSERT INTO EMPLOYEES ([Name], Email, Phone_Number)
VALUES ('LeBron James', 'lebron.james@basketball.com', '(234) 567-8901');
INSERT INTO EMPLOYEES ([Name], Email, Phone_Number)
VALUES ('Serena Williams', 'serena.williams@tennis.org', '(345) 678-9012');
INSERT INTO EMPLOYEES ([Name], Email, Phone_Number)
VALUES ('Lionel Messi', 'lionel.messi@soccer.net', '(456) 789-0123');
INSERT INTO EMPLOYEES ([Name], Email, Phone_Number)
VALUES ('Tom Brady', 'tom.brady@football.co', '(567) 890-1234');
INSERT INTO EMPLOYEES ([Name], Email, Phone_Number)
VALUES ('Roger Federer', 'roger.federer@tennis.com', '(678) 901-2345');
INSERT INTO EMPLOYEES ([Name], Email, Phone_Number)
VALUES ('Simone Biles', 'simone.biles@gymnastics.org', '(789) 012-3456');
INSERT INTO EMPLOYEES ([Name], Email, Phone_Number)
VALUES ('Cristiano Ronaldo', 'cristiano.ronaldo@soccer.co', '(890) 123-4567');
INSERT INTO EMPLOYEES ([Name], Email, Phone_Number)
VALUES ('Michael Phelps', 'michael.phelps@swimming.net', '(901) 234-5678');
INSERT INTO EMPLOYEES ([Name], Email, Phone_Number)
VALUES ('Usain Bolt', 'usain.bolt@track.com', '(012) 345-6789');
GO

-- Do a complex search. Find any email where the word "will" appears after the "." in an eamil address and ends in .org
/* ^[^@]+: Matches one or more characters that are not the "@" symbol at the start of the string.
\.: Matches the literal dot character ".".
[^.]*will: Matches zero or more characters that are not the dot character, followed by "will". This ensures "will" appears somewhere after the first dot.
.*: Matches any character (except for line terminators) zero or more times. It allows for any characters to appear after "will".
\.: Matches the literal dot character ".".
org: Matches the exact sequence "org".
$: Asserts the position at the end of the string. */

SELECT * FROM EMPLOYEES
WHERE REGEXP_LIKE(Email, '^[^@]+\.[^.]*will.*\.org$');
GO


-- Think Dynamic Data masking on the fly!
SELECT Name, REGEXP_REPLACE( Phone_Number, '\d{4}$', '****') FROM EMPLOYEES;

-- extract sub-string
SELECT REGEXP_SUBSTR(Email, '@(.+)$', 1, 1, 'i', 1) AS Domain FROM EMPLOYEES

--
SELECT value FROM REGEXP_SPLIT_TO_TABLE('A,B,C', ',');
-- Need more data than hr has :)
use AdventureWorks;
go
-- Count occurances
SELECT ProductNumber, REGEXP_COUNT(ProductNumber, '\d') FROM Production.Product;;

USE wideworldimportersdw;
GO
-- like
SELECT [Primary Contact]
FROM Dimension.Customer 
WHERE REGEXP_LIKE(Customer.[Primary Contact], '^A.*A$'); 


-- Find all citiess with a double s letter
SELECT [City Key],
       City,
       [State Province],
       REGEXP_COUNT(City.City, '[sS]{2,}', 6) AS SequenceCount
FROM   Dimension.City
WHERE  REGEXP_COUNT(City.City, '[sS]{2,}', 6) > 0
ORDER BY REGEXP_COUNT(City.City, '[sS]{2,}', 6) DESC; 

-- find cities that have new then a space character
SELECT City.City,
       City.[State Province],
       REGEXP_INSTR(City.City, 'New') AS StringLocation
FROM   Dimension.City
WHERE  REGEXP_INSTR(City.City, 'New') > 0;

-- what cities that have a double s past the first 6 characters
SELECT   [City Key],
         City,
         [State Province],
         REGEXP_COUNT(City.City, '[sS]{2,}', 6) AS SequenceCount
FROM     Dimension.City
WHERE    REGEXP_COUNT(City.City, '[sS]{2,}', 6) > 0
ORDER BY REGEXP_COUNT(City.City, '[sS]{2,}', 6) DESC;

-- same as above but start looking from character position 2
SELECT City.City,
       City.[State Province],
       REGEXP_INSTR(City.City, 'New', 2) AS StringLocation
FROM   Dimension.City
WHERE  REGEXP_INSTR(City.City, 'New', 2) > 0;

-- how about multiple occurances
SELECT City.City,
       City.[State Province],
       REGEXP_INSTR(City.City, 'New', 1, 2) AS StringLocation
FROM   Dimension.City
WHERE  REGEXP_INSTR(City.City, 'New', 1, 2) > 0;

-- matching
SELECT   [City Key],
         City,
         [State Province],
         RegexMatchData.*
FROM     Dimension.City CROSS APPLY REGEXP_MATCHES (City.City, '[sS]{2,}') AS RegexMatchData
WHERE    REGEXP_COUNT(City.City, '[sS]{2,}') > 1
ORDER BY City.City ASC;

-- split to table
SELECT   [City Key],
         City,
         [State Province],
         RegexSplitData.*
FROM     Dimension.City CROSS APPLY REGEXP_SPLIT_TO_TABLE (City.City, '[sS]{2,}') AS RegexSplitData
WHERE    REGEXP_COUNT(City.City, '[sS]{2,}') > 1
ORDER BY City.City ASC;

