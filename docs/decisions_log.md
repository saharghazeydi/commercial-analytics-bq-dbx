# Decisions Log — Commercial Analytics

This document records key technical, analytical, and data quality decisions made during the Commercial Analytics project.

The purpose of this log is to make project assumptions, modeling choices, validation logic, and known limitations explicit, reviewable, and defensible.

---

# Decision 001 — Use January 2021 as the Initial GA4 Development Window

## Status

Accepted

## Context

The GA4 public ecommerce dataset contains event-level data from:

```text
2020-11-01 to 2021-01-31
```

Although the full dataset is available, raw GA4 event tables can become inefficient to query repeatedly during early development.

## Decision

Use January 2021 as the initial profiling, staging, and validation window:

```text
2021-01-01 to 2021-01-31
```

## Rationale

This one-month window provides:

- full calendar-month coverage
- sufficient event volume
- realistic ecommerce behavior
- manageable BigQuery scan cost
- faster debugging and iteration

## Impact

Profiling, staging, and staging validation currently use January 2021 unless explicitly marked as global coverage validation.

Full-range modeling should only happen after staging, fact tables, marts, and KPI logic are stable.

---

# Decision 002 — Use `_TABLE_SUFFIX` Filtering for GA4 Wildcard Tables

## Status

Accepted

## Context

GA4 public export tables are stored as daily sharded tables using the pattern:

```text
events_YYYYMMDD
```

## Decision

Use wildcard table access with `_TABLE_SUFFIX` filters:

```sql
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20210101' AND '20210131'
```

## Rationale

This limits scanned tables and keeps queries cost-aware.

## Impact

All GA4 profiling, staging, and validation queries should use explicit date filters unless a full historical scan is intentionally required.

---

# Decision 003 — Treat `user_pseudo_id` as the Primary Anonymous User Identifier

## Status

Accepted

## Context

The GA4 dataset contains `user_pseudo_id`, while authenticated `user_id` coverage is limited or unavailable for reliable customer-level modeling.

## Decision

Use `user_pseudo_id` as the primary user-level identifier.

## Rationale

`user_pseudo_id` is consistently populated and supports anonymous behavioral analysis.

## Impact

User-level metrics should be interpreted as anonymous device/browser-level behavior, not authenticated customer identity.

---

# Decision 004 — Use Composite Session Key

## Status

Accepted

## Context

`ga_session_id` is stored inside the nested `event_params` array.

It should not be assumed globally unique across all users.

## Decision

Use a composite session key:

```text
user_pseudo_id + ga_session_id
```

## Rationale

Combining user and session identifiers reduces the risk of session collision.

## Impact

Session-level modeling should use the composite `session_key` created in staging.

---

# Decision 005 — Extract GA4 Parameters Selectively

## Status

Accepted

## Context

GA4 stores many attributes inside the nested `event_params` array.

Flattening every parameter would create unnecessary complexity, noisy wide tables, and harder-to-maintain SQL.

## Decision

Extract only high-value analytical parameters during staging.

Extracted parameters include:

- `ga_session_id`
- `ga_session_number`
- `page_location`
- `page_title`
- `page_referrer`
- `engagement_time_msec`
- `session_engaged`
- `source`
- `medium`
- `campaign`
- `search_term`
- `percent_scrolled`
- `coupon`
- `payment_type`

## Rationale

Selective extraction keeps staging readable, maintainable, and aligned with commercial analytics use cases.

## Impact

Future staging logic should remain event-aware and avoid blindly flattening all GA4 parameters.

---

# Decision 006 — Use Event-Level Acquisition Parameters

## Status

Accepted

## Context

GA4 includes top-level `traffic_source` fields, but those are more user-scoped / first-user oriented.

For this project, event/session-level acquisition signals are more useful for downstream channel and session analysis.

## Decision

Use `source`, `medium`, and `campaign` extracted from `event_params`.

## Rationale

This better reflects acquisition signals available at event/session behavior level.

## Impact

Channel modeling should include normalization and fallback handling because many rows contain `(not set)` values.

---

# Decision 007 — Normalize Missing Acquisition Values to `(not set)`

## Status

Accepted

## Context

Acquisition fields may be missing, blank, or unavailable at event grain.

## Decision

Normalize null or blank acquisition fields to:

```text
(not set)
```

## Rationale

This prevents inconsistent handling of missing attribution values across downstream SQL and BI tools.

## Impact

`(not set)` should remain visible in downstream marts and dashboards rather than being silently dropped.

---

# Decision 008 — Keep Channel Grouping Outside Staging

## Status

Accepted

## Context

Staging should remain close to the raw source and focus on extraction, normalization, and quality flags.

