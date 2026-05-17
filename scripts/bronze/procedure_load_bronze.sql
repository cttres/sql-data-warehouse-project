/*
=============================================================
Stored Procedure: Load Bronze Tables Data
=============================================================
Script Purpose:
	• This script uses BULK INSERT to insert data from .csv files
	into it's corresponding table from the 'bronze' schema. 
	• It first TRUNCATES the table and then inserts the data from the specific file path.
	• Additionally, displays the loading stages, each step it takes,
	and also the loading time of each table and the loading as a whole.
Parameters:
	This stored procedure does NOT accept any parameters nor return any values.
Usage Example:
	EXEC bronze.load_bronze;
Warning:
	This script will TRUNCATE the tables and delete all the data
	permanently before inserting the data in the .csv files.
*/


-- BULK INSERT data into bronze tables STORED PROCEDURE
CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @bronze_layer_start_time DATETIME, @bronze_layer_end_time DATETIME;
	BEGIN TRY

		SET @bronze_layer_start_time = GETDATE();
		
		PRINT '=======================================';
		PRINT 'Loading Bronze Layer';
		PRINT '=======================================';

		PRINT '---------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '---------------------------------------';

		-- 1st crm BULK INSERT
		SET @start_time = GETDATE();
		PRINT '>> TRUNCATING Table: bronze.crm_cust_info';
		TRUNCATE TABLE bronze.crm_cust_info;
		PRINT '>> BULK INSERT Table: bronze.crm_cust_info';
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Users\Carlos\Documents\SQL Bootcamp\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Loading Time: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' seconds';
		PRINT '-------------------------------------------';

		-- 2nd crm BULK INSERT
		SET @start_time = GETDATE();
		PRINT '>> TRUNCATING Table: bronze.crm_prd_info';
		TRUNCATE TABLE bronze.crm_prd_info;
		PRINT '>> BULK INSERT Table: bronze.crm_prd_info';
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\Users\Carlos\Documents\SQL Bootcamp\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Loading Time: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' seconds';
		PRINT '-------------------------------------------';

		-- 3rd crm BULK INSERT
		SET @start_time = GETDATE();
		PRINT '>> TRUNCATING Table: bronze.crm_sales_details';
		TRUNCATE TABLE bronze.crm_sales_details;
		PRINT '>> BULK INSERT Table: bronze.crm_sales_details';
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\Carlos\Documents\SQL Bootcamp\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Loading Time: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' seconds';
		PRINT '-------------------------------------------';

		PRINT '---------------------------------------';
		PRINT 'Loading ERP Tables';
		PRINT '---------------------------------------';

		-- 1st erp BULK INSERT
		SET @start_time = GETDATE();
		PRINT '>> TRUNCATING Table: bronze.erp_cust_az12';
		TRUNCATE TABLE bronze.erp_cust_az12;
		PRINT '>> BULK INSERT Table: bronze.erp_cust_az12';
		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\Users\Carlos\Documents\SQL Bootcamp\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Loading Time: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' seconds';
		PRINT '-------------------------------------------';

		-- 2nd erp BULK INSERT
		SET @start_time = GETDATE();
		PRINT '>> TRUNCATING Table: bronze.erp_loc_a101';
		TRUNCATE TABLE bronze.erp_loc_a101;
		PRINT '>> BULK INSERT Table: bronze.erp_loc_a101'
		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\Users\Carlos\Documents\SQL Bootcamp\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Loading Time: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' seconds';
		PRINT '-------------------------------------------';

		-- 3rd erp BLOCK INSERT
		SET @start_time = GETDATE();
		PRINT '>> TRUNCATING Table: bronze.erp_px_cat_g1v2';
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;
		PRINT '>> BULK INSERT Table: bronze.erp_px_cat_g1v2'
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\Users\Carlos\Documents\SQL Bootcamp\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Loading Time: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' seconds';
		PRINT '-------------------------------------------';

		SET @bronze_layer_end_time = GETDATE();
		PRINT '=======================================';
		PRINT '>> Bronze Layer Loading Time: ' + CAST(DATEDIFF(second, @bronze_layer_start_time, @bronze_layer_end_time) AS VARCHAR) + ' seconds';
		PRINT '=======================================';

	END TRY
	BEGIN CATCH
		PRINT '======================================';
		PRINT 'Error Message: ' + ERROR_MESSAGE();
		PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR);
		PRINT 'Error State: ' + CAST(ERROR_STATE() AS VARCHAR);
		PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR);
		PRINT '======================================';
	END CATCH
END;
