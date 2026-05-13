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
````md id="z8v1pt"
## C1 — Null Rate Validation for Core Tracking Identifiers

### Objective
This query was used to validate the completeness and reliability of core tracking identifiers within the January 2021 GA4 sample window.

The goal of this step was to identify whether any critical analytical fields contained missing values that could negatively impact:

- KPI calculations
- session-level analysis
- event sequencing
- user-level analysis
- downstream transformations

The validation focused specifically on foundational tracking fields required for reliable behavioral analytics.

---

## Query

```sql
-- C1) null rates for core identifiers (sample window)

SELECT
  COUNT(*) AS total_rows,

  SUM(CASE WHEN event_date IS NULL THEN 1 ELSE 0 END)
    AS null_event_date,

  SUM(CASE WHEN event_timestamp IS NULL THEN 1 ELSE 0 END)
    AS null_event_timestamp,

  SUM(CASE WHEN event_name IS NULL THEN 1 ELSE 0 END)
    AS null_event_name,

  SUM(CASE WHEN user_pseudo_id IS NULL THEN 1 ELSE 0 END)
    AS null_user_pseudo_id

FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`

WHERE _TABLE_SUFFIX BETWEEN '20210101' AND '20210131';
````

---

## Query Result

| total_rows | null_event_date | null_event_timestamp | null_event_name | null_user_pseudo_id |
| ---------- | --------------- | -------------------- | --------------- | ------------------- |
| 1,210,147  | 0               | 0                    | 0               | 0                   |

---

## Query Result Screenshot

![GA4 Null Rate Validation](screenshots/ga4_null_rates_core_fields.png)

---

## Key Observations

### 1. No Missing Values Detected in Core Tracking Fields

The validation confirmed that all selected core identifiers contained zero null values within the sampled dataset.

The following fields showed complete coverage:

* `event_date`
* `event_timestamp`
* `event_name`
* `user_pseudo_id`

This indicates strong structural consistency within the GA4 event tracking implementation.

---

### 2. Event Tracking Structure Appears Reliable

Because all core event identifiers are fully populated, the dataset appears suitable for:

* event-level aggregation
* session construction
* user-level behavioral analysis
* engagement KPI modeling
* time-series analysis

without requiring immediate remediation for missing foundational identifiers.

---

### 3. User-Level Behavioral Analysis is Feasible

The absence of null values in `user_pseudo_id` is particularly important because this field serves as the primary anonymous user identifier within the dataset.

This supports future analysis related to:

* user activity tracking
* session behavior
* engagement analysis
* acquisition analysis
* user segmentation

---

### 4. Timestamp Integrity Appears Consistent

The complete population of `event_timestamp` confirms that event sequencing and temporal analysis can be performed reliably.

This is critical for downstream analytical tasks such as:

* session ordering
* behavioral flow analysis
* funnel analysis
* event chronology validation

---

### 5. Tracking Implementation Appears Structurally Healthy

The absence of missing values across key event metadata suggests that the GA4 tracking implementation was configured consistently within the observed sample window.

At this stage, no major structural reliability issues were identified in the core behavioral tracking fields.

---

## Analytical Implications

The validation results indicate that the dataset is structurally reliable for downstream analytics engineering and KPI modeling workflows.

Specifically:

* core identifiers are complete
* user-level tracking is available
* event sequencing is reliable
* foundational event metadata is consistently populated

This reduces the likelihood of major data completeness issues during transformation and reporting phases.

---
![alt text](ga4_null_rates_core_fields.png)

```
```
````md id="j4x8pw"
## C2 — Approximate Duplicate Event Validation Using Proxy Key

### Objective
This query was used to identify potential duplicate event records within the January 2021 GA4 sample window.

Because the raw GA4 export does not provide a simple single-column event primary key, an approximate proxy key was constructed using a combination of:

- `user_pseudo_id`
- `event_timestamp`
- `event_name`

The purpose of this validation step was to evaluate whether multiple rows shared the same core event identity characteristics, which could indicate possible duplicate event records.

---

## Query

```sql
-- C2) Approximate duplicate event check using proxy key
-- Proxy key: user_pseudo_id + event_timestamp + event_name

WITH base AS (

  SELECT
    user_pseudo_id,
    event_timestamp,
    event_name

  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`

  WHERE _TABLE_SUFFIX BETWEEN '20210101' AND '20210131'

),

