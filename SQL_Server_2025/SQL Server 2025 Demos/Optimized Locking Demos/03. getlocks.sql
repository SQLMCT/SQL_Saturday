
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

SELECT 
    resource_type,
    resource_database_id,
    resource_associated_entity_id,
   -- resource_description,
    request_mode,
    request_session_id,
    request_status,
    COUNT(*) AS lock_count
FROM 
    sys.dm_tran_locks
WHERE resource_type != 'DATABASE'
GROUP BY 
    resource_type,
    resource_database_id,
    resource_associated_entity_id,
    request_mode,
    request_session_id,
    request_status
ORDER BY 
    resource_type,
    resource_database_id,
    resource_associated_entity_id,
    request_mode,
    request_session_id,
    request_status;
GO

