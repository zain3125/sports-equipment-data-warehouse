/*
=================================
Create tables for the bronze layer
=================================
Script Purpose:
    This script creates a new Tables after checking if it already exists. 
    If the Table exists, it is dropped and recreated. Additionally

WARNING:
    Running this script will drop the entire Tables if it exists. 
    Proceed with caution and ensure you have proper backups before running this script.

*/
CREATE OR REPLACE PROCEDURE bronze.ddl_bronze_layer()
LANGUAGE PLPGSQL
AS $$
BEGIN
    RAISE NOTICE '------------------------------------------------';
    RAISE NOTICE 'Starting Bronze Layer loading process';
    RAISE NOTICE '------------------------------------------------';

    -- ======================================================
    -- CRM system tables
    -- ======================================================
    RAISE NOTICE '>> Creating CRM tables...';

    DROP TABLE IF EXISTS bronze.crm_cust_info;
    CREATE TABLE bronze.crm_cust_info(
        cst_id INT,
        cst_key VARCHAR(20),
        cst_firstname VARCHAR(50),
        cst_lastname VARCHAR(50),
        cst_marital_status CHAR(1),
        cst_gndr CHAR(1),
        cst_create_date DATE
    );

    DROP TABLE IF EXISTS bronze.crm_prd_info;
    CREATE TABLE bronze.crm_prd_info(
        prd_id INT,
        prd_key VARCHAR(50),
        prd_nm VARCHAR(50),
        prd_cost INT,
        prd_line CHAR(1),
        prd_start_dt DATE,
        prd_end_dt DATE
    );

    DROP TABLE IF EXISTS bronze.crm_sales_details;
    CREATE TABLE bronze.crm_sales_details(
        sls_ord_num VARCHAR(20),
        sls_prd_key VARCHAR(50),
        sls_cust_id INT,
        sls_order_dt INT,
        sls_ship_dt INT,
        sls_due_dt INT,
        sls_sales INT,
        sls_quantity INT,
        sls_price INT
    );

    -- ======================================================
    -- ERP system tables
    -- ======================================================
    RAISE NOTICE '>> Creating ERP tables...';

    DROP TABLE IF EXISTS bronze.erp_cust_az12;
    CREATE TABLE bronze.erp_cust_az12(
        cid VARCHAR(20),
        bdate DATE,
        gen VARCHAR(10)
    );

    DROP TABLE IF EXISTS bronze.erp_loc_a101;
    CREATE TABLE bronze.erp_loc_a101(
        cid VARCHAR(20),
        cntry VARCHAR(50)
    );

    DROP TABLE IF EXISTS bronze.erp_px_cat_g1v2;
    CREATE TABLE bronze.erp_px_cat_g1v2(
        id VARCHAR(20),
        cat VARCHAR(20),
        subcat VARCHAR(20),
        maintenance VARCHAR(20)
    );

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
