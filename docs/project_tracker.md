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
- [X] Access GA4 public dataset
- [X] Explore events table
- [ ] sanity_check(01_data_profiling.sql structure)
- [ ] Create stg_ga4_events table
- [ ] Extract session-level data
- [ ] Extract purchase events
- [ ] Validate data (counts, nulls, date ranges)


````md
## GA4 Initial Data Inspection & Structure Validation

### Objective
The purpose of this initial query was to perform a structure sanity check on the GA4 ecommerce dataset before beginning transformation and KPI modeling work.  
A limited sample window (January 2021) was selected to reduce query cost and enable faster profiling of the dataset structure, event schema, and tracking implementation.

---

## Sample Query

```sql
-- A1) sample rows (structure sanity)

SELECT *
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20210101' AND '20210131'
LIMIT 10;
````

---

## Key Dataset Observations

### 1. Daily Partitioned Event Tables

The GA4 dataset is stored as daily event tables using the naming convention:

```text
events_YYYYMMDD
```

The wildcard table pattern (`events_*`) combined with `_TABLE_SUFFIX` filtering allows efficient querying of a limited date range without scanning the full dataset.

---

### 2. Event-Level Behavioral Tracking Structure

The dataset follows an event-driven behavioral analytics schema where each record represents user interaction events such as:

* `page_view`
* `scroll`

This indicates that the dataset is designed primarily for digital behavior and engagement analysis rather than transactional-only reporting.

---

### 3. Nested & Repeated Event Parameters

GA4 stores many event attributes inside nested key-value parameter structures:

* `event_params.key`
* `event_params.value.*`

Observed parameters included:

* `page_location`
* `page_title`
* `ga_session_id`
* `percent_scrolled`
* `engagement_time_msec`

This structure requires parameter extraction and flattening during downstream modeling.

---

### 4. Granularity Consideration

Initial inspection showed that multiple rows may belong to the same event due to repeated event parameter structures.

As a result:

* raw row counts should not be interpreted directly as unique events
* event aggregation logic will require careful handling during transformation

This is an important consideration for session and engagement KPI calculations.

---

### 5. Session Tracking Availability

The dataset contains session-level tracking fields including:

* `ga_session_id`
* `ga_session_number`
* `session_engaged`

These fields support future analysis related to:

* session volume
* engagement rate
* session-based conversion behavior

---

### 6. Anonymous User Identification

User tracking is primarily handled through:

```text
user_pseudo_id
```

while `user_id` is mostly null in the sampled records.

This suggests that the dataset mainly represents anonymous web analytics behavior rather than authenticated customer-level tracking.

---

### 7. Traffic Acquisition Data Availability

Traffic attribution fields were observed, including:

* `traffic_source.source`
* `traffic_source.medium`
* `traffic_source.name`

Examples observed:

* Google / Organic
* Referral traffic

This enables future acquisition and channel performance analysis.

---

### 8. Device & Geographic Segmentation

The dataset includes segmentation dimensions such as:

#### Device Data

* device category
* operating system
* browser

#### Geographic Data

* country
* region
* city

These fields support future behavioral segmentation and performance comparisons across devices and locations.

---

### 9. Ecommerce Fields Exist but are Event-Specific

Ecommerce-related columns such as:

* `purchase_revenue`
* `transaction_id`
* item-level fields

were mostly null within sampled behavioral events.

This indicates that ecommerce fields are populated only for relevant transactional events (e.g. purchases) and should not be expected across all event types.

---

## Initial Data Quality Notes

Several early-stage data quality observations were identified:

* some geographic fields contain `(not set)`
* ecommerce fields are sparsely populated outside transactional events
* `user_id` coverage appears limited
* nested parameter structures require flattening before analysis

These considerations will influence downstream transformation and KPI modeling logic.

---

## Candidate KPI Areas Identified

Based on the initial inspection, the following analytical domains appear feasible within the dataset:

| KPI Area      | Example Metrics                   |
| ------------- | --------------------------------- |
| Acquisition   | Users by source/medium            |
| Engagement    | Engaged sessions, scroll activity |
| Sessions      | Session volume, sessions per user |
| Ecommerce     | Revenue, transactions, AOV        |
| User Behavior | Page views, engagement depth      |
| Segmentation  | Device and geo performance        |

---


```
```



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
