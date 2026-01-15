/*
========================
Checking crm_cust_info
========================
*/

-- Check id duplicates and NULL id's
select cst_id, count(*) from silver.crm_cust_info
GROUP BY cst_id
HAVING count(*) > 1 OR cst_id IS NULL;

-- Check spaces before OR after name
select cst_firstname, cst_lastname from silver.crm_cust_info
where cst_firstname != TRIM(cst_firstname)
or cst_lastname != TRIM(cst_lastname);

-- Data Standardization & Consistency
select cst_marital_status
FROM silver.crm_cust_info
GROUP BY cst_marital_status;

-- Data Standardization & Consistency
select cst_gndr
FROM silver.crm_cust_info
GROUP BY cst_gndr;

/*
========================
Checking crm_prd_info
========================
*/

-- Check prd_id duplicates and NULL prd_id's
select prd_id, count(*) from silver.crm_prd_info
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
select * from silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;
