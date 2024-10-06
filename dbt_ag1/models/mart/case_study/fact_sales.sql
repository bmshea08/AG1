--fact table for sales
select {{ dbt_utils.generate_surrogate_key(['orders.order_id','orders.customer_id','orders.product_id']) }} as sales_sk,
    customer_sk,
    product_sk,
    order_id,
    order_date,
    sum(order_quantity) as order_quantity,
    sum(order_quantity * unit_price) as revenue
from {{ ref('stg_case_study__orders') }} orders 
left join {{ ref('dim_customers') }} customers
    on customers.customer_id = orders.customer_id
left join {{ ref('dim_products')}} products 
    on products.product_id = orders.product_id
group by sales_sk, 
    customer_sk,
    product_sk,
    order_id,
    order_date