select
    user_id,
    email,
    full_name,
    country_code,
    created_at,
    updated_at
from {{ ref('stg_users') }}
