with orders as (

    select distinct
        order_id,
        customer_id,
        product_id,
        cast(order_date as date) as order_date,
        cast(quantity as integer) as order_quantity

    from {{ source('raw_case_study', 'orders') }}

)

select * from orders