# Automated ELT Pipeline with Quality Gates

Senior DataOps portfolio project that demonstrates:
- ELT with PostgreSQL + dbt
- Data quality enforcement with dbt tests
- Orchestration with Airflow
- BI consumption with Metabase
- CI quality gates on pull requests

## Stack
- PostgreSQL
- dbt Core
- Apache Airflow (LocalExecutor)
- Metabase
- GitHub Actions (optional Jenkins extension)

## Repository Layout
- infra/: local infrastructure definitions
- dbt/: transformation project
- scripts/: setup and helper scripts
- docs/: charter, roadmap, runbooks
- .github/workflows/: CI pipelines

## Day 0 Quick Start (Ubuntu VM)
1. Clone the project in Ubuntu and enter the repository folder.
2. Make VM helper scripts executable:
   - chmod +x scripts/vm/bootstrap_ubuntu.sh scripts/vm/first_run.sh scripts/vm/validate_stack.sh
3. Install base dependencies and Docker:
   - ./scripts/vm/bootstrap_ubuntu.sh
4. Re-login to apply Docker group membership, then continue in project folder.
5. Create your environment file:
   - cp .env.example .env
6. Set a real Airflow fernet key in .env:
   - AIRFLOW_FERNET_KEY can be generated with: python3 -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"
7. Set secure secrets in .env before first run:
   - POSTGRES_PASSWORD
   - DBT_PASSWORD
   - AIRFLOW_ADMIN_PASSWORD
   - AIRFLOW_WEBSERVER_SECRET_KEY
8. Start the full local stack:
   - ./scripts/vm/first_run.sh
9. Validate the stack:
   - ./scripts/vm/validate_stack.sh

## Service Endpoints
- Metabase: http://localhost:3000
- Airflow: http://localhost:8080
  - default username from .env: AIRFLOW_ADMIN_USER
  - default password from .env: AIRFLOW_ADMIN_PASSWORD

## Airflow Runbook
Trigger and verify a manual run from the VM:

```bash
cd ~/projects/'DataOps - Automated ELT Pipeline with Quality Gates'

docker compose exec -T airflow-scheduler airflow dags trigger daily_dbt_pipeline

RUN_ID=$(docker compose exec -T airflow-scheduler airflow dags list-runs -d daily_dbt_pipeline --no-backfill | awk -F'|' '/manual__/{gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2; exit}')

echo "$RUN_ID"

docker compose exec -T airflow-scheduler airflow tasks states-for-dag-run daily_dbt_pipeline "$RUN_ID"
docker compose exec -T airflow-scheduler airflow dags list-runs -d daily_dbt_pipeline --no-backfill | head -n 20
```

Expected success criteria:
- dbt_run = success
- dbt_test = success
- quality_gate_row_counts = success
- DAG run state = success

## Troubleshooting (Airflow CLI)
- Placeholder run IDs fail in shell commands:
   - Do not use angle brackets like `<new_run_id>` because bash treats them as redirection.
   - Use the real run ID value, for example `manual__2026-06-30T18:35:54+00:00`.
- `airflow tasks logs` command not found:
   - In this Airflow version, `tasks logs` is not a valid subcommand.
   - Use `airflow tasks state` and `airflow tasks states-for-dag-run`, or read logs from `/opt/airflow/logs/...`.
- DAG appears stuck in `queued` right after trigger:
   - This is often normal for a short period while scheduler picks up tasks.
   - Re-run `airflow tasks states-for-dag-run` after a few seconds.
- `Ooops!` in UI or trigger traceback for metadata/log template:
   - Ensure Airflow DB connection resolves `airflow_meta` schema via search path.
   - Recreate `airflow-webserver` and `airflow-scheduler` containers after compose updates.

## Results (Latest Verified Run)
- Latest manual run:
   - run_id: `manual__2026-06-30T18:35:54+00:00`
   - state: `success`
- Task outcomes:
   - `dbt_run`: success
   - `dbt_test`: success
- Historical evidence:
   - Multiple manual runs completed successfully.
   - The previously problematic scheduled run (`scheduled__2026-06-29T02:00:00+00:00`) also completed successfully.
- Operational outcome:
   - Airflow orchestration, dbt execution, and quality gates are running end-to-end.

## Notes
- Airflow is configured with LocalExecutor.
- dbt profile is checked in at dbt/profiles.yml and uses environment variables.
- Local compose ports are bound to localhost only for safer host exposure.
- CI requires GitHub Actions secret CI_DBT_PASSWORD.
- PostgreSQL schemas created on initialization:
  - raw_data
  - analytics_dev
  - analytics_ci
  - analytics_prod
  - airflow_meta

## CI Secrets Setup
Configure this repository secret before running the dbt CI workflow:

1. In GitHub, open repository Settings -> Secrets and variables -> Actions.
2. Click New repository secret.
3. Name: CI_DBT_PASSWORD
4. Value: strong password used by CI Postgres service.
5. Save and rerun the workflow.

Security notes:
- Never commit this value to files, logs, or PR comments.
- Rotate the secret if it is ever exposed.

## Week 1 Objective
Bring up PostgreSQL and Metabase, create raw and analytics schemas, and seed deterministic sample data.

## Portfolio Evidence
Use the checklist in docs/portfolio-evidence-checklist.md to capture screenshots, metrics, and architecture summary for project presentation.
Use docs/images/README.md for a suggested screenshot naming scaffold.
Use docs/run-results.md for a command-and-output proof log you can reference during interviews and demos.
