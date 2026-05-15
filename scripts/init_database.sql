/*
==========================================
Create Database and Scemas
==========================================
Script Purpose:
  This script creates a new database named 'DataWarehouseProject' after checking if it already exists.
  If the database exists it is droped and recreated. Additionally, the script sets up three schemas
  within the database: 'bronze', 'silver', and 'gold'.

Warning:
  Running this script will drop the entire 'DataWarehouseProject' database if it exists.
  All the data in the database will be permanently deleted. Proceed with caution and
  ensure you have proper backups before running the script.
*/

-- Create Database
USE master;
GO

-- Drop and recreate DataWarehouseProject DB
IF EXISTS(SELECT 1 FROM sys.databases WHERE name = 'DataWarehouseProject')
BEGIN
	ALTER DATABASE DataWarehouseProject SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWarehouseProject;

END;
GO

-- Create DataWarehouseProject
CREATE DATABASE DataWarehouseProject;
GO

-- Change to the created DB
USE DataWarehouseProject;
GO

-- Create bronze, silver, and gold schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
