/*
Name:			prod_recreate_db
Parameters:		none
Returns:		none
Author:			M. Tynes
Date:			2021.04.07
Description:	drop and recreate escalate database with extensions
Notes:			!!!WARNING: This drops the entire escalate database, run at your own risk!!!
                Needs to be run from a connection to another db (e.g. postgres)
*/
--DROP DATABASE escalate WITH (FORCE); -- postgres >= 13
DROP DATABASE escalate; -- postgres < 13
CREATE DATABASE escalate OWNER escalate;