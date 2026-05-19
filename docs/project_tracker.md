# Project Tracker — Commercial Analytics

## Current Phase

➡️ Phase 1A — GA4 Raw Data Profiling & Staging Preparation

---

# Phase 0 — Repository & Environment Setup

## Completed

- [x] Created GitHub repository
- [x] Established project folder structure
- [x] Added README skeleton
- [x] Configured `.gitignore`
- [x] Added `requirements.txt`
- [x] Connected local Windows Bootcamp environment using `git clone`
- [x] Refactored documentation structure
- [x] Initialized project tracking workflow
- [x] Created GA4 profiling script: `sql/ga4/01_data_profiling.sql`
- [x] Created GA4 screenshot directories
- [x] Added `.gitkeep` placeholders for future screenshot folders
- [x] Added GA4 profiling screenshots to `bi/screenshots/ga4/`

---

# Current Repository Structure

```text
commercial-analytics-bq-dbx/
│
├── bi/
│   └── screenshots/
│       ├── dashboards/
│       │   └── .gitkeep
│       │
│       ├── ga4/
│       │   ├── ga4_daily_event_volume_distribution.png
│       │   ├── ga4_date_coverage_sample.png
│       │   ├── ga4_duplicate_proxy.png
│       │   ├── ga4_event_parameter_coverage_by_event.png
│       │   ├── ga4_event_parameter_key_frequency.png
│       │   ├── ga4_global_date_coverage.png
│       │   ├── ga4_items_sparsity_by_event.png
│       │   ├── ga4_null_rates_core_fields.png
│       │   ├── ga4_purchase_presence_revenue.png
│       │   ├── ga4_purchase_transaction_quality.png
│       │   ├── ga4_revenue_transaction_validation.png
│       │   ├── ga4_session_id_availability.png
│       │   ├── ga4_top_events_distribution.png
│       │   ├── ga4_traffic_source_distribution.png
│       │   └── ga4_user_session_volume_profiling.png
│       │
│       └── olist/
│           └── .gitkeep
│
├── data/
│   ├── processed/
│   └── raw/
│       └── olist/
│
├── ├── docs/
│   ├── architecture.md
│   ├── data_dictionary.md
│   ├── decisions_log.md
│   ├── kpi_definitions.md
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

# Screenshot Inventory — GA4 Profiling

All GA4 profiling screenshots are stored in:

```text
bi/screenshots/ga4/
```

Because `project_tracker.md` is stored inside the `docs/` folder, all image references use this relative path pattern:

```text
../bi/screenshots/ga4/<filename>.png
```

| Step | Screenshot File | Status |
|---|---|---|
| B1 | `ga4_date_coverage_sample.png` | Available |
| B1b | `ga4_global_date_coverage.png` | Available |
| C1 | `ga4_null_rates_core_fields.png` | Available |
| C2 | `ga4_duplicate_proxy.png` | Available |
| D1 | `ga4_top_events_distribution.png` | Available |
| D2 | `ga4_purchase_presence_revenue.png` | Available |
| D3 | `ga4_items_sparsity_by_event.png` | Available |
| D4 | `ga4_daily_event_volume_distribution.png` | Available |
| D5 | `ga4_user_session_volume_profiling.png` | Available |
| D6 | `ga4_session_id_availability.png` | Available |
| D7 | `ga4_traffic_source_distribution.png` | Available |
| D8 | `ga4_purchase_transaction_quality.png` | Available |
| D9 | `ga4_revenue_transaction_validation.png` | Available |
| D10 | `ga4_event_parameter_key_frequency.png` | Available |
| D11 | `ga4_event_parameter_coverage_by_event.png` | Available |

---

# Phase 1A — GA4 Raw Data Profiling

## Objective

The purpose of this phase was to validate the raw GA4 ecommerce event export before building staging tables, analytical marts, and downstream KPI layers.

The profiling focused on:

- raw structure validation
- sample and global date coverage
- core identifier completeness
- duplicate event risk
- event taxonomy
- session availability
- acquisition parameter structure
- ecommerce purchase quality
- transaction-level revenue integrity
- event parameter structure

## Source Table

```text
bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*
```

## Sample Window

```text
2021-01-01 to 2021-01-31
```

## Main SQL File

```text
sql/ga4/01_data_profiling.sql
```

---

# A1 — Initial Structure Validation

## Objective

Validate the raw GA4 table structure before downstream transformation and KPI modeling.

## Query Reference

```sql
-- A1) sample rows (structure sanity)

SELECT *
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20210101' AND '20210131'
LIMIT 10;
```

## Key Observations

- GA4 uses daily sharded event tables following the `events_YYYYMMDD` naming pattern.
- The dataset follows an event-driven behavioral schema.
- Key nested structures include:
  - `event_params`
  - `items`
  - `ecommerce`
- Primary anonymous user tracking relies on:
  - `user_pseudo_id`
- Ecommerce fields are event-specific and should not be expected across all event types.

## Analytical Implications

The dataset supports:

- behavioral analytics
- session analysis
- acquisition analysis
- ecommerce funnel analysis
- KPI prototyping

---

# B1 — Sample Date Coverage Validation

## Objective

Validate whether the selected January 2021 sample window contains complete date coverage and sufficient event volume for profiling.

## Query Reference

```sql
-- B1) date coverage (sample window)

SELECT
  MIN(PARSE_DATE('%Y%m%d', event_date)) AS min_date,
  MAX(PARSE_DATE('%Y%m%d', event_date)) AS max_date,
  COUNT(*) AS total_rows
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20210101' AND '20210131';
```

## Result

| min_date | max_date | total_rows |
|---|---|---:|
| 2021-01-01 | 2021-01-31 | 1,210,147 |

![GA4 Sample Date Coverage](../bi/screenshots/ga4/profiling/ga4_date_coverage_sample.png)

## Key Findings

- January 2021 sample window loaded successfully.
- Full 31-day event coverage confirmed.
- Event volume is sufficient for downstream profiling and KPI modeling.

---

# B1b — Global Dataset Date Coverage Validation

## Objective

Validate the full historical date range available in the public GA4 ecommerce dataset.

## Query Reference

```sql
-- B1b) date coverage (global)

