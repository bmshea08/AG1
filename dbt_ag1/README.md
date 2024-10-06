# E-Commerce Data Pipeline Project

## Overview

This project demonstrates how to build a scalable and maintainable data pipeline using dbt (data build tool) and Snowflake as the cloud data warehouse. The pipeline is designed to address key e-commerce business challenges such as customer engagement analysis, product optimization, and inventory management.

## Project Structure

- **`dbt_project.yml`**: Defines the project structure and configurations for dbt models, seeds, tests, and more.
- **`profiles.yml`**: Contains Snowflake connection settings, linking dbt to the Snowflake environment.
- **SQL Models**: Includes fact and dimension tables for sales, customers, and products.
- **Macros**: Utilized to generate schema names dynamically and manage Snowflake environments.
- **Seeds**: Three seed files loaded into Snowflake (orders, customers, and products).

## Steps Implemented

### 1. Setting up Snowflake
- Created a **Snowflake trial account**.
- Configured a **new database called `AG1`** to house the e-commerce data.
- Established necessary roles and permissions for managing the data warehouse.

### 2. Connecting dbt-core to Snowflake
- Set up **`profiles.yml`** to connect dbt to Snowflake:
    - Defined Snowflake credentials such as `account`, `user`, `password`, `database`, `warehouse`, and `role`.
    - Specified the `schema` parameter to ensure dbt loads data into the appropriate schema in Snowflake.

#### Sample `profiles.yml`:
```yaml
my_project:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: <your_snowflake_account>
      user: <your_username>
      password: <your_password>
      role: <your_role>
      warehouse: <your_warehouse>
      database: AG1
      schema: raw_data
      threads: 4
```

### 3. Setting up `dbt_project.yml`
- Created and configured **`dbt_project.yml`**:
    - This file defines the structure of the dbt project, including the model directories, version control, and naming conventions.
    - It also specifies the use of a macro for dynamic schema generation to ensure models are loaded into the correct schemas.

#### Sample `dbt_project.yml`:
```yaml
name: 'ecommerce_project'
version: '1.0'
config-version: 2

profile: 'my_project'

macro-paths: ["macros"]

models:
  ecommerce_project:
    raw:
      +schema: raw_data
    staging:
      +schema: staging_data
    marts:
      +schema: marts
```

### 4. Using `generate_schema_name.sql` Macro
- Implemented the `generate_schema_name.sql` macro to dynamically assign schemas based on model paths:
    - Raw data is loaded into the `raw_data` schema.
    - Staged data transformations go into the `staging_data` schema.
    - Final models (fact and dimension tables) are loaded into the `marts` schema.

#### Sample Macro (in `macros/generate_schema_name.sql`):
```sql
{% macro generate_schema_name(custom_schema_name, node) %}
    {%- if custom_schema_name is none -%}
        {{ default_schema }}
    {%- else -%}
        {{ custom_schema_name }}
    {%- endif -%}
{% endmacro %}
```

### 5. Data Loading & Normalization
- Loaded data from three CSV tabs (`orders`, `customers`, `products`) into dbt seed files:
    - Seed files were normalized and loaded into the `raw_data` schema within Snowflake using the `dbt seed` command.

### 6. Data Modeling
- Designed a star schema:
    - **Fact Table: `fact_sales`**: Captures sales transactions (e.g., order_id, product_id, customer_id, sale_date, quantity, revenue).
    - **Dimension Tables**:
        - `dim_customers`: Contains attributes like customer name, contact details, and loyalty card status.
        - `dim_products`: Stores product-related attributes such as product category, roast type, size, and pricing details.

### 7. Data Validation
- Implemented schema tests using `dbt test` to ensure the data conforms to expected formats and integrity.
    - **Schema Tests**: Validate columns like `Customer_ID`, `Product_ID`, and `Order_ID` for uniqueness and not null values.
    - **Custom SQL Tests**: Additional validation was applied for data quality, such as ensuring valid price ranges for products.

### 8. Documentation
- Generated dbt documentation for the project using `dbt docs generate`:
    - Detailed information on each model, including column descriptions and relationships, was documented to make it easier for stakeholders to understand the data structure.

### 9. CI/CD Setup
- Established a simple CI/CD process for the project:
    - Each change to the models or configuration files triggers a dbt run and test in a continuous integration pipeline to ensure data consistency before deployment to production.

## Project Commands

- **Run dbt seeds**:
  ```bash
  dbt seed
  ```

- **Run dbt models**:
  ```bash
  dbt run
  ```

- **Test dbt models**:
  ```bash
  dbt test
  ```

- **Generate docs**:
  ```bash
  dbt docs generate
  ```

## Conclusion

This project provides a robust, scalable, and maintainable data pipeline that integrates multiple data sources, performs data transformation and modeling, and generates business insights to solve the core challenges of customer engagement, product optimization, and inventory management.

For any further details or clarifications, feel free to reach out.

--- 

This README covers everything from project setup to execution. Let me know if you'd like to add any additional information!