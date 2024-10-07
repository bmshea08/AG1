WITH orders AS (

    SELECT DISTINCT
        order_id,
        customer_id,
        product_id,
        cast(order_date as date) AS order_date,
        cast(quantity as integer) AS order_quantity

    FROM {{ source('raw_case_study', 'orders') }}

)

SELECT * FROM orders