SELECT
  MIN(PARSE_DATE('%Y%m%d', event_date)) AS global_min_date,
  MAX(PARSE_DATE('%Y%m%d', event_date)) AS global_max_date
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`;
```

## Result

| global_min_date | global_max_date |
|---|---|
| 2020-11-01 | 2021-01-31 |

![GA4 Global Date Coverage](../bi/screenshots/ga4/profiling/ga4_global_date_coverage.png)

## Key Findings

- The public dataset contains approximately three months of historical data.
- The data is sufficient for KPI prototyping and dashboard development.
- The dataset is limited for:
  - long-term seasonality analysis
  - year-over-year comparison
  - mature cohort analysis
  - long-horizon forecasting

---

# C1 — Core Identifier Null Validation

## Objective

Validate whether core tracking identifiers are complete within the January 2021 sample window.

## Query Reference

```sql
-- C1) null rates for core identifiers (sample window)

SELECT
  COUNT(*) AS total_rows,
  SUM(CASE WHEN event_date IS NULL THEN 1 ELSE 0 END) AS null_event_date,
  SUM(CASE WHEN event_timestamp IS NULL THEN 1 ELSE 0 END) AS null_event_timestamp,
  SUM(CASE WHEN event_name IS NULL THEN 1 ELSE 0 END) AS null_event_name,
  SUM(CASE WHEN user_pseudo_id IS NULL THEN 1 ELSE 0 END) AS null_user_pseudo_id
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20210101' AND '20210131';
```

## Result

| total_rows | null_event_date | null_event_timestamp | null_event_name | null_user_pseudo_id |
|---:|---:|---:|---:|---:|
| 1,210,147 | 0 | 0 | 0 | 0 |

![GA4 Null Rates Core Fields](../bi/screenshots/ga4/profiling/ga4_null_rates_core_fields.png)

## Key Findings

- Core identifiers are fully populated.
- Event sequencing is structurally reliable.
- User-level analysis is feasible.
- No major completeness risk was detected for foundational tracking fields.

---

# C2 — Approximate Duplicate Event Validation

## Objective

Identify potential duplicate event records using an approximate proxy key.

## Proxy Key

```text
user_pseudo_id + event_timestamp + event_name
```

## Query Reference

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
```

## Result

| row_count | distinct_proxy | duplicate_proxy_rows |
|---:|---:|---:|
| 1,210,147 | 1,210,147 | 0 |

![GA4 Duplicate Proxy Validation](../bi/screenshots/ga4/profiling/ga4_duplicate_proxy.png)

## Key Findings

- No approximate duplicate event patterns were detected.
- Event tracking structure appears stable at the behavioral event level.
- This reduces the risk of inflated event-level KPI calculations.

---

# C3 — Invalid Event Date Validation

## Objective

Validate whether all `event_date` values can be safely parsed using the expected GA4 `YYYYMMDD` format.

## Query Reference

```sql
-- C3) invalid event_date format check

SELECT
  COUNT(*) AS total_rows,
  SUM(CASE WHEN SAFE.PARSE_DATE('%Y%m%d', event_date) IS NULL THEN 1 ELSE 0 END) AS invalid_event_date_rows
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20210101' AND '20210131';
```

## Result

| total_rows | invalid_event_date_rows |
|---:|---:|
| 1,210,147 | 0 |

## Key Findings

- All `event_date` values successfully parsed.
- No malformed date patterns were detected.
- Dataset is safe for time-series analysis and date-based aggregation.

---

# D1 — Top Event Distribution Profiling

## Objective

Understand the dominant event types in the January 2021 sample window.

## Query Reference

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
```

![GA4 Top Event Distribution](../bi/screenshots/ga4/profiling/ga4_top_events_distribution.png)

## Key Findings

Top behavioral and ecommerce events include:

- `page_view`
- `user_engagement`
- `scroll`
- `session_start`
- `view_item`
- `add_to_cart`
- `begin_checkout`
- `purchase`

## Analytical Implications

The dataset supports:

- ecommerce funnel analysis
- engagement KPI modeling
- behavioral segmentation
- customer journey analysis

---

# D2 — Purchase Presence & Revenue Validation

## Objective

Validate whether purchase events, revenue values, and valid transaction identifiers exist in the dataset.

## Query Reference

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

  COUNT(DISTINCT
    CASE
      WHEN event_name = 'purchase'
        AND ecommerce.transaction_id IS NOT NULL
        AND ecommerce.transaction_id != '(not set)'
      THEN ecommerce.transaction_id
    END
  ) AS distinct_valid_purchase_transaction_ids
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20210101' AND '20210131';
```

## Result

| Metric | Result |
|---|---:|
| Purchase events | 1,204 |
| Total purchase revenue | 57,350.0 |
| Distinct valid purchase transaction IDs | 894 |

![GA4 Purchase Presence Revenue](../bi/screenshots/ga4/profiling/ga4_purchase_presence_revenue.png)

## Key Findings

- Purchase activity exists within the dataset.
- Revenue tracking is populated.
- Valid transaction-level identifiers are available.
- Purchase events exceed distinct valid transaction IDs, indicating possible duplicate or invalid purchase event behavior.

---

# D3 — Item Array Population by Event Type

## Objective

Analyze item-level tracking coverage across GA4 event types.

## Query Reference

```sql
-- D3) explain items sparsity by event type (sample window)

SELECT
  event_name,
  COUNT(*) AS row_count,
  SUM(CASE WHEN ARRAY_LENGTH(items) IS NULL OR ARRAY_LENGTH(items) = 0 THEN 1 ELSE 0 END) AS no_items_row_count,
  SUM(CASE WHEN ARRAY_LENGTH(items) > 0 THEN 1 ELSE 0 END) AS has_items_row_count
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20210101' AND '20210131'
GROUP BY event_name
ORDER BY has_items_row_count DESC, row_count DESC
LIMIT 30;
```

![GA4 Items Sparsity By Event](../bi/screenshots/ga4/profiling/ga4_items_sparsity_by_event.png)

## Key Findings

- Ecommerce events consistently contain populated item arrays.
- Behavioral events correctly lack item arrays.
- Partial item population exists for some discovery and promotion events.

## Modeling Implications

Item-level extraction logic should remain event-aware. Product-level modeling should focus on ecommerce-specific events rather than all raw events.

---

# D4 — Daily Event Volume Distribution

## Objective

Validate daily event continuity and identify potential ingestion gaps or abnormal event-volume patterns.

## Query Reference

```sql
-- D4) Daily event volume distribution (sample window)