counts AS (

  SELECT

    COUNT(*) AS row_count,

    COUNT(DISTINCT CONCAT(
      user_pseudo_id,
      '|',
      CAST(event_timestamp AS STRING),
      '|',
      event_name
    )) AS distinct_proxy

  FROM base

)

SELECT
  row_count,
  distinct_proxy,
  row_count - distinct_proxy AS duplicate_proxy_rows

FROM counts;
````

---

## Query Result

| row_count | distinct_proxy | duplicate_proxy_rows |
| --------- | -------------- | -------------------- |
| 1,210,147 | 1,210,147      | 0                    |

---

## Query Result Screenshot

![GA4 Approximate Duplicate Validation](screenshots/ga4_duplicat_proxy.png)

---

## Key Observations

### 1. No Approximate Duplicate Events Detected

The validation returned zero duplicate proxy rows within the selected sample window.

This indicates that no multiple rows shared the same combination of:

* `user_pseudo_id`
* `event_timestamp`
* `event_name`

based on the selected proxy key logic.

---

### 2. Event-Level Tracking Appears Structurally Consistent

The absence of approximate duplicate events suggests that the GA4 export structure is behaving consistently at the event level within the observed sample period.

This reduces the likelihood of:

* inflated event counts
* duplicated engagement metrics
* artificial session activity inflation
* inaccurate behavioral aggregations

during downstream analysis.

---

### 3. Proxy Key Approach Used for Approximate Validation

The duplicate validation was intentionally designed as an approximate duplicate check rather than a strict event uniqueness validation.

This is important because GA4 events may contain:

* nested parameters
* repeated item records
* additional metadata fields

that are not included within the selected proxy key.

As a result, the validation should be interpreted as a structural reliability check rather than an absolute event deduplication guarantee.

---

### 4. Dataset Appears Reliable for Event Aggregation

Based on the observed results, the dataset appears suitable for:

* event-level aggregation
* engagement analysis
* session-based KPIs
* behavioral funnel analysis
* traffic attribution analysis

without requiring immediate duplicate remediation logic.

---

## Analytical Implications

The duplicate validation results indicate that the sampled GA4 dataset demonstrates strong structural consistency at the behavioral event level.

Specifically:

* no approximate duplicate event patterns were identified
* event tracking appears stable within the sampled period
* downstream KPI calculations are less likely to be artificially inflated by duplicate event activity

This increases confidence in the reliability of future transformation and reporting workflows.

---

![alt text](ga4_duplicat_proxy.png)

```
```
````md id="u9v2kx"
## C3 — Invalid `event_date` Format Validation

### Objective
This query was used to validate the structural integrity and format consistency of the `event_date` field within the January 2021 GA4 sample window.

While previous validation steps confirmed that `event_date` was not null, this step focused specifically on verifying whether all values could be successfully parsed into valid date objects using the expected GA4 date format:

```text
YYYYMMDD
````

The purpose of this check was to identify any malformed or invalid date values that could negatively impact:

* time-series analysis
* date-based aggregations
* partition filtering
* KPI calculations
* downstream transformation logic

---

## Query

```sql
-- C3) invalid event_date format check

SELECT

  COUNT(*) AS total_rows,

  SUM(
    CASE
      WHEN SAFE.PARSE_DATE('%Y%m%d', event_date) IS NULL
      THEN 1
      ELSE 0
    END
  ) AS invalid_event_date_rows

FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`

WHERE _TABLE_SUFFIX BETWEEN '20210101' AND '20210131';
```

---

## Query Result

| total_rows | invalid_event_date_rows |
| ---------- | ----------------------- |
| 1,210,147  | 0                       |

---

## Query Result Screenshot

![GA4 Invalid Event Date Validation](screenshots/c3.png)

---

## Key Observations

### 1. No Invalid `event_date` Values Detected

The validation returned zero invalid `event_date` records within the selected sample window.

All observed values were successfully parsed using:

```sql
SAFE.PARSE_DATE('%Y%m%d', event_date)
```

This indicates that the date field follows the expected GA4 formatting standard consistently across the sampled dataset.

---

### 2. Date Field Structure Appears Reliable

