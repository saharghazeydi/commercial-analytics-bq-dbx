# Project Tracker — Commercial Analytics

## Current Status

✅ Phase 0 — Repository & Environment Setup: Completed  
✅ Phase 1A — GA4 Raw Data Profiling: Completed  
✅ Phase 1B — GA4 Staging View: Completed  
✅ Phase 1C — GA4 Staging Validation: Completed  

➡️ Next Phase: Phase 2 — Session & Commercial Mart Construction

---

# Project Objective

Build an end-to-end commercial analytics portfolio project using realistic data engineering, analytics engineering, BI, and experimentation workflows.

The project is designed to demonstrate:

- raw data profiling
- staging-layer design
- validation-first analytics engineering
- dimensional modeling
- commercial KPI development
- BI-ready mart construction
- executive dashboarding
- A/B testing measurement logic
- documented business decision-making

---

# Phase 0 — Repository & Environment Setup

## Status

✅ Completed

## Completed Tasks

- [x] Created GitHub repository
- [x] Established project folder structure
- [x] Added README skeleton
- [x] Configured `.gitignore`
- [x] Added `requirements.txt`
- [x] Connected local Windows Bootcamp environment using `git clone`
- [x] Refactored documentation structure
- [x] Initialized project tracking workflow
- [x] Created GA4 profiling script
- [x] Created GA4 screenshot directories
- [x] Added `.gitkeep` placeholders where needed
- [x] Added GA4 profiling screenshots
- [x] Added GA4 staging validation screenshots
- [x] Standardized GA4 profiling screenshot names
- [x] Reorganized GA4 staging validation screenshots
- [x] Committed and pushed work to GitHub

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
│       │   ├── profiling/
│       │   │   ├── ga4_profiling_b01_date_coverage_sample.png
│       │   │   ├── ga4_profiling_b01b_global_date_coverage.png
│       │   │   ├── ga4_profiling_c01_core_nulls.png
│       │   │   ├── ga4_profiling_c02_duplicate_proxy.png
│       │   │   ├── ga4_profiling_d01_event_distribution.png
│       │   │   ├── ga4_profiling_d02_purchase_presence_revenue.png
│       │   │   ├── ga4_profiling_d03_items_sparsity_by_event.png
│       │   │   ├── ga4_profiling_d04_daily_event_volume_distribution.png
│       │   │   ├── ga4_profiling_d05_user_session_volume.png
│       │   │   ├── ga4_profiling_d06_session_id_availability.png
│       │   │   ├── ga4_profiling_d07_traffic_source_distribution.png
│       │   │   ├── ga4_profiling_d08_purchase_transaction_quality.png
│       │   │   ├── ga4_profiling_d09_revenue_transaction_validation.png
│       │   │   ├── ga4_profiling_d10_event_parameter_key_frequency.png
│       │   │   └── ga4_profiling_d11_event_parameter_coverage_by_event.png
│       │   │
│       │   └── staging_validation/
│       │       ├── ga4_staging_validation_v01_row_count.png
│       │       ├── ga4_staging_validation_v02_date_range.png
│       │       ├── ga4_staging_validation_v03_core_nulls.png
│       │       ├── ga4_staging_validation_v04_session_availability.png
│       │       ├── ga4_staging_validation_v05_session_volume.png
│       │       ├── ga4_staging_validation_v06_duplicate_proxy.png
│       │       ├── ga4_staging_validation_v07_event_distribution.png
│       │       ├── ga4_staging_validation_v08_ecommerce_funnel_flags.png
│       │       ├── ga4_staging_validation_v09_purchase_quality.png
│       │       ├── ga4_staging_validation_v10_valid_transactions_revenue.png
│       │       ├── ga4_staging_validation_v11_transaction_duplicate_risk.png
│       │       ├── ga4_staging_validation_v12_acquisition_distribution.png
│       │       ├── ga4_staging_validation_v13_not_set_acquisition_rate.png
│       │       ├── ga4_staging_validation_v14_item_array_validation.png
│       │       ├── ga4_staging_validation_v15_engagement_validation.png
│       │       ├── ga4_staging_validation_v16_quality_flag_summary.png
│       │       └── ga4_staging_validation_v17_final_status.png
│       │
│       └── olist/
│           └── .gitkeep
│
├── data/
│   ├── processed/
│   └── raw/
│       └── olist/
│
├── docs/
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
│   ├── validation/
│   │   └── ga4/
│   │       └── 02b_validate_stg_ga4_events.sql
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

# Screenshot Naming Decision

## Current Decision

GA4 screenshots are organized by workflow area:

```text
bi/screenshots/ga4/profiling/
bi/screenshots/ga4/staging_validation/
```

Profiling screenshots now use a structured phase-based naming pattern:

```text
ga4_profiling_<step>_<description>.png
```

Example:

```text
ga4_profiling_b01_date_coverage_sample.png
ga4_profiling_d08_purchase_transaction_quality.png
ga4_profiling_d10_event_parameter_key_frequency.png
```

Staging validation screenshots use a formal validation-suite naming pattern:

```text
ga4_staging_validation_v##_description.png
```

Example:

```text
ga4_staging_validation_v01_row_count.png
ga4_staging_validation_v17_final_status.png
```

## Rationale

This naming convention keeps the project review-friendly and separates:

- exploratory profiling evidence
- formal staging validation evidence
- future dashboard screenshots
- future Olist screenshots

---

# Phase 1A — GA4 Raw Data Profiling

## Status

✅ Completed

## Objective

Validate the raw GA4 ecommerce event export before building staging views, analytical marts, KPI layers, and BI-ready datasets.

The profiling phase focused on:

- raw structure validation
- date coverage
- core identifier completeness
- duplicate event risk
- event taxonomy
- session availability
- acquisition parameter structure
- ecommerce purchase quality
- transaction-level revenue integrity
- event parameter structure
- item-array behavior

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

## Screenshot Directory

```text
bi/screenshots/ga4/profiling/
```

---

# GA4 Profiling Screenshot Inventory

| Step | Topic | Screenshot |
|---|---|---|
| B1 | Sample date coverage | `ga4_profiling_b01_date_coverage_sample.png` |
| B1b | Global date coverage | `ga4_profiling_b01b_global_date_coverage.png` |
| C1 | Core null validation | `ga4_profiling_c01_core_nulls.png` |
| C2 | Duplicate proxy validation | `ga4_profiling_c02_duplicate_proxy.png` |
| D1 | Event distribution | `ga4_profiling_d01_event_distribution.png` |
| D2 | Purchase presence and revenue | `ga4_profiling_d02_purchase_presence_revenue.png` |
| D3 | Item sparsity by event | `ga4_profiling_d03_items_sparsity_by_event.png` |
| D4 | Daily event volume | `ga4_profiling_d04_daily_event_volume_distribution.png` |
| D5 | User and session volume | `ga4_profiling_d05_user_session_volume.png` |
| D6 | Session ID availability | `ga4_profiling_d06_session_id_availability.png` |
| D7 | Traffic source distribution | `ga4_profiling_d07_traffic_source_distribution.png` |
| D8 | Purchase transaction quality | `ga4_profiling_d08_purchase_transaction_quality.png` |
| D9 | Revenue transaction validation | `ga4_profiling_d09_revenue_transaction_validation.png` |
| D10 | Event parameter key frequency | `ga4_profiling_d10_event_parameter_key_frequency.png` |
| D11 | Event parameter coverage by event | `ga4_profiling_d11_event_parameter_coverage_by_event.png` |

---

## A1 — Initial Structure Validation

### Objective

Validate the raw GA4 table structure before downstream transformation and KPI modeling.

### Key Observations

- GA4 uses daily sharded event tables following the `events_YYYYMMDD` naming pattern.
- The dataset follows an event-driven behavioral schema.
- Key nested structures include:
  - `event_params`
  - `items`
  - `ecommerce`
- Primary anonymous user tracking relies on `user_pseudo_id`.
- Ecommerce fields are event-specific and should not be expected across all event types.

### Analytical Implications

The dataset supports:

