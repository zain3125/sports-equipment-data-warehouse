CREATE OR REPLACE PROCEDURE gold.quality_checks_gold_layer()
LANGUAGE plpgsql
AS $$
DECLARE
    v_check_count INT;
BEGIN
    RAISE NOTICE '================================================';
    RAISE NOTICE 'Starting Gold Layer Quality Checks';
    RAISE NOTICE '================================================';

    -- ======================================================
    -- Check duplicates in dim_products
    -- ======================================================
    RAISE NOTICE '>> Checking dim_products duplicates...';

    SELECT COUNT(*)
    INTO v_check_count
    FROM (
        SELECT product_number
        FROM gold.dim_products
        GROUP BY product_number
        HAVING COUNT(*) > 1
    ) t;

    IF v_check_count > 0 THEN
        RAISE WARNING '   - Found % duplicate product numbers', v_check_count;
    ELSE
        RAISE NOTICE '   - No duplicate product numbers found';
    END IF;

    -- ======================================================
    -- Check duplicates in dim_customers
    -- ======================================================
    RAISE NOTICE '>> Checking dim_customers duplicates...';

    SELECT COUNT(*)
    INTO v_check_count
    FROM (
        SELECT customer_id
        FROM gold.dim_customers
        GROUP BY customer_id
        HAVING COUNT(*) > 1
    ) t;

    IF v_check_count > 0 THEN
        RAISE WARNING '   - Found % duplicate customer IDs', v_check_count;
    ELSE
        RAISE NOTICE '   - No duplicate customer IDs found';
    END IF;

    -- ======================================================
    -- Check data integration (customer gender mapping)
    -- ======================================================
    RAISE NOTICE '>> Checking customer gender integration...';

    SELECT COUNT(*)
    INTO v_check_count
    FROM (
        SELECT DISTINCT
            ci.cst_gndr,
            ca.gen,
            CASE
                WHEN ci.cst_gndr != 'N/A' THEN ci.cst_gndr
                ELSE COALESCE(ca.gen, 'N/A')
            END AS new_gen
        FROM silver.crm_cust_info ci
        LEFT JOIN silver.erp_cust_az12 ca ON ci.cst_key = ca.cid
        LEFT JOIN silver.erp_loc_a101 la ON ci.cst_key = la.cid
    ) t;

    RAISE NOTICE '   - Gender integration rows checked: %', v_check_count;

    -- ======================================================
    -- Check fact to dimension relationships
    -- ======================================================
    RAISE NOTICE '>> Checking fact_sales relationships...';

    SELECT COUNT(*)
    INTO v_check_count
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON p.product_key = f.product_key
    LEFT JOIN gold.dim_customers c
        ON c.customer_key = f.customer_key
    WHERE p.product_key IS NULL
       OR c.customer_key IS NULL;

    IF v_check_count > 0 THEN
        RAISE WARNING '   - Found % orphan fact records (missing dimensions)', v_check_count;
    ELSE
        RAISE NOTICE '   - All fact records are properly linked';
    END IF;

    RAISE NOTICE '================================================';
    RAISE NOTICE 'Gold Layer Quality Checks Completed';
    RAISE NOTICE '================================================';

EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'Error during Gold layer checks';
        RAISE WARNING 'Error message: %', SQLERRM;
        RAISE;
END;
$$;