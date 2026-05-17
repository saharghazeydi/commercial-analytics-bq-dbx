/*
GA4 Data Profiling
Project: Commercial Analytics
BigQuery Project ID: commercial-analytics-bq-dbx
Dataset: commercial_analytics_us
Source: bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*
Sample window: 2021-01-01 to 2021-01-31

Purpose:
- Validate basic data availability and schema structure
- Check date coverage, null rates, duplicate proxy risk, and event distribution
- Confirm purchase and item-level event presence before staging/modeling

Note:
The sample window is used to reduce query cost while validating event-level structure.
Global date coverage is checked separately.
*/

-- A1) sample rows (structure sanity)
SELECT *
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20210101' AND '20210131'
LIMIT 10;

-- B1) date coverage (sample window)
SELECT
  MIN(PARSE_DATE('%Y%m%d', event_date)) AS min_date,
  MAX(PARSE_DATE('%Y%m%d', event_date)) AS max_date,
  COUNT(*) AS total_rows
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20210101' AND '20210131';

-- B1b) date coverage (global)
SELECT
  MIN(PARSE_DATE('%Y%m%d', event_date)) AS global_min_date,
  MAX(PARSE_DATE('%Y%m%d', event_date)) AS global_max_date
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`;

-- C1) null rates for core identifiers (sample window)
SELECT
  COUNT(*) AS total_rows,
  SUM(CASE WHEN event_date IS NULL THEN 1 ELSE 0 END) AS null_event_date,
  SUM(CASE WHEN event_timestamp IS NULL THEN 1 ELSE 0 END) AS null_event_timestamp,
  SUM(CASE WHEN event_name IS NULL THEN 1 ELSE 0 END) AS null_event_name,
  SUM(CASE WHEN user_pseudo_id IS NULL THEN 1 ELSE 0 END) AS null_user_pseudo_id
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20210101' AND '20210131';

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

-- C3) invalid event_date format check
SELECT
  COUNT(*) AS total_rows,
  SUM(CASE WHEN SAFE.PARSE_DATE('%Y%m%d', event_date) IS NULL THEN 1 ELSE 0 END) AS invalid_event_date_rows
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20210101' AND '20210131';

-- D1) Top event distribution (sample window)
SELECT
  event_name,
  COUNT(*) AS event_count
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20210101' AND '20210131'
GROUP BY 1
ORDER BY event_count DESC
LIMIT 20;

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

-- D4) Daily event volume distribution (sample window)
SELECT
  PARSE_DATE('%Y%m%d', event_date) AS event_dt,
  COUNT(*) AS event_count
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20210101' AND '20210131'
GROUP BY event_dt
ORDER BY event_dt;

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