- behavioral analytics
- session analysis
- acquisition analysis
- ecommerce funnel analysis
- KPI prototyping

---

## B1 — Sample Date Coverage Validation

### Result

| min_date | max_date | total_rows |
|---|---|---:|
| 2021-01-01 | 2021-01-31 | 1,210,147 |

![GA4 Sample Date Coverage](../bi/screenshots/ga4/profiling/ga4_profiling_b01_date_coverage_sample.png)

### Key Findings

- January 2021 sample window loaded successfully.
- Full 31-day event coverage confirmed.
- Event volume is sufficient for downstream profiling and KPI modeling.

---

## B1b — Global Dataset Date Coverage Validation

### Result

| global_min_date | global_max_date |
|---|---|
| 2020-11-01 | 2021-01-31 |

![GA4 Global Date Coverage](../bi/screenshots/ga4/profiling/ga4_profiling_b01b_global_date_coverage.png)

### Key Findings

- The public GA4 dataset contains approximately three months of historical data.
- The dataset is suitable for KPI prototyping and dashboard development.
- The dataset is limited for:
  - long-term seasonality analysis
  - year-over-year comparison
  - mature cohort analysis
  - long-horizon forecasting

---

## C1 — Core Identifier Null Validation

### Result

| total_rows | null_event_date | null_event_timestamp | null_event_name | null_user_pseudo_id |
|---:|---:|---:|---:|---:|
| 1,210,147 | 0 | 0 | 0 | 0 |

![GA4 Null Rates Core Fields](../bi/screenshots/ga4/profiling/ga4_profiling_c01_core_nulls.png)

### Key Findings

- Core identifiers are fully populated.
- Event sequencing is structurally reliable.
- User-level analysis is feasible.
- No major completeness risk was detected for foundational tracking fields.

---

## C2 — Approximate Duplicate Event Validation

### Proxy Key

```text
user_pseudo_id + event_timestamp + event_name
```

### Result

| row_count | distinct_proxy | duplicate_proxy_rows |
|---:|---:|---:|
| 1,210,147 | 1,210,147 | 0 |

![GA4 Duplicate Proxy Validation](../bi/screenshots/ga4/profiling/ga4_profiling_c02_duplicate_proxy.png)

### Key Findings

- No approximate duplicate event patterns were detected.
- Event tracking structure appears stable at the behavioral event level.
- This reduces the risk of inflated event-level KPI calculations.

---

## C3 — Invalid Event Date Validation

### Result

| total_rows | invalid_event_date_rows |
|---:|---:|
| 1,210,147 | 0 |

### Key Findings

- All `event_date` values successfully parsed.
- No malformed date patterns were detected.
- Dataset is safe for time-series analysis and date-based aggregation.

---

## D1 — Top Event Distribution Profiling

![GA4 Top Event Distribution](../bi/screenshots/ga4/profiling/ga4_profiling_d01_event_distribution.png)

### Key Findings

Top behavioral and ecommerce events include:

- `page_view`
- `user_engagement`
- `scroll`
- `session_start`
- `first_visit`
- `view_item`
- `add_to_cart`
- `begin_checkout`
- `purchase`

### Analytical Implications

The dataset supports:

- ecommerce funnel analysis
- engagement KPI modeling
- behavioral segmentation
- customer journey analysis

---

## D2 — Purchase Presence & Revenue Validation

### Result

| Metric | Result |
|---|---:|
| Purchase events | 1,204 |
| Total purchase revenue | 57,350.0 |
| Distinct valid purchase transaction IDs | 894 |

![GA4 Purchase Presence Revenue](../bi/screenshots/ga4/profiling/ga4_profiling_d02_purchase_presence_revenue.png)

### Key Findings

- Purchase activity exists within the dataset.
- Revenue tracking is populated.
- Valid transaction-level identifiers are available.
- Purchase events exceed distinct valid transaction IDs, indicating possible duplicate or invalid purchase event behavior.

---

## D3 — Item Array Population by Event Type

![GA4 Items Sparsity By Event](../bi/screenshots/ga4/profiling/ga4_profiling_d03_items_sparsity_by_event.png)

### Key Findings

- Ecommerce events consistently contain populated item arrays.
- Behavioral events correctly lack item arrays.
- Partial item population exists for some discovery and promotion events.

### Modeling Implications

Item-level extraction logic should remain event-aware.

Product-level modeling should be handled separately from event-level staging to avoid row multiplication.

---

## D4 — Daily Event Volume Distribution

![GA4 Daily Event Volume Distribution](../bi/screenshots/ga4/profiling/ga4_profiling_d04_daily_event_volume_distribution.png)

### Key Findings

- No missing event dates detected.
- Event flow remains continuous across January 2021.
- Daily activity levels appear behaviorally plausible.

### Modeling Implications

Dataset is suitable for:

- daily KPI aggregation
- rolling metrics
- time-series dashboarding

---

## D5 — User & Session Volume Profiling

### Result

| total_rows | unique_users | unique_sessions |
|---:|---:|---:|
| 1,210,147 | 94,790 | 118,380 |

![GA4 User Session Volume Profiling](../bi/screenshots/ga4/profiling/ga4_profiling_d05_user_session_volume.png)

### Key Findings

- Strong behavioral scale detected.
- Session structure appears reliable.
- Session extraction from nested parameters succeeded.

### Modeling Implications

Session-level marts and engagement KPIs are feasible.

---

## D6 — Session ID Availability Validation

### Result

| total_rows | null_ga_session_id_rows | has_ga_session_id_rows |
|---:|---:|---:|
| 1,210,147 | 0 | 1,210,147 |

![GA4 Session ID Availability](../bi/screenshots/ga4/profiling/ga4_profiling_d06_session_id_availability.png)

### Key Findings

- Session identifiers are fully populated.
- No immediate session completeness risk was identified.
- Dataset is suitable for downstream sessionization logic.

---

## D7 — Event-Level Traffic Source Distribution

![GA4 Traffic Source Distribution](../bi/screenshots/ga4/profiling/ga4_profiling_d07_traffic_source_distribution.png)

### Key Findings

- Event-level acquisition metadata was successfully extracted.
- Major channel types observed:
  - organic
  - referral
  - email
  - affiliate
  - cpc
- `(not set)` values require downstream normalization logic.

### Modeling Implications

Acquisition modeling should include fallback attribution handling and channel normalization.

---

## D8 — Purchase Transaction Quality Validation

### Result

| Metric | Result |
|---|---:|
| Purchase events | 1,204 |
| Missing or invalid transaction IDs | 300 |
| Missing or invalid transaction ID rate | 24.92% |
| Missing purchase revenue | 300 |
| Missing revenue rate | 24.92% |
| Zero revenue purchases | 0 |
| Negative revenue purchases | 0 |

![GA4 Purchase Transaction Quality](../bi/screenshots/ga4/profiling/ga4_profiling_d08_purchase_transaction_quality.png)

### Key Findings

- 300 purchase events contain missing or invalid transaction IDs.
- The same number of purchase events also have missing revenue.
- No zero or negative purchase revenue values were detected.
- Revenue KPIs require defensive handling.

---

## D9 — Transaction-Level Duplicate & Revenue Validation

![GA4 Revenue Transaction Validation](../bi/screenshots/ga4/profiling/ga4_profiling_d09_revenue_transaction_validation.png)

### Key Findings

- Duplicate purchase event behavior was detected.
- Revenue inflation risk exists if raw purchase rows are summed directly.
- Majority of valid transactions still maintain single-row integrity.

### Recommended Modeling Approach

Future marts should:

- treat valid `transaction_id` as the business grain
- apply transaction-level deduplication
- avoid naïve raw-row revenue summation
- use defensive logic such as `MAX(purchase_revenue)` or row ranking when needed

---

## D10 — Event Parameter Key Frequency Profiling

![GA4 Event Parameter Key Frequency](../bi/screenshots/ga4/profiling/ga4_profiling_d10_event_parameter_key_frequency.png)

### Key Findings

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

### Modeling Implications

Future staging should selectively extract reusable high-value parameters instead of flattening every event parameter.

---

## D11 — Event Parameter Coverage by Event Type

