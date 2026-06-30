# Project Charter V2

## Objective
Build a senior-level DataOps platform that enforces data quality before deployment and serves trusted analytics to BI.

## Scope Highlights
- PostgreSQL schemas: raw_data, analytics_dev, analytics_ci, analytics_prod
- dbt transformations and tests
- Airflow orchestration
- Metabase dashboards
- CI quality gates for pull requests

## Core Success Criteria
1. Failed PR on broken dbt quality tests.
2. Daily pipeline run succeeds and is idempotent.
3. Metabase dashboard reflects refined analytics tables.
4. Alerting triggers on pipeline failure.