SELECT
  PARSE_DATE('%Y%m%d', event_date) AS event_dt,
  COUNT(*) AS event_count
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20210101' AND '20210131'
GROUP BY event_dt
ORDER BY event_dt;
```

![GA4 Daily Event Volume Distribution](../bi/screenshots/ga4/profiling/ga4_daily_event_volume_distribution.png)

## Key Findings

- No missing event dates detected.
- Event flow remains continuous across January 2021.
- Daily activity levels appear behaviorally plausible.

## Modeling Implications

Dataset is suitable for:

- daily KPI aggregation
- rolling metrics
- time-series dashboarding

---

# D5 — User & Session Volume Profiling

## Objective

Profile event volume, unique users, and unique sessions within the sample window.

## Query Reference

```sql
-- D5) User and session volume profiling (sample window)

SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT user_pseudo_id) AS unique_users,
  COUNT(DISTINCT CONCAT(
    user_pseudo_id,
    '|',
    CAST((
      SELECT value.int_value
      FROM UNNEST(event_params)
      WHERE key = 'ga_session_id'
    ) AS STRING)
  )) AS unique_sessions
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20210101' AND '20210131';
```

## Result

| total_rows | unique_users | unique_sessions |
|---:|---:|---:|
| 1,210,147 | 94,790 | 118,380 |

![GA4 User Session Volume Profiling](../bi/screenshots/ga4/profiling/ga4_user_session_volume_profiling.png)

## Key Findings

- Strong behavioral scale detected.
- Session structure appears reliable.
- Session extraction from nested parameters succeeded.

## Modeling Implications

Session-level marts and engagement KPIs are feasible.

---

# D6 — Session ID Availability Validation

## Objective

Validate whether `ga_session_id` is consistently available across event records.

## Query Reference

```sql
-- D6) Session ID availability check (sample window)

WITH base AS (
  SELECT
    (
      SELECT value.int_value
      FROM UNNEST(event_params)
      WHERE key = 'ga_session_id'
    ) AS ga_session_id
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _TABLE_SUFFIX BETWEEN '20210101' AND '20210131'
)

SELECT
  COUNT(*) AS total_rows,

  SUM(
    CASE
      WHEN ga_session_id IS NULL
      THEN 1
      ELSE 0
    END
  ) AS null_ga_session_id_rows,

  SUM(
    CASE
      WHEN ga_session_id IS NOT NULL
      THEN 1
      ELSE 0
    END
  ) AS has_ga_session_id_rows
FROM base;
```

## Result

| total_rows | null_ga_session_id_rows | has_ga_session_id_rows |
|---:|---:|---:|
| 1,210,147 | 0 | 1,210,147 |

![GA4 Session ID Availability](../bi/screenshots/ga4/profiling/ga4_session_id_availability.png)

## Key Findings

- Session identifiers are fully populated.
- No immediate session completeness risk was identified.
- Dataset is suitable for downstream sessionization logic.

---

# D7 — Event-Level Traffic Source Distribution

## Objective

Profile event-level acquisition parameters extracted from `event_params`.

## Query Reference

```sql
-- D7) Event-level traffic source parameter distribution (sample window)
-- Uses event_params source / medium / campaign instead of user-scoped traffic_source fields

WITH base AS (
  SELECT
    user_pseudo_id,

    (
      SELECT value.string_value
      FROM UNNEST(event_params)
      WHERE key = 'source'
    ) AS source,

    (
      SELECT value.string_value
      FROM UNNEST(event_params)
      WHERE key = 'medium'
    ) AS medium,

    (
      SELECT value.string_value
      FROM UNNEST(event_params)
      WHERE key = 'campaign'
    ) AS campaign_name
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _TABLE_SUFFIX BETWEEN '20210101' AND '20210131'
)

SELECT
  COALESCE(source, '(not set)') AS source,
  COALESCE(medium, '(not set)') AS medium,
  COALESCE(campaign_name, '(not set)') AS campaign_name,
  COUNT(*) AS event_count,
  COUNT(DISTINCT user_pseudo_id) AS unique_users
FROM base
GROUP BY
  source,
  medium,
  campaign_name
ORDER BY event_count DESC
LIMIT 30;
```

![GA4 Traffic Source Distribution](../bi/screenshots/ga4/profiling/ga4_traffic_source_distribution.png)

## Key Findings

- Event-level acquisition metadata was successfully extracted.
- Major channel types observed:
  - organic
  - referral
  - email
  - affiliate
  - cpc
- `(not set)` values require downstream normalization logic.

## Modeling Implications

Acquisition modeling should include fallback attribution handling and channel normalization.

---

# D8 — Purchase Transaction Quality Validation

## Objective

Validate purchase transaction quality, including invalid transaction IDs, missing revenue, zero revenue, and negative revenue.

## Query Reference

```sql
-- D8) Purchase transaction quality check

WITH q AS (
  SELECT
    COUNTIF(event_name = 'purchase') AS purchases,

    COUNTIF(
      event_name = 'purchase'
      AND (
        ecommerce.transaction_id IS NULL
        OR ecommerce.transaction_id = '(not set)'
      )
    ) AS missing_or_invalid_txn_id,

    COUNTIF(
      event_name = 'purchase'
      AND ecommerce.purchase_revenue IS NULL
    ) AS missing_revenue,

    COUNTIF(
      event_name = 'purchase'
      AND ecommerce.purchase_revenue = 0
    ) AS zero_revenue,

    COUNTIF(
      event_name = 'purchase'
      AND ecommerce.purchase_revenue < 0
    ) AS negative_revenue
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _TABLE_SUFFIX BETWEEN '20210101' AND '20210131'
)

