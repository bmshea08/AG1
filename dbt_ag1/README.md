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
name: 'dbt_ag1'
version: '1.0'
config-version: 2

profile: 'dbt_ag1'

macro-paths: ["macros"]

models:
  AG1:
    raw:
      +schema: raw_case_study
    staging:
      +schema: staging_case_study
    marts:
      +schema: analytics
```

### 4. Using `generate_schema_name.sql` Macro
- Implemented the `generate_schema_name.sql` macro to dynamically assign schemas based on model paths:
    - Raw data is loaded into the `raw_case_study` schema.
    - Staged data transformations go into the `staging_case_study` schema.
    - Final models (fact and dimension tables) are loaded into the `analytics` schema.

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
    - Seed files were normalized and loaded into the `raw_case_study` schema within Snowflake using the `dbt seed` command.

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
    - Detailed information on models, including column descriptions and relationships, was documented to make it easier for stakeholders to understand the data structure.

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

Here’s an updated section for the `README.md` that includes the analytical queries based on the fact table, as well as descriptions of what each query achieves.

---

### Analytical Queries

The following are SQL queries that can be run on top of the fact and dimension tables to gain valuable insights from the data.

1. **Average Reorder in Days by Product**  
   This query calculates the average number of days between reorders for each product by analyzing order dates.

    ```sql
    WITH reorder_cte AS (
        SELECT
            customers.Customer_ID,
            products.Product_ID,
            sales.Order_Date,
            LEAD(sales.Order_Date) OVER (PARTITION BY customers.Customer_ID, products.Product_ID ORDER BY sales.Order_Date) AS Next_Order_Date
        FROM ag1.analytics.fact_sales sales 
        JOIN ag1.analytics.dim_customers customers
            ON customers.Customer_SK = sales.Customer_SK
        JOIN ag1.analytics.dim_products products 
            ON products.Product_SK = sales.Product_SK
    )
    -- Filter out any rows where there's no next order 
    SELECT
        r.Product_ID,
        AVG(DATEDIFF('day', r.Order_Date, r.Next_Order_Date)) AS avg_reorder_days
    FROM reorder_cte r
    WHERE r.Next_Order_Date IS NOT NULL
    GROUP BY r.Product_ID
    ORDER BY avg_reorder_days ASC;
    ```

2. **Identify Top Selling Products**  
   This query identifies the top-selling products by total revenue and total quantity sold, giving an insight into which products are performing best.

    ```sql
    SELECT 
        Product_ID, 
        SUM(Revenue) AS Total_Revenue, 
        SUM(Order_Quantity) AS Total_Quantity_Sold 
    FROM ag1.analytics.fact_sales sales 
    JOIN ag1.analytics.dim_products product 
        ON product.Product_SK = sales.Product_SK
    GROUP BY Product_ID 
    ORDER BY Total_Revenue DESC 
    LIMIT 10;
    ```

3. **Profit Analysis by Product**  
   This query calculates the total revenue and profit for each product, grouped by coffee type and roast type, helping to understand product profitability.

    ```sql
    SELECT 
        product.Product_ID, 
        product.Coffee_Type, 
        product.Roast_Type, 
        SUM(sales.Revenue) AS Total_Revenue, 
        SUM(sales.Order_Quantity) AS Total_Quantity, 
        SUM(sales.Order_Quantity * product.Profit) AS Total_Profit 
    FROM ag1.analytics.fact_sales sales 
    JOIN ag1.analytics.dim_products product 
        ON sales.Product_SK = product.Product_SK
    GROUP BY product.Product_ID, product.Coffee_Type, product.Roast_Type 
    ORDER BY Total_Profit DESC;
    ```

4. **Total Purchases by Customer**  
   This query returns the total number of purchases each customer has made, allowing for customer engagement and loyalty analysis.

    ```sql
    SELECT 
        Customer_ID, 
        COUNT(Order_ID) AS Total_Purchases 
    FROM ag1.analytics.fact_sales sales 
    JOIN ag1.analytics.dim_customers customers
        ON customers.Customer_SK = sales.Customer_SK
    GROUP BY Customer_ID
    ORDER BY Total_Purchases DESC;
    ```

5. **Average Order Value by Customer**  
   This query calculates the average order value for each customer, which is helpful in identifying high-value customers.

    ```sql
    SELECT 
        Customer_ID, 
        AVG(Revenue) AS Average_Order_Value 
    FROM ag1.analytics.fact_sales sales 
    JOIN ag1.analytics.dim_customers customers
        ON customers.Customer_SK = sales.Customer_SK
    GROUP BY Customer_ID
    ORDER BY Average_Order_Value DESC;
    ```

---

## Other Considerations

This project was built to demonstrate the capabilities of dbt for data modeling, transformation, and analysis. Given the simplicity of the dataset, there are a few considerations that should be taken into account:

1. **Surrogate Keys (SKs) vs. Natural Keys**  
   In this project, I chose to use Surrogate Keys (SKs) for fact and dimension tables, which is a common best practice in data warehousing. However, considering that the data is static and provided from a single source (the Excel sheet), using the natural keys, such as `Customer_ID` or `Product_ID`, would have been equally sufficient. This would simplify the model by reducing unnecessary fields and transformations.

2. **Data Source Complexity**  
   The dataset provided is relatively small and comes from a single source, meaning that many of the typical complexities of data integration (such as dealing with multiple systems or sources with varying formats) are not present. In a real-world scenario, data would likely be pulled from multiple disparate systems, necessitating additional steps like deduplication, conflict resolution, and data enrichment.

3. **Static Nature of Data**  
   Since the data in this case study is static and does not change over time, features such as incremental models, slowly changing dimensions (SCDs) or tracking changes in customer or product attributes are not implemented here. In a dynamic, real-world e-commerce environment, these features would be critical to maintain accurate and up-to-date analytics.

4. **Performance Considerations**  
   For small datasets like the one used in this project, performance issues related to queries and transformations are minimal. However, in a production environment where data volume is much larger, performance tuning might be required. This could involve optimizing SQL queries, adding appropriate indexes, partitioning large tables, and ensuring that queries are run efficiently to avoid bottlenecks.

5. **Business Logic Enhancements**  
   While the current queries provide useful insights for basic customer engagement, product optimization, and inventory management, additional business logic might be required to cater to more complex requirements. For example, incorporating customer segmentation, time-based trend analysis, or more advanced predictive analytics would add further value.

---

These considerations highlight the flexibility and scalability of dbt as a tool, as well as the potential adjustments needed when working with more complex, real-world datasets. While the provided data was relatively simple, the methodologies and best practices applied here can be extended to larger, more complex projects.

## Conclusion

This project provides a robust, scalable, and maintainable data pipeline that integrates multiple data sources, performs data transformation and modeling, and generates business insights to solve the core challenges of customer engagement, product optimization, and inventory management.

For any further details or clarifications, feel free to reach out.

--- 
