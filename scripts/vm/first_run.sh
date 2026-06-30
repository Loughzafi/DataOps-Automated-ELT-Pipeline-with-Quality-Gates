#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

if [[ ! -f .env ]]; then
  cp .env.example .env
  echo "Created .env from .env.example"
fi

set -a
source .env
set +a

echo "Starting core services..."
docker compose up -d postgres

echo "Waiting for PostgreSQL to be ready..."
until docker exec dataops-postgres pg_isready -U "$POSTGRES_USER" -d "$POSTGRES_DB" >/dev/null 2>&1; do
  sleep 2
done

echo "Applying database initialization script..."
docker exec -i dataops-postgres psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" < infra/postgres/init.sql

echo "Starting Airflow and Metabase..."
docker compose up -d airflow-init airflow-webserver airflow-scheduler metabase

echo "Services are up."
echo "Metabase: http://localhost:3000"
echo "Airflow:  http://localhost:8080"
