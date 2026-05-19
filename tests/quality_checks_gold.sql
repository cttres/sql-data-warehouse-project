/*
==========================================================================
Quality Checks: Gold Layer
==========================================================================
Purpose:
	Validate gold-layer views for customer, product, and sales accuracy.
	Checks include duplicate keys, lookup enrichment consistency, and foreign key joins.
Scope:
	- gold.dim_customers
	- gold.dim_products
	- gold.fact_sales
Notes:
	- Use it after building or refreshing the gold layer views.
*/

-- ================================
-- VIEW Check: gold.dim_customers
-- ================================

SELECT DISTINCT
	ci.cst_gndr,
	ca.gen,
	CASE
		WHEN ci.cst_gndr = 'n/a' THEN ISNULL(ca.gen, 'n/a')
		ELSE ci.cst_gndr
	END AS cst_gndr
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca
ON ci.cst_key = ca.cid
ORDER BY 1, 2;
-- Check VIEW: gold.dim_customers
SELECT * FROM gold.dim_customers;

-- ================================
-- VIEW Check: gold.dim_products
-- ================================

-- Check VIEW: gold.dim_products
SELECT * FROM gold.dim_products;
SELECT product_id, COUNT(*) FROM gold.dim_products GROUP BY product_id HAVING COUNT(*) > 1;

-- ================================
-- VIEW Check: gold.fact_sales
-- ================================

SELECT
	sls_ord_num,
	COUNT(*)
FROM silver.crm_sales_details
GROUP BY sls_ord_num
HAVING COUNT(*) > 1;

-- Check VIEW: gold.fact_sales
SELECT * FROM gold.fact_sales;
-- Check Foreign Key Integrity (JOIN with Dimension)
SELECT
	*
FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_customers AS dc
ON fs.customer_key = dc.customer_key
LEFT JOIN gold.dim_products AS dp
ON fs.product_key = dp.product_key;