![GA4 Event Parameter Coverage By Event](../bi/screenshots/ga4/profiling/ga4_profiling_d11_event_parameter_coverage_by_event.png)

### Key Findings

- Event schemas differ across event categories.
- Commerce events show stable parameter structures.
- Attribution fields are sparse for some ecommerce events.
- Parameter extraction logic must remain event-aware.

### Modeling Implications

Downstream staging should not assume every parameter exists for every event.

Extraction logic should be based on event type and business use case.

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

## Decision 2 — Build Event-Aware Staging Logic

GA4 event schemas differ significantly by event type.

Extraction logic should remain selective and event-aware.

## Decision 3 — Use Composite Session Keys

Session grain should use:

```text
user_pseudo_id + ga_session_id
```

because `ga_session_id` alone should not be assumed globally unique.

## Decision 4 — Treat `(not set)` Transaction IDs as Invalid

`transaction_id = '(not set)'` should not be counted as a valid transaction ID.

## Decision 5 — Apply Transaction-Level Revenue Deduplication

Revenue aggregation should avoid naïve raw-row summation due to duplicate purchase event patterns.

---

# Phase 1B — GA4 Staging View

## Status

✅ Completed

## Objective

Create a flattened GA4 event-level staging view that converts the nested raw GA4 export into a reusable analytical layer for downstream fact tables, marts, validation checks, and BI-ready KPI modeling.

The staging view preserves the raw event grain:

```text
one row per raw GA4 event
```

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

---

## Completed Staging Tasks

- [x] Created `stg_ga4_events` view in BigQuery
- [x] Preserved event-level grain
- [x] Extracted core event fields
- [x] Extracted session fields from `event_params`
- [x] Created composite `session_key`
- [x] Extracted page and content parameters
- [x] Extracted engagement parameters
- [x] Extracted acquisition parameters
- [x] Preserved raw acquisition fields for debugging
- [x] Extracted selected ecommerce fields
- [x] Added item-array metadata without unnesting items
- [x] Added ecommerce funnel event flags
- [x] Added purchase event flags
- [x] Added data quality flags
- [x] Added event proxy key for duplicate validation

---

## Implemented Staging Fields

### Core Event Fields

- `event_date`
- `event_date_raw`
- `event_timestamp_utc`
- `event_timestamp_raw`
- `event_name`
- `user_pseudo_id`
- `source_table_suffix`

### Session Fields

- `ga_session_id`
- `ga_session_number`
- `session_key`

### Page & Content Fields

- `page_location`
- `page_title`
- `page_referrer`

### Engagement Fields

- `engagement_time_msec`
- `session_engaged_raw`
- `is_session_engaged`

### Acquisition Fields

- `source`
- `medium`
- `campaign`
- `source_raw`
- `medium_raw`
- `campaign_raw`

### Additional Event Parameters

- `search_term`
- `percent_scrolled`
- `coupon`
- `payment_type`

### Ecommerce Fields

- `transaction_id_raw`
- `transaction_id`
- `purchase_revenue`
- `total_item_quantity`
- `unique_items`
- `item_array_length`
- `has_items`

### Event Classification Flags

- `is_purchase_event`
- `is_ecommerce_funnel_event`

### Data Quality Flags

- `is_invalid_event_date`
- `is_missing_user_pseudo_id`
- `is_missing_ga_session_id`
- `is_missing_session_key`
- `is_invalid_purchase_transaction_id`
- `is_missing_purchase_revenue`
- `is_zero_purchase_revenue`
- `is_negative_purchase_revenue`

### Validation Key

- `event_proxy_key`

---

# Key Staging Design Decisions

## Decision 1 — Preserve Event-Level Grain

The staging view keeps one row per raw GA4 event.

The `items` array is not unnested in this layer because unnesting would multiply rows and break event-level grain.

Product-level or item-level modeling should be handled in a separate downstream fact table if needed.

## Decision 2 — Use Selective Parameter Extraction

Only high-value GA4 parameters were extracted from `event_params`.

This avoids flattening every GA4 parameter unnecessarily and keeps staging readable, maintainable, and business-driven.

## Decision 3 — Build Composite Session Key

Session grain uses:

```text
user_pseudo_id + ga_session_id
```

because `ga_session_id` alone should not be assumed globally unique across users.

## Decision 4 — Normalize Acquisition Nulls Only

Acquisition fields were normalized only for null or blank values.

Blank or null values are converted to:

```text
(not set)
```

Business-level channel grouping is intentionally left for the downstream `dim_channel` or mart layer.

## Decision 5 — Flag Data Quality Issues Without Filtering Rows

The staging view adds quality flags but does not remove or deduplicate records.

This keeps staging transparent and auditable.

## Decision 6 — Revenue Deduplication Is Deferred

Transaction-level revenue deduplication is not performed in staging.

This is intentional because staging should remain close to the raw event export.

Revenue deduplication should happen later in fact or mart logic where the business grain is clearly defined.

---

# Initial Staging Sanity Check

## Query Purpose

Confirm that the staging view was created successfully and contains expected high-level metrics.

## Result

| total_rows | min_event_date | max_event_date | unique_sessions | purchase_events |
|---:|---|---|---:|---:|
| 1,210,147 | 2021-01-01 | 2021-01-31 | 118,380 | 1,204 |

## Key Findings

- The staging view was created successfully.
- Row volume matches the expected January 2021 profiling window.
- Date range matches the intended sample window.
- Session extraction is working.
- Purchase event count matches the profiling result.
- The view is ready for structured validation.

---

# Phase 1C — GA4 Staging Validation

## Status

✅ Completed

## Objective

Validate that the GA4 staging view correctly preserves raw event volume, date coverage, session logic, event taxonomy, ecommerce flags, acquisition fields, engagement fields, item metadata, and data quality indicators.

## Main SQL File

```text
sql/validation/ga4/02b_validate_stg_ga4_events.sql
```

## Target View

```text
commercial-analytics-bq-dbx.commercial_analytics_us.stg_ga4_events
```

## Screenshot Directory

```text
bi/screenshots/ga4/staging_validation/
```

---

# GA4 Staging Validation Screenshot Inventory

| Step | Validation Check | Screenshot File |
|---|---|---|
| V1 | Raw vs staging row count validation | `ga4_staging_validation_v01_row_count.png` |
| V2 | Staging date range validation | `ga4_staging_validation_v02_date_range.png` |
| V3 | Core field null validation | `ga4_staging_validation_v03_core_nulls.png` |
| V4 | Session field availability validation | `ga4_staging_validation_v04_session_availability.png` |
| V5 | Session volume validation | `ga4_staging_validation_v05_session_volume.png` |
| V6 | Duplicate proxy validation | `ga4_staging_validation_v06_duplicate_proxy.png` |
| V7 | Event distribution validation | `ga4_staging_validation_v07_event_distribution.png` |
| V8 | Ecommerce funnel event validation | `ga4_staging_validation_v08_ecommerce_funnel_flags.png` |
| V9 | Purchase quality validation | `ga4_staging_validation_v09_purchase_quality.png` |
| V10 | Valid transaction and revenue validation | `ga4_staging_validation_v10_valid_transactions_revenue.png` |
| V11 | Transaction duplicate / revenue inflation risk | `ga4_staging_validation_v11_transaction_duplicate_risk.png` |
| V12 | Acquisition field validation | `ga4_staging_validation_v12_acquisition_distribution.png` |
| V13 | Not set acquisition rate | `ga4_staging_validation_v13_not_set_acquisition_rate.png` |
| V14 | Item array validation by event type | `ga4_staging_validation_v14_item_array_validation.png` |
| V15 | Engagement field validation | `ga4_staging_validation_v15_engagement_validation.png` |
| V16 | Data quality flag summary | `ga4_staging_validation_v16_quality_flag_summary.png` |
| V17 | Final staging validation status | `ga4_staging_validation_v17_final_status.png` |

---

## V1 — Raw vs Staging Row Count Validation

### Result

| raw_row_count | staging_row_count | row_count_difference | validation_status |
|---:|---:|---:|---|
| 1,210,147 | 1,210,147 | 0 | PASS |

