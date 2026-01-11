/*
=================================
Create tables for the bronz layer
=================================
Script Purpose:
    This script creates a new Tables after checking if it already exists. 
    If the Table exists, it is dropped and recreated. Additionally
	
WARNING:
    Running this script will drop the entire Tables if it exists. 
    Proceed with caution and ensure you have proper backups before running this script.

*/
-- CRM tables schema
DROP TABLE IF EXISTS bronz.crm_cust_info;
CREATE TABLE bronz.crm_cust_info(
	cst_id INT,
	cst_key VARCHAR(20),
	cst_firstname VARCHAR(50),
	cst_lastname VARCHAR(50),
	cst_marital_status CHAR(1),
	cst_gndr CHAR(1),
	cst_create_date DATE
);

DROP TABLE IF EXISTS bronz.crm_prd_info;
CREATE TABLE bronz.crm_prd_info(
	prd_id INT,
	prd_key VARCHAR(50),
	prd_nm VARCHAR(50),
	prd_cost INT,
	prd_line CHAR(1),
	prd_start_dt DATE,
	prd_end_dt DATE
);

DROP TABLE IF EXISTS bronz.crm_sales_details;
CREATE TABLE bronz.crm_sales_details(
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

-- ERP tables schema
DROP TABLE IF EXISTS bronz.erp_CUST_AZ12;
CREATE TABLE bronz.erp_CUST_AZ12(
CID VARCHAR(20),
BDATE DATE,
GEN VARCHAR(10)
);

DROP TABLE IF EXISTS bronz.erp_LOC_A101;
CREATE TABLE bronz.erp_LOC_A101(
CID VARCHAR(20),
CNTRY VARCHAR(50)
);

DROP TABLE IF EXISTS bronz.erp_PX_CAT_G1V2;
CREATE TABLE bronz.erp_PX_CAT_G1V2(
ID VARCHAR(20),
CAT VARCHAR(20),
SUBCAT VARCHAR(20),
MAINTENANCE VARCHAR(20)
);