Because all `event_date` values were parseable into valid dates, the dataset appears structurally reliable for:

* daily aggregations
* time-series analysis
* trend analysis
* date-based filtering
* downstream transformation pipelines

without requiring additional remediation logic for malformed date values.

---

### 3. Safe Parsing Logic Used for Validation

The validation intentionally used `SAFE.PARSE_DATE()` instead of `PARSE_DATE()`.

This approach prevents query failure when encountering malformed values and is considered a safer production-style validation pattern for large-scale analytical datasets.

If invalid values had existed, the safe parsing logic would have returned `NULL` instead of terminating the query execution.

---

### 4. Event Date Standardization Appears Consistent

The successful parsing of all sampled records suggests that the GA4 export maintains strong date formatting consistency during ingestion and storage.

This increases confidence in the reliability of future:

* temporal modeling
* partition-aware querying
* KPI trend calculations
* reporting workflows

built on top of the dataset.

---

## Analytical Implications

The validation results indicate that:

* the `event_date` field is fully populated
* all observed values follow the expected GA4 date structure
* no malformed date patterns were identified
* downstream analytical workflows can safely rely on this field for time-based analysis

This reduces the likelihood of transformation or reporting issues caused by invalid date formatting.

---
````md id="r8y4kp"
## D1 — Top Event Distribution Profiling

### Objective
This query was used to identify the most frequently occurring event types within the January 2021 GA4 sample window.

The purpose of this profiling step was to better understand:

- the behavioral composition of the dataset
- dominant user interaction patterns
- ecommerce funnel event availability
- engagement tracking structure
- the overall richness of the GA4 event taxonomy

This analysis provides an early behavioral overview of how users interact with the ecommerce platform.

---

## Query

```sql
-- D1) Top event distribution (sample window)

SELECT

  event_name,

  COUNT(*) AS event_count

FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`

WHERE _TABLE_SUFFIX BETWEEN '20210101' AND '20210131'

GROUP BY event_name

ORDER BY event_count DESC

LIMIT 20;
````

---

## Query Result Screenshot

![GA4 Top Event Distribution](screenshots/ga4_top_events_distribution.png)

---

## Key Observations

### 1. Page View Events Dominate the Dataset

The most frequent event observed was:

* `page_view` → 419,004 events

This indicates that the dataset is heavily behavior-oriented and contains substantial user navigation activity.

The high page view volume also suggests that the dataset is suitable for:

* behavioral analysis
* page interaction analysis
* engagement measurement
* session flow analysis

---

### 2. Strong Engagement Tracking Signals are Present

Several engagement-related events appeared among the top event types, including:

* `user_engagement`
* `scroll`
* `session_start`

This indicates that the GA4 implementation includes meaningful engagement instrumentation beyond simple page tracking.

These events support future analysis related to:

* session engagement
* interaction depth
* engagement quality
* behavioral intensity

---

### 3. Ecommerce Funnel Events are Clearly Available

The dataset includes multiple ecommerce funnel events, including:

* `view_item`
* `add_to_cart`
* `begin_checkout`
* `add_shipping_info`
* `add_payment_info`
* `purchase`

This confirms that the dataset contains sufficient ecommerce behavioral depth for:

* funnel analysis
* conversion analysis
* cart abandonment analysis
* checkout progression analysis
* ecommerce KPI modeling

---

### 4. Funnel Drop-Off Patterns are Immediately Visible

A substantial volume decrease can already be observed across the funnel stages.

For example:

* `view_item` → 86,971 events
* `add_to_cart` → 15,522 events
* `begin_checkout` → 11,034 events
* `purchase` → 1,204 events

This suggests the presence of meaningful behavioral drop-off throughout the purchase journey.

While no formal funnel calculations have been performed yet, the event distribution already indicates strong potential for downstream conversion funnel analysis.

---

### 5. Acquisition & Promotional Interaction Events Exist

Promotional and discovery-related events were also observed, including:

* `view_promotion`
* `select_promotion`
* `view_search_results`

This suggests that the dataset supports future analysis related to:

* promotional effectiveness
* product discovery behavior
* onsite search engagement
* campaign interaction analysis

---

### 6. Behavioral Tracking Structure Appears Rich & Well-Instrumented

The observed event taxonomy suggests that the GA4 implementation contains:

