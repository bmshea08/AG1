--fact table for sales
SELECT {{ dbt_utils.generate_surrogate_key(['orders.order_id','orders.customer_id','orders.product_id']) }} AS sales_sk,
    customer_sk,
    product_sk,
    order_id,
    order_date,
    SUM(order_quantity) as order_quantity,
    SUM(order_quantity * unit_price) as revenue
FROM {{ ref('stg_case_study__orders') }} orders 
LEFT JOIN {{ ref('dim_customers') }} customers
    ON customers.customer_id = orders.customer_id
LEFT JOIN {{ ref('dim_products')}} products 
    ON products.product_id = orders.product_id
GROUP BY sales_sk, 
    customer_sk,
    product_sk,
    order_id,
    order_date