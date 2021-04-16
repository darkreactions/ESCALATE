/*
Name:			prod_intialize_db
Parameters:		none
Returns:		none
Author:			M. Tynes
Date:			2021.04.07
Description:	create schema and add extensions
Notes:			none
*/


CREATE SCHEMA dev;
CREATE EXTENSION if not exists ltree;
CREATE EXTENSION if not exists tablefunc;
CREATE EXTENSION if not exists "uuid-ossp";
CREATE EXTENSION IF not exists hstore;
