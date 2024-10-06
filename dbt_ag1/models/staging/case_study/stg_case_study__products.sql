with products as (

    select distinct
        product_id,
        coffee_type,
        roast_type,
        size,
        cast(unit_price as decimal(18,2)) as unit_price,
        cast(price_per_100g as decimal(18,2)) as price_per_110g,
        cast(profit as decimal(18,2)) as profit

    from {{ source('raw_case_study', 'products') }}

)

select * from products