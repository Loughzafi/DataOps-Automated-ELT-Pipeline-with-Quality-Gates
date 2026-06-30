# Run Results Proof Log

This document captures command and output evidence for the successful end-to-end execution of the Automated ELT Pipeline with Quality Gates.

## Environment
- Host: Ubuntu VM on VMware
- Orchestration: Docker Compose
- Scheduler: Apache Airflow (LocalExecutor)
- Transform/Test: dbt Core + dbt-postgres
- Warehouse: PostgreSQL 16

## Evidence Timestamp
- Date: 2026-06-30 (UTC)
- Primary successful run_id: manual__2026-06-30T18:35:54+00:00

## 1. Trigger and Capture Run ID
Command:
```bash
cd ~/projects/'DataOps - Automated ELT Pipeline with Quality Gates'

docker compose exec -T airflow-scheduler airflow dags trigger daily_dbt_pipeline

RUN_ID=$(docker compose exec -T airflow-scheduler airflow dags list-runs -d daily_dbt_pipeline --no-backfill | awk -F'|' '/manual__/{gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2; exit}')

echo "$RUN_ID"
```

Observed output snippet:
```text
manual__2026-06-30T18:35:54+00:00
```

## 2. Task-Level State Evidence
Command:
```bash
docker compose exec -T airflow-scheduler airflow tasks states-for-dag-run daily_dbt_pipeline "$RUN_ID"
```

Observed output:
```text
dag_id             | execution_date            | task_id  | state   | start_date                       | end_date
===================+===========================+==========+=========+==================================+=================================
daily_dbt_pipeline | 2026-06-30T18:35:54+00:00 | dbt_run  | success | 2026-06-30T18:35:55.585137+00:00 | 2026-06-30T18:36:07.077778+00:00
daily_dbt_pipeline | 2026-06-30T18:35:54+00:00 | dbt_test | success | 2026-06-30T18:36:08.185440+00:00 | 2026-06-30T18:36:18.976071+00:00
```

## 3. DAG Run History Evidence
Command:
```bash
docker compose exec -T airflow-scheduler airflow dags list-runs -d daily_dbt_pipeline --no-backfill | head -n 20
```

Observed output:
```text
dag_id             | run_id                                   | state   | execution_date                   | start_date                       | end_date
===================+==========================================+=========+==================================+==================================+=================================
daily_dbt_pipeline | manual__2026-06-30T18:35:54+00:00        | success | 2026-06-30T18:35:54+00:00        | 2026-06-30T18:35:54.992224+00:00 | 2026-06-30T18:36:19.800143+00:00
daily_dbt_pipeline | manual__2026-06-30T18:25:28.516265+00:00 | success | 2026-06-30T18:25:28.516265+00:00 | 2026-06-30T18:25:28.703975+00:00 | 2026-06-30T18:25:51.774082+00:00
daily_dbt_pipeline | manual__2026-06-30T18:07:36+00:00        | success | 2026-06-30T18:07:36+00:00        | 2026-06-30T18:07:37.074598+00:00 | 2026-06-30T18:08:01.372671+00:00
daily_dbt_pipeline | scheduled__2026-06-29T02:00:00+00:00     | success | 2026-06-29T02:00:00+00:00        | 2026-06-30T18:07:22.719606+00:00 | 2026-06-30T18:07:47.815559+00:00
```

## Interview Summary
- Manual and scheduled runs are succeeding in Airflow.
- Core pipeline tasks are succeeding (dbt_run and dbt_test).
- Run history shows repeatable successful executions.
- End-to-end orchestration is stable after metadata/search_path and DAG hardening updates.

## Re-run Verification Commands
```bash
cd ~/projects/'DataOps - Automated ELT Pipeline with Quality Gates'
docker compose exec -T airflow-scheduler airflow dags trigger daily_dbt_pipeline
RUN_ID=$(docker compose exec -T airflow-scheduler airflow dags list-runs -d daily_dbt_pipeline --no-backfill | awk -F'|' '/manual__/{gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2; exit}')
docker compose exec -T airflow-scheduler airflow tasks states-for-dag-run daily_dbt_pipeline "$RUN_ID"
docker compose exec -T airflow-scheduler airflow dags list-runs -d daily_dbt_pipeline --no-backfill | head -n 20
```
