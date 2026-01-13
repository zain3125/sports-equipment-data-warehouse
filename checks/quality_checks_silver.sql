-- Check id duplicates and NULL id's
select cst_id, count(*) from silver.crm_cust_info
GROUP BY cst_id
HAVING count(*) > 1 OR cst_id IS NULL;

-- Check spaces before OR after name
select cst_firstname, cst_lastname from silver.crm_cust_info
where cst_firstname != TRIM(cst_firstname)
or cst_lastname != TRIM(cst_lastname);

-- Check values of marital_status
select cst_marital_status
FROM silver.crm_cust_info
GROUP BY cst_marital_status;

-- Check values of gndr
select cst_gndr
FROM silver.crm_cust_info
GROUP BY cst_gndr;

select * from silver.crm_cust_info;
