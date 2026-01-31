-- Check for duplicates of products Key in gold.dim_products
SELECT product_number, COUNT(*)
    FROM gold.dim_products
GROUP BY product_number
HAVING COUNT(*) > 1;

-- Check for duplicates of customers Key in gold.dim_customers
SELECT
    customer_id, COUNT(*)
FROM gold.dim_customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- Check data integration for gold.dim_customers
SELECT DISTINCT
    ci.cst_gndr,
    ca.gen,
    CASE
        WHEN ci.cst_gndr != 'N/A' THEN ci.cst_gndr --CRM is the Master 
        ELSE COALESCE(ca.gen, 'N/A')
    END AS new_gen
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la ON ci.cst_key = la.cid
ORDER BY 1, 2;

-- Check the data model connectivity between facts and dimensions
SELECT *
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p ON p.product_key = f.product_key
LEFT JOIN gold.dim_customers c ON c.customer_key = f.customer_key
WHERE p.product_key IS NULL OR c.customer_key IS NULL
