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

````md id="g6y3qn"
## B1 — Date Coverage Validation

### Objective
This query was used to validate the actual date coverage and row volume available within the selected GA4 sample window before starting downstream transformations and KPI modeling.

The primary goal of this step was to confirm that:

- the selected date filter was functioning correctly
- event data existed across the full expected time range
- the sample window contained sufficient data volume for profiling and exploratory analysis

---

## Query

```sql
-- Validate GA4 sample window coverage

SELECT
    MIN(PARSE_DATE('%Y%m%d', event_date)) AS min_date,
    MAX(PARSE_DATE('%Y%m%d', event_date)) AS max_date,
    COUNT(*) AS total_rows

FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`

WHERE _TABLE_SUFFIX BETWEEN '20210101' AND '20210131';
````

---

## Query Result

| min_date   | max_date   | total_rows |
| ---------- | ---------- | ---------- |
| 2021-01-01 | 2021-01-31 | 1,210,147  |

---

## Key Observations

### 1. Date Coverage Successfully Validated

The returned minimum and maximum dates matched the expected sample window boundaries:

* minimum date: `2021-01-01`
* maximum date: `2021-01-31`

This confirms that the wildcard table filter and `_TABLE_SUFFIX` condition correctly captured the full January 2021 event range.

---

### 2. Sample Window Contains Sufficient Data Volume

The query returned more than 1.2 million rows within the selected one-month window.

This indicates that:

* the dataset contains high-volume behavioral tracking data
* the selected sample period is sufficiently large for exploratory analysis and KPI prototyping
* downstream aggregations and transformations can be tested on realistic event-scale data

---

### 3. Initial Scalability Consideration

Even a restricted one-month sample produced over one million records.

This highlights the importance of:

* partition filtering
* selective querying
* avoiding unnecessary `SELECT *` operations during large-scale analysis

These practices are critical for controlling query cost and improving performance in cloud data warehouse environments.

---

### 4. Event Data is Stored at High Granularity

The large row count relative to a one-month window suggests highly granular event-level tracking.

This is consistent with GA4’s event-driven architecture, where:

* each user interaction generates separate events
* nested event parameters increase row complexity
* behavioral tracking produces significantly larger datasets than traditional transactional systems

---

## Analytical Implications

Based on this validation step, the dataset appears suitable for:

* session-level analysis
* acquisition analysis
* engagement KPI development
* behavioral funnel analysis
* ecommerce event tracking
* user segmentation analysis

---
![GA4 Date Coverage](screenshots/ga4_date_coverage.png)


```
```
````md id="l6m2vd"
## B1-b — Global Dataset Date Coverage Validation

### Objective
This query was used to validate the full historical date coverage available across the GA4 sample ecommerce dataset.

Unlike the previous sample-window validation step, this check scanned the entire dataset without applying a `_TABLE_SUFFIX` filter in order to identify the true analytical boundaries of the available event data.

This validation step helps determine:

- the earliest available event date
- the latest available event date
- the overall historical coverage period available for analysis

---

## Query

```sql
-- date coverage (global)

SELECT
    MIN(PARSE_DATE('%Y%m%d', event_date)) AS global_min_date,
    MAX(PARSE_DATE('%Y%m%d', event_date)) AS global_max_date

FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`;
````

---

## Query Result

| global_min_date | global_max_date |
| --------------- | --------------- |
| 2020-11-01      | 2021-01-31      |

---

## Query Result Screenshot

![GA4 Global Date Coverage](screenshots/ga4_global_date_coverage.png)

---

## Key Observations

### 1. Dataset Historical Coverage

The dataset contains event-level tracking data between:

* `2020-11-01`
* `2021-01-31`

This indicates that the publicly available GA4 ecommerce dataset provides approximately three months of historical behavioral tracking data.

---

### 2. Limited Long-Term Historical Depth

Because the dataset spans only a relatively short historical window, certain advanced analytical use cases may be limited, including:

* long-term seasonality analysis
* year-over-year comparisons
* mature cohort retention analysis
* long-horizon forecasting

This limitation should be considered during KPI interpretation and downstream reporting design.

---

### 3. Dataset is Suitable for Behavioral & KPI Prototyping

Despite the shorter historical range, the dataset still appears highly suitable for:

* acquisition analysis
* session-level behavior analysis
* engagement KPI modeling
* ecommerce event tracking
* funnel analysis
* dashboard prototyping
* transformation pipeline development

---

### 4. Full Dataset Scan Increased Processed Data Volume

Unlike the previous filtered sample-window query, this validation scanned the entire dataset and processed a larger amount of data.

This reinforces the importance of:

* partition-aware querying
* selective filtering
* query cost awareness

when working with cloud warehouse environments such as BigQuery.

---

## Analytical Implications

The dataset boundary validation confirmed that:

* the dataset is event-driven and behavior-focused
* historical coverage is relatively short-term
* the available time range is sufficient for exploratory analytics and KPI development
* future transformations should remain optimized for large-scale event data processing

---
![alt text](ga4_global_date_coverage.png)


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
