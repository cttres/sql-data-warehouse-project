/*
==========================================================================
Quality Checks: Silver Layer
==========================================================================
Purpose:
	Validate silver-layer data quality by checking normalization,
	whitespace issues, missing or duplicate values, date consistency,
	and data enrichment/derived value expectations.
Scope:
	Runs against silver tables and a small bronze reference check
	to verify the output of silver loading and transformation logic.
Notes:
	- Keep queries grouped by table so failing rows are easy to inspect.
Usage:
	Run in SQL Server Management Studio or a compatible query tool.
*/

-- =============================================================
-- Table: silver.crm_cust_info
-- =============================================================
-- Detect duplicate cst_id rows while showing the latest record per customer.
SELECT
	*,
	ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
FROM silver.crm_cust_info;

-- Find rows with leading/trailing whitespace in customer names.
SELECT
	*
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

SELECT
	*
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);

-- Review normalized categorical values for customer marital status and gender.
SELECT DISTINCT
	cst_marital_status
FROM silver.crm_cust_info;

SELECT DISTINCT
	cst_gndr
FROM silver.crm_cust_info;

-- Full table preview for crm_cust_info.
SELECT * FROM silver.crm_cust_info;

-- =============================================================
-- Table: silver.crm_prd_info
-- =============================================================
-- Check for duplicate product keys in the silver product table.
SELECT
	COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1;

-- Verify source product category ID length from the reference bronze table.
SELECT DISTINCT
	LEN(id) AS catalog_id_length
FROM bronze.erp_px_cat_g1v2;

-- Detect product names with unwanted whitespace.
SELECT
	*
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- Review normalized product line values.
SELECT DISTINCT
	prd_line
FROM silver.crm_prd_info;

-- Identify inconsistent date intervals in product validity range.
SELECT
	*
FROM silver.crm_prd_info
WHERE prd_start_dt > prd_end_dt;

-- Full table preview for crm_prd_info.
SELECT * FROM silver.crm_prd_info;

-- =============================================================
-- Table: silver.crm_sales_details
-- =============================================================
-- Check order date formatting issues in sales details.
SELECT
	sls_cust_id,
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt
FROM silver.crm_sales_details
WHERE LEN(sls_order_dt) != 8;

-- Review sales rows with missing or non-positive sales values.
SELECT
	*
FROM silver.crm_sales_details
WHERE sls_sales IS NULL OR sls_sales <= 0;

-- Full table preview for crm_sales_details.
SELECT * FROM silver.crm_sales_details;

-- =============================================================
-- Table: silver.erp_cust_az12
-- =============================================================
-- Check for duplicate or missing customer IDs.
SELECT
	COUNT(*)
FROM silver.erp_cust_az12
GROUP BY cid
HAVING COUNT(*) > 1;

-- Review normalized gender values in the ERP customer table.
SELECT DISTINCT
	gen
FROM silver.erp_cust_az12;

-- Detect rows missing the customer identifier.
SELECT
	*
FROM silver.erp_cust_az12
WHERE cid IS NULL;

-- =============================================================
-- Table: silver.erp_loc_a101
-- =============================================================
-- Check for duplicate location IDs and inspect country values.
SELECT
	COUNT(*)
FROM silver.erp_loc_a101
GROUP BY cid
HAVING COUNT(*) > 1;

SELECT DISTINCT
	cntry
FROM silver.erp_loc_a101;

-- =============================================================
-- Table: silver.erp_px_cat_g1v2
-- =============================================================
-- Check for duplicate or missing category IDs and review maintenance codes.
SELECT
	COUNT(*)
FROM silver.erp_px_cat_g1v2
GROUP BY id
HAVING COUNT(*) > 1 OR id IS NULL;

SELECT DISTINCT
	maintenance
FROM silver.erp_px_cat_g1v2;
