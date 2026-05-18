

````markdown
# Decisions Log — Commercial Analytics

This document records key technical and analytical decisions made during the Commercial Analytics project.

The purpose of this log is to make project assumptions, modeling choices, and data quality decisions explicit and reviewable.

---

# Decision 001 — Use January 2021 as the GA4 Profiling Window

## Status

Accepted

## Context

The GA4 public ecommerce dataset contains event-level data from:

- `2020-11-01`
- `2021-01-31`

The full dataset is available for analysis, but raw GA4 event tables can become expensive and inefficient to query without date filters.

## Decision

Use January 2021 as the primary profiling sample window:

```text
2021-01-01 to 2021-01-31
````

## Rationale

This window provides:

* full month coverage
* sufficient event volume
* realistic behavioral scale
* manageable BigQuery scan cost

## Impact

All raw profiling checks in `sql/ga4/01_data_profiling.sql` use January 2021 unless explicitly marked as global coverage validation.

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

This approach limits scanned tables and keeps profiling queries cost-aware.

## Impact

All GA4 profiling and transformation queries should use date filters unless a full historical scan is intentionally required.

---

# Decision 003 — Treat `user_pseudo_id` as the Primary Anonymous User Identifier

## Status

Accepted

## Context

The GA4 dataset contains `user_pseudo_id`, while authenticated `user_id` coverage is limited.

## Decision

Use `user_pseudo_id` as the primary user-level identifier.

## Rationale

`user_pseudo_id` is consistently populated and supports anonymous behavioral analysis.

## Impact

User-level metrics should be interpreted as device/browser-level anonymous user behavior, not authenticated customer identity.

---

# Decision 004 — Use Composite Session Key

## Status

Accepted

## Context

`ga_session_id` is stored inside `event_params`.

It should not be assumed globally unique across all users.

## Decision

Use a composite session key:

```text
user_pseudo_id + ga_session_id
```

## Rationale

Combining user and session identifiers reduces the risk of session collision.

## Impact

Session-level modeling should use composite session logic in staging and marts.

---

# Decision 005 — Extract GA4 Parameters Selectively

## Status

Accepted

## Context

GA4 stores many attributes inside the nested `event_params` array.

Flattening every parameter would create unnecessary complexity and noisy wide tables.

## Decision

Extract only high-value analytical parameters during staging.

Initial candidates include:

* `ga_session_id`
* `ga_session_number`
* `page_location`
* `page_title`
* `source`
* `medium`
* `campaign`

## Rationale

Selective extraction keeps staging tables readable, maintainable, and aligned with business use cases.

## Impact

Future staging logic should remain event-aware and avoid blindly flattening all parameters.

---

# Decision 006 — Use Event-Level Acquisition Parameters for Profiling

## Status

Accepted

## Context

GA4 includes top-level `traffic_source` fields, but those are more user-scoped / first-user oriented.

For this project, event/session-level acquisition signals are more useful for downstream channel analysis.

## Decision

Use `source`, `medium`, and `campaign` extracted from `event_params` for event-level acquisition profiling.

## Rationale

This better reflects acquisition signals available at event/session behavior level.

## Impact

Channel modeling should include normalization and fallback handling because many rows contain `(not set)` values.

---

# Decision 007 — Treat `(not set)` Transaction IDs as Invalid

## Status

Accepted

## Context

During purchase profiling, some purchase events contained:

```text
transaction_id = '(not set)'
```

This is a placeholder value, not a valid transaction identifier.

## Decision

Do not count `'(not set)'` as a valid transaction ID.

Valid transaction logic should exclude:

```sql
ecommerce.transaction_id IS NULL
OR ecommerce.transaction_id = '(not set)'
```

## Rationale

Counting placeholder values as real transactions would distort transaction-level metrics.

## Impact

Transaction counts and purchase quality checks must exclude or flag invalid transaction IDs.

---

# Decision 008 — Flag Missing Purchase Revenue

## Status

Accepted

## Context

Purchase transaction quality profiling showed that some purchase events have missing revenue.

## Decision

Do not silently treat missing revenue as clean zero revenue.

Instead:

* flag missing revenue
* document completeness issue
* handle carefully in downstream KPI logic

## Rationale

`NULL` revenue means missing or unavailable value, not necessarily zero-value purchase.

## Impact

Revenue KPIs must use defensive logic and disclose known revenue completeness limitations.

---

# Decision 009 — Deduplicate Purchase Revenue at Transaction Grain

## Status

Accepted

## Context

Transaction-level validation identified duplicated purchase event rows for some valid transaction IDs.

In several cases, summed revenue was greater than the maximum transaction revenue, indicating potential duplicate purchase event firing.

## Decision

Avoid naïve raw-row summation of purchase revenue.

Future revenue modeling should deduplicate at transaction grain using logic such as:

* valid `transaction_id`
* row ranking
* `MAX(purchase_revenue)` where appropriate
* explicit duplicate flags

## Rationale

Raw purchase rows may inflate revenue if duplicate purchase events are summed directly.

## Impact

Revenue marts should be built at transaction grain before aggregating revenue KPIs.

---

# Decision 010 — Keep Raw Profiling Separate from Staging Logic

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

# Decision 011 — Store Screenshots Under `bi/screenshots/`

## Status

Accepted

## Context

Screenshots are supporting evidence for profiling, QA checks, and dashboards.

## Decision

Store screenshots by analytical area:

```text
bi/screenshots/ga4/
bi/screenshots/olist/
bi/screenshots/dashboards/
```

## Rationale

Keeping screenshots under `bi/` avoids cluttering `docs/` and creates a cleaner artifact structure.

## Impact

Markdown files inside `docs/` should reference screenshots using relative paths like:

```text
../bi/screenshots/ga4/<filename>.png
```

---

# Decision 012 — Do Not Screenshot Every Query

## Status

Accepted

## Context

Not every profiling query creates useful visual evidence.

## Decision

Keep screenshots only for analytically meaningful outputs.

Screenshots are kept for:

* date coverage
* null checks
* duplicate proxy
* event distribution
* purchase validation
* item coverage
* daily event volume
* user/session volume
* session availability
* traffic source distribution
* transaction quality
* revenue transaction validation
* event parameter profiling

Screenshots are not required for:

* A1 sample rows
* C3 invalid date validation

## Rationale

This avoids screenshot spam and keeps project evidence selective and reviewable.

## Impact

Screenshots should support analytical findings, not simply prove that SQL was run.

---

# Decision 013 — Maintain a Separate Project Tracker

## Status

Accepted

## Context

The project includes multiple phases across profiling, staging, modeling, BI, and experimentation.

## Decision

Use `docs/project_tracker.md` as the operational project tracker.

## Rationale

The tracker keeps phase progress, validation results, and upcoming work visible.

## Impact

The tracker should summarize work completed and decisions made, while detailed architecture and KPI definitions may later move into dedicated documentation files.

---

# Decision 014 — Document Known Dataset Limitations

## Status

Accepted

## Context

The GA4 public sample dataset has several limitations:

* short historical coverage
* anonymous user identity
* sparse acquisition parameters
* missing revenue values
* invalid transaction IDs
* duplicate purchase event patterns

## Decision

Document these limitations explicitly rather than hiding them.

## Rationale

Transparent limitations make the project more credible and interview-ready.

## Impact

Final README and dashboard interpretation should include known limitations and assumptions.

---

# Decision 015 — Proceed to GA4 Staging After Profiling

## Status

Accepted

## Context

Raw profiling completed the required checks for:

* structure
* completeness
* duplicate risk
* sessions
* acquisition fields
* ecommerce purchase quality
* event parameters

## Decision

Proceed to GA4 staging as the next technical phase.

## Rationale

The raw source is sufficiently understood to design a clean staging layer.

## Impact

Next phase should focus on building `stg_ga4_events` with:

* extracted core fields
* session identifiers
* acquisition fields
* purchase fields
* invalid transaction flags
* defensive revenue handling

```
```