Business-level channel grouping requires interpretation and may change over time.

## Decision

Do not create final channel grouping inside `stg_ga4_events`.

Channel grouping should happen later in:

```text
dim_channel
```

or downstream mart logic.

## Rationale

This keeps staging reusable and avoids embedding business assumptions too early.

## Impact

The staging layer contains normalized `source`, `medium`, and `campaign`, but not final channel categories.

---

# Decision 009 — Treat `(not set)` Transaction IDs as Invalid

## Status

Accepted

## Context

During purchase profiling and staging validation, some purchase events contained:

```text
transaction_id = '(not set)'
```

This is a placeholder value, not a valid transaction identifier.

## Decision

Do not count `'(not set)'` as a valid transaction ID.

Valid transaction logic should exclude:

```sql
transaction_id IS NULL
OR transaction_id = '(not set)'
```

## Rationale

Counting placeholder values as real transactions would distort transaction-level metrics.

## Impact

Transaction counts and purchase quality checks must exclude or flag invalid transaction IDs.

---

# Decision 010 — Flag Missing Purchase Revenue

## Status

Accepted

## Context

Purchase transaction quality checks showed that some purchase events have missing revenue.

## Decision

Do not silently treat missing revenue as clean zero revenue.

Instead:

- flag missing revenue
- document completeness issue
- handle carefully in downstream KPI logic

## Rationale

`NULL` revenue means missing or unavailable value, not necessarily zero-value purchase.

## Impact

Revenue KPIs must use defensive logic and disclose known revenue completeness limitations.

---

# Decision 011 — Defer Revenue Deduplication Until Transaction-Level Modeling

## Status

Accepted

## Context

Transaction-level validation identified duplicated purchase event rows for some valid transaction IDs.

In several cases, summed revenue was greater than the maximum transaction revenue, indicating potential duplicate purchase event firing.

## Decision

Do not deduplicate purchase revenue inside event-level staging.

Revenue deduplication should happen later at transaction grain using logic such as:

- valid `transaction_id`
- row ranking
- `MAX(purchase_revenue)` where appropriate
- explicit duplicate flags

## Rationale

Staging should preserve event-level source behavior and expose quality risks, not prematurely collapse business grain.

## Impact

Revenue marts should be built at transaction grain before aggregating revenue KPIs.

---

# Decision 012 — Preserve Event-Level Grain in Staging

## Status

Accepted

## Context

GA4 contains nested and repeated fields such as:

- `event_params`
- `items`
- `ecommerce`

Incorrect use of `UNNEST` can multiply rows and break event-level grain.

## Decision

Create `stg_ga4_events` at event grain:

```text
one row per raw GA4 event
```

Do not unnest `items` in the staging view.

## Rationale

Event-level staging should remain one-to-one with raw GA4 event records.

## Impact

Item-level or product-level analysis should be handled in a separate downstream fact table if needed.

---

# Decision 013 — Add Data Quality Flags Instead of Filtering Rows

## Status

Accepted

## Context

Profiling and validation identified purchase-related quality issues, including missing transaction IDs and missing revenue.

## Decision

Add explicit data quality flags in staging, including:

- `is_invalid_event_date`
- `is_missing_user_pseudo_id`
- `is_missing_ga_session_id`
- `is_missing_session_key`
- `is_invalid_purchase_transaction_id`
- `is_missing_purchase_revenue`
- `is_zero_purchase_revenue`
- `is_negative_purchase_revenue`

## Rationale

Staging should be transparent and auditable.

Rows should not be removed simply because they have quality issues.

## Impact

Downstream marts can decide whether to exclude, flag, or separately report problematic records.

---

# Decision 014 — Create an Event Proxy Key for Validation

## Status

Accepted

## Context

GA4 does not provide a guaranteed globally unique event identifier in the public sample dataset.

## Decision

Create an approximate event proxy key using:

```text
user_pseudo_id + event_timestamp_raw + event_name
```

## Rationale

This provides a practical duplicate proxy check for staging validation.

## Impact

The proxy key is used to confirm that staging did not introduce duplicate event rows.

---

# Decision 015 — Keep Raw Profiling Separate from Staging Logic

## Status

Accepted

## Context

Raw profiling is exploratory and diagnostic, while staging logic should be reusable and production-like.

## Decision

Keep profiling queries in:

```text
sql/ga4/01_data_profiling.sql
```

and staging queries in:

```text
sql/ga4/02_stg_ga4_events.sql
```

## Rationale

Separating profiling from transformation keeps the project structure clean and easier to review.

## Impact

Profiling queries should not be reused directly as production transformations.

---

# Decision 016 — Create a Separate Staging Validation SQL File

## Status

Accepted

## Context