![GA4 Staging Validation V01 Row Count](../bi/screenshots/ga4/staging_validation/ga4_staging_validation_v01_row_count.png)

### Key Findings

- Raw GA4 row count and staging row count match exactly.
- No rows were lost during staging.
- No row multiplication occurred during parameter extraction.
- Event-level grain was preserved successfully.

### Status

```text
PASS
```

---

## V2 — Staging Date Range Validation

### Result

| min_event_date | max_event_date | distinct_event_dates | total_rows |
|---|---|---:|---:|
| 2021-01-01 | 2021-01-31 | 31 | 1,210,147 |

![GA4 Staging Validation V02 Date Range](../bi/screenshots/ga4/staging_validation/ga4_staging_validation_v02_date_range.png)

### Key Findings

- The staging view preserved the full intended January 2021 sample window.
- All 31 expected event dates are present.
- No missing or unexpected dates were detected.
- Event continuity remains stable after staging transformation.

### Status

```text
PASS
```

---

## V3 — Core Field Null Validation

### Result

| total_rows | null_event_date | null_event_timestamp_utc | null_event_timestamp_raw | null_event_name | null_user_pseudo_id |
|---:|---:|---:|---:|---:|---:|
| 1,210,147 | 0 | 0 | 0 | 0 | 0 |

![GA4 Staging Validation V03 Core Nulls](../bi/screenshots/ga4/staging_validation/ga4_staging_validation_v03_core_nulls.png)

### Key Findings

- No null values were detected in the core staging fields.
- Event date parsing did not introduce invalid or missing dates.
- Event timestamps remained fully populated after transformation.
- Event names are complete across all staged rows.
- `user_pseudo_id` is fully populated.

### Status

```text
PASS
```

---

## V4 — Session Field Availability Validation

### Result

| total_rows | null_ga_session_id | null_session_key | populated_ga_session_id | populated_session_key |
|---:|---:|---:|---:|---:|
| 1,210,147 | 0 | 0 | 1,210,147 | 1,210,147 |

![GA4 Staging Validation V04 Session Availability](../bi/screenshots/ga4/staging_validation/ga4_staging_validation_v04_session_availability.png)

### Key Findings

- All staged events contain a valid `ga_session_id`.
- All staged events contain a valid composite `session_key`.
- No session identifier loss occurred during parameter extraction.
- Session-level modeling can safely rely on these fields.

### Status

```text
PASS
```

---

## V5 — Session Volume Validation

### Result

| total_event_rows | unique_users | unique_sessions | avg_events_per_session |
|---:|---:|---:|---:|
| 1,210,147 | 94,790 | 118,380 | 10.22 |

![GA4 Staging Validation V05 Session Volume](../bi/screenshots/ga4/staging_validation/ga4_staging_validation_v05_session_volume.png)

### Key Findings

- Approximately 94.8K unique users were identified.
- Approximately 118.4K unique sessions were constructed successfully.
- Average events per session is approximately 10.22.
- Session volume appears realistic and internally consistent.

### Status

```text
PASS
```

---

## V6 — Duplicate Proxy Validation

### Result

| row_count | distinct_event_proxy_keys | duplicate_proxy_rows | validation_status |
|---:|---:|---:|---|
| 1,210,147 | 1,210,147 | 0 | PASS |

![GA4 Staging Validation V06 Duplicate Proxy](../bi/screenshots/ga4/staging_validation/ga4_staging_validation_v06_duplicate_proxy.png)

### Key Findings

- No duplicate proxy rows were detected.
- Event-level grain was preserved successfully.
- Parameter extraction logic did not multiply event rows.
- No accidental Cartesian expansion occurred.

### Status

```text
PASS
```

---

## V7 — Event Distribution Validation

### Result

| event_name | event_count | event_share |
|---|---:|---:|
| page_view | 419,004 | 0.3462 |
| user_engagement | 250,097 | 0.2067 |
| scroll | 138,997 | 0.1149 |
| session_start | 116,549 | 0.0963 |
| first_visit | 88,873 | 0.0734 |
| view_item | 86,971 | 0.0719 |
| view_promotion | 53,885 | 0.0445 |
| add_to_cart | 15,522 | 0.0128 |
| begin_checkout | 11,034 | 0.0091 |
| purchase | 1,204 | 0.0010 |

![GA4 Staging Validation V07 Event Distribution](../bi/screenshots/ga4/staging_validation/ga4_staging_validation_v07_event_distribution.png)

### Key Findings

- Behavioral events dominate the dataset as expected.
- Ecommerce funnel events remain visible and logically distributed.
- Event taxonomy was preserved successfully.
- The staged event distribution is consistent with earlier profiling.

### Status

```text
PASS
```

---

## V8 — Ecommerce Funnel Event Validation

### Result

| event_name | event_count | ecommerce_funnel_flagged_rows | rows_with_items | purchase_flagged_rows |
|---|---:|---:|---:|---:|
| view_item | 86,971 | 86,971 | 60,750 | 0 |
| add_to_cart | 15,522 | 15,522 | 15,522 | 0 |
| begin_checkout | 11,034 | 11,034 | 11,034 | 0 |
| purchase | 1,204 | 1,204 | 1,204 | 1,204 |

![GA4 Staging Validation V08 Ecommerce Funnel Flags](../bi/screenshots/ga4/staging_validation/ga4_staging_validation_v08_ecommerce_funnel_flags.png)

### Key Findings

- All ecommerce funnel events were correctly flagged.
- All `purchase` events were correctly identified.
- Funnel event classification remained consistent.
- Item presence is correctly associated with downstream ecommerce funnel events.

### Status

```text
PASS
```

---

## V9 — Purchase Quality Validation

### Result

| purchase_events | invalid_purchase_transaction_id_events | invalid_purchase_transaction_id_rate | missing_purchase_revenue_events | missing_purchase_revenue_rate | zero_purchase_revenue_events | negative_purchase_revenue_events |
|---:|---:|---:|---:|---:|---:|---:|
| 1,204 | 300 | 0.2492 | 300 | 0.2492 | 0 | 0 |

![GA4 Staging Validation V09 Purchase Quality](../bi/screenshots/ga4/staging_validation/ga4_staging_validation_v09_purchase_quality.png)

### Key Findings

- 300 purchase events have invalid or missing transaction IDs.
- 300 purchase events have missing purchase revenue.
- Invalid transaction ID rate is 24.92%.
- Missing purchase revenue rate is 24.92%.
- No zero-revenue purchase events were detected.
- No negative-revenue purchase events were detected.

### Status

```text
PASS WITH KNOWN DATA QUALITY ISSUE
```

---

## V10 — Valid Transaction and Revenue Validation

### Result

| purchase_event_rows | purchase_rows_with_valid_transaction_id | distinct_valid_transaction_ids | raw_purchase_revenue_sum |
|---:|---:|---:|---:|
| 1,204 | 904 | 894 | 57,350.0 |

![GA4 Staging Validation V10 Valid Transactions Revenue](../bi/screenshots/ga4/staging_validation/ga4_staging_validation_v10_valid_transactions_revenue.png)

### Key Findings

- Raw purchase-event volume is larger than the number of valid transactions.
- Some purchase rows contain duplicated transaction IDs.
- Some purchase rows contain invalid or missing transaction identifiers.
- Downstream revenue logic must use transaction-level deduplication.

### Status

```text
PASS WITH KNOWN TRANSACTION QUALITY CONSTRAINTS
```

---

## V11 — Transaction Duplicate & Revenue Inflation Risk Validation

### Result

The validation identified multiple transaction IDs appearing across more than one purchase-event row.

Example duplicated transactions:

| transaction_id | purchase_event_rows | summed_transaction_revenue | max_transaction_revenue | possible_revenue_overstatement |
|---|---:|---:|---:|---:|
| 145915 | 2 | 168.0 | 84.0 | 84.0 |
| 22807 | 2 | 166.0 | 83.0 | 83.0 |
| 594908 | 2 | 187.0 | 113.0 | 74.0 |
| 87482 | 2 | 140.0 | 70.0 | 70.0 |
| 468655 | 2 | 110.0 | 55.0 | 55.0 |

