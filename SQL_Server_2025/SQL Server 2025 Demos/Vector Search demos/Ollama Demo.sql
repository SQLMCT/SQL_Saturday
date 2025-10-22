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

-- step 0 Setup Ollama / Docker/ Linux / NgINX
-- Enable Windows Subsytem for Linux (if on your local machine)
-- install Docker
-- Then user docker compose script to create the resources.
-- see ollama-sql-faststart-main.zip for the details
-- There is a detailed readme.md file in the zip which walks through the entire process.

-- once installed and tested
-- start WSL
-- start docker container. This will spin up a localhosr on port 1433 so make sure you adjust the port for onther instnaces on your machine
-- or you will get conflicts.

-- Finally
-- Step 1: Restore the AdventureWorks2025 database from a backup file -------------------
--USE [master]; 
--GO
--RESTORE DATABASE [AdventureWorks2025]
--FROM DISK = '/mssql/backup/AdventureWorks2025_FULL.bak'
--WITH
--    MOVE 'AdventureWorksLT2022_Data' TO '/mssql/data/AdventureWorks2025_Data.mdf',
--    MOVE 'AdventureWorksLT2022_Log' TO '/mssql/data/AdventureWorks2025_log.ldf',
--    FILE = 1,
--    NOUNLOAD,
--    STATS = 5;
--GO

----------------------------------------------------------------------------------------

-- Step 2: Create and test an External Model pointing to our local Ollama Container ----
USE [AdventureWorks2025]
GO
sp_configure 'external rest endpoint enabled', 1
GO

DROP EXTERNAL MODEL ollama; 

CREATE EXTERNAL MODEL ollama
WITH (
    LOCATION = 'https://model-web:443/api/embed',
    API_FORMAT = 'Ollama',
    MODEL_TYPE = EMBEDDINGS,
    MODEL = 'nomic-embed-text'
);
GO

PRINT 'Testing the external model by calling AI_GENERATE_EMBEDDINGS function...';
GO
BEGIN
    DECLARE @result NVARCHAR(MAX);
    SET @result = (SELECT CONVERT(NVARCHAR(MAX), AI_GENERATE_EMBEDDINGS(N'test text' USE MODEL ollama)))
    SELECT AI_GENERATE_EMBEDDINGS(N'test text' USE MODEL ollama) AS GeneratedEmbedding

    IF @result IS NOT NULL
        PRINT 'Model test successful. Result: ' + @result;
    ELSE
        PRINT 'Model test failed. No result returned.';
END;
GO
----------------------------------------------------------------------------------------


-- Step 3: Altering a Table to Add Vector Embeddings Column ----------------------------
USE [AdventureWorks2025];
GO
-- 
DROP INDEX vec_idx ON [SalesLT].[Product];
-- for replay
ALTER TABLE [SalesLT].[Product]
DROP COLUMN embeddings, chunk;
GO
ALTER TABLE [SalesLT].[Product]
ADD embeddings VECTOR(768), 
    chunk NVARCHAR(2000);
GO
----------------------------------------------------------------------------------------


-- Step 4: CREATE THE EMBEDDINGS (This demo is based off the MS SQL 2025 demo repository)
UPDATE p
SET 
 [chunk] = p.Name + ' ' + ISNULL(p.Color, 'No Color') + ' ' + c.Name + ' ' + m.Name + ' ' + ISNULL(d.Description, ''),
 [embeddings] = AI_GENERATE_EMBEDDINGS(p.Name + ' ' + ISNULL(p.Color, 'No Color') + ' ' + c.Name + ' ' + m.Name + ' ' + ISNULL(d.Description, '') USE MODEL ollama)
FROM [SalesLT].[Product] p
JOIN [SalesLT].[ProductCategory] c ON p.ProductCategoryID = c.ProductCategoryID
JOIN [SalesLT].[ProductModel] m ON p.ProductModelID = m.ProductModelID
LEFT JOIN [SalesLT].[vProductAndDescription] d ON p.ProductID = d.ProductID AND d.Culture = 'en'
WHERE p.embeddings IS NULL;

-- Review the created embeddings
SELECT TOP 10 chunk, embeddings, * 
FROM [SalesLT].[Product] p
----------------------------------------------------------------------------------------


-- Step 5: Perform Vector Search -------------------------------------------------------
DECLARE @search_text NVARCHAR(MAX) = 'I am looking for a red bike and I dont want to spend a lot';
DECLARE @search_vector VECTOR(768) = AI_GENERATE_EMBEDDINGS(@search_text USE MODEL ollama);

SELECT TOP(4)
    p.ProductID,
    p.Name,
    p.chunk,
    vector_distance('cosine', @search_vector, p.embeddings) AS distance
FROM [SalesLT].[Product] p
ORDER BY distance;
GO

----------------------------------------------------------------------------------------

DECLARE @search_text NVARCHAR(MAX) = 'I am looking for a safe helmet that does not weigh much';
DECLARE @search_vector VECTOR(768) = AI_GENERATE_EMBEDDINGS(@search_text USE MODEL ollama);

SELECT TOP(4)
    p.ProductID,
    p.Name,
    p.chunk,
    vector_distance('cosine', @search_vector, p.embeddings) AS distance
FROM [SalesLT].[Product] p
ORDER BY distance;
GO

----------------------------------------------------------------------------------------

DECLARE @search_text NVARCHAR(MAX) = 'Do you sell any padded seats that are good on trails?';
DECLARE @search_vector VECTOR(768) = AI_GENERATE_EMBEDDINGS(@search_text USE MODEL ollama);

SELECT TOP(4)
    p.ProductID,
    p.Name,
    p.chunk,
    vector_distance('cosine', @search_vector, p.embeddings) AS distance
FROM [SalesLT].[Product] p
ORDER BY distance;
GO

----------------------------------------------------------------------------------------


-- Step 6: Create a Vector Index - Uses Approximate Nearest Neighbors or ANN------------
-- Enable Preview Feature
ALTER DATABASE SCOPED CONFIGURATION
SET PREVIEW_FEATURES = ON;
GO

SELECT * FROM sys.database_scoped_configurations
WHERE [name] = 'PREVIEW_FEATURES'
GO
-- Create a vector index
CREATE VECTOR INDEX vec_idx ON [SalesLT].[Product]([embeddings])
WITH (
    metric = 'cosine',
    type = 'diskann',
    maxdop = 8
);
GO

-- Verify the vector index
SELECT * 
FROM sys.indexes 
WHERE type = 8;
GO

-- ANN Search and then applies the predicate specified in the WHERE clause.
DECLARE @search_text NVARCHAR(MAX) = 'Do you sell any padded seats that are good on trails?';
DECLARE @search_vector VECTOR(768) = AI_GENERATE_EMBEDDINGS(@search_text USE MODEL ollama);

SELECT
    t.ProductID,
    t.chunk,
    s.distance,
    t.ListPrice
FROM vector_search(
    table = [SalesLT].[Product] AS t,
    column = [embeddings],
    similar_to = @search_vector,
    metric = 'cosine',
    top_n = 10
) AS s
WHERE ListPrice < 40
ORDER BY s.distance;
GO
----------------------------------------------------------------------------------------


