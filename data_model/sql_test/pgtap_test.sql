--======================================================================
/*
Name:			pgTap_test
Parameters:		
Returns:		
Author:			G. Cattabriga
Date:			2020.10.10
Description:	
Notes:							
*/

BEGIN;

SELECT plan(2);
-- SELECT * from no_plan();

SELECT ok(1 + 2 = 3);
SELECT ok(1 + 2 = 4);


-- clean up
SELECT * from finish();
ROLLBACK;