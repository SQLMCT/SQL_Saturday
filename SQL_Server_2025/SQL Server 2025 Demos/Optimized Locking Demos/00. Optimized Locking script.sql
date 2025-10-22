
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

 -- This is the standard behavior. We will examine it first, then look at optimized locking
 -- Step 0 - if needed import AdventureWorks from the AdventureWorks.bacpac
 -- Step 1 - Accelerated Data Recovery must be enabled to support both features
 -- Execute 01. enableadr.sql
 -- Execute 02. disableoptimizedlocking.sql
 -- Step 2 - Load the 03. getlocks.sql in a separate query window. Leave open throughout
 -- Step 3 - Execute the code in 04.updatefreightsmall.sql DO NOT RUN THE ROLLBACK TRAN
 --          Leave this window open so you can rollback later
 -- Step 4 - Execute the getlocks.sql code
-- You will see ~2500 KEY X locks and 111 PAGE locks. Without optimized locking, key and page locks are held as long as the transaaction is active. 
-- If more rows are updated, lock escalation can occur. Move forward to the next steps to see how.
-- Step 5 - execute the ROLLBACK TRAN in 04.updatefreightsmall.sql
-- Step 6 - verify locks are gone by executing 03. getlocks.sql
-- Step 7 - execute the 05. updatefreightbig.sql script DO NOT RUN THE ROLLBACK TRAN
-- Step 8 - execute the 03.getlocks.sql script
-- Step 9 - execute the 06. updatefreightmax.sql
-- Step 10 - execute 07. showblocking.sql to show blocking
-- Step 11 - execute the ROLLBACK TRAN in 05 and 06

-- Now let's investigate the new behavior with optimized locking
-- Step 1 - enable optimized locking by executing 08. enableoptimizedlocking.sql
-- Step 2 - execute 04. updatefreightsmall.sql
-- Step 3 - execute 03. getlocks.sql

-- You will see an OBJECT IX lock as seen before but now only a XACT X lock. This is because the transaction ID lock is held for the duration of the transaction. 
-- KEY and PAGE locks are released as soon as each row is updated. 
-- This allows for more concurrency.

-- Step 4 - ROLLBACK the transactions in 04. updatefreightsmall.sql
-- Step 5 - Now let's rerun the 06. updatefreightbig.sql this will not escalate!
-- Step 6 - verify with 03. getlocks.sql You will see an OBJECT IX lock and a XACT X lock. 
-- There is no lock escalation.
-- Step 7 - execute the 06. updatefreightbig.sql
-- Step 8 - execute 07. showblocking.sql
-- Step 9 - ROLLBACK TRAN for 06. updatefreightbig.sql