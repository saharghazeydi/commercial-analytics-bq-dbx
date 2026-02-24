# Commercial Analytics (GA4 BigQuery + Olist)

## Business Goal
Build a reproducible analytics warehouse (staging → marts) for acquisition + conversion KPIs using GA4 public export and Olist datasets.

## Stack
BigQuery (SQL), Python (optional), GitHub, (later: Databricks, Tableau)

## Data Sources
- GA4 Sample Ecommerce (BigQuery public dataset)
- Olist Brazilian E-commerce (Kaggle)
- Olist Marketing Funnel (Kaggle)

## Repo Structure
- sql/ga4: GA4 staging + facts
- sql/olist: Olist staging
- sql/marts: star schema + KPI marts
- docs: data dictionary + assumptions + readouts