
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
USE AdventureWorks;
-- For use in the Extended Event script
select DB_ID() --18
-- before optimized sp_executesql

-- Step 1 - execute 01. disable_optimized_so_executesql
-- Step 2 - execute 02. clearplancache.sql
-- Step 3 - start the extended event in 04. tracelocks
--		No object X lock. default behavior
-- Step 4 - load 03. getcachedplans.sql - we will run this after the workload has completed.
-- Step 5 - from a terminal window, execute workload.cmd - should only take seconds
-- Step 6 - execute the 03. getcachedplans.sql - you will see multiple rows for the same plan

-- Optimized sp_executesql
-- Step 7 - Execute 05. enable_optimized_sp_executesql.sql
-- Step 8 - execute 02. clearplancache.sql
-- Step 9 - from a terminal window, execute workload.cmd - should only take seconds
-- Step 10- execute the 03. getcahcedplans.sql - you will see only one row returned!
-- Step 11- Examine the Extended events and now we see an OBJECT X lock like a stored procedure!