![GA4 Staging Validation V11 Transaction Duplicate Risk](../bi/screenshots/ga4/staging_validation/ga4_staging_validation_v11_transaction_duplicate_risk.png)

### Key Findings

- Multiple transaction IDs appear across duplicated purchase-event rows.
- Some duplicated transactions repeat the exact same revenue value.
- Some duplicated transactions contain different revenue values across rows.
- Raw revenue aggregation can materially overstate actual transaction revenue.

### Status

```text
PASS WITH CONFIRMED REVENUE DEDUPLICATION REQUIREMENT
```

---

## V12 — Acquisition Field Validation

### Result

Top observed acquisition combinations:

| source | medium | campaign | event_count | unique_users | unique_sessions |
|---|---|---|---:|---:|---:|
| `(not set)` | `(not set)` | `(not set)` | 873,805 | 94,757 | 118,330 |
| `shop.googlemerchandisestore...` | `referral` | `(referral)` | 158,458 | 21,904 | 29,224 |
| `google` | `organic` | `(organic)` | 83,604 | 32,198 | 35,183 |
| `(direct)` | `(none)` | `(direct)` | 28,697 | 8,950 | 9,400 |
| `<Other>` | `<Other>` | `<Other>` | 18,065 | 6,219 | 6,293 |
| `google` | `cpc` | `<Other>` | 5,252 | 1,840 | 1,850 |

![GA4 Staging Validation V12 Acquisition Distribution](../bi/screenshots/ga4/staging_validation/ga4_staging_validation_v12_acquisition_distribution.png)

### Key Findings

- Acquisition fields were successfully extracted and normalized.
- The largest acquisition bucket is `(not set) / (not set) / (not set)`.
- Referral and organic traffic sources are clearly visible.
- Direct, CPC, affiliate, and email patterns are represented.
- Attribution sparsity is significant and must be handled downstream.

### Status

```text
PASS WITH ATTRIBUTION SPARSITY NOTE
```

---

## V13 — Not Set Acquisition Rate Validation

### Result

| total_rows | not_set_source_rows | not_set_source_rate | not_set_medium_rows | not_set_medium_rate | not_set_campaign_rows | not_set_campaign_rate |
|---:|---:|---:|---:|---:|---:|---:|
| 1,210,147 | 874,947 | 0.7230 | 873,805 | 0.7221 | 873,807 | 0.7221 |

![GA4 Staging Validation V13 Not Set Acquisition Rate](../bi/screenshots/ga4/staging_validation/ga4_staging_validation_v13_not_set_acquisition_rate.png)

### Key Findings

- Approximately 72% of staged events contain `(not set)` acquisition values.
- Attribution sparsity is consistent across source, medium, and campaign.
- This is a source-data limitation, not a staging failure.

### Status

```text
PASS WITH HIGH ATTRIBUTION SPARSITY OBSERVED
```

---

## V14 — Item Array Validation by Event Type

### Result

| event_name | event_rows | rows_with_items | rows_without_items | item_coverage_rate |
|---|---:|---:|---:|---:|
| view_item | 86,971 | 60,750 | 26,221 | 0.6985 |
| view_promotion | 53,885 | 40,500 | 13,385 | 0.7516 |
| add_to_cart | 15,522 | 15,522 | 0 | 1.0000 |
| begin_checkout | 11,034 | 11,034 | 0 | 1.0000 |
| select_item | 10,229 | 10,229 | 0 | 1.0000 |
| purchase | 1,204 | 1,204 | 0 | 1.0000 |

![GA4 Staging Validation V14 Item Array Validation](../bi/screenshots/ga4/staging_validation/ga4_staging_validation_v14_item_array_validation.png)

### Key Findings

- Core ecommerce events have strong or full item coverage.
- Behavioral events correctly contain no item metadata.
- The staging layer preserved item-array metadata without multiplying event rows.

### Status

```text
PASS
```

---

## V15 — Engagement Field Validation

### Result

| session_engaged_raw | is_session_engaged | event_count | rows_with_engagement_time | engagement_time_coverage_rate |
|---|---|---:|---:|---:|
| 1 | TRUE | 996,282 | 738,993 | 0.7418 |
| 0 | FALSE | 117,361 | 1,028 | 0.0088 |
| NULL | NULL | 96,504 | 0 | 0.0000 |

![GA4 Staging Validation V15 Engagement Validation](../bi/screenshots/ga4/staging_validation/ga4_staging_validation_v15_engagement_validation.png)

### Key Findings

- Engagement parsing logic works correctly.
- Engagement-time metadata is concentrated within engaged sessions.
- Non-engaged sessions contain minimal engagement time values.
- NULL engagement rows contain no engagement-time metadata.

### Status

```text
PASS
```

---

## V16 — Data Quality Flag Summary

### Result

| total_rows | invalid_event_date_rows | missing_user_pseudo_id_rows | missing_ga_session_id_rows | missing_session_key_rows | invalid_purchase_transaction_id_rows | missing_purchase_revenue_rows | zero_purchase_revenue_rows | negative_purchase_revenue_rows |
|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 1,210,147 | 0 | 0 | 0 | 0 | 300 | 300 | 0 | 0 |

![GA4 Staging Validation V16 Quality Flag Summary](../bi/screenshots/ga4/staging_validation/ga4_staging_validation_v16_quality_flag_summary.png)

### Key Findings

- Core behavioral and session fields are clean.
- Purchase-related quality issues remain visible and documented.
- No zero or negative revenue issues were detected.
- No critical structural issues exist after staging.

### Status

```text
PASS WITH PURCHASE QUALITY FLAGS OBSERVED
```

---

## V17 — Final Staging Validation Status

### Result

| total_rows | staging_validation_status | null_event_date | null_event_timestamp_raw | null_event_name | null_user_pseudo_id | null_ga_session_id | null_session_key | duplicate_proxy_rows | negative_purchase_revenue_rows |
|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|
| 1,210,147 | PASS | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |

![GA4 Staging Validation V17 Final Status](../bi/screenshots/ga4/staging_validation/ga4_staging_validation_v17_final_status.png)

### Key Findings

- No critical null issues exist in core event fields.
- No missing session identifiers were detected.
- No duplicate proxy rows were detected.
- No negative purchase revenue values were detected.
- The staging layer successfully passed all structural validation conditions.

### Final Staging Conclusion

The GA4 staging layer successfully transformed nested raw export data into a reusable analytical foundation while preserving:

- event grain
- session integrity
- behavioral consistency
- acquisition metadata
- engagement metadata
- ecommerce event taxonomy

### Status

```text
FINAL STAGING VALIDATION STATUS: PASS
```

---

# Phase 1C Summary

## Completed

- [x] Created GA4 staging validation SQL file
- [x] Built 17 validation checks
- [x] Validated raw-to-staging row count consistency
- [x] Validated date coverage
- [x] Validated core null patterns
- [x] Validated session field availability
- [x] Validated session volume
- [x] Validated duplicate proxy logic
- [x] Validated event distribution
- [x] Validated ecommerce funnel flags
- [x] Validated purchase quality
- [x] Validated valid transaction logic
- [x] Confirmed transaction duplicate / revenue inflation risk
- [x] Validated acquisition fields
- [x] Quantified attribution sparsity
- [x] Validated item-array behavior
- [x] Validated engagement fields
- [x] Summarized data quality flags
- [x] Produced final staging validation status
- [x] Saved all validation screenshots
- [x] Pushed validation outputs to GitHub

---

# Known Data Quality Notes