SELECT
  purchases,
  missing_or_invalid_txn_id,
  ROUND(SAFE_DIVIDE(missing_or_invalid_txn_id, purchases), 4) AS missing_or_invalid_txn_rate,
  missing_revenue,
  ROUND(SAFE_DIVIDE(missing_revenue, purchases), 4) AS missing_rev_rate,
  zero_revenue,
  ROUND(SAFE_DIVIDE(zero_revenue, purchases), 4) AS zero_rev_rate,
  negative_revenue,
  ROUND(SAFE_DIVIDE(negative_revenue, purchases), 4) AS negative_rev_rate
FROM q;
```

## Result

| Metric | Result |
|---|---:|
| Purchase events | 1,204 |
| Missing or invalid transaction IDs | 300 |
| Missing or invalid transaction ID rate | 24.92% |
| Missing purchase revenue | 300 |
| Missing revenue rate | 24.92% |
| Zero revenue purchases | 0 |
| Negative revenue purchases | 0 |

![GA4 Purchase Transaction Quality](../bi/screenshots/ga4/profiling/ga4_purchase_transaction_quality.png)

## Key Findings

- 300 purchase events contain missing or invalid transaction IDs.
- The same number of purchase events also have missing revenue.
- No zero or negative purchase revenue values were detected.
- Revenue KPIs require defensive handling.

---

# D9 — Transaction-Level Duplicate & Revenue Validation

## Objective

Validate transaction-level revenue integrity and identify duplicate purchase event risks.

## Query Reference

```sql
-- D9) Transaction-level duplicate and revenue validation

SELECT
  ecommerce.transaction_id,
  COUNT(*) AS purchase_event_rows,
  COUNT(DISTINCT ecommerce.purchase_revenue) AS distinct_revenue_values,
  SUM(ecommerce.purchase_revenue) AS summed_transaction_revenue,
  MAX(ecommerce.purchase_revenue) AS max_transaction_revenue
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20210101' AND '20210131'
  AND event_name = 'purchase'
  AND ecommerce.transaction_id IS NOT NULL
  AND ecommerce.transaction_id != '(not set)'
GROUP BY ecommerce.transaction_id
ORDER BY purchase_event_rows DESC, summed_transaction_revenue DESC
LIMIT 30;
```

![GA4 Revenue Transaction Validation](../bi/screenshots/ga4/profiling/ga4_revenue_transaction_validation.png)

## Key Findings

- Duplicate purchase event behavior was detected.
- Revenue inflation risk exists if raw purchase rows are summed directly.
- Majority of valid transactions still maintain single-row integrity.

## Recommended Modeling Approach

Future marts should:

- treat valid `transaction_id` as the business grain
- apply transaction-level deduplication
- avoid naïve raw-row revenue summation
- use defensive logic such as `MAX(purchase_revenue)` or row ranking when needed

---

# D10 — Event Parameter Key Frequency Profiling

## Objective

Identify high-value reusable event parameters and event-specific parameters for future staging extraction.

## Query Reference

```sql
-- D10) Event parameter key frequency (sample window)

SELECT
  ep.key AS event_param_key,
  COUNT(*) AS param_occurrence_count,
  COUNT(DISTINCT event_name) AS event_name_count
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`,
UNNEST(event_params) AS ep
WHERE _TABLE_SUFFIX BETWEEN '20210101' AND '20210131'
GROUP BY ep.key
ORDER BY param_occurrence_count DESC
LIMIT 50;
```

![GA4 Event Parameter Key Frequency](../bi/screenshots/ga4/profiling/ga4_event_parameter_key_frequency.png)

## Key Findings

Common reusable parameters include:

- `ga_session_id`
- `ga_session_number`
- `page_location`
- `page_title`
- `source`
- `medium`
- `campaign`

Event-specific parameters include:

- `transaction_id`
- `payment_type`
- `coupon`
- `search_term`
- `percent_scrolled`

## Modeling Implications

Future staging should selectively extract reusable high-value parameters instead of flattening every event parameter.

---

# D11 — Event Parameter Coverage by Event Type

## Objective

Validate how event parameter coverage differs across event types.

## Query Reference

```sql
-- D11) Event parameter coverage by event type (sample window)

SELECT
  event_name,
  ep.key AS event_param_key,
  COUNT(*) AS param_occurrence_count
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`,
UNNEST(event_params) AS ep
WHERE _TABLE_SUFFIX BETWEEN '20210101' AND '20210131'
GROUP BY
  event_name,
  ep.key
ORDER BY
  event_name,
  param_occurrence_count DESC;
