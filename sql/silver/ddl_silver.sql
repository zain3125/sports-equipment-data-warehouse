/*
=================================
Create tables for the silver layer
=================================
Script Purpose:
    This script creates a stored procedure to build the silver layer tables
    with proper error handling and logging. If tables exist, they are dropped
    and recreated.
	
WARNING:
    Running this script will drop the entire Tables if it exists. 
    Proceed with caution and ensure you have proper backups before running this script.

*/
CREATE OR REPLACE PROCEDURE silver.ddl_silver_layer()
LANGUAGE PLPGSQL
AS $$
BEGIN
    RAISE NOTICE '------------------------------------------------';
    RAISE NOTICE 'Starting Silver Layer loading process';
    RAISE NOTICE '------------------------------------------------';

    -- ======================================================
    -- CRM system tables
    -- ======================================================
    RAISE NOTICE '>> Creating CRM tables...';

    DROP TABLE IF EXISTS silver.crm_cust_info;
    CREATE TABLE silver.crm_cust_info(
        cst_id INT,
        cst_key VARCHAR(20),
        cst_firstname VARCHAR(50),
        cst_lastname VARCHAR(50),
        cst_marital_status VARCHAR(10),
        cst_gndr VARCHAR(10),
        cst_create_date DATE,
        dwh_create_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    );
    RAISE NOTICE '   - crm_cust_info created successfully';

    DROP TABLE IF EXISTS silver.crm_prd_info;
    CREATE TABLE silver.crm_prd_info(
        prd_id INT,
        cat_id VARCHAR(50),
        prd_key VARCHAR(50),
        prd_nm VARCHAR(50),
        prd_cost INT,
        prd_line VARCHAR(20),
        prd_start_dt DATE,
        prd_end_dt DATE,
        dwh_create_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    );
    RAISE NOTICE '   - crm_prd_info created successfully';

    DROP TABLE IF EXISTS silver.crm_sales_details;
    CREATE TABLE silver.crm_sales_details(
        sls_ord_num VARCHAR(20),
        sls_prd_key VARCHAR(50),
        sls_cust_id INT,
        sls_order_dt DATE,
        sls_ship_dt DATE,
        sls_due_dt DATE,
        sls_sales INT,
        sls_quantity INT,
        sls_price INT,
        dwh_create_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    );
    RAISE NOTICE '   - crm_sales_details created successfully';

    -- ======================================================
    -- ERP system tables
    -- ======================================================
    RAISE NOTICE '>> Creating ERP tables...';

    DROP TABLE IF EXISTS silver.erp_CUST_AZ12;
    CREATE TABLE silver.erp_CUST_AZ12(
        cid VARCHAR(20),
        bdate DATE,
        gen VARCHAR(10),
        dwh_create_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    );
    RAISE NOTICE '   - erp_CUST_AZ12 created successfully';

    DROP TABLE IF EXISTS silver.erp_LOC_A101;
    CREATE TABLE silver.erp_LOC_A101(
        cid VARCHAR(20),
        cntry VARCHAR(50),
        dwh_create_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    );
    RAISE NOTICE '   - erp_LOC_A101 created successfully';

    DROP TABLE IF EXISTS silver.erp_PX_CAT_G1V2;
    CREATE TABLE silver.erp_PX_CAT_G1V2(
        id VARCHAR(20),
        cat VARCHAR(20),
        subcat VARCHAR(20),
        maintenance VARCHAR(20),
        dwh_create_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    );
    RAISE NOTICE '   - erp_PX_CAT_G1V2 created successfully';

    RAISE NOTICE '------------------------------------------------';
    RAISE NOTICE 'All tables have been created successfully!';
    RAISE NOTICE '------------------------------------------------';

EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'An error occurred while creating the tables';
        RAISE WARNING 'Error message: %', SQLERRM;
        RAISE;
END;
$$;
