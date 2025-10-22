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


-- Standard encoding
SELECT BASE64_ENCODE(CAST('hello world' AS VARBINARY));
-- Output: aGVsbG8gd29ybGQ=

-- URL-safe encoding
SELECT BASE64_ENCODE(0xCAFECAFE, 1);
-- Output: yv7K_g

--Notes:
--No newline characters are added.
--Padding (=) may be included unless URL-safe mode is used.

DECLARE @encoded VARCHAR(MAX) = 'SGVsbG8gd29ybGQ=';
SELECT CONVERT(VARCHAR, BASE64_DECODE(@encoded));
-- Output: hello world