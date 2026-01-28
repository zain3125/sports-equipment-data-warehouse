/*
================================
Quality Checks for Silver Layer
================================
Script Purpose:
    This script creates a stored procedure to perform data quality checks
    on all silver layer tables with error handling and logging.

*/
CREATE OR REPLACE PROCEDURE silver.quality_checks_silver_layer()
LANGUAGE PLPGSQL
AS $$
DECLARE
    v_check_count INT;
BEGIN
    RAISE NOTICE '================================================';
    RAISE NOTICE 'Starting Silver Layer Quality Checks';
    RAISE NOTICE '================================================';

    -- ======================================================
    -- Checking crm_cust_info
    -- ======================================================
    RAISE NOTICE '';
    RAISE NOTICE '>> Checking crm_cust_info...';
    
    -- Check id duplicates and NULL id's
    SELECT COUNT(*) INTO v_check_count FROM silver.crm_cust_info
    WHERE (cst_id IN (
        SELECT cst_id FROM silver.crm_cust_info
        GROUP BY cst_id HAVING COUNT(*) > 1
    ) OR cst_id IS NULL);
    IF v_check_count > 0 THEN
        RAISE WARNING '   - Found % duplicate or NULL customer IDs', v_check_count;
    ELSE
        RAISE NOTICE '   - No duplicate or NULL customer IDs found';
    END IF;

    -- Check spaces before OR after name
    SELECT COUNT(*) INTO v_check_count FROM silver.crm_cust_info
    WHERE cst_firstname != TRIM(cst_firstname)
    OR cst_lastname != TRIM(cst_lastname);
    IF v_check_count > 0 THEN
        RAISE WARNING '   - Found % records with whitespace in names', v_check_count;
    ELSE
        RAISE NOTICE '   - No whitespace issues in names';
    END IF;

    -- Data Standardization & Consistency for marital status
    SELECT COUNT(DISTINCT cst_marital_status) INTO v_check_count FROM silver.crm_cust_info;
    RAISE NOTICE '   - Marital status has % unique values', v_check_count;

    -- Data Standardization & Consistency for gender
    SELECT COUNT(DISTINCT cst_gndr) INTO v_check_count FROM silver.crm_cust_info;
    RAISE NOTICE '   - Gender has % unique values', v_check_count;

    -- ======================================================
    -- Checking crm_prd_info
    -- ======================================================
    RAISE NOTICE '';
    RAISE NOTICE '>> Checking crm_prd_info...';
    
    -- Check prd_id duplicates and NULL prd_id's
    SELECT COUNT(*) INTO v_check_count FROM silver.crm_prd_info
    WHERE (prd_id IN (
        SELECT prd_id FROM silver.crm_prd_info
        GROUP BY prd_id HAVING COUNT(*) > 1
    ) OR prd_id IS NULL);
    IF v_check_count > 0 THEN
        RAISE WARNING '   - Found % duplicate or NULL product IDs', v_check_count;
    ELSE
        RAISE NOTICE '   - No duplicate or NULL product IDs found';
    END IF;

    -- Check for Unwanted Spaces
    SELECT COUNT(*) INTO v_check_count FROM silver.crm_prd_info
    WHERE prd_nm != TRIM(prd_nm);
    IF v_check_count > 0 THEN
        RAISE WARNING '   - Found % product names with whitespace', v_check_count;
    ELSE
        RAISE NOTICE '   - No whitespace issues in product names';
    END IF;

    -- Check for NULLs or Negative Values in Cost
    SELECT COUNT(*) INTO v_check_count FROM silver.crm_prd_info
    WHERE prd_cost < 0 OR prd_cost IS NULL;
    IF v_check_count > 0 THEN
        RAISE WARNING '   - Found % products with NULL or negative costs', v_check_count;
    ELSE
        RAISE NOTICE '   - All product costs are valid';
    END IF;

    -- Data Standardization & Consistency for product line
    SELECT COUNT(DISTINCT prd_line) INTO v_check_count FROM silver.crm_prd_info;
    RAISE NOTICE '   - Product line has % unique values', v_check_count;

    -- Check start date is before end date
    SELECT COUNT(*) INTO v_check_count FROM silver.crm_prd_info
    WHERE prd_end_dt < prd_start_dt;
    IF v_check_count > 0 THEN
        RAISE WARNING '   - Found % products with end date before start date', v_check_count;
    ELSE
        RAISE NOTICE '   - All product date ranges are valid';
    END IF;

    -- ======================================================
    -- Checking crm_sales_details
    -- ======================================================
    RAISE NOTICE '';
    RAISE NOTICE '>> Checking crm_sales_details...';
    
    -- Check spaces before OR after prd_key
    SELECT COUNT(*) INTO v_check_count FROM silver.crm_sales_details
    WHERE sls_prd_key != TRIM(sls_prd_key);
    IF v_check_count > 0 THEN
        RAISE WARNING '   - Found % product keys with whitespace', v_check_count;
    ELSE
        RAISE NOTICE '   - No whitespace issues in product keys';
    END IF;

    -- Check logic order of Dates
    SELECT COUNT(*) INTO v_check_count FROM silver.crm_sales_details
    WHERE sls_order_dt > sls_ship_dt
    OR sls_ship_dt > sls_due_dt;
    IF v_check_count > 0 THEN
        RAISE WARNING '   - Found % sales records with invalid date sequences', v_check_count;
    ELSE
        RAISE NOTICE '   - All sale date sequences are valid';
    END IF;

    -- Check for NULLs or Negative Values
    SELECT COUNT(*) INTO v_check_count FROM silver.crm_sales_details
    WHERE sls_sales <= 0 OR sls_sales IS null
    OR sls_quantity <= 0 OR sls_quantity IS null
    OR sls_price <= 0 OR sls_price IS null;
    IF v_check_count > 0 THEN
        RAISE WARNING '   - Found % sales records with NULL or negative values', v_check_count;
    ELSE
        RAISE NOTICE '   - All sales values are valid';
    END IF;

    -- Check price calculation
    SELECT COUNT(*) INTO v_check_count FROM silver.crm_sales_details
    WHERE sls_sales != sls_price * sls_quantity;
    IF v_check_count > 0 THEN
        RAISE WARNING '   - Found % sales records where calculation is incorrect', v_check_count;
    ELSE
        RAISE NOTICE '   - All price calculations are correct';
    END IF;

    -- ======================================================
    -- Checking erp_cust_az12
    -- ======================================================
    RAISE NOTICE '';
    RAISE NOTICE '>> Checking erp_cust_az12...';
    
    -- Check spaces before OR after cid
    SELECT COUNT(*) INTO v_check_count FROM silver.erp_cust_az12
    WHERE cid != TRIM(cid);
    IF v_check_count > 0 THEN
        RAISE WARNING '   - Found % customer IDs with whitespace', v_check_count;
    ELSE
        RAISE NOTICE '   - No whitespace issues in customer IDs';
    END IF;

    -- Check cid duplicates and NULL cid's
    SELECT COUNT(*) INTO v_check_count FROM silver.erp_cust_az12
    WHERE (cid IN (
        SELECT cid FROM silver.erp_cust_az12
        GROUP BY cid HAVING COUNT(*) > 1
    ) OR cid IS NULL);
    IF v_check_count > 0 THEN
        RAISE WARNING '   - Found % duplicate or NULL customer IDs', v_check_count;
    ELSE
        RAISE NOTICE '   - No duplicate or NULL customer IDs found';
    END IF;

    -- Check birth date before current date
    SELECT COUNT(*) INTO v_check_count FROM silver.erp_cust_az12
    WHERE bdate > CURRENT_DATE;
    IF v_check_count > 0 THEN
        RAISE WARNING '   - Found % birth dates in the future', v_check_count;
    ELSE
        RAISE NOTICE '   - All birth dates are valid';
    END IF;

    -- Data Standardization & Consistency for gender
    SELECT COUNT(DISTINCT gen) INTO v_check_count FROM silver.erp_cust_az12;
    RAISE NOTICE '   - Gender has % unique values', v_check_count;

    -- ======================================================
    -- Checking erp_LOC_A101
    -- ======================================================
    RAISE NOTICE '';
    RAISE NOTICE '>> Checking erp_LOC_A101...';
    
    -- Data Standardization & Consistency for countries
    SELECT COUNT(DISTINCT cntry) INTO v_check_count FROM silver.erp_loc_a101;
    RAISE NOTICE '   - Countries has % unique values', v_check_count;

    RAISE NOTICE '';
    RAISE NOTICE '================================================';
    RAISE NOTICE 'Quality checks completed successfully!';
    RAISE NOTICE '================================================';

EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'An error occurred during quality checks';
        RAISE WARNING 'Error message: %', SQLERRM;
        RAISE;
END;
$$;