```

![GA4 Event Parameter Coverage By Event](../bi/screenshots/ga4/profiling/ga4_event_parameter_coverage_by_event.png)

## Key Findings

- Event schemas differ across event categories.
- Commerce events show stable parameter structures.
- Attribution fields are sparse for some ecommerce events.
- Parameter extraction logic must remain event-aware.

## Modeling Implications

Downstream staging should not assume every parameter exists for every event. Extraction logic should be based on event type and business use case.

---

# Phase 1A Summary

## Completed

- [x] Raw structure inspection
- [x] Sample date coverage validation
- [x] Global date coverage validation
- [x] Core null validation
- [x] Approximate duplicate validation
- [x] Invalid date validation
- [x] Event taxonomy profiling
- [x] Purchase presence and revenue validation
- [x] Item array profiling
- [x] Daily volume validation
- [x] User and session volume profiling
- [x] Session ID availability validation
- [x] Event-level traffic source profiling
- [x] Purchase transaction quality validation
- [x] Transaction-level revenue integrity validation
- [x] Event parameter key frequency profiling
- [x] Event parameter coverage profiling

---

# Key Profiling Decisions

## Decision 1 — Use January 2021 as Profiling Window

January 2021 was selected to balance:

- sufficient event scale
- manageable BigQuery scan cost
- realistic profiling coverage

---

## Decision 2 — Build Event-Aware Staging Logic

GA4 event schemas differ significantly by event type. Future extraction logic should remain selective and event-aware.

---

## Decision 3 — Use Composite Session Keys

Session grain should use:

```text
user_pseudo_id + ga_session_id
```

because `ga_session_id` alone should not be assumed globally unique.

---

## Decision 4 — Treat `(not set)` Transaction IDs as Invalid

`transaction_id = '(not set)'` should not be counted as a valid transaction ID.

---

## Decision 5 — Apply Transaction-Level Revenue Deduplication

Revenue aggregation should avoid naïve raw-row summation due to duplicate purchase event patterns.

---

# Known Data Quality Notes

| Area | Issue | Impact |
|---|---|---|
| Historical coverage | Dataset limited to 2020-11-01 through 2021-01-31 | Reduced long-term trend and seasonality analysis |
| Acquisition fields | Frequent `(not set)` values | Requires fallback attribution and channel mapping |
| Revenue completeness | 300 purchase events have missing revenue | Revenue KPI caution required |
| Transaction IDs | 300 purchase events have missing or invalid transaction IDs | Invalid transactions should be excluded or flagged |
| Purchase duplication | Duplicate purchase event behavior detected | Revenue inflation risk if raw rows are summed |

---

# Next Phase — GA4 Staging

## Planned Tasks

- [ ] Create `stg_ga4_events`
- [ ] Extract core event fields:
  - `event_date`
  - `event_timestamp`
  - `event_name`
  - `user_pseudo_id`
- [ ] Extract session fields:
  - `ga_session_id`
  - `ga_session_number`
- [ ] Extract page fields:
  - `page_location`
  - `page_title`
- [ ] Extract acquisition fields:
  - `source`
  - `medium`
  - `campaign`
- [ ] Extract ecommerce fields:
  - `transaction_id`
  - `purchase_revenue`
- [ ] Create composite session key
- [ ] Flag invalid transaction IDs
- [ ] Handle missing purchase revenue
- [ ] Design transaction deduplication logic
- [ ] Validate row counts after staging



# Phase 1B — GA4 Staging View

## Objective

Create a flattened GA4 event-level staging view that converts the nested raw GA4 export into a reusable analytical layer for downstream fact tables, marts, validation checks, and BI-ready KPI modeling.

The staging view preserves the raw event grain:

```text
one row per raw GA4 event
````

## Main SQL File

```text
sql/ga4/02_stg_ga4_events.sql
```

## Target View

```text
commercial-analytics-bq-dbx.commercial_analytics_us.stg_ga4_events
```

## Source Table

```text
bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*
```

## Sample Window

```text
2021-01-01 to 2021-01-31
```

## Completed

* [x] Created `stg_ga4_events` view in BigQuery
* [x] Preserved event-level grain
* [x] Extracted core event fields
* [x] Extracted session fields from `event_params`
* [x] Created composite `session_key`
* [x] Extracted page and content parameters
* [x] Extracted engagement parameters
* [x] Extracted acquisition parameters
* [x] Preserved raw acquisition fields for debugging
* [x] Extracted selected ecommerce fields
* [x] Added item-array metadata without unnesting items
* [x] Added ecommerce funnel event flags
* [x] Added purchase event flags
* [x] Added data quality flags
* [x] Added event proxy key for duplicate validation

## Key Design Decisions

### Decision 1 — Preserve Event-Level Grain

The staging view keeps one row per raw GA4 event. The `items` array is not unnested in this layer because unnesting would multiply rows and break event-level grain.

Product-level or item-level modeling should be handled in a separate downstream fact table if needed.

### Decision 2 — Use Selective Parameter Extraction

Only high-value GA4 parameters were extracted from `event_params`, including:

* `ga_session_id`
* `ga_session_number`
* `page_location`
* `page_title`
* `page_referrer`
* `engagement_time_msec`
* `session_engaged`
* `source`
* `medium`
* `campaign`
* `search_term`
* `percent_scrolled`
* `coupon`
* `payment_type`

This avoids flattening every GA4 parameter unnecessarily.

### Decision 3 — Build Composite Session Key

Session grain uses:

```text
user_pseudo_id + ga_session_id
```

because `ga_session_id` alone should not be assumed globally unique across users.

### Decision 4 — Normalize Acquisition Nulls Only

Acquisition fields were normalized only for null or blank values:

```text
source
medium
campaign
```

Blank or null values are converted to:

```text
(not set)
```

Business-level channel grouping is intentionally left for the downstream `dim_channel` or mart layer.

### Decision 5 — Flag Data Quality Issues Without Filtering Rows

The staging view adds quality flags but does not remove or deduplicate records.

Important flags include:

* `is_invalid_event_date`
* `is_missing_user_pseudo_id`
* `is_missing_ga_session_id`
* `is_missing_session_key`
* `is_invalid_purchase_transaction_id`
* `is_missing_purchase_revenue`
* `is_zero_purchase_revenue`
* `is_negative_purchase_revenue`

This keeps staging transparent and auditable.

### Decision 6 — Revenue Deduplication Is Deferred

Transaction-level revenue deduplication is not performed in staging.

This is intentional because staging should remain close to the raw event export. Revenue deduplication should happen later in fact or mart logic where the business grain is clearly defined.

## Initial Staging Sanity Check

After creating the staging view, a quick sanity check was executed.

```sql
SELECT
  COUNT(*) AS total_rows,
  MIN(event_date) AS min_event_date,
  MAX(event_date) AS max_event_date,
  COUNT(DISTINCT session_key) AS unique_sessions,
  COUNTIF(is_purchase_event = TRUE) AS purchase_events
FROM `commercial-analytics-bq-dbx.commercial_analytics_us.stg_ga4_events`;
```

## Result

| total_rows | min_event_date | max_event_date | unique_sessions | purchase_events |
| ---------: | -------------- | -------------- | --------------: | --------------: |
|  1,210,147 | 2021-01-01     | 2021-01-31     |         118,380 |           1,204 |

## Key Findings

