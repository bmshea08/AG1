WITH customers AS (

    SELECT DISTINCT
        customer_id,
        -- Extract the first name by getting the substring before the first space
        substring(customer_name, 1, position(' ' in customer_name) - 1) AS customer_first_name,
        -- Extract the last name by getting everything after the first space
        trim(substring(customer_name, position(' ' in customer_name) + 1)) AS customer_last_name,
        customer_name as customer_full_name,
        email,
        phone_number,
        address_line_1,
        city,
        country,
        postcode as postal_code,
        loyalty_card

    FROM {{ source('raw_case_study', 'customers') }}

)

SELECT * FROM customers