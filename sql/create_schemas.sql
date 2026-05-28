/*
=============================================================
Create Schemas
=============================================================
Script Purpose:
    This script creates a new schemas after checking if it already exists. 
    If the schemas exists, it is dropped and recreated. Additionally
	
WARNING:
    Running this script will drop the entire schema if it exists. 
    All data in the database will be permanently deleted. Proceed with caution 
    and ensure you have proper backups before running this script.
*/

DROP SCHEMA IF EXISTS bronze CASCADE;
CREATE SCHEMA bronze;

DROP SCHEMA IF EXISTS silver CASCADE;
CREATE SCHEMA silver;

DROP SCHEMA IF EXISTS gold CASCADE;
CREATE SCHEMA gold;
