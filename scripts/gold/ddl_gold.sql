/*
==========================================================================
DDL Script: Create Gold Layer Views
==========================================================================
Purpose:
	Creates or recreates gold-layer views and the fact_sales view from
	silver tables with customer, product, and sales enrichment.
Scope:
	- gold.dim_customers
	- gold.dim_products
	- gold.fact_sales
Notes:
	- Existing views are dropped and recreated for a clean gold build.
	- This script defines presentation-layer views, not physical tables.
Usage:
	Execute this script to refresh the gold layer view definitions.
*/

-- CREATE CUSTOMER'S DIMENSION
IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
	DROP VIEW gold.dim_customers;
GO
CREATE VIEW gold.dim_customers AS
	SELECT
		ROW_NUMBER() OVER(ORDER BY ci.cst_id) AS customer_key,
		ci.cst_id AS customer_id,
		ci.cst_key AS customer_number,
		ci.cst_firstname AS first_name,
		ci.cst_lastname AS last_name,
		ea.cntry AS country,
		ci.cst_marital_status AS marital_status,
		CASE
			WHEN ci.cst_gndr = 'n/a' THEN ISNULL(ca.gen, 'n/a') -- CRM gender is the MASTER gender
			ELSE ci.cst_gndr
		END AS gender,
		ca.bdate AS birthdate,
		ci.cst_create_date AS create_date
	FROM silver.crm_cust_info AS ci
	LEFT JOIN silver.erp_cust_az12 AS ca
	ON ci.cst_key = ca.cid
	LEFT JOIN silver.erp_loc_a101 AS ea
	ON ci.cst_key = ea.cid
	WHERE ci.cst_id IS NOT NULL;
GO

-- CREATE PRODUCT'S DIMENSION
IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
	DROP VIEW gold.dim_products;
GO
CREATE VIEW gold.dim_products AS
	SELECT
		ROW_NUMBER() OVER(ORDER BY pri.prd_start_dt, pri.prd_key) AS product_key,
		pri.prd_id AS product_id,
		pri.prd_key AS product_number,
		pri.prd_nm AS product_name,
		pri.cat_id AS category_id,
		pc.cat AS category,
		pc.subcat AS subcategory,
		pc.maintenance,
		pri.prd_cost AS cost,
		pri.prd_line AS product_line,
		pri.prd_start_dt AS start_date
	FROM silver.crm_prd_info AS pri
	LEFT JOIN silver.erp_px_cat_g1v2 AS pc
	ON pri.cat_id = pc.id
	WHERE pri.prd_end_dt IS NULL; -- only current product price records are kept for the gold product dimension
GO

-- CREATE SALES' FACT TABLE
IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
	DROP VIEW gold.fact_sales;
GO
CREATE VIEW gold.fact_sales AS
	SELECT
		sd.sls_ord_num AS order_number,
		dp.product_key,
		dc.customer_key,
		sd.sls_order_dt AS order_date,
		sd.sls_ship_dt AS shipping_date,
		sd.sls_due_dt AS due_date,
		sd.sls_sales AS sales_amount,
		sd.sls_quantity AS quantity,
		sd.sls_price AS price
	FROM silver.crm_sales_details AS sd
	LEFT JOIN gold.dim_customers AS dc
	ON sd.sls_cust_id = dc.customer_id
	LEFT JOIN gold.dim_products AS dp
	ON sd.sls_prd_key = dp.product_number;
GO
