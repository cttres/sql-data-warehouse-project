/* 
==========================================================================
DDL Script: Create Bronze Layer Tables
==========================================================================
Script Purpose:
	• This script is to create the tables of the 'bronze' schema.
	• Drops existing tables if they already exists.
	• Run this script to redefine the DDL structure of the 'bronze' tables.
Warning:
	This script will drop the entire table and delete its data permanently.
*/


-- Create CRM bronze Tables

IF OBJECT_ID('bronze.crm_cust_info', 'U') IS NOT NULL
	DROP TABLE bronze.crm_cust_info;
CREATE TABLE bronze.crm_cust_info (
	cst_id INT,
	cst_key NVARCHAR(50),
	cst_firstname VARCHAR(25),
	cst_lastname VARCHAR(25),
	cst_marital_status VARCHAR(1) CHECK(cst_marital_status IN('M', 'S')),
	cst_gndr VARCHAR(1) CHECK(cst_gndr IN('M', 'F')),
	cst_create_date DATE,
	--CONSTRAINT pk_crm_cust_info PRIMARY KEY (cst_id)
); 
GO

IF OBJECT_ID('bronze.crm_prd_info', 'U') IS NOT NULL
	DROP TABLE bronze.crm_prd_info;
CREATE TABLE bronze.crm_prd_info (
	prd_id INT,
	prd_key NVARCHAR(50),
	prd_nm NVARCHAR(100),
	prd_cost INT,
	prd_line VARCHAR(25),
	prd_start_dt DATE,
	prd_end_dt DATE,
	--CONSTRAINT pk_crm_prd_info PRIMARY KEY (prd_id)
); 
GO

IF OBJECT_ID('bronze.crm_sales_details', 'U') IS NOT NULL
	DROP TABLE bronze.crm_sales_details;
CREATE TABLE bronze.crm_sales_details (
	sls_ord_num NVARCHAR(50),
	sls_prd_key NVARCHAR(50),
	sls_cust_id INT,
	sls_order_dt INT,
	sls_ship_dt INT,
	sls_due_dt INT,
	sls_sales INT,
	sls_quantity INT,
	sls_price INT,
	--CONSTRAINT pk_crm_sales_details PRIMARY KEY (sls_ord_num)
); 
GO

-- Create ERP bronze Tables

IF OBJECT_ID('bronze.erp_cust_az12', 'U') IS NOT NULL
	DROP TABLE bronze.erp_cust_az12;
CREATE TABLE bronze.erp_cust_az12 (
	cid NVARCHAR(50),
	bdate DATE,
	gen VARCHAR(25),
	--CONSTRAINT pk_erp_cust_az12 PRIMARY KEY (cid)
);

IF OBJECT_ID('bronze.erp_loc_a101', 'U') IS NOT NULL
	DROP TABLE bronze.erp_loc_a101;
CREATE TABLE bronze.erp_loc_a101 (
	cid NVARCHAR(50),
	cntry VARCHAR(50),
	--CONSTRAINT pk_erp_loc_a101 PRIMARY KEY (cid)
); 
GO

IF OBJECT_ID('bronze.erp_px_cat_g1v2', 'U') IS NOT NULL
	DROP TABLE bronze.erp_px_cat_g1v2;
CREATE TABLE bronze.erp_px_cat_g1v2 (
	id NVARCHAR(25),
	cat VARCHAR(50),
	subcat VARCHAR(50),
	maintenance VARCHAR(3) CHECK(maintenance IN('Yes', 'No')),
	--CONSTRAINT pk_erp_px_cat_g1v2 PRIMARY KEY (id)
); 
GO