* The staging view was created successfully.
* Row volume matches the expected January 2021 profiling window.
* Date range matches the intended sample window.
* Session extraction is working.
* Purchase event count matches the profiling result.
* The view is ready for structured validation.

---

# Phase 1C — GA4 Staging Validation

## Objective

Validate that the GA4 staging view correctly preserves raw event volume, date coverage, session logic, event taxonomy, ecommerce flags, acquisition fields, and data quality indicators.

## Main SQL File

```text
sql/validation/ga4/02b_validate_stg_ga4_events.sql
```

## Screenshot Directory

```text
bi/screenshots/ga4/validation/staging/
```

## Screenshot Naming Convention

| Validation Step                                      | Screenshot File                                             |
| ---------------------------------------------------- | ----------------------------------------------------------- |
| V1 — Raw vs staging row count validation             | `ga4_staging_validation_v01_row_count.png`                  |
| V2 — Staging date range validation                   | `ga4_staging_validation_v02_date_range.png`                 |
| V3 — Core field null validation                      | `ga4_staging_validation_v03_core_nulls.png`                 |
| V4 — Session field availability validation           | `ga4_staging_validation_v04_session_availability.png`       |
| V5 — Session volume validation                       | `ga4_staging_validation_v05_session_volume.png`             |
| V6 — Duplicate proxy validation                      | `ga4_staging_validation_v06_duplicate_proxy.png`            |
| V7 — Event distribution validation                   | `ga4_staging_validation_v07_event_distribution.png`         |
| V8 — Ecommerce funnel event validation               | `ga4_staging_validation_v08_ecommerce_funnel_flags.png`     |
| V9 — Purchase quality validation                     | `ga4_staging_validation_v09_purchase_quality.png`           |
| V10 — Valid transaction and revenue validation       | `ga4_staging_validation_v10_valid_transactions_revenue.png` |
| V11 — Transaction duplicate / revenue inflation risk | `ga4_staging_validation_v11_transaction_duplicate_risk.png` |
| V12 — Acquisition field validation                   | `ga4_staging_validation_v12_acquisition_distribution.png`   |
| V13 — Not set acquisition rate                       | `ga4_staging_validation_v13_not_set_acquisition_rate.png`   |
| V14 — Item array validation by event type            | `ga4_staging_validation_v14_item_array_validation.png`      |
| V15 — Engagement field validation                    | `ga4_staging_validation_v15_engagement_validation.png`      |
| V16 — Data quality flag summary                      | `ga4_staging_validation_v16_quality_flag_summary.png`       |
| V17 — Final staging validation status                | `ga4_staging_validation_v17_final_status.png`               |

---

## V1 — Raw vs Staging Row Count Validation

### Objective

Confirm that the staging view preserves the same number of rows as the raw GA4 event source for the January 2021 sample window.

This validates that the staging transformation did not accidentally drop, duplicate, filter, or multiply event rows.

### Query Reference

```sql
WITH raw_count AS (
  SELECT
    COUNT(*) AS raw_row_count
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _TABLE_SUFFIX BETWEEN '20210101' AND '20210131'
),

staging_count AS (
  SELECT
    COUNT(*) AS staging_row_count
  FROM `commercial-analytics-bq-dbx.commercial_analytics_us.stg_ga4_events`
)

SELECT
  raw_row_count,
  staging_row_count,
  raw_row_count - staging_row_count AS row_count_difference,
  CASE
    WHEN raw_row_count = staging_row_count THEN 'PASS'
    ELSE 'FAIL'
  END AS validation_status
FROM raw_count
CROSS JOIN staging_count;
```

### Result

| raw_row_count | staging_row_count | row_count_difference | validation_status |
| ------------: | ----------------: | -------------------: | ----------------- |
|     1,210,147 |         1,210,147 |                    0 | PASS              |

![GA4 Staging Validation V01 Row Count](../bi/screenshots/ga4/validation/staging/ga4_staging_validation_v01_row_count.png)
![alt text](ga4_staging_validation_v01_row_count.png)

### Key Findings

* Raw GA4 row count and staging row count match exactly.
* No rows were lost during staging.
* No row multiplication occurred during parameter extraction.
* Event-level grain was preserved successfully.

### Status

```text
PASS
```

---
````markdown
---

## V2 — Staging Date Range Validation

### Objective

Validate that the staging view preserves the correct date coverage from the January 2021 GA4 sample window.

This validation confirms that:

- the staging transformation did not accidentally exclude dates
- no unexpected dates were introduced
- daily event continuity remains intact
- the intended sample window was preserved correctly

### Query Reference

```sql
SELECT
  MIN(event_date) AS min_event_date,
  MAX(event_date) AS max_event_date,
  COUNT(DISTINCT event_date) AS distinct_event_dates,
  COUNT(*) AS total_rows
FROM `commercial-analytics-bq-dbx.commercial_analytics_us.stg_ga4_events`;
````

### Result

| min_event_date | max_event_date | distinct_event_dates | total_rows |
| -------------- | -------------- | -------------------: | ---------: |
| 2021-01-01     | 2021-01-31     |                   31 |  1,210,147 |

![GA4 Staging Validation V02 Date Range](../bi/screenshots/ga4/validation/staging/ga4_staging_validation_v02_date_range.png)

### Key Findings

* The staging view preserved the full intended January 2021 sample window.
* All 31 expected event dates are present.
* No missing or unexpected dates were detected.
* Event continuity remains stable after staging transformation.
* Total row volume remains aligned with earlier profiling and staging sanity checks.

### Validation Implications

This confirms that:

* date parsing logic is functioning correctly
* staging transformations did not filter event dates unintentionally
* the staging layer is safe for:

  * time-series aggregation
  * rolling KPI calculations
  * daily trend analysis
  * downstream session modeling

### Status

```text
PASS
```

---
![alt text](ga4_staging_validation_v02_date_range.png)
```
```
````markdown
---

## V3 — Core Field Null Validation in Staging

### Objective

Validate that the most important event-level fields remain fully populated after the GA4 staging transformation.

This check focuses on the core fields required for downstream modeling:

- `event_date`
- `event_timestamp_utc`
- `event_timestamp_raw`
- `event_name`
- `user_pseudo_id`

These fields are foundational for time-series analysis, event sequencing, user-level aggregation, session modeling, and KPI construction.

### Query Reference

```sql
SELECT
  COUNT(*) AS total_rows,

  COUNTIF(event_date IS NULL) AS null_event_date,
  COUNTIF(event_timestamp_utc IS NULL) AS null_event_timestamp_utc,
  COUNTIF(event_timestamp_raw IS NULL) AS null_event_timestamp_raw,
  COUNTIF(event_name IS NULL) AS null_event_name,
  COUNTIF(user_pseudo_id IS NULL) AS null_user_pseudo_id,

  ROUND(SAFE_DIVIDE(COUNTIF(event_date IS NULL), COUNT(*)), 4) AS null_event_date_rate,
  ROUND(SAFE_DIVIDE(COUNTIF(event_timestamp_utc IS NULL), COUNT(*)), 4) AS null_event_timestamp_utc_rate,
  ROUND(SAFE_DIVIDE(COUNTIF(event_name IS NULL), COUNT(*)), 4) AS null_event_name_rate,
  ROUND(SAFE_DIVIDE(COUNTIF(user_pseudo_id IS NULL), COUNT(*)), 4) AS null_user_pseudo_id_rate
