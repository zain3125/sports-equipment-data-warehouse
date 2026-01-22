/*
=================================
Insert CRM data to bronze layer
=================================
Script Purpose:
    This script insert CRM data after checking if it already exists. 
    If the data exists, it is dropped and re-inserted. Additionally
	
WARNING:
    Running this script will drop the entire CRM data if it exists. 
    Proceed with caution and ensure you have proper backups before running this script.

*/
CREATE OR REPLACE PROCEDURE bronze.load_bronze_layer()
LANGUAGE PLPGSQL
AS $$
BEGIN
    RAISE NOTICE '---------------------------------------------';
    RAISE NOTICE 'Starting CRM data load into Bronze layer';
    RAISE NOTICE '---------------------------------------------';

    -- =============================
    -- Load crm_cust_info
    -- =============================
    RAISE NOTICE 'Truncating table: bronze.crm_cust_info';
    TRUNCATE TABLE bronze.crm_cust_info;

    RAISE NOTICE 'Loading data into: bronze.crm_cust_info';
    COPY bronze.crm_cust_info
    FROM '/mnt/ssd/sports-equipment-data-warehouse/data/source_crm_csv/cust_info.csv'
    WITH (
        FORMAT csv,
        HEADER true,
        DELIMITER ','
    );

    -- =============================
    -- Load crm_prd_info
    -- =============================
    RAISE NOTICE 'Truncating table: bronze.crm_prd_info';
    TRUNCATE TABLE bronze.crm_prd_info;

    RAISE NOTICE 'Loading data into: bronze.crm_prd_info';
    COPY bronze.crm_prd_info
    FROM '/mnt/ssd/sports-equipment-data-warehouse/data/source_crm_csv/prd_info.csv'
    WITH (
        FORMAT csv,
        HEADER true,
        DELIMITER ','
    );

    -- =============================
    -- Load crm_sales_details
    -- =============================
    RAISE NOTICE 'Truncating table: bronze.crm_sales_details';
    TRUNCATE TABLE bronze.crm_sales_details;

    RAISE NOTICE 'Loading data into: bronze.crm_sales_details';
    COPY bronze.crm_sales_details
    FROM '/mnt/ssd/sports-equipment-data-warehouse/data/source_crm_csv/sales_details.csv'
    WITH (
        FORMAT csv,
        HEADER true,
        DELIMITER ','
    );

    RAISE NOTICE '---------------------------------------------';
    RAISE NOTICE 'CRM data loaded successfully into Bronze layer';
    RAISE NOTICE '---------------------------------------------';

EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING '---------------------------------------------';
        RAISE WARNING 'Error occurred while loading CRM data into Bronze layer';
        RAISE WARNING 'Error message: %', SQLERRM;
        RAISE;
END;
$$;
