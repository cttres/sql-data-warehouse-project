/*
==========================================================================
DDL Script: Create Silver Layer Tables
==========================================================================
 Script Purpose:
	Creates or recreates the tables in the 'silver' schema.
	Existing silver tables are dropped first, then recreated.
Notes:
	- Use this script to redefine silver table structure.
	- Table data is lost when existing tables are dropped.
*/


-- Create CRM silver Tables

IF OBJECT_ID('silver.crm_cust_info', 'U') IS NOT NULL
	DROP TABLE silver.crm_cust_info;
CREATE TABLE silver.crm_cust_info (
	cst_id INT,
	cst_key NVARCHAR(50),
	cst_firstname VARCHAR(25),
	cst_lastname VARCHAR(25),
	cst_marital_status VARCHAR(25),
	cst_gndr VARCHAR(25),
	cst_create_date DATE,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
); 
GO

IF OBJECT_ID('silver.crm_prd_info', 'U') IS NOT NULL
	DROP TABLE silver.crm_prd_info;
CREATE TABLE silver.crm_prd_info (
	prd_id INT,
	cat_id NVARCHAR(25),
	prd_key NVARCHAR(50),
	prd_nm NVARCHAR(100),
	prd_cost INT,
	prd_line VARCHAR(25),
	prd_start_dt DATE,
	prd_end_dt DATE,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
); 
GO

IF OBJECT_ID('silver.crm_sales_details', 'U') IS NOT NULL
	DROP TABLE silver.crm_sales_details;
CREATE TABLE silver.crm_sales_details (
	sls_ord_num NVARCHAR(50),
	sls_prd_key NVARCHAR(50),
	sls_cust_id INT,
	sls_order_dt DATE,
	sls_ship_dt DATE,
	sls_due_dt DATE,
	sls_sales INT,
	sls_quantity INT,
	sls_price INT,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
); 
GO

-- Create ERP bronze Tables

IF OBJECT_ID('silver.erp_cust_az12', 'U') IS NOT NULL
	DROP TABLE silver.erp_cust_az12;
CREATE TABLE silver.erp_cust_az12 (
	cid NVARCHAR(50),
	bdate DATE,
	gen VARCHAR(25),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID('silver.erp_loc_a101', 'U') IS NOT NULL
	DROP TABLE silver.erp_loc_a101;
CREATE TABLE silver.erp_loc_a101 (
	cid NVARCHAR(50),
	cntry VARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
); 
GO

IF OBJECT_ID('silver.erp_px_cat_g1v2', 'U') IS NOT NULL
	DROP TABLE silver.erp_px_cat_g1v2;
CREATE TABLE silver.erp_px_cat_g1v2 (
	id NVARCHAR(25),
	cat VARCHAR(50),
	subcat VARCHAR(50),
	maintenance VARCHAR(3) CHECK(maintenance IN('Yes', 'No')),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
); 
GO
