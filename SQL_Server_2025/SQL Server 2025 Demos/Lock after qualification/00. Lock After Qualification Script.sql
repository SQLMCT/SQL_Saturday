
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
 
 -- these two projects will demonstate the new Optimized Locking features
 -- the first will demonstrate optimized locking and the second will show Lock After Qualification

 -- Step 1 - disable RCSI by executing 09. disablercsi.sql
 -- Step 2 - execute 10. updatefreightpo1.sql DO NOT RUN the ROLLBACK TRAN!
 -- Step 3 - execute 11. updatefreightpo2.sql DO NOT RUN the ROLLBACK TRAN!
 -- Step 4 - execute 07. showblocking.sql
 -- Step 5 - rollback both transactions

 -- Now let's see the LAQ feature!
 -- Step 6 - execute 12. enablercsi.sql
 -- Step 7 - execute 10. updatefreightpo1.sql DO NOT RUN the ROLLBACK TRAN!
 -- Step 8 - execute 11. updatefreightpo2.sql DO NOT RUN the ROLLBACK TRAN!
 -- Step 9 - execute 03. getlocks.sql
 -- Notice that both sessions now have Exclusive (X) XACT locks. This is because LAQ allows the second 
 -- update to qualify rows that don't meet the query criteria without acquiring a lock.
 -- Step 5 - rollback both transactions