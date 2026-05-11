# Project Tracker — Commercial Analytics

# Project Tracker — Commercial Analytics

## Current Phase

➡️ Phase 1A — GA4 BigQuery Staging

---

# Phase 0 — Repository & Environment Setup

## Completed

* [x] Created GitHub repository
* [x] Established initial project folder structure
* [x] Added README skeleton
* [x] Configured `.gitignore`
* [x] Added `requirements.txt`
* [x] Connected local Windows Bootcamp environment using `git clone`
* [x] Refactored documentation structure
* [x] Initialized project tracking workflow

---

## Current Repository Structure

```text
commercial-analytics-bq-dbx/
│
├── bi/
│   └── screenshots/
│       └── ga4/
│
├── data/
│   ├── processed/
│   └── raw/
│       └── olist/
│
├── docs/
│   ├── decisions_log.md
│   └── project_tracker.md
│
├── sql/
│   ├── ga4/
│   │   ├── 01_data_profiling.sql
│   │   ├── 02_stg_ga4_events.sql
│   │   └── 03_fact_sessions_daily.sql
│   │
│   └── marts/
│       ├── 01_dim_date.sql
│       ├── 02_dim_channel.sql
│       ├── 03_mart_channel_daily.sql
│       ├── 04_mart_executive_daily.sql
│       └── 05_mart_executive_enhanced.sql
│
├── .gitignore
├── README.md
└── requirements.txt
```

---



## Phase 1A — GA4 (BigQuery)
- [] Access GA4 public dataset
- [] Explore events table
- [ ] Create stg_ga4_events table
- [ ] Extract session-level data
- [ ] Extract purchase events
- [ ] Validate data (counts, nulls, date ranges)

---

## Phase 1B — Olist Ingestion
- [ ] Load CSVs into Databricks
- [ ] Clean data types
- [ ] Create staging tables in BigQuery

---

## Phase 2 — Data Quality
- [ ] Check duplicates
- [ ] Validate keys
- [ ] Handle null values
- [ ] Document data quality issues

---

## Phase 3 — Modeling
- [ ] Create dim_customer
- [ ] Create dim_date
- [ ] Create fact_orders
- [ ] Create fact_sessions

---

## Phase 4 — Integration
- [ ] Join Olist datasets
- [ ] Build channel_to_revenue logic
- [ ] Document assumptions

---

## Phase 5 — KPIs
- [ ] Define conversion rate
- [ ] Define AOV
- [ ] Define retention

---

## Phase 6 — Dashboard
- [ ] Build Executive dashboard
- [ ] Build Funnel dashboard
- [ ] Export screenshots

---

## Phase 7 — A/B Testing
- [ ] Define experiment
- [ ] Assign groups
- [ ] Calculate metrics
- [ ] Make decision (ship / no-ship)

---

## Phase 8 — Packaging
- [ ] Final README
- [ ] Add architecture diagram
- [ ] Add business recommendation
