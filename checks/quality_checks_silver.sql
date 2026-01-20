/*
========================
Checking crm_cust_info
========================
*/

-- Check id duplicates and NULL id's
SELECT cst_id, count(*) FROM silver.crm_cust_info
GROUP BY cst_id
HAVING count(*) > 1 OR cst_id IS NULL;

-- Check spaces before OR after name
SELECT cst_firstname, cst_lastname FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)
OR cst_lastname != TRIM(cst_lastname);

-- Data Standardization & Consistency
SELECT cst_marital_status
FROM silver.crm_cust_info
GROUP BY cst_marital_status;

-- Data Standardization & Consistency
SELECT cst_gndr
FROM silver.crm_cust_info
GROUP BY cst_gndr;

/*
========================
Checking crm_prd_info
========================
*/

-- Check prd_id duplicates and NULL prd_id's
SELECT prd_id, count(*) FROM silver.crm_prd_info
GROUP BY prd_id
HAVING count(*) > 1 OR prd_id IS NULL;

-- Check for Unwanted Spaces
SELECT 
    prd_nm 
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- Check for NULLs or Negative Values in Cost
SELECT 
    prd_cost 
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Data Standardization & Consistency
SELECT DISTINCT 
    prd_line 
FROM silver.crm_prd_info;

-- Check start date is before end date
SELECT * FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;

/*
============================
Checking crm_sales_details
============================
*/
-- Check spaces before OR after prd_key
SELECT sls_prd_key FROM silver.crm_sales_details
WHERE sls_prd_key != TRIM(sls_prd_key);

-- Check logic order of Dates
SELECT * FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt
OR sls_ship_dt > sls_due_dt;

-- Check for NULLs or Negative Values
SELECT * FROM silver.crm_sales_details
WHERE
sls_sales <= 0 OR sls_sales IS null
OR sls_quantity <= 0 OR sls_quantity IS null
OR sls_price <= 0 OR sls_price IS null;

-- check price calculation
SELECT * FROM silver.crm_sales_details
WHERE sls_sales != sls_price * sls_quantity;

SELECT * FROM silver.crm_sales_details
WHERE sls_sales != sls_price * sls_quantity;

/*
============================
Checking erp_cust_az12
============================
*/
-- Check spaces before OR after cid
SELECT * FROM silver.erp_cust_az12
WHERE cid != TRIM(cid);

-- Check cid duplicates and NULL cid's
SELECT cid, COUNT(*) FROM silver.erp_cust_az12
GROUP BY cid
HAVING COUNT(*) > 1 OR cid IS NULL;

-- Check birth date before current date
SELECT * FROM silver.erp_cust_az12
WHERE bdate > CURRENT_DATE;

-- Data Standardization & Consistency
SELECT DISTINCT gen,
    CASE 
        WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN  'Female'
        WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN  'Male'
        ELSE 'N/A'
    END AS gen
FROM silver.erp_cust_az12;

/*
============================
Checking erp_LOC_A101
============================
*/
-- Data Standardization & Consistency
SELECT DISTINCT cntry FROM silver.erp_loc_a101;