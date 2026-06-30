# Portfolio Evidence Checklist

Use this checklist to assemble a complete project walkthrough package.

## 1. Screenshots
- [ ] Airflow DAG graph view for daily_dbt_pipeline
- [ ] Airflow successful run with dbt_run, dbt_test, and quality_gate_row_counts
- [ ] dbt build summary showing all models/tests passed
- [ ] Metabase dashboard with at least one KPI tile and one trend chart
- [ ] Docker compose service status showing postgres, airflow, and metabase healthy

## 2. Key Metrics
- [ ] Model count (staging + marts)
- [ ] Test count and pass rate
- [ ] DAG run duration for latest successful run
- [ ] Source freshness result (warn/error thresholds)
- [ ] Fact table row count and latest updated_at watermark

## 3. Architecture Summary
- [ ] One-paragraph problem statement and business value
- [ ] Component overview: PostgreSQL, dbt, Airflow, Metabase, GitHub Actions
- [ ] Data flow summary: raw_data -> staging -> marts -> BI
- [ ] Quality gate summary: dbt tests + post-build row-count gate + CI build gate
- [ ] Reliability features: retries, timeout, optional webhook alerts

## 4. Demo Script (5-10 minutes)
- [ ] Start with architecture and repository layout
- [ ] Trigger manual DAG run and show task progression
- [ ] Show successful dbt test evidence
- [ ] Validate final mart outputs with SQL row counts
- [ ] End with CI workflow and next roadmap items

## 5. Publish Package
- [ ] README updated with runbook and outcomes
- [ ] Add 3-5 screenshots under docs/images
- [ ] Include command transcript snippets for reproducibility
- [ ] Add short lessons learned section