FROM `commercial-analytics-bq-dbx.commercial_analytics_us.stg_ga4_events`;
````

### Result

| total_rows | null_event_date | null_event_timestamp_utc | null_event_timestamp_raw | null_event_name | null_user_pseudo_id | null_event_date_rate | null_event_timestamp_utc_rate | null_event_name_rate | null_user_pseudo_id_rate |
| ---------: | --------------: | -----------------------: | -----------------------: | --------------: | ------------------: | -------------------: | ----------------------------: | -------------------: | -----------------------: |
|  1,210,147 |               0 |                        0 |                        0 |               0 |                   0 |                  0.0 |                           0.0 |                  0.0 |                      0.0 |

![GA4 Staging Validation V03 Core Nulls](../bi/screenshots/ga4/validation/staging/ga4_staging_validation_v03_core_nulls.png)

### Key Findings

* No null values were detected in the core staging fields.
* Event date parsing did not introduce invalid or missing dates.
* Event timestamps remained fully populated after transformation.
* Event names are complete across all staged rows.
* `user_pseudo_id` is fully populated, supporting user-level and session-level modeling.

### Validation Implications

This confirms that the staging layer is reliable for:

* daily event aggregation
* event sequencing
* session construction
* user-level behavioral analysis
* downstream fact table development

No remediation is required for core field completeness.

### Status

```text
PASS
```

---
![alt text](ga4_staging_validation_v03_core_nulls.png)
```
```
````markdown
---

## V4 — Session Field Availability Validation

### Objective

Validate that the session-related fields remain fully populated after staging transformation.

This validation focuses on the two most important session identifiers:

- `ga_session_id`
- `session_key`

The purpose of this check is to confirm that session extraction logic is functioning correctly and that downstream session-level modeling can safely rely on these fields.

### Query Reference

```sql
SELECT
  COUNT(*) AS total_rows,

  COUNTIF(ga_session_id IS NULL) AS null_ga_session_id,
  COUNTIF(session_key IS NULL) AS null_session_key,

  COUNTIF(ga_session_id IS NOT NULL) AS populated_ga_session_id,
  COUNTIF(session_key IS NOT NULL) AS populated_session_key,

  ROUND(SAFE_DIVIDE(COUNTIF(ga_session_id IS NULL), COUNT(*)), 4) AS null_ga_session_id_rate,
  ROUND(SAFE_DIVIDE(COUNTIF(session_key IS NULL), COUNT(*)), 4) AS null_session_key_rate
FROM `commercial-analytics-bq-dbx.commercial_analytics_us.stg_ga4_events`;
````

### Result

| total_rows | null_ga_session_id | null_session_key | populated_ga_session_id | populated_session_key | null_ga_session_id_rate | null_session_key_rate |
| ---------: | -----------------: | ---------------: | ----------------------: | --------------------: | ----------------------: | --------------------: |
|  1,210,147 |                  0 |                0 |               1,210,147 |             1,210,147 |                     0.0 |                   0.0 |

![GA4 Staging Validation V04 Session Availability](../bi/screenshots/ga4/validation/staging/ga4_staging_validation_v04_session_availability.png)

### Key Findings

* All staged events contain a valid `ga_session_id`.
* All staged events contain a valid composite `session_key`.
* No session identifier loss occurred during parameter extraction.
* Session-level grain remains stable after staging transformation.

### Validation Implications

This confirms that the staging layer is reliable for:

* session-level aggregation
* session KPI construction
* session-to-user relationship modeling
* traffic acquisition attribution
* funnel progression analysis
* downstream session fact table generation

The composite session key strategy:

```text
user_pseudo_id + ga_session_id
```

was successfully populated across the full dataset.

### Technical Interpretation

The result also confirms that:

* `event_params` extraction logic worked correctly
* session parameter parsing remained stable
* no unintended null propagation occurred during transformation
* the staging layer preserved session continuity successfully

### Status

```text
PASS
```
![alt text](ga4_staging_validation_v04_session_availability.png)
---

```
```
````markdown
---

## V5 — Session Volume Validation

### Objective

Validate that the session volume extracted from the staging layer remains stable, internally consistent, and analytically plausible.

This validation focuses on:

- total event volume
- unique user count
- unique session count
- average event activity per session

The goal is to confirm that session extraction logic did not introduce abnormal session inflation or unexpected session sparsity.

### Query Reference

```sql
SELECT
  COUNT(*) AS total_event_rows,
  COUNT(DISTINCT user_pseudo_id) AS unique_users,
  COUNT(DISTINCT session_key) AS unique_sessions,
  ROUND(SAFE_DIVIDE(COUNT(*), COUNT(DISTINCT session_key)), 2) AS avg_events_per_session
FROM `commercial-analytics-bq-dbx.commercial_analytics_us.stg_ga4_events`;
````

### Result

