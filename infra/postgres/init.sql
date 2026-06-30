-- Create logical schemas for environment separation.
CREATE SCHEMA IF NOT EXISTS raw_data;
CREATE SCHEMA IF NOT EXISTS analytics_dev;
CREATE SCHEMA IF NOT EXISTS analytics_ci;
CREATE SCHEMA IF NOT EXISTS analytics_prod;
CREATE SCHEMA IF NOT EXISTS airflow_meta;

-- Raw source tables.
CREATE TABLE IF NOT EXISTS raw_data.users_raw (
  user_id BIGINT PRIMARY KEY,
  email TEXT NOT NULL,
  full_name TEXT NOT NULL,
  country_code TEXT,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);

CREATE TABLE IF NOT EXISTS raw_data.orders_raw (
  order_id BIGINT PRIMARY KEY,
  user_id BIGINT NOT NULL,
  order_ts TIMESTAMP NOT NULL,
  order_status TEXT NOT NULL,
  amount NUMERIC(12,2) NOT NULL,
  currency TEXT NOT NULL,
  updated_at TIMESTAMP NOT NULL
);

-- Deterministic seed data for local testing.
INSERT INTO raw_data.users_raw (user_id, email, full_name, country_code, created_at, updated_at)
VALUES
  (1, 'alice@example.com', 'Alice Baker', 'US', '2026-01-01 10:00:00', '2026-01-01 10:00:00'),
  (2, 'bob@example.com', 'Bob Carter', 'GB', '2026-01-02 11:00:00', '2026-01-02 11:00:00'),
  (3, 'chloe@example.com', 'Chloe Diaz', 'DE', '2026-01-03 12:00:00', '2026-01-03 12:00:00')
ON CONFLICT (user_id) DO NOTHING;

INSERT INTO raw_data.orders_raw (order_id, user_id, order_ts, order_status, amount, currency, updated_at)
VALUES
  (1001, 1, '2026-01-10 09:15:00', 'completed', 120.50, 'USD', '2026-01-10 09:15:00'),
  (1002, 1, '2026-01-11 12:45:00', 'completed', 89.99, 'USD', '2026-01-11 12:45:00'),
  (1003, 2, '2026-01-12 18:30:00', 'cancelled', 49.99, 'GBP', '2026-01-12 18:30:00'),
  (1004, 3, '2026-01-13 14:05:00', 'completed', 220.00, 'EUR', '2026-01-13 14:05:00')
ON CONFLICT (order_id) DO NOTHING;