| Area | Issue | Impact | Handling |
|---|---|---|---|
| Historical coverage | Dataset limited to 2020-11-01 through 2021-01-31 | Limited long-term seasonality and YoY analysis | Use for KPI prototyping and short-range behavioral analysis |
| Acquisition fields | High `(not set)` rate around 72% | Channel attribution is incomplete at event grain | Preserve `(not set)` and handle in channel mart |
| Revenue completeness | 300 purchase events have missing revenue | Revenue KPIs require caution | Flag and exclude from trusted revenue logic |
| Transaction IDs | 300 purchase events have missing or invalid transaction IDs | Invalid transactions should not count as valid orders | Use cleaned `transaction_id` and validity flags |
| Purchase duplication | Some transaction IDs appear in multiple purchase rows | Raw revenue summation can inflate revenue | Deduplicate at transaction grain downstream |
| Item arrays | Item coverage varies by event type | Product analytics requires separate grain | Do not unnest items in event-level staging |
| Engagement fields | Engagement time is not available on all events | Event-level engagement coverage is sparse | Aggregate carefully at session/event type level |

---

# Modeling Rules Going Forward

## Rule 1 — Preserve Grain Discipline

Do not mix event-level, session-level, item-level, and transaction-level logic in the same table unless the grain is clearly documented.

## Rule 2 — Do Not Sum Raw Purchase Rows Naively

Revenue should not be calculated directly from raw purchase rows without transaction-level deduplication.

## Rule 3 — Keep `(not set)` Visible

Do not silently drop unattributed events.

Attribution gaps should remain visible in downstream BI.

## Rule 4 — Separate Event and Item Modeling

The event-level staging view should not unnest `items`.

If product-level analysis is needed, create a separate item-level fact table.

## Rule 5 — Build Channel Logic Outside Staging

Channel grouping should be implemented in `dim_channel` or downstream marts, not inside staging.

## Rule 6 — Use Validation Before Modeling

Every downstream table should have at least one validation step before it is considered complete.

---

# Project Decisions Log Summary

## Decision — Use January 2021 as Initial Development Window

Reason:

- manageable BigQuery scan cost
- enough event volume
- full 31-day coverage
- realistic ecommerce behavior

## Decision — Use BigQuery as Core Warehouse

Reason:

- public GA4 dataset is native to BigQuery
- SQL-first workflow fits analytics engineering
- clean integration with BI and documentation

## Decision — Use Event-Level Staging View

Reason:

- preserves raw GA4 behavior
- keeps transformations auditable
- allows downstream marts to define business grain separately

## Decision — Store Screenshots by Workflow Area

Current structure:

```text
bi/screenshots/ga4/profiling/
bi/screenshots/ga4/staging_validation/
```

Reason:

- avoids mixing profiling and validation evidence
- makes project review easier
- improves documentation clarity

---

# Current Project Health

## Technical Health

✅ Good

Reasons:

- repository structure is clear
- raw profiling is complete
- staging view is complete
- validation suite is complete
- screenshots are organized
- BigQuery work is backed by GitHub documentation

## Analytics Engineering Health

✅ Strong

Reasons:

- grain is documented
- validation checks are explicit
- data quality risks are surfaced
- downstream modeling requirements are clear
- revenue deduplication risk is documented

## Portfolio Readiness

🟡 In Progress

Reason:

The foundation is strong, but the project still needs:

- session fact table
- dimensional marts
- KPI layer
- BI dashboards
- final README
- business narrative

---

# Next Phase — Phase 2: Session & Commercial Mart Construction

## Status

➡️ Planned / Next

## Objective

Build downstream analytical tables using the validated GA4 staging layer.

The next phase should convert event-level staging data into reusable session, channel, and commercial KPI layers.

## Important Scope Note

The project is still using the January 2021 sample window.

This is intentional.

The one-month development window is used to:

- reduce query cost
- simplify debugging
- stabilize business logic
- validate transformations faster
- build reliable modeling patterns before expanding scope

Full available GA4 data should only be used after the session fact table, mart logic, KPI logic, and validation checks are stable.

## Planned Tasks

- [ ] Build `fact_sessions_daily`
- [ ] Validate session-level grain
- [ ] Build `dim_date`
- [ ] Build `dim_channel`
- [ ] Build `mart_channel_daily`
- [ ] Build `mart_executive_daily`
- [ ] Build `mart_executive_enhanced`
- [ ] Add transaction deduplication logic where revenue is modeled
- [ ] Validate KPI consistency against staging
- [ ] Document mart grain and assumptions

## Immediate Next SQL File

```text
sql/ga4/03_fact_sessions_daily.sql
```

## Immediate Next Validation Need

After building `fact_sessions_daily`, validate:

- row grain
- date coverage
- session counts
- user counts
- purchase session counts
- revenue logic
- attribution behavior
- duplicate session risk

---

# Full Data Expansion Plan

## Current Scope

```text
2021-01-01 to 2021-01-31
```

## Reason

The one-month sample window is used as a controlled development sandbox.

## When to Expand

Expand from the one-month sample window to the full available GA4 range only after:

- staging logic is stable
- session fact table passes validation
- mart logic is stable
- KPI definitions are validated
- revenue deduplication logic is implemented
- attribution handling is documented

## Full Available GA4 Range

```text
2020-11-01 to 2021-01-31
```

---

# Phase 2A — GA4 Session Fact Modeling

## Status

✅ Completed

## Objective

Build a daily session-level fact table from the validated GA4 staging layer.

The purpose of this phase is to convert event-level GA4 data into a stable session-level analytical table that supports downstream commercial KPIs, acquisition analysis, funnel reporting, engagement metrics, and revenue-safe reporting.

## Main SQL File

```text
sql/ga4/03_fact_sessions_daily.sql
```

## Target Table

```text
commercial-analytics-bq-dbx.commercial_analytics_us.fact_sessions_daily
```

## Source View

```text
commercial-analytics-bq-dbx.commercial_analytics_us.stg_ga4_events
```

## Grain

```text
one row per event_date + session_key
```

## Screenshot Directory

```text
bi/screenshots/ga4/session_fact/
```

---

## Modeling Logic Implemented

The session fact table includes:

- session identifiers
- user identifier
- session start and end timestamps
- session duration
- session-level acquisition fields
- event counts
- engagement metrics
- ecommerce funnel indicators
- purchase event indicators
- valid transaction count
- deduplicated revenue
- purchase quality flags

---

## Key Modeling Decisions

### Session Grain

The table is modeled at:

```text
event_date + session_key
```

This supports daily reporting while preserving session-level analytical logic.

### Acquisition Rollup

Session-level acquisition fields are selected from the first available event within the session:

```text
session_source
session_medium
session_campaign
```

### Revenue Deduplication

Revenue is not calculated by naïvely summing raw purchase rows.

Instead, purchase revenue is deduplicated at transaction level using:

```text
event_date + session_key + transaction_id
```

and:

```sql
MAX(purchase_revenue)
```

This avoids revenue inflation caused by duplicated purchase event rows.

---

# Session Fact Pre-Creation Checks

Before creating the final table, the modeling logic was tested step-by-step in BigQuery.

---

## F1 — Session Base Summary Check

### Purpose

Validate the session-level aggregation before creating the final fact table.

### Result

| session_rows | distinct_sessions | min_event_date | max_event_date | avg_events_per_session |
|---:|---:|---|---|---:|
| 118,618 | 118,380 | 2021-01-01 | 2021-01-31 | 10.20 |

![GA4 Session Fact F01 Session Summary](../bi/screenshots/ga4/session_fact/ga4_session_fact_f01_session_summary.png)![alt text](ga4_session_fact_f01_session_summary.png)

### Key Findings

- Session-level aggregation was successfully created from staging.
- Date coverage remains aligned with the January 2021 development window.
- Average events per session remains consistent with staging validation.
- A small difference exists between `session_rows` and `distinct_sessions`, indicating some sessions may span multiple dates or contain cross-date behavior.

### Interpretation

This difference is acceptable for daily session reporting because the intended grain is:

```text
event_date + session_key
```

rather than `session_key` alone.

### Status

```text
PASS
```

---

## F2 — Transaction Revenue Deduplication Check

### Purpose

Validate transaction-level revenue deduplication before creating the final session fact table.

### Result

| transaction_rows | distinct_transaction_ids | deduplicated_revenue |
|---:|---:|---:|
| 895 | 894 | 56,880.0 |

![GA4 Session Fact F02 Revenue Deduplication](../bi/screenshots/ga4/session_fact/ga4_session_fact_f02_revenue_deduplication.png)![alt text](ga4_session_fact_f02_revenue_deduplication.png)

