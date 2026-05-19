# Data Catalog — Gold Layer

## Overview
The Gold Layer is the business-level data representation, structured to support analytical and reporting use cases. It consists of dimension tables and a fact table built around specific business metrics.

---

## Data Model — Star Schema

![Sales Data Mart — Star Schema](.docs/data_mart.png)

---

## 1. gold.dim_customers
**Purpose:** Stores customer details enriched with demographic and geographic data.

| Column Name | Data Type | Description |
|---|---|---|
| `customer_key` | `INT` | Surrogate key uniquely identifying each customer record in the dimension table. |
| `customer_id` | `INT` | Unique numerical identifier assigned to each customer. |
| `customer_number` | `NVARCHAR(50)` | Alphanumeric identifier representing the customer, used for tracking and referencing (e.g., `'AW00010001'`). |
| `first_name` | `VARCHAR(25)` | The customer's first name as recorded in the system (e.g., `'John'`). |
| `last_name` | `VARCHAR(25)` | The customer's last name or family name (e.g., `'Smith'`). |
| `country` | `VARCHAR(50)` | The country of residence for the customer (e.g., `'Australia'`). |
| `marital_status` | `VARCHAR(25)` | The marital status of the customer (e.g., `'Married'`, `'Single'`). |
| `gender` | `VARCHAR(25)` | The gender of the customer (e.g., `'Male'`, `'Female'`, `'n/a'`). |
| `birthdate` | `DATE` | The date of birth of the customer, formatted as YYYY-MM-DD (e.g., `1971-10-06`). |
| `create_date` | `DATE` | The date when the customer record was created in the system (e.g., `2021-03-22`). |

---

## 2. gold.dim_products
**Purpose:** Provides information about the products and their attributes.

| Column Name | Data Type | Description |
|---|---|---|
| `product_key` | `INT` | Surrogate key uniquely identifying each product record in the product dimension table. |
| `product_id` | `INT` | A unique identifier assigned to the product for internal tracking and referencing. |
| `product_number` | `NVARCHAR(50)` | A structured alphanumeric code representing the product, often used for categorization or inventory (e.g., `'BK-R50B-44'`). |
| `product_name` | `NVARCHAR(100)` | Descriptive name of the product, including key details such as type, color, and size (e.g., `'Road-650 Black, 44'`). |
| `category_id` | `NVARCHAR(25)` | A unique identifier for the product's category, linking to its high-level classification. |
| `category` | `VARCHAR(50)` | The broader classification of the product (e.g., `'Bikes'`, `'Components'`). |
| `subcategory` | `VARCHAR(50)` | A more detailed classification of the product within its category (e.g., `'Road Bikes'`, `'Helmets'`). |
| `maintenance` | `VARCHAR(3)` | Indicates whether the product requires maintenance (e.g., `'Yes'`, `'No'`). |
| `cost` | `INT` | The cost or base price of the product, measured in whole monetary units (e.g., `250`). |
| `product_line` | `VARCHAR(25)` | The specific product line or series to which the product belongs (e.g., `'Road'`, `'Mountain'`). |
| `start_date` | `DATE` | The date when the product became available or the current version became effective, formatted as YYYY-MM-DD (e.g., `2021-01-01`). |

---

## 3. gold.fact_sales
**Purpose:** Stores transactional sales data for analytical purposes.

| Column Name | Data Type | Description |
|---|---|---|
| `order_number` | `NVARCHAR(50)` | A unique alphanumeric identifier for each sales order (e.g., `'SO54496'`). |
| `product_key` | `INT` | Surrogate key linking the order line to the product dimension table (`gold.dim_products`). |
| `customer_key` | `INT` | Surrogate key linking the order line to the customer dimension table (`gold.dim_customers`). |
| `order_date` | `DATE` | The date when the order was placed (e.g., `2023-01-15`). |
| `shipping_date` | `DATE` | The date when the order was shipped to the customer (e.g., `2023-01-18`). |
| `due_date` | `DATE` | The date when the order was due for delivery (e.g., `2023-01-25`). |
| `sales_amount` | `INT` | The total monetary value of the sale for the line item, in whole currency units (e.g., `3578`). |
| `quantity` | `INT` | The number of units of the product ordered for the line item (e.g., `1`). |
| `price` | `INT` | The price per unit of the product for the line item, in whole currency units (e.g., `3578`). |
