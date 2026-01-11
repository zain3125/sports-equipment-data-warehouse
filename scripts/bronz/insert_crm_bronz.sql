/*
=================================
Insert CRM data to tables
=================================
Script Purpose:
    This script insert CRM data after checking if it already exists. 
    If the data exists, it is dropped and recreated. Additionally
	
WARNING:
    Running this script will drop the entire CRM data if it exists. 
    Proceed with caution and ensure you have proper backups before running this script.

*/

TRUNCATE TABLE bronz.crm_cust_info;
COPY bronz.crm_cust_info
FROM '/mnt/ssd/sports-equipment-data-warehouse/data/source_crm_csv/cust_info.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);

TRUNCATE TABLE bronz.crm_prd_info;
COPY bronz.crm_prd_info
FROM '/mnt/ssd/sports-equipment-data-warehouse/data/source_crm_csv/prd_info.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);

TRUNCATE TABLE bronz.crm_sales_details;
COPY bronz.crm_sales_details
FROM '/mnt/ssd/sports-equipment-data-warehouse/data/source_crm_csv/sales_details.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);
select * from bronz.crm_prd_info;