* behavioral tracking
* engagement tracking
* ecommerce funnel instrumentation
* promotional interaction tracking

This increases the analytical flexibility of the dataset for downstream KPI development and dashboard design.

---

## Analytical Implications

The event distribution profiling indicates that the dataset is highly suitable for:

* ecommerce funnel analysis
* behavioral segmentation
* session engagement analysis
* conversion KPI modeling
* customer journey analysis
* acquisition performance analysis

The presence of both engagement events and ecommerce progression events provides a strong foundation for realistic commercial analytics workflows.

---
![alt text](ga4_top_events_distribution.png)

```
```
````md id="t5q9wr"
## D2 — Purchase Presence & Revenue Validation

### Objective
This query was used to validate the existence and structural reliability of ecommerce purchase activity within the January 2021 GA4 sample window.

The purpose of this profiling step was to confirm:

- whether purchase events exist in the dataset
- whether purchase revenue is populated
- whether transaction identifiers are available
- whether the dataset is suitable for downstream ecommerce KPI modeling

This validation is important because purchase-related fields form the foundation of commercial analytics metrics such as:

- revenue
- transactions
- conversion rate
- average order value (AOV)
- checkout funnel analysis

---

## Query

```sql
-- D2) Purchase presence and revenue validation (sample window)

SELECT

  COUNTIF(event_name = 'purchase') AS purchase_events,

  SUM(
    CASE
      WHEN event_name = 'purchase'
      THEN COALESCE(ecommerce.purchase_revenue, 0)
      ELSE 0
    END
  ) AS total_purchase_revenue,

  COUNT(
    DISTINCT CASE
      WHEN event_name = 'purchase'
      THEN ecommerce.transaction_id
      ELSE NULL
    END
  ) AS distinct_purchase_transaction_ids

FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`

WHERE _TABLE_SUFFIX BETWEEN '20210101' AND '20210131';
````

---

## Query Result

| purchase_events | total_purchase_revenue | distinct_purchase_transaction_ids |
| --------------- | ---------------------- | --------------------------------- |
| 1,204           | 57,350.0               | 895                               |

---

## Query Result Screenshot

![GA4 Purchase Validation](screenshots/D2.png)

---

## Key Observations

### 1. Purchase Activity Exists Within the Dataset

The validation identified:

* `1,204` purchase events

This confirms that the dataset contains real ecommerce conversion activity and is suitable for downstream commercial analytics workflows.

The presence of purchase events enables future analysis related to:

* conversion performance
* revenue generation
* checkout behavior
* customer purchase journeys

---

### 2. Purchase Revenue is Successfully Populated

The query returned:

* total purchase revenue = `57,350.0`

This indicates that ecommerce revenue tracking is functioning and that the dataset supports revenue-based KPI modeling.

The populated revenue field increases the analytical value of the dataset for:

* revenue reporting
* monetization analysis
* AOV calculations
* commercial performance dashboards

---

### 3. Transaction-Level Identifiers are Available

The dataset contains:

* `895` distinct purchase transaction IDs

This confirms that transaction-level purchase identification is available for downstream aggregation and transaction analysis.

The availability of transaction identifiers supports future work related to:

* order-level analysis
* deduplication logic
* purchase validation
* transaction-based KPI calculations

---

### 4. Purchase Events Exceed Distinct Transaction IDs

The number of purchase events (`1,204`) is greater than the number of distinct transaction IDs (`895`).

This suggests that:

* some transactions may generate multiple purchase-related records
* repeated item-level structures may exist
* certain purchase events may contain duplicated transaction references

At this stage, no remediation is required, but this behavior should be considered during downstream transaction-level modeling and aggregation design.

---

### 5. Ecommerce Tracking Implementation Appears Functional

The successful population of:

* purchase events
* revenue values
* transaction identifiers

suggests that the ecommerce instrumentation within the GA4 export is functioning consistently within the sampled period.

This increases confidence in the reliability of future ecommerce KPI development.

---

## Analytical Implications

The validation results indicate that the dataset is suitable for:

* ecommerce KPI modeling
* revenue analysis
* conversion funnel analysis
* transaction-level reporting
* checkout behavior analysis
* customer purchase analysis

The dataset appears to contain sufficient commercial depth for realistic analytics engineering and BI workflows.

---



```
```



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
