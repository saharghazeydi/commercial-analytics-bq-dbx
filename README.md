# Commercial Analytics – BigQuery & Databricks

🚧 Project Status: Work in Progress

## Objective
This project builds an end-to-end commercial analytics workflow to analyze business performance data and produce decision-ready insights.

The goal is to simulate a real analytics environment where data is ingested, transformed, and prepared for BI dashboards and business reporting.

## Tech Stack
- BigQuery
- Databricks
- SQL
- Python
- Power BI / Tableau (planned)

## Project Scope
The project focuses on building a structured analytics layer for commercial performance analysis, including revenue trends, customer behavior, and operational KPIs.

## Current Progress
- Data ingestion and initial dataset preparation
- SQL transformation layer for business metrics
- KPI table generation for reporting
- Data preparation for BI dashboards

## Planned Next Steps
- Additional KPI modeling
- BI dashboard development
- Insight documentation and business interpretation
- Final project documentation

## Example Analytical Questions
- How does revenue evolve over time?
- Which customer segments drive the most value?
- What are the key drivers of commercial performance?

## Repository Structure
- `/sql` – transformation queries and metric calculations
- `/notebooks` – exploratory analysis and experimentation
- `/data` – processed datasets used for analytics
- `/docs` – documentation and project notes

## Goal
Deliver a portfolio-ready analytics case study demonstrating SQL-based analytics workflows and BI-ready data modeling.
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
