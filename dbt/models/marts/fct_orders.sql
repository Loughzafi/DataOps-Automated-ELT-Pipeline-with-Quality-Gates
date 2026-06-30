{{
  config(
    materialized='incremental',
    unique_key='order_id',
    on_schema_change='sync_all_columns'
  )
}}

select
    o.order_id,
    o.user_id,
    u.email as user_email,
    o.order_ts,
    date_trunc('day', o.order_ts) as order_date,
    o.order_status,
    o.amount,
    o.currency,
    o.updated_at
from {{ ref('stg_orders') }} o
left join {{ ref('dim_users') }} u
    on o.user_id = u.user_id
{% if is_incremental() %}
where o.updated_at > (select coalesce(max(updated_at), '1900-01-01'::timestamp) from {{ this }})
{% endif %}
