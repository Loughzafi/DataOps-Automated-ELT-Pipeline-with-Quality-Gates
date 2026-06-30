select
    user_id,
    lower(trim(email)) as email,
    trim(full_name) as full_name,
    upper(country_code) as country_code,
    created_at,
    updated_at
from {{ source('raw_data', 'users_raw') }}
