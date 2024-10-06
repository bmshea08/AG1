/*
Dimension table for products. With the current dataset provided the SK genaration may be a bit overkill since the 
product_id is already unique. I have included it in this sample data regardless. Many times products can come from
different upstream sources and product_id could have some overlap which would make an SK more valuable. In that situation
we would also need to modify the SK generation to include additional fields.
*/

select  {{ dbt_utils.generate_surrogate_key(['product_id']) }} as product_sk,
    product_id,
    coffee_type,
    roast_type,
    size,
    unit_price,
    price_per_110g,
    profit
from {{ ref('stg_case_study__products') }}