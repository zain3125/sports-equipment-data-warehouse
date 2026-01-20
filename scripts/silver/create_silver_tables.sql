/*
=================================
Create tables for the silver layer
=================================
Script Purpose:
    This script creates a new Tables -created dwh_create_ts For Debugging purposes-
    after checking if it already exists. 
    If the Table exists, it is dropped and recreated. Additionally
	
WARNING:
    Running this script will drop the entire Tables if it exists. 
    Proceed with caution and ensure you have proper backups before running this script.

*/
-- CRM tables schema
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

-- ERP tables schema
DROP TABLE IF EXISTS silver.erp_CUST_AZ12;
CREATE TABLE silver.erp_CUST_AZ12(
    cid VARCHAR(20),
    bdate DATE,
    gen VARCHAR(10),
    dwh_create_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS silver.erp_LOC_A101;
CREATE TABLE silver.erp_LOC_A101(
    cid VARCHAR(20),
    cntry VARCHAR(50),
    dwh_create_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS silver.erp_PX_CAT_G1V2;
CREATE TABLE silver.erp_PX_CAT_G1V2(
    id VARCHAR(20),
    cat VARCHAR(20),
    subcat VARCHAR(20),
    maintenance VARCHAR(20),
    dwh_create_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