| total_event_rows | unique_users | unique_sessions | avg_events_per_session |
| ---------------: | -----------: | --------------: | ---------------------: |
|        1,210,147 |       94,790 |         118,380 |                  10.22 |

![GA4 Staging Validation V05 Session Volume](../bi/screenshots/ga4/validation/staging/ga4_staging_validation_v05_session_volume.png)

### Key Findings

* The staging layer contains over 1.21 million event rows.
* Approximately 94.8K unique users were identified.
* Approximately 118.4K unique sessions were constructed successfully.
* The average number of events per session is approximately 10.22.

### Validation Interpretation

The session volume distribution appears realistic and internally consistent for ecommerce behavioral analytics.

The results suggest that:

* session extraction logic is functioning correctly
* session inflation is not occurring
* session fragmentation is not occurring
* composite session keys are stable
* downstream session-level aggregation is reliable

### Business Interpretation

An average of approximately 10 events per session is analytically plausible for GA4 ecommerce browsing behavior because sessions commonly include:

* page views
* scroll activity
* session engagement events
* product interactions
* cart interactions
* checkout progression
* purchase activity

This indicates healthy behavioral continuity across the staged dataset.

### Validation Implications

The staging layer is suitable for:

* session KPI modeling
* funnel analysis
* behavioral analytics
* session attribution
* engagement analysis
* downstream fact session table construction

### Status

```text
PASS
```
![alt text](ga4_staging_validation_v05_session_volume.png)
---

```
```
````markdown
---

## V6 — Duplicate Proxy Validation in Staging

### Objective

Validate that the GA4 staging transformation did not accidentally introduce duplicate event rows.

Because GA4 raw exports do not provide a guaranteed globally unique event identifier, a proxy event key was constructed for duplicate detection using:

```text
user_pseudo_id + event_timestamp_raw + event_name
````

This validation checks whether staging transformations, parameter extraction logic, or event flattening introduced unintended row multiplication.

### Query Reference

```sql
SELECT
  COUNT(*) AS row_count,
  COUNT(DISTINCT event_proxy_key) AS distinct_event_proxy_keys,
  COUNT(*) - COUNT(DISTINCT event_proxy_key) AS duplicate_proxy_rows,
  CASE
    WHEN COUNT(*) = COUNT(DISTINCT event_proxy_key) THEN 'PASS'
    ELSE 'CHECK'
  END AS validation_status
FROM `commercial-analytics-bq-dbx.commercial_analytics_us.stg_ga4_events`;
```

### Result

| row_count | distinct_event_proxy_keys | duplicate_proxy_rows | validation_status |
| --------: | ------------------------: | -------------------: | ----------------- |
| 1,210,147 |                 1,210,147 |                    0 | PASS              |

![GA4 Staging Validation V06 Duplicate Proxy](../bi/screenshots/ga4/validation/staging/ga4_staging_validation_v06_duplicate_proxy.png)

### Key Findings

* No duplicate proxy rows were detected in the staging layer.
* Event-level grain was preserved successfully.
* Parameter extraction logic did not multiply event rows.
* The staging transformation remained one-to-one with the raw event structure.

### Validation Interpretation

This result is especially important because GA4 datasets contain nested and repeated structures.

Incorrect handling of:

* `UNNEST(event_params)`
* `UNNEST(items)`
* repeated ecommerce arrays

can easily create silent row multiplication.

The validation confirms that:

* no accidental Cartesian expansion occurred
* item arrays were handled safely
* event parameter extraction remained row-safe
* the staging layer preserved raw event integrity

### Technical Implications

This validation significantly reduces downstream risk for:

* revenue inflation
* session inflation
* duplicate funnel events
* distorted conversion metrics
* inaccurate KPI aggregation

The result confirms that downstream fact and mart layers can safely aggregate staged events without hidden duplication introduced during staging.

### Status

```text
PASS
```
![alt text](ga4_staging_validation_v06_duplicate_proxy.png)
---

```
```


# Phase 1B — Olist Ingestion

## Planned Tasks

- [ ] Load Olist CSVs into Databricks
- [ ] Clean data types
- [ ] Create curated Olist datasets
- [ ] Export transformed datasets into BigQuery
- [ ] Store Olist screenshots in `bi/screenshots/olist/`

---

# Phase 2 — Data Quality

## Planned Tasks

- [ ] Validate duplicates
- [ ] Validate primary and foreign keys
- [ ] Validate NULL patterns
- [ ] Validate date coverage
- [ ] Document data quality issues

---

# Phase 3 — Modeling

## Planned Tasks

- [ ] Create dimensional models
- [ ] Build fact tables
- [ ] Create commercial marts
- [ ] Validate KPI logic
- [ ] Document grain and assumptions

---

# Phase 4 — Integration

## Planned Tasks

- [ ] Integrate GA4 behavioral data with commercial modeling layer
- [ ] Integrate Olist transactional data
- [ ] Document source limitations and join assumptions
- [ ] Build acquisition-to-revenue analytical logic where appropriate

---

# Phase 5 — KPI Layer

## Planned Tasks

- [ ] Define conversion KPIs
- [ ] Define revenue KPIs
- [ ] Define AOV logic
- [ ] Define engagement KPIs
- [ ] Create executive KPI layer

---

# Phase 6 — BI Layer

## Planned Tasks

- [ ] Build Executive dashboard
- [ ] Build Funnel dashboard
- [ ] Build Acquisition dashboard
- [ ] Export dashboard screenshots
- [ ] Store dashboard screenshots in `bi/screenshots/dashboards/`

---

# Phase 7 — A/B Testing Layer

## Planned Tasks

- [ ] Define experiment framework
- [ ] Build assignment logic
- [ ] Calculate treatment vs control KPIs
- [ ] Evaluate absolute and relative lift
- [ ] Make ship / no-ship recommendation

---

# Phase 8 — Final Packaging

## Planned Tasks

- [ ] Final README
- [ ] Architecture diagram
- [ ] Data dictionary
- [ ] Business recommendation summary
- [ ] Final dashboard screenshots
- [ ] Final project review checklist