After creating the staging view, the transformation needed structured QA validation.

## Decision

Store staging validation queries in:

```text
sql/validation/ga4/02b_validate_stg_ga4_events.sql
```

## Rationale

Validation logic should be separate from transformation logic.

This makes the workflow easier to audit:

```text
profiling → staging → validation
```

## Impact

Future modeling phases should follow the same pattern:

```text
build SQL
validate SQL
document results
```

---

# Decision 017 — Run Staging SQL as One Unit, Run Validation SQL Step-by-Step

## Status

Accepted

## Context

The staging SQL creates or replaces one BigQuery view.

The validation SQL contains multiple independent checks.

## Decision

Run `02_stg_ga4_events.sql` as one complete query.

Run `02b_validate_stg_ga4_events.sql` section by section.

## Rationale

Staging is a single transformation.

Validation is diagnostic and each result needs to be reviewed independently.

## Impact

Each validation step is documented separately in `project_tracker.md`.

---

# Decision 018 — Keep All 17 Staging Validation Screenshots

## Status

Accepted

## Context

The staging validation suite contains 17 checks covering row count, date coverage, nulls, sessions, duplicates, ecommerce logic, acquisition sparsity, item arrays, engagement fields, and final status.

## Decision

Keep all 17 staging validation screenshots in the repository.

## Rationale

These screenshots are evidence for the completed validation suite.

The README may show only selected key screenshots, but the repository should preserve the full evidence layer.

## Impact

All staging validation screenshots are stored in:

```text
bi/screenshots/ga4/staging_validation/
```

---

# Decision 019 — Standardize GA4 Profiling Screenshot Names

## Status

Accepted

## Context

Initial profiling screenshot names were descriptive but not consistently step-numbered.

After staging validation screenshots were standardized, profiling screenshots were renamed for consistency.

## Decision

Use this profiling screenshot naming pattern:

```text
ga4_profiling_<step>_<description>.png
```

Examples:

```text
ga4_profiling_b01_date_coverage_sample.png
ga4_profiling_d08_purchase_transaction_quality.png
ga4_profiling_d10_event_parameter_key_frequency.png
```

## Rationale

Consistent screenshot naming improves repo readability and makes documentation easier to maintain.

## Impact

All `project_tracker.md` image paths must use the updated profiling screenshot names.

---

# Decision 020 — Store Screenshots by Workflow Area

## Status

Accepted

## Context

Screenshots are supporting evidence for profiling, QA checks, and dashboards.

## Decision

Store screenshots by workflow area:

```text
bi/screenshots/ga4/profiling/
bi/screenshots/ga4/staging_validation/
bi/screenshots/olist/
bi/screenshots/dashboards/
```

## Rationale

This avoids mixing profiling, validation, dashboard, and source-specific evidence.

## Impact

Markdown files inside `docs/` should reference screenshots using relative paths like:

```text
../bi/screenshots/ga4/profiling/<filename>.png
../bi/screenshots/ga4/staging_validation/<filename>.png
```

---

# Decision 021 — Do Not Screenshot Every Query

## Status

Accepted

## Context

Not every query creates useful visual evidence.

## Decision

Keep screenshots only for analytically meaningful outputs.

Screenshots are kept for:

- profiling summaries
- data quality checks
- validation results
- dashboard outputs
- final QA evidence

Screenshots are not required for:

- simple sample row inspection
- minor exploratory queries
- quick sanity checks unless they support documentation

## Rationale

This avoids screenshot spam and keeps project evidence reviewable.

## Impact

Screenshots should support analytical findings, not simply prove that SQL was run.

---

# Decision 022 — Maintain a Separate Project Tracker

## Status

Accepted

## Context

The project includes multiple phases across profiling, staging, validation, modeling, BI, and experimentation.

## Decision

Use:

```text
docs/project_tracker.md
```

as the operational project tracker.

## Rationale

The tracker keeps phase progress, validation results, and upcoming work visible.

## Impact

The tracker should summarize work completed and decisions made, while detailed architecture and KPI definitions may later move into dedicated documentation files.

---

# Decision 023 — Document Known Dataset Limitations

## Status

Accepted

## Context

The GA4 public sample dataset has several limitations:

- short historical coverage
- anonymous user identity
- sparse acquisition parameters
- missing revenue values
- invalid transaction IDs
- duplicate purchase event patterns
- inconsistent item coverage across event types

## Decision

Document these limitations explicitly rather than hiding them.

## Rationale

Transparent limitations make the project more credible and interview-ready.

## Impact

Final README and dashboard interpretation should include known limitations and assumptions.

---

# Decision 024 — Keep `(not set)` Attribution Visible

## Status

Accepted

## Context

