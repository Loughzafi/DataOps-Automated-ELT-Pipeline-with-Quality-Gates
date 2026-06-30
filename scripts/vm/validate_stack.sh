#!/usr/bin/env bash
set -euo pipefail

echo "Checking container status..."
docker compose ps

echo "Checking PostgreSQL schemas..."
docker exec -i dataops-postgres psql -U dataops -d postgres -c "SELECT schema_name FROM information_schema.schemata WHERE schema_name IN ('raw_data','analytics_dev','analytics_ci','analytics_prod','airflow_meta') ORDER BY schema_name;"

echo "Checking Airflow health endpoint..."
curl -fsS http://localhost:8080/health || true

echo "Stack validation checks completed."
