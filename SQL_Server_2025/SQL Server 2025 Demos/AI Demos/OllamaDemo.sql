
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
-- step 1
USE [AdventureWorks2025]; 
GO 
USE master;
GO
sp_configure 'external rest endpoint enabled', 1;
GO
RECONFIGURE WITH OVERRIDE;
GO

--Step 2 Will not be necessary in release version
-- Enable vector index and search for CTP builds
DBCC TRACEON (466, 13981, -1) 
GO
USE [AdventureWorks2025]; 
GO 

DROP EXTERNAL MODEL myOllamaEmbeddingmodel; 

-- Create the EXTERNAL MODEL 
CREATE EXTERNAL MODEL myOllamaEmbeddingmodel
WITH ( 
LOCATION = 'https://localhost:11434/api/embed', 
API_FORMAT = 'Ollama', 
MODEL_TYPE =embeddings , 
MODEL = 'mxbai-embed-large');
GRANT EXECUTE ON EXTERNAL MODEL::myOllamaEmbeddingmodel TO [REDMOND\bobtay];


DROP TABLE IF EXISTS Production.ProductDescriptionEmbeddingsOllama;
GO
CREATE TABLE Production.ProductDescriptionEmbeddingsOllama
( 
  ProductDescEmbeddingID INT IDENTITY NOT NULL PRIMARY KEY CLUSTERED, -- Need a single column as cl index to support vector index reqs
  ProductID INT NOT NULL,
  ProductDescriptionID INT NOT NULL,
  ProductModelID INT NOT NULL,
  CultureID nchar(6) NOT NULL,
  Embedding vector(1024)
);

-- Populate rows with embeddings
-- Need to make sure and only get Products that have ProductModels
INSERT INTO Production.ProductDescriptionEmbeddingsOllama
SELECT p.ProductID, pmpdc.ProductDescriptionID, pmpdc.ProductModelID, pmpdc.CultureID, 
AI_GENERATE_EMBEDDINGS(pd.Description USE MODEL myOllamaEmbeddingmodel)
FROM Production.ProductModelProductDescriptionCulture pmpdc
JOIN Production.Product p
ON pmpdc.ProductModelID = p.ProductModelID
JOIN Production.ProductDescription pd
ON pd.ProductDescriptionID = pmpdc.ProductDescriptionID
ORDER BY p.ProductID;
GO
-- SELECT TOP 10  * from [Production].[ProductDescriptionEmbeddings]

-- Create an alternate key using an ncl index
CREATE UNIQUE NONCLUSTERED INDEX [IX_ProductDescriptionEmbeddings_AlternateKey_Ollama]
ON [Production].ProductDescriptionEmbeddingsOllama
(
    [ProductID] ASC,
    [ProductModelID] ASC,
    [ProductDescriptionID] ASC,
    [CultureID] ASC
);
GO
-- SELECT top 10 * from [Production].[ProductDescriptionEmbeddings]

--CREATE VECTOR INDEX index_name
--ON object ( vector_column )  
--[ WITH (
--    [,] METRIC = { 'cosine' | 'dot' | 'euclidean' }
--    [ [,] TYPE = 'DiskANN' ] -- Currently the only type of index ANN is Approximate Nearest Neighbor
-- https://suhasjs.github.io/files/diskann_neurips19.pdf
--    [ [,] MAXDOP = max_degree_of_parallelism ]
--) ]
--[ ON { filegroup_name | "default" } ]
--[;]

--Step 7 Create vector index
CREATE VECTOR INDEX product_vector_index 
ON Production.ProductDescriptionEmbeddingsOllama (Embedding)
WITH (METRIC = 'cosine', TYPE = 'diskann', MAXDOP = 8);
GO

--Step 8 Let's setup to query the data!
CREATE OR ALTER PROCEDURE [find_relevant_products_vector_search_Ollama]
	@prompt NVARCHAR(max), -- NL prompt
	@stock SMALLINT = 500, -- Only show product with stock level of >= 500. User can override
	@top INT = 10, -- Only show top 10. User can override
	@min_similarity DECIMAL(19,16) = 0.3 -- Similarity level that user can change but recommend to leave default
AS
-- short circuit if no prompt
IF (@prompt is null) RETURN;

DECLARE @retval INT, @vector VECTOR(1536);
-- AI_GENERATE_EMBEDDINGS is a built-in function that creates embeddings (vector arrays) 
-- using a precreated AI model definition stored in the database.
SELECT @vector = AI_GENERATE_EMBEDDINGS(@prompt USE MODEL myOllamaEmbeddingmodel)
-- if there was an error, return
IF (@retval != 0) RETURN;

-- Use VECTOR_SEARCH to search for vectors similar to a given 
-- query vectors using an approximate nearest neighbors vector search algorithm. 
SELECT p.Name as ProductName, pd.Description AS ProductDescription, p.SafetyStockLevel AS StockLevel
FROM VECTOR_SEARCH(
	TABLE = Production.ProductDescriptionEmbeddingsOllama AS t,
	COLUMN = Embedding,
	similar_to = @vector,
	metric = 'cosine',
	top_n = @top
	) AS s
JOIN Production.ProductDescriptionEmbeddingsOllama pe
ON t.ProductDescEmbeddingID = pe.ProductDescEmbeddingID
JOIN Production.Product p
ON pe.ProductID = p.ProductID
JOIN Production.ProductDescription pd
ON pd.ProductDescriptionID = pe.ProductDescriptionID
-- key phrase!
WHERE (1-s.distance) > @min_similarity
AND p.SafetyStockLevel >= @stock
ORDER by s.distance;
GO

--Step 9 Query
EXEC find_relevant_products_vector_search_Ollama
@prompt = N'Show me stuff for extreme outdoor sports',
@stock = 100, 
@top = 20;
GO


