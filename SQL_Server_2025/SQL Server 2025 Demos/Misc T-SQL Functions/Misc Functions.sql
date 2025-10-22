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

-- CURRENT_DATE
SELECT CURRENT_DATE;
-- same as manually casting
SELECT CAST(GETDATE() AS DATE)

-- UNISTR() -- requres UTF-8 collation. This will throw an error on my machine
SELECT UNISTR('\00E9cole');
-- Returns: école

--SUBSTRING()
-- Old syntax (required length)
-- SUBSTRING(expression, start, length)
-- New syntax (length optional)
-- SUBSTRING(expression, start [, length])
SELECT SUBSTRING('Hello', 1);

--|| string concat operator
SELECT 'SQL ' || 'Server';