### Key Findings

- Valid transaction rows were successfully identified.
- Distinct valid transaction IDs remain aligned with earlier staging validation.
- Deduplicated revenue equals 56,880.0.
- This differs from raw purchase revenue because duplicated transaction rows were controlled.

### Interpretation

The check confirms that revenue inflation risk identified during staging validation is handled in the session fact model.

This is a critical improvement over naïve raw purchase revenue summation.

### Status

```text
PASS
```

---

# Final Table Creation

## Status

✅ Completed

The final `fact_sessions_daily` table was created after the session aggregation and revenue deduplication checks passed.

## Final Modeling Outcome

The table is now ready for downstream:

- session KPI validation
- channel marts
- executive daily marts
- conversion analysis
- revenue-safe KPI modeling
- BI-ready reporting layers

---

# Phase 2A Summary

## Completed

- [x] Reviewed old `fact_sessions_daily` logic
- [x] Replaced outdated project references
- [x] Rebuilt the fact model using validated staging fields
- [x] Added session-level grain logic
- [x] Added acquisition rollup logic
- [x] Added engagement metrics
- [x] Added ecommerce funnel metrics
- [x] Added purchase quality flags
- [x] Added transaction-level revenue deduplication
- [x] Tested `session_base`
- [x] Tested session summary output
- [x] Tested transaction revenue logic
- [x] Tested revenue deduplication output
- [x] Tested final model output before table creation
- [x] Created `fact_sessions_daily`

---

# Next Step

## Phase 2B — Session Fact Validation

The next step is to create a dedicated validation SQL file for `fact_sessions_daily`.

Suggested file:

```text
sql/validation/ga4/03b_validate_fact_sessions_daily.sql
```

Validation should include:

- row count validation
- session grain validation
- date coverage validation
- duplicate session-key/date validation
- revenue consistency validation
- purchase session validation
- acquisition distribution validation
- engagement metric validation
- final fact validation status

حق با توئه؛ من بد گفتم. **FSV1 و FSV4 باید در project tracker بیایند، فقط screenshot برایشان نمی‌گذاریم.** این نسخه درست است:

````markdown
---

## FSV1 — Fact Table Row Count

### Purpose

Confirm that `fact_sessions_daily` was created successfully and contains the expected number of session-level rows.

### Result

| total_fact_rows |
|---:|
| 118,618 |

### Key Findings

- The fact table was created successfully.
- The table contains 118,618 session-level rows.
- Row volume is consistent with the expected January 2021 session aggregation output.

### Screenshot

```text
Not stored. This was a basic row-count sanity check.
````

### Status

```text
PASS
```

---

## FSV2 — Session Grain Uniqueness Validation

### Purpose

Confirm that the fact table contains one row per:

```text
event_date + session_key
```

### Result

| total_rows | distinct_session_grain | duplicate_session_grain_rows |
| ---------: | ---------------------: | ---------------------------: |
|    118,618 |                118,618 |                            0 |

![GA4 Session Fact Validation V02 Grain Uniqueness](../bi/screenshots/ga4/session_fact_validation/ga4_session_fact_validation_v02_grain_uniqueness.png)![alt text](ga4_session_fact_validation_v02_grain_uniqueness.png)

### Key Findings

* Total rows match the distinct session grain count.
* No duplicate rows exist at the intended grain.
* The table preserves the intended daily session-level grain.

### Status

```text
PASS
```

---

## FSV3 — Date Coverage Validation

### Purpose

Confirm that the session fact table covers the expected January 2021 development window.

### Result

| min_event_date | max_event_date | distinct_dates |
| -------------- | -------------- | -------------: |
| 2021-01-01     | 2021-01-31     |             31 |

![GA4 Session Fact Validation V03 Date Coverage](../bi/screenshots/ga4/session_fact_validation/ga4_session_fact_validation_v03_date_coverage.png)![alt text](ga4_session_fact_validation_v03_date_coverage.png)

### Key Findings

* The session fact table covers the full January 2021 window.
* All 31 expected dates are present.
* Date coverage remains consistent with the staging layer and raw profiling window.

### Status

```text
PASS
```

---

## FSV4 — Null Critical Field Validation

### Purpose

Validate that required analytical fields are populated in the session fact table.

### Result

| total_rows | null_event_date | null_session_key | null_user_pseudo_id | null_session_start | null_session_end | null_session_source | null_session_medium | null_session_campaign |
| ---------: | --------------: | ---------------: | ------------------: | -----------------: | ---------------: | ------------------: | ------------------: | --------------------: |
|    118,618 |               0 |                0 |                   0 |                  0 |                0 |                   0 |                   0 |                     0 |

### Key Findings

* No null values exist in critical session identifiers.
* Session start and end timestamps are fully populated.
* Acquisition fields are fully populated after `(not set)` normalization.
* The table is structurally safe for downstream KPI modeling.

### Screenshot

```text
Not stored. This was a basic structural null check.
```

### Status

```text
PASS
```

```
```
بله، طبق تصمیم قبلی:

```text
FSV5 و FSV6 → در tracker می‌آیند، ولی screenshot لازم ندارند.
FSV7 و FSV8 → هم در tracker می‌آیند، هم screenshot لازم دارند.
```

````markdown
---

## FSV5 — Session Duration Validation

### Purpose

Inspect the distribution of session duration values in `fact_sessions_daily`.

### Result

| min_session_duration | max_session_duration | avg_session_duration | negative_duration_sessions | zero_duration_sessions |
|---:|---:|---:|---:|---:|
| 0 | 72,560 | 164.66 | 0 | 14,098 |

### Key Findings

- No negative session durations were detected.
- Some sessions have zero duration, which is expected in GA4-style behavioral data.
- Average session duration is 164.66 seconds.
- The maximum session duration is high and should be treated as a possible long-session/outlier behavior, not as a modeling failure.

### Screenshot

```text
Not stored. This was a supporting distribution check.
````

### Status

```text
PASS
```

---

## FSV6 — Event Count Validation

### Purpose

Inspect event-count distribution per session.

### Result

| min_events_per_session | max_events_per_session | avg_events_per_session | zero_event_sessions |
| ---------------------: | ---------------------: | ---------------------: | ------------------: |
|                      1 |                  1,007 |                  10.20 |                   0 |

### Key Findings

* Every session contains at least one event.
* No zero-event sessions were detected.
* Average events per session remains consistent with earlier staging validation.
* The maximum event count indicates possible high-activity sessions, but does not break the model.

### Screenshot

```text
Not stored. This was a supporting distribution check.
```

### Status

```text
PASS
```

---

## FSV7 — Acquisition Distribution Validation

### Purpose

Inspect normalized session-level acquisition fields.

### Result

Top acquisition combinations:

| session_source                   | session_medium | session_campaign | sessions | session_share |
| -------------------------------- | -------------- | ---------------- | -------: | ------------: |
| `(not set)`                      | `(not set)`    | `(not set)`      |   91,291 |        0.7696 |
| `google`                         | `organic`      | `(organic)`      |   12,430 |        0.1048 |
| `shop.googlemerchandisestore...` | `referral`     | `(referral)`     |    3,712 |        0.0313 |
| `(direct)`                       | `(none)`       | `(direct)`       |    3,175 |        0.0268 |
| `<Other>`                        | `<Other>`      | `<Other>`        |    2,011 |        0.0170 |

![GA4 Session Fact Validation V07 Acquisition Distribution](../bi/screenshots/ga4/session_fact_validation/ga4_session_fact_validation_v07_acquisition_distribution.png)![alt text](ga4_session_fact_validation_v07_acquisition_distribution.png)

### Key Findings

* Session-level acquisition rollup works correctly.
* `(not set)` remains the dominant acquisition bucket.
* Organic Google traffic is the largest identifiable acquisition source.
* Referral, direct, CPC, affiliate, and email traffic are visible in the session fact layer.
* Attribution sparsity remains a source-data limitation and should stay visible in downstream marts.

### Status

```text
PASS WITH ATTRIBUTION SPARSITY OBSERVED
```

---

