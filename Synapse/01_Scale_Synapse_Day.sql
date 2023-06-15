--Run the Scripts to load NYCTaxi Data


-- a. Cleanup
IF OBJECT_ID('dimDate') IS NOT NULL    DROP TABLE [dimDate]
IF OBJECT_ID('fctTrip') IS NOT NULL    DROP TABLE [fctTrip]
IF OBJECT_ID('fctTrip_RR') IS NOT NULL DROP TABLE [fctTrip_RR]


-- b. Create tables - REPLICATED / HASH DISTRIBUTED / ROUND-ROBIN DISTRIBUTED
CREATE TABLE [dimDate]
WITH
	(DISTRIBUTION = REPLICATE,
	 CLUSTERED INDEX (DateID) )
AS
SELECT *
	FROM [dbo].[Date]

CREATE TABLE [fctTrip]
WITH
	(DISTRIBUTION = HASH(DateID),
	 CLUSTERED COLUMNSTORE INDEX )
AS
SELECT *
	FROM [dbo].[Trip]

CREATE TABLE [fctTrip_RR]
WITH
	(DISTRIBUTION = ROUND_ROBIN,
	 CLUSTERED COLUMNSTORE INDEX )
AS
SELECT *
	FROM [dbo].[Trip]

--Show scale with Hash-Distributed Table
DBCC PDW_SHOWSPACEUSED ('dbo.fctTrip')

--Show scale with Round Robin Table
DBCC PDW_SHOWSPACEUSED ('dbo.fctTrip_RR');