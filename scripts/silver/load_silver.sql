/*
=================================
Load tables for the silver layer
=================================
Script Purpose:
    This script creates a stored procedure to load data into the silver layer
    with proper data transformations, error handling and logging.
	
WARNING:
    Running this script will truncate and reload the Tables. 
    Proceed with caution and ensure you have proper backups before running this script.

*/
CREATE OR REPLACE PROCEDURE silver.load_silver_layer()
LANGUAGE PLPGSQL
AS $$
DECLARE
    v_rows_affected INT;
BEGIN
    RAISE NOTICE '------------------------------------------------';
    RAISE NOTICE 'Starting Silver Layer data loading process';
    RAISE NOTICE '------------------------------------------------';

    -- ======================================================
    -- Load CRM tables
    -- ======================================================
    RAISE NOTICE '>> Loading CRM tables...';

    TRUNCATE TABLE silver.crm_cust_info;
    INSERT INTO silver.crm_cust_info(
        cst_id,
        cst_key,
        cst_firstname,
        cst_lastname,
        cst_marital_status,
        cst_gndr,cst_create_date
        )
    SELECT 
        cst_id,
        cst_key,
        TRIM(cst_firstname) AS cst_firstname,
        TRIM(cst_lastname) AS cst_lastname,
        CASE
            WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
            WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
            ELSE 'N/A'
        END AS cst_marital_status,
        CASE
            WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
            WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
            ELSE 'N/A'
        END AS cst_gndr,
        cst_create_date
    FROM
        (SELECT *, ROW_NUMBER() OVER(
            PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag
        FROM bronze.crm_cust_info WHERE cst_id IS NOT NULL) t
    WHERE flag = 1;
    GET DIAGNOSTICS v_rows_affected = ROW_COUNT;
    RAISE NOTICE '   - crm_cust_info loaded with % rows', v_rows_affected;

    TRUNCATE TABLE silver.crm_prd_info;
    INSERT INTO silver.crm_prd_info(
        prd_id,
        cat_id,
        prd_key,
        prd_nm,
        prd_cost,
        prd_line,
        prd_start_dt,
        prd_end_dt
        )
    SELECT
        prd_id,
        substr(prd_key, 1, 5) AS cat_id,
        substr(prd_key, 7) AS prd_key,
        prd_nm,
        COALESCE(prd_cost, 0) AS prd_cost,
        CASE 
            WHEN UPPER(TRIM(prd_line)) = 'S' THEN  'Other Sales'
            WHEN UPPER(TRIM(prd_line)) = 'T' THEN  'Touring'
            WHEN UPPER(TRIM(prd_line)) = 'M' THEN  'Mountain'
            WHEN UPPER(TRIM(prd_line)) = 'R' THEN  'Road'
            ELSE  'N/A'
        END AS prd_line,
        prd_start_dt,
        LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt) -1 AS prd_end_dt
    FROM bronze.crm_prd_info;
    GET DIAGNOSTICS v_rows_affected = ROW_COUNT;
    RAISE NOTICE '   - crm_prd_info loaded with % rows', v_rows_affected;

    TRUNCATE TABLE silver.crm_sales_details;
    INSERT INTO silver.crm_sales_details(
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        sls_order_dt,
        sls_ship_dt,
        sls_due_dt,
        sls_price,
        sls_quantity,
        sls_sales
        )
    WITH sales_clean AS (
        SELECT 
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            CASE 
                WHEN sls_order_dt BETWEEN 19000101 AND 20500101
                    THEN TO_DATE(sls_order_dt::TEXT, 'YYYYMMDD')
                ELSE NULL
            END AS sls_order_dt,
            CASE 
                WHEN sls_ship_dt BETWEEN 19000101 AND 20500101
                    THEN TO_DATE(sls_ship_dt::TEXT, 'YYYYMMDD')
                ELSE NULL
            END AS sls_ship_dt,
            CASE 
                WHEN sls_due_dt BETWEEN 19000101 AND 20500101
                    THEN TO_DATE(sls_due_dt::TEXT, 'YYYYMMDD')
                ELSE NULL
            END AS sls_due_dt,
            CASE 
                WHEN sls_sales IS NULL OR sls_sales = 0
                    THEN (sls_quantity * sls_price)
                ELSE ABS(sls_sales)
            END AS sls_price,
            sls_quantity
        FROM bronze.crm_sales_details
    )
    SELECT *,
           sls_price * sls_quantity AS sls_sales
    FROM sales_clean;
    GET DIAGNOSTICS v_rows_affected = ROW_COUNT;
    RAISE NOTICE '   - crm_sales_details loaded with % rows', v_rows_affected;

    -- ======================================================
    -- Load ERP tables
    -- ======================================================
    RAISE NOTICE '>> Loading ERP tables...';

    TRUNCATE TABLE silver.erp_cust_az12;
    INSERT INTO silver.erp_cust_az12(cid, bdate, gen)
    SELECT
        CASE 
            WHEN cid LIKE 'NAS%' THEN substr(cid, 4)
            ELSE cid
        END AS cid,
        CASE 
            WHEN bdate > CURRENT_DATE THEN NULL
            ELSE bdate
        END AS bdate,
        CASE 
            WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN  'Female'
            WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN  'Male'
            ELSE 'N/A'
        END AS gen
    FROM bronze.erp_cust_az12;
    GET DIAGNOSTICS v_rows_affected = ROW_COUNT;
    RAISE NOTICE '   - erp_cust_az12 loaded with % rows', v_rows_affected;

    TRUNCATE TABLE silver.erp_LOC_A101;
    INSERT INTO silver.erp_LOC_A101(cid, cntry)
    SELECT
        REPLACE(cid, '-', ''),
        CASE 
            WHEN TRIM(cntry) IN ('USA', 'US') THEN 'United States'
            WHEN TRIM(cntry) = 'DE' THEN 'Germany'
            WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'N/A'
            ELSE TRIM(cntry)
        END cntry
    FROM bronze.erp_LOC_A101;
    GET DIAGNOSTICS v_rows_affected = ROW_COUNT;
    RAISE NOTICE '   - erp_LOC_A101 loaded with % rows', v_rows_affected;

    TRUNCATE TABLE silver.erp_PX_CAT_G1V2;
    INSERT INTO silver.erp_PX_CAT_G1V2(id, cat, subcat, maintenance)
    SELECT * FROM bronze.erp_PX_CAT_G1V2;
    GET DIAGNOSTICS v_rows_affected = ROW_COUNT;
    RAISE NOTICE '   - erp_PX_CAT_G1V2 loaded with % rows', v_rows_affected;

    RAISE NOTICE '------------------------------------------------';
    RAISE NOTICE 'All tables have been loaded successfully!';
    RAISE NOTICE '------------------------------------------------';

EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'An error occurred while loading the tables';
        RAISE WARNING 'Error message: %', SQLERRM;
        RAISE;
END;
$$;