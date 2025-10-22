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
USE FuzzyMatch;
GO

 -- Step 1: Create the table
CREATE TABLE WordPairs (
    WordID INT IDENTITY(1,1) PRIMARY KEY, -- Auto-incrementing ID
    WordUK NVARCHAR(50), -- UK English word
    WordUS NVARCHAR(50)  -- US English word
);

-- Step 2: Insert the data
INSERT INTO WordPairs (WordUK, WordUS) VALUES
('Colour', 'Color'),
('Flavour', 'Flavor'),
('Centre', 'Center'),
('Theatre', 'Theater'),
('Organise', 'Organize'),
('Analyse', 'Analyze'),
('Catalogue', 'Catalog'),
('Programme', 'Program'),
('Metre', 'Meter'),
('Honour', 'Honor'),
('Neighbour', 'Neighbor'),
('Travelling', 'Traveling'),
('Grey', 'Gray'),
('Defence', 'Defense'),
('Practise', 'Practice'), -- Verb form in UK
('Practice', 'Practice'), -- Noun form in both
('Aluminium', 'Aluminum'),
('Cheque', 'Check'); -- Bank cheque vs. check

-- EDIT DISTANCE
SELECT WordUK, WordUS, EDIT_DISTANCE(WordUK, WordUS) AS Distance
FROM WordPairs
WHERE EDIT_DISTANCE(WordUK, WordUS) <= 2
ORDER BY Distance ASC;

--EWDIT_DISTANCE_SIMILARITY
SELECT WordUK, WordUS, EDIT_DISTANCE_SIMILARITY(WordUK, WordUS) AS Similarity
FROM WordPairs
WHERE EDIT_DISTANCE_SIMILARITY(WordUK, WordUS) >=75
ORDER BY Similarity DESC;

--JARO_WINKLER_DISTANCE
SELECT WordUK, WordUS, JARO_WINKLER_DISTANCE(WordUK, WordUS) AS Distance
FROM WordPairs
WHERE JARO_WINKLER_DISTANCE(WordUK, WordUS) <= .05
ORDER BY Distance ASC;

-- JARO_WINKLER_SIMILARITY
SELECT WordUK, WordUS, JARO_WINKLER_SIMILARITY(WordUK, WordUS) AS Similarity
FROM WordPairs
WHERE JARO_WINKLER_SIMILARITY(WordUK, WordUS) > .90
ORDER BY  Similarity DESC;