## FSV8 — Not Set Acquisition Rate Validation

### Purpose

Quantify attribution sparsity in session-level acquisition fields.

### Result

| total_sessions | not_set_source_sessions | not_set_source_rate | not_set_medium_sessions | not_set_medium_rate | not_set_campaign_sessions | not_set_campaign_rate |
| -------------: | ----------------------: | ------------------: | ----------------------: | ------------------: | ------------------------: | --------------------: |
|        118,618 |                  91,472 |              0.7711 |                  91,291 |              0.7696 |                    91,292 |                0.7696 |

![GA4 Session Fact Validation V08 Not Set Acquisition Rate](../bi/screenshots/ga4/session_fact_validation/ga4_session_fact_validation_v08_not_set_acquisition_rate.png)![alt text](ga4_session_fact_validation_v08_not_set_acquisition_rate.png)

### Key Findings

* Around 77% of sessions have `(not set)` source values.
* Around 77% of sessions have `(not set)` medium and campaign values.
* Attribution sparsity increased slightly at session grain compared with event-grain staging validation.
* This confirms that downstream channel reporting must include an explicit unattributed/unknown bucket.

### Status

```text
PASS WITH HIGH ATTRIBUTION SPARSITY OBSERVED
```

```
```
درست:
`FSV9` و `FSV11` در tracker می‌آیند، **ولی screenshot لازم ندارند**.
`FSV10` و `FSV12` هم در tracker می‌آیند، **هم screenshot دارند**.

````markdown
---

## FSV9 — Engagement Validation

### Purpose

Inspect engagement metric coverage in the session fact table.

### Result

| total_sessions | engaged_sessions | engaged_session_rate | avg_engagement_time_msec | max_engagement_time_msec |
|---:|---:|---:|---:|---:|
| 118,618 | 111,357 | 0.9388 | 49,413.60 | 53,156,838 |

### Key Findings

- 93.88% of sessions are marked as engaged.
- Engagement fields were successfully carried from staging into the session fact table.
- Average engagement time is populated and usable for downstream session engagement KPIs.
- The maximum engagement time is high and should be treated as potential long-session/outlier behavior, not a table failure.

### Screenshot

```text
Not stored. This was a supporting engagement coverage check.
````

### Status

```text
PASS
```

---

## FSV10 — Funnel Event Validation

### Purpose

Validate that ecommerce funnel event counts were preserved after session-level aggregation.

### Result

| total_view_item_events | total_add_to_cart_events | total_begin_checkout_events | total_purchase_events |
| ---------------------: | -----------------------: | --------------------------: | --------------------: |
|                 86,971 |                   15,522 |                      11,034 |                 1,204 |

![GA4 Session Fact Validation V10 Funnel Validation](../bi/screenshots/ga4/session_fact_validation/ga4_session_fact_validation_v10_funnel_validation.png)![alt text](ga4_session_fact_validation_v10_funnel_validation.png)

### Key Findings

* Funnel event totals match the staging-level validation outputs.
* `view_item`, `add_to_cart`, `begin_checkout`, and `purchase` counts were preserved.
* Session-level aggregation did not lose ecommerce funnel events.
* The fact table is safe for downstream funnel KPI modeling.

### Status

```text
PASS
```

---

## FSV11 — Purchase Session Validation

### Purpose

Inspect purchase-session behavior after transaction and revenue logic were applied.

### Result

| purchase_sessions | avg_transactions_per_purchase_session | avg_purchase_session_revenue | max_purchase_session_revenue |
| ----------------: | ------------------------------------: | ---------------------------: | ---------------------------: |
|             1,116 |                                  0.80 |                        50.97 |                      1,200.0 |

### Key Findings

* 1,116 sessions contained at least one purchase event.
* Average valid transactions per purchase session is below 1 because some purchase sessions contain invalid transaction IDs or missing revenue.
* Average purchase-session revenue is 50.97.
* The maximum purchase-session revenue is 1,200.0.

### Screenshot

```text
Not stored. This was a supporting purchase-session behavior check.
```

### Status

```text
PASS WITH KNOWN PURCHASE QUALITY LIMITATIONS
```

---

## FSV12 — Revenue Integrity Validation

### Purpose

Validate that deduplicated transaction revenue logic works correctly in the session fact table.

### Result

| total_valid_transactions | total_deduplicated_revenue | negative_revenue_sessions | zero_revenue_purchase_sessions |
| -----------------------: | -------------------------: | ------------------------: | -----------------------------: |
|                      895 |                   56,880.0 |                         0 |                            270 |

![GA4 Session Fact Validation V12 Revenue Integrity](../bi/screenshots/ga4/session_fact_validation/ga4_session_fact_validation_v12_revenue_integrity.png)![alt text](ga4_session_fact_validation_v12_revenue_integrity.png)

### Key Findings

* Total valid transactions equal 895 after session-level aggregation.
* Deduplicated revenue equals 56,880.0.
* No negative revenue sessions were detected.
* 270 purchase sessions have purchase activity but zero deduplicated revenue, which aligns with the known invalid transaction ID / missing revenue issue identified during staging validation.
* Revenue inflation risk is controlled by transaction-level deduplication.

### Status

```text
PASS WITH KNOWN PURCHASE QUALITY LIMITATIONS
```

```
```




## Future Expansion Work

- [ ] Replace hardcoded January 2021 filters with configurable date ranges
- [ ] Re-run staging on full available GA4 range
- [ ] Re-run validation suite on full range
- [ ] Compare one-month metrics vs full-range metrics
- [ ] Confirm no new data quality patterns appear
- [ ] Update documentation if full-range findings differ

---

# Future Phase Roadmap

## Phase 3 — Olist Ingestion

### Planned Tasks

- [ ] Load Olist CSVs into Databricks
- [ ] Clean data types
- [ ] Create curated Olist datasets
- [ ] Export transformed datasets into BigQuery
- [ ] Store Olist screenshots in `bi/screenshots/olist/`

---

## Phase 4 — Data Quality Layer

### Planned Tasks

- [ ] Validate duplicates
- [ ] Validate primary and foreign keys
- [ ] Validate NULL patterns
- [ ] Validate date coverage
- [ ] Document data quality issues

---

## Phase 5 — Modeling & Integration

### Planned Tasks

- [ ] Create dimensional models
- [ ] Build fact tables
- [ ] Create commercial marts
- [ ] Integrate GA4 behavioral data with commercial modeling layer
- [ ] Integrate Olist transactional data
- [ ] Document source limitations and join assumptions
- [ ] Build acquisition-to-revenue analytical logic where appropriate

---

## Phase 6 — KPI Layer

### Planned Tasks

- [ ] Define conversion KPIs
- [ ] Define revenue KPIs
- [ ] Define AOV logic
- [ ] Define engagement KPIs
- [ ] Create executive KPI layer
- [ ] Validate KPI logic

---

## Phase 7 — BI Layer

### Planned Tasks

- [ ] Build Executive dashboard
- [ ] Build Funnel dashboard
- [ ] Build Acquisition dashboard
- [ ] Export dashboard screenshots
- [ ] Store dashboard screenshots in `bi/screenshots/dashboards/`

---

## Phase 8 — A/B Testing Layer

### Planned Tasks

- [ ] Define experiment framework
- [ ] Build assignment logic
- [ ] Calculate treatment vs control KPIs
- [ ] Evaluate absolute and relative lift
- [ ] Make ship / no-ship recommendation

---

## Phase 9 — Final Packaging

### Planned Tasks

- [ ] Final README
- [ ] Architecture diagram
- [ ] Data dictionary
- [ ] KPI definitions
- [ ] Business recommendation summary
- [ ] Final dashboard screenshots
- [ ] Final project review checklist

---

# Final Notes

The GA4 profiling, staging, and staging validation phases are now complete.

The project has a reliable analytical foundation and is ready to move into downstream modeling.

The most important risks to carry forward are:

- attribution sparsity
- transaction duplication
- missing purchase revenue
- transaction-level revenue deduplication
- strict grain separation between event, session, item, and transaction layers

These risks are documented and should be explicitly handled in future marts and BI reporting.