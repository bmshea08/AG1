/*
Dimension table for customers. With the current dataset provided the SK genaration may be a bit overkill since the 
customer_id is already unique. I have included it in this sample data regardless. Many times customers can come from
different upstream sources and customer_id could have some overlap which would make an SK more valuable. In that situation
we would also need to modify the SK generation to include additional fields.
*/

select {{ dbt_utils.generate_surrogate_key(['customer_id']) }} as customer_sk,
    customer_id,
    customer_first_name,
    customer_last_name,
    customer_full_name,
    email,
    phone_number,
    address_line_1,
    city,
    country,
    postal_code,
    loyalty_card
from {{ ref('stg_case_study__customers') }}