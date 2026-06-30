import json
import os
from datetime import datetime, timedelta
from urllib import request

from airflow import DAG
from airflow.operators.bash import BashOperator


def notify_on_failure(context):
    """Send an optional webhook alert when a task fails."""
    webhook_url = os.getenv("AIRFLOW_ALERT_WEBHOOK")
    if not webhook_url:
        return

    payload = {
        "text": (
            f"Airflow task failed: dag={context['dag'].dag_id}, "
            f"task={context['task_instance'].task_id}, "
            f"run_id={context.get('run_id', 'unknown')}"
        )
    }

    try:
        req = request.Request(
            webhook_url,
            data=json.dumps(payload).encode("utf-8"),
            headers={"Content-Type": "application/json"},
        )
        request.urlopen(req, timeout=10)
    except Exception as exc:
        print(f"Failure alert webhook error: {exc}")


default_args = {
    "owner": "dataops",
    "depends_on_past": False,
    "retries": 2,
    "retry_delay": timedelta(minutes=5),
    "on_failure_callback": notify_on_failure,
}

with DAG(
    dag_id="daily_dbt_pipeline",
    start_date=datetime(2026, 1, 1),
    schedule="0 2 * * *",
    catchup=False,
    default_args=default_args,
    dagrun_timeout=timedelta(minutes=45),
    tags=["dataops", "dbt"],
) as dag:
    dbt_run = BashOperator(
        task_id="dbt_run",
        bash_command="cd /opt/airflow/dbt && dbt run --target prod",
        execution_timeout=timedelta(minutes=20),
    )

    dbt_test = BashOperator(
        task_id="dbt_test",
        bash_command="cd /opt/airflow/dbt && dbt test --target prod",
        execution_timeout=timedelta(minutes=20),
    )

    quality_gate_row_counts = BashOperator(
        task_id="quality_gate_row_counts",
        bash_command=r'''python - <<'PY'
import os
import psycopg2

conn = psycopg2.connect(
    host=os.getenv("DBT_HOST", "postgres"),
    port=int(os.getenv("DBT_PORT", "5432")),
    user=os.getenv("DBT_USER", "dataops"),
    password=os.environ["DBT_PASSWORD"],
    dbname=os.getenv("DBT_DBNAME", "postgres"),
)

checks = {
    "analytics_prod.dim_users": 1,
    "analytics_prod.fct_orders": 1,
}

with conn, conn.cursor() as cur:
    for table_name, min_rows in checks.items():
        cur.execute(f"SELECT COUNT(*) FROM {table_name};")
        row_count = cur.fetchone()[0]
        print(f"{table_name} row_count={row_count}")
        if row_count < min_rows:
            raise SystemExit(
                f"Quality gate failed: {table_name} has {row_count} rows (< {min_rows})"
            )

print("Quality gate passed.")
PY''',
        execution_timeout=timedelta(minutes=5),
    )

    dbt_run >> dbt_test >> quality_gate_row_counts
