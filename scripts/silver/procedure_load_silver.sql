/*
=============================================================
Stored Procedure: silver.load_silver
=============================================================
Script Purpose:
	Creates or alters the stored procedure that refreshes the
	'silver' schema from bronze source tables with cleansing.
	Each silver table is truncated and reloaded with cleaned rows.
Notes:
	- No parameters are accepted.
	- The procedure prints per-table and total load times.
	- Existing silver data is permanently removed before reload.
Usage:
	EXEC silver.load_silver;
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @silver_layer_start_time DATETIME, @silver_layer_end_time DATETIME;

	BEGIN TRY
		
		SET @silver_layer_start_time = GETDATE();

		PRINT '===========================================';
		PRINT 'Loading Silver Layer';
		PRINT '===========================================';

		PRINT '-------------------------------------------';
		PRINT 'Cleansing and Loading CRM Tables';
		PRINT '-------------------------------------------';
		-- Insert and Data Cleansing of silver.crm_cust_info table
		SET @start_time = GETDATE();
		PRINT '>> TRUNCATING Table: silver.crm_cust_info';
		TRUNCATE TABLE silver.crm_cust_info;
		PRINT '>> LOADING Table: silver.crm_cust_info';
		INSERT INTO silver.crm_cust_info (cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date)
			SELECT
				cst_id,
				cst_key,
				TRIM(cst_firstname) AS cst_firstname,
				TRIM(cst_lastname) AS cst_lastname,
				CASE 
					WHEN UPPER(cst_marital_status) = 'S' THEN 'Single'
					WHEN UPPER(cst_marital_status) = 'M' THEN 'Married'
					ELSE 'n/a'
				END AS cst_marital_status,
				CASE 
					WHEN UPPER(cst_gndr) = 'M' THEN 'Male'
					WHEN UPPER(cst_gndr) = 'F' THEN 'Female'
					ELSE 'n/a'
				END AS cst_gndr,
				cst_create_date
			FROM (
				SELECT
					*,
					ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
				FROM bronze.crm_cust_info ) AS t
			WHERE flag_last = 1; -- keep only the latest record for each customer

		SET @end_time = GETDATE();
		PRINT '>> Loading Time: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' seconds';
		PRINT '---------------------------------------------------------';

		-- Insert and Data Cleansing of silver.crm_prd_info table
		SET @start_time = GETDATE();
		PRINT '>> TRUNCATING Table: silver.crm_prd_info';
		TRUNCATE TABLE silver.crm_prd_info;
		PRINT '>> LOADING Table: silver.crm_prd_info';
		INSERT INTO silver.crm_prd_info (prd_id, cat_id, prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt)
			SELECT
				prd_id,
				REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
				SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
				prd_nm,
				COALESCE(prd_cost, 0) AS prd_cost,
				CASE UPPER(prd_line)
					WHEN 'M' THEN 'Mountain'
					WHEN 'R' THEN 'Road'
					WHEN 'T' THEN 'Trail'
					WHEN 'S' THEN 'Other Sales'
					ELSE 'n/a'
				END AS prd_line,
				CAST(prd_start_dt AS DATE) AS prd_start_dt,
				CAST(LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt) - 1 AS DATE) AS prd_end_dt
			FROM bronze.crm_prd_info; -- split product key into category and normalized product key

		SET @end_time = GETDATE();
		PRINT '>> Loading Time: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' seconds';
		PRINT '---------------------------------------------------------';

		-- Insert and Data Cleansing of silver.crm_sales_details table
		SET @start_time = GETDATE();
		PRINT '>> TRUNCATING Table: silver.crm_sales_details';
		TRUNCATE TABLE silver.crm_sales_details;
		PRINT '>> LOADING Table: silver.crm_sales_details';
		INSERT INTO silver.crm_sales_details (sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt,sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price)
			SELECT 
				sls_ord_num,
				sls_prd_key,
				sls_cust_id,
				CASE 
					WHEN LEN(sls_order_dt) != 8 OR sls_order_dt = 0 THEN NULL
					ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
				END AS sls_order_dt,
				CASE 
					WHEN LEN(sls_ship_dt) != 8 OR sls_ship_dt = 0 THEN NULL
					ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
				END AS sls_ship_dt,
				CASE 
					WHEN LEN(sls_due_dt) != 8 OR sls_due_dt = 0 THEN NULL
					ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
				END AS sls_due_dt,
				CASE
					WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != ABS(sls_price) * sls_quantity THEN ABS(sls_price) * sls_quantity
					ELSE sls_sales
				END AS sls_sales,
				sls_quantity,
				CASE
					WHEN sls_price IS NULL OR sls_price <= 0 THEN sls_sales * NULLIF(sls_quantity, 0)
					ELSE sls_price
				END AS sls_price
			FROM bronze.crm_sales_details;
		SET @end_time = GETDATE();
		PRINT '>> Loading Time: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' seconds';
		PRINT '---------------------------------------------------------';

		PRINT '-------------------------------------------';
		PRINT 'Cleansing and Loading ERP Tables';
		PRINT '-------------------------------------------';
		-- Insert and Data Cleansing of silver.erp_cust_az12 table
		SET @start_time = GETDATE();
		PRINT '>> TRUNCATING Table: silver.erp_cust_az12';
		TRUNCATE TABLE silver.erp_cust_az12;
		PRINT '>> LOADING Table: silver.erp_cust_az12';
		INSERT INTO silver.erp_cust_az12 (cid, bdate, gen)
			SELECT 
				CASE 
					WHEN LEN(cid) > 10 THEN SUBSTRING(cid, 4, LEN(cid))
					ELSE cid
				END AS cid,
				CASE 
					WHEN bdate > GETDATE() THEN NULL
					ELSE bdate
				END AS bdate,
				CASE
					WHEN UPPER(TRIM(gen)) IN('M', 'MALE') THEN 'Male'
					WHEN UPPER(TRIM(gen)) IN('F', 'FEMALE') THEN 'Female'
					ELSE 'n/a'
				END AS gen
			FROM bronze.erp_cust_az12;
		SET @end_time = GETDATE();
		PRINT '>> Loading Time: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' seconds';
		PRINT '---------------------------------------------------------';

		-- Insert and Data Cleansing of silver.erp_loc_a101 table
		SET @start_time = GETDATE();
		PRINT '>> TRUNCATING Table: silver.erp_loc_a101';
		TRUNCATE TABLE silver.erp_loc_a101;
		PRINT '>> LOADING Table: silver.erp_loc_a101';
		INSERT INTO silver.erp_loc_a101 (cid, cntry)
			SELECT 
				REPLACE(cid, '-', '') AS cid,
				CASE
					WHEN UPPER(TRIM(cntry)) = 'DE' THEN 'Germany'
					WHEN UPPER(TRIM(cntry)) IN('USA', 'US') THEN 'United States'
					WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
					ELSE cntry
				END AS cntry
			FROM bronze.erp_loc_a101;
		SET @end_time = GETDATE();
		PRINT '>> Loading Time: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' seconds';
		PRINT '---------------------------------------------------------';

		-- Insert and Data Cleansing of silver.erp_px_cat_g1v2 table
		SET @start_time = GETDATE();
		PRINT '>> TRUNCATING Table: silver.erp_px_cat_g1v2';
		TRUNCATE TABLE silver.erp_px_cat_g1v2;
		PRINT '>> LOADING Table: silver.erp_px_cat_g1v2';
		INSERT INTO silver.erp_px_cat_g1v2 (id, cat, subcat, maintenance)
			SELECT 
				id,
				cat,
				subcat,
				maintenance
			FROM bronze.erp_px_cat_g1v2;
		SET @end_time = GETDATE();
		PRINT '>> Loading Time: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' seconds';
		PRINT '---------------------------------------------------------';

		SET @silver_layer_end_time = GETDATE();
		PRINT '========================================';
		PRINT '>> Silver Layer Loading Time: ' + CAST(DATEDIFF(second, @silver_layer_start_time, @silver_layer_end_time) AS VARCHAR) + ' seconds';
		PRINT '========================================';

	END TRY
	BEGIN CATCH
		PRINT '================================================';
		PRINT 'Error Message: ' + ERROR_MESSAGE();
		PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR);
		PRINT 'Error State: ' + CAST(ERROR_STATE() AS VARCHAR);
		PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR);
		PRINT '================================================';
	END CATCH
END;