Staging validation showed high `(not set)` rates in event-level acquisition fields.

## Decision

Preserve `(not set)` values in downstream modeling.

Do not silently drop unattributed rows.

## Rationale

Attribution sparsity is a real data quality and interpretation issue.

Hiding it would make channel reporting misleading.

## Impact

Channel marts and dashboards should include an explicit unknown/unattributed category.

---

# Decision 025 — Treat Staging Validation as Passed with Known Data Quality Constraints

## Status

Accepted

## Context

Final staging validation passed all critical structural checks:

- row count matched raw source
- date coverage was complete
- core fields were non-null
- session identifiers were complete
- no duplicate proxy rows were detected
- no negative revenue rows were detected

However, ecommerce-specific quality issues remain:

- invalid transaction IDs
- missing purchase revenue
- duplicate transaction IDs
- attribution sparsity

## Decision

Approve the staging layer for downstream modeling.

## Rationale

The remaining issues are source-data limitations, not staging transformation failures.

## Impact

Downstream marts can now be built, but must include defensive logic for revenue, transactions, attribution, and grain handling.

---

# Decision 026 — Expand to Full GA4 Data Only After Modeling Logic Is Stable

## Status

Accepted

## Context

The project currently uses January 2021 as the development window.

The full public GA4 range is:

```text
2020-11-01 to 2021-01-31
```

## Decision

Do not expand to the full GA4 range immediately.

Expand only after:

- session fact table is built and validated
- mart logic is stable
- KPI definitions are validated
- transaction deduplication logic is implemented
- attribution handling is documented

## Rationale

Expanding too early increases debugging cost and can spread unstable logic across a larger dataset.

## Impact

Current work continues on January 2021 until modeling and validation patterns are stable.

---

# Decision 027 — Proceed to Session & Commercial Mart Construction

## Status

Accepted

## Context

GA4 profiling, staging, and staging validation are complete.

The staging layer has passed final validation and is ready for downstream modeling.

## Decision

Proceed to:

```text
Phase 2 — Session & Commercial Mart Construction
```

with the immediate next SQL file:

```text
sql/ga4/03_fact_sessions_daily.sql
```

## Rationale

The project now has a validated event-level foundation.

The next step is to convert events into stable analytical grains such as:

- session-level fact table
- channel dimension
- daily channel mart
- executive KPI mart

## Impact

Future work should focus on:

- session grain definition
- session-level KPI logic
- attribution rollup
- transaction/revenue safeguards
- mart validation

---

# Decision 028 — Enforce Grain Discipline in Downstream Modeling

## Status

Accepted

## Context

GA4 contains multiple analytical grains:

- event grain
- session grain
- item grain
- transaction grain
- daily mart grain

Mixing these grains incorrectly can create inflated KPIs.

## Decision

Every downstream table must document its grain.

## Rationale

Clear grain definition prevents:

- revenue inflation
- duplicate sessions
- incorrect conversion rates
- misleading item/product analytics
- broken BI metrics

## Impact

Future fact and mart files should explicitly document grain in SQL comments and project documentation.

---

# Decision 029 — Use Validation Before Marking Any Downstream Table Complete

## Status

Accepted

## Context

Staging validation materially improved project quality and exposed important issues early.

## Decision

Every future modeled table should have validation checks before being considered complete.

## Rationale

Validation-first workflow is more realistic and interview-ready than simply building tables and dashboards.

## Impact

Future phases should include validation for:

- row counts
- grain uniqueness
- date coverage
- nulls
- duplicate risk
- KPI consistency
- revenue logic
- attribution behavior

---

# Decision 030 — Keep Staging Close to Raw Source, Put Business Logic in Marts

## Status

Accepted

## Context

Staging currently extracts, normalizes, and flags data while preserving raw event behavior.

Business logic such as final channel grouping, revenue deduplication, and executive KPI calculation belongs downstream.

## Decision

Keep staging as a source-aligned analytical layer.

Place business rules in fact tables, dimensions, marts, or KPI layers.

## Rationale

This creates cleaner separation of responsibilities:

```text
staging = extraction + normalization + quality flags
facts/dims = grain definition + business modeling
marts = KPI-ready business outputs
BI = presentation and interpretation
```

## Impact

Future modeling should avoid overloading `stg_ga4_events` with business logic.

---

# Final Decision Summary

The project has completed:

- GA4 raw profiling
- GA4 event-level staging
- GA4 staging validation

The staging layer is approved for downstream modeling.

The most important modeling principles going forward are:

- preserve grain discipline
- validate every downstream table
- deduplicate revenue at transaction grain
- keep `(not set)` attribution visible
- separate event, session, item, transaction, and mart logic
- expand to full GA4 data only after logic is stable