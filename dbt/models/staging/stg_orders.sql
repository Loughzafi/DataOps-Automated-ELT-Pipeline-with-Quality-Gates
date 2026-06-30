select
    order_id,
    user_id,
    order_ts,
    lower(order_status) as order_status,
    amount,
    upper(currency) as currency,
    updated_at
from {{ source('raw_data', 'orders_raw') }}
