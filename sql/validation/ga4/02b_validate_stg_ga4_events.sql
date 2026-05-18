-- 02b_validate_stg_ga4_events.sql
-- Purpose: Validate GA4 staging view after flattening raw GA4 event data
-- Target view: commercial-analytics-bq-dbx.commercial_analytics_us.stg_ga4_events
-- Grain expected: one row per raw GA4 event
-- Sample window: 2021-01-01 to 2021-01-31
--
-- Important:
-- These checks do not modify data.
-- Run each section separately in BigQuery and save screenshots where useful.

-- ============================================================
-- V1) Raw vs staging row count validation
-- Expected: raw_row_count = staging_row_count
-- ============================================================

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


-- ============================================================
-- V2) Staging date range validation
-- Expected: 2021-01-01 to 2021-01-31
-- ============================================================

SELECT
  MIN(event_date) AS min_event_date,
  MAX(event_date) AS max_event_date,
  COUNT(DISTINCT event_date) AS distinct_event_dates,
  COUNT(*) AS total_rows
FROM `commercial-analytics-bq-dbx.commercial_analytics_us.stg_ga4_events`;


-- ============================================================
-- V3) Core field null validation in staging
-- Expected: core fields should have zero nulls based on profiling
-- ============================================================

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


-- ============================================================
-- V4) Session field availability validation
-- Expected: ga_session_id and session_key should be fully populated
-- based on earlier profiling
-- ============================================================

SELECT
  COUNT(*) AS total_rows,

  COUNTIF(ga_session_id IS NULL) AS null_ga_session_id,
  COUNTIF(session_key IS NULL) AS null_session_key,

  COUNTIF(ga_session_id IS NOT NULL) AS populated_ga_session_id,
  COUNTIF(session_key IS NOT NULL) AS populated_session_key,

  ROUND(SAFE_DIVIDE(COUNTIF(ga_session_id IS NULL), COUNT(*)), 4) AS null_ga_session_id_rate,
  ROUND(SAFE_DIVIDE(COUNTIF(session_key IS NULL), COUNT(*)), 4) AS null_session_key_rate
FROM `commercial-analytics-bq-dbx.commercial_analytics_us.stg_ga4_events`;


-- ============================================================
-- V5) Session volume validation
-- Expected: unique sessions should be stable and plausible
-- ============================================================

SELECT
  COUNT(*) AS total_event_rows,
  COUNT(DISTINCT user_pseudo_id) AS unique_users,
  COUNT(DISTINCT session_key) AS unique_sessions,
  ROUND(SAFE_DIVIDE(COUNT(*), COUNT(DISTINCT session_key)), 2) AS avg_events_per_session
FROM `commercial-analytics-bq-dbx.commercial_analytics_us.stg_ga4_events`;


-- ============================================================
-- V6) Duplicate proxy validation in staging
-- Expected: duplicate_proxy_rows should remain 0 based on profiling
-- Proxy key: user_pseudo_id + event_timestamp_raw + event_name
-- ============================================================

SELECT
  COUNT(*) AS row_count,
  COUNT(DISTINCT event_proxy_key) AS distinct_event_proxy_keys,
  COUNT(*) - COUNT(DISTINCT event_proxy_key) AS duplicate_proxy_rows,
  CASE
    WHEN COUNT(*) = COUNT(DISTINCT event_proxy_key) THEN 'PASS'
    ELSE 'CHECK'
  END AS validation_status
FROM `commercial-analytics-bq-dbx.commercial_analytics_us.stg_ga4_events`;


-- ============================================================
-- V7) Event distribution validation
-- Purpose: confirm staging preserved event taxonomy
-- ============================================================

SELECT
  event_name,
  COUNT(*) AS event_count,
  ROUND(SAFE_DIVIDE(COUNT(*), SUM(COUNT(*)) OVER ()), 4) AS event_share
FROM `commercial-analytics-bq-dbx.commercial_analytics_us.stg_ga4_events`
GROUP BY event_name
ORDER BY event_count DESC
LIMIT 30;


-- ============================================================
-- V8) Ecommerce funnel event validation
-- Purpose: confirm ecommerce funnel events are correctly flagged
-- ============================================================

SELECT
  event_name,
  COUNT(*) AS event_count,
  COUNTIF(is_ecommerce_funnel_event = TRUE) AS ecommerce_funnel_flagged_rows,
  COUNTIF(has_items = TRUE) AS rows_with_items,
  COUNTIF(is_purchase_event = TRUE) AS purchase_flagged_rows
FROM `commercial-analytics-bq-dbx.commercial_analytics_us.stg_ga4_events`
WHERE event_name IN (
  'view_item',
  'add_to_cart',
  'begin_checkout',
  'purchase'
)
GROUP BY event_name
ORDER BY event_count DESC;


-- ============================================================
-- V9) Purchase quality validation
-- Expected from profiling:
-- purchase_events around 1,204
-- invalid transaction IDs around 300
-- missing purchase revenue around 300
-- zero and negative revenue should be 0
-- ============================================================

SELECT
  COUNTIF(is_purchase_event = TRUE) AS purchase_events,

  COUNTIF(is_invalid_purchase_transaction_id = TRUE) AS invalid_purchase_transaction_id_events,
  ROUND(
    SAFE_DIVIDE(
      COUNTIF(is_invalid_purchase_transaction_id = TRUE),
      COUNTIF(is_purchase_event = TRUE)
    ),
    4
  ) AS invalid_purchase_transaction_id_rate,

  COUNTIF(is_missing_purchase_revenue = TRUE) AS missing_purchase_revenue_events,
  ROUND(
    SAFE_DIVIDE(
      COUNTIF(is_missing_purchase_revenue = TRUE),
      COUNTIF(is_purchase_event = TRUE)
    ),
    4
  ) AS missing_purchase_revenue_rate,

  COUNTIF(is_zero_purchase_revenue = TRUE) AS zero_purchase_revenue_events,
  COUNTIF(is_negative_purchase_revenue = TRUE) AS negative_purchase_revenue_events
FROM `commercial-analytics-bq-dbx.commercial_analytics_us.stg_ga4_events`;


-- ============================================================
-- V10) Valid transaction and revenue validation
-- Purpose: compare purchase events vs valid transaction IDs
-- ============================================================

SELECT
  COUNTIF(is_purchase_event = TRUE) AS purchase_event_rows,

  COUNTIF(
    is_purchase_event = TRUE
    AND transaction_id IS NOT NULL
  ) AS purchase_rows_with_valid_transaction_id,

  COUNT(DISTINCT
    CASE
      WHEN is_purchase_event = TRUE
        AND transaction_id IS NOT NULL
      THEN transaction_id
    END
  ) AS distinct_valid_transaction_ids,

  SUM(
    CASE
      WHEN is_purchase_event = TRUE
      THEN COALESCE(purchase_revenue, 0)
      ELSE 0
    END
  ) AS raw_purchase_revenue_sum
FROM `commercial-analytics-bq-dbx.commercial_analytics_us.stg_ga4_events`;


-- ============================================================
-- V11) Transaction duplicate / revenue inflation risk
-- Purpose: identify transaction IDs appearing in multiple purchase rows
-- Important: this confirms why revenue deduplication must happen later
-- ============================================================

SELECT
  transaction_id,
  COUNT(*) AS purchase_event_rows,
  COUNT(DISTINCT purchase_revenue) AS distinct_revenue_values,
  SUM(purchase_revenue) AS summed_transaction_revenue,
  MAX(purchase_revenue) AS max_transaction_revenue,
  SUM(purchase_revenue) - MAX(purchase_revenue) AS possible_revenue_overstatement
FROM `commercial-analytics-bq-dbx.commercial_analytics_us.stg_ga4_events`
WHERE is_purchase_event = TRUE
  AND transaction_id IS NOT NULL
GROUP BY transaction_id
HAVING COUNT(*) > 1
ORDER BY purchase_event_rows DESC, possible_revenue_overstatement DESC
LIMIT 50;


-- ============================================================
-- V12) Acquisition field validation
-- Purpose: inspect normalized source / medium / campaign values
-- ============================================================

SELECT
  source,
  medium,
  campaign,
  COUNT(*) AS event_count,
  COUNT(DISTINCT user_pseudo_id) AS unique_users,
  COUNT(DISTINCT session_key) AS unique_sessions
FROM `commercial-analytics-bq-dbx.commercial_analytics_us.stg_ga4_events`
GROUP BY
  source,
  medium,
  campaign
ORDER BY event_count DESC
LIMIT 50;


-- ============================================================
-- V13) Not set acquisition rate
-- Purpose: quantify attribution sparsity after staging normalization
-- ============================================================

SELECT
  COUNT(*) AS total_rows,

  COUNTIF(source = '(not set)') AS not_set_source_rows,
  ROUND(SAFE_DIVIDE(COUNTIF(source = '(not set)'), COUNT(*)), 4) AS not_set_source_rate,

  COUNTIF(medium = '(not set)') AS not_set_medium_rows,
  ROUND(SAFE_DIVIDE(COUNTIF(medium = '(not set)'), COUNT(*)), 4) AS not_set_medium_rate,

  COUNTIF(campaign = '(not set)') AS not_set_campaign_rows,
  ROUND(SAFE_DIVIDE(COUNTIF(campaign = '(not set)'), COUNT(*)), 4) AS not_set_campaign_rate
FROM `commercial-analytics-bq-dbx.commercial_analytics_us.stg_ga4_events`;


-- ============================================================
-- V14) Item array validation by event type
-- Purpose: confirm items remain event-aware and are not unnested here
-- ============================================================

SELECT
  event_name,
  COUNT(*) AS event_rows,
  COUNTIF(has_items = TRUE) AS rows_with_items,
  COUNTIF(has_items = FALSE) AS rows_without_items,
  ROUND(SAFE_DIVIDE(COUNTIF(has_items = TRUE), COUNT(*)), 4) AS item_coverage_rate
FROM `commercial-analytics-bq-dbx.commercial_analytics_us.stg_ga4_events`
GROUP BY event_name
ORDER BY rows_with_items DESC, event_rows DESC
LIMIT 30;


-- ============================================================
-- V15) Engagement field validation
-- Purpose: inspect session_engaged parsing and engagement time availability
-- ============================================================

SELECT
  session_engaged_raw,
  is_session_engaged,
  COUNT(*) AS event_count,
  COUNTIF(engagement_time_msec IS NOT NULL) AS rows_with_engagement_time,
  ROUND(
    SAFE_DIVIDE(
      COUNTIF(engagement_time_msec IS NOT NULL),
      COUNT(*)
    ),
    4
  ) AS engagement_time_coverage_rate
FROM `commercial-analytics-bq-dbx.commercial_analytics_us.stg_ga4_events`
GROUP BY
  session_engaged_raw,
  is_session_engaged
ORDER BY event_count DESC;


-- ============================================================
-- V16) Data quality flag summary
-- Purpose: compact overview of staging-level quality flags
-- ============================================================

SELECT
  COUNT(*) AS total_rows,

  COUNTIF(is_invalid_event_date = TRUE) AS invalid_event_date_rows,
  COUNTIF(is_missing_user_pseudo_id = TRUE) AS missing_user_pseudo_id_rows,
  COUNTIF(is_missing_ga_session_id = TRUE) AS missing_ga_session_id_rows,
  COUNTIF(is_missing_session_key = TRUE) AS missing_session_key_rows,

  COUNTIF(is_invalid_purchase_transaction_id = TRUE) AS invalid_purchase_transaction_id_rows,
  COUNTIF(is_missing_purchase_revenue = TRUE) AS missing_purchase_revenue_rows,
  COUNTIF(is_zero_purchase_revenue = TRUE) AS zero_purchase_revenue_rows,
  COUNTIF(is_negative_purchase_revenue = TRUE) AS negative_purchase_revenue_rows
FROM `commercial-analytics-bq-dbx.commercial_analytics_us.stg_ga4_events`;


-- ============================================================
-- V17) Final staging validation status
-- Purpose: high-level pass/check/fail summary for documentation
-- ============================================================

WITH checks AS (
  SELECT
    COUNT(*) AS total_rows,
    COUNTIF(event_date IS NULL) AS null_event_date,
    COUNTIF(event_timestamp_raw IS NULL) AS null_event_timestamp_raw,
    COUNTIF(event_name IS NULL) AS null_event_name,
    COUNTIF(user_pseudo_id IS NULL) AS null_user_pseudo_id,
    COUNTIF(ga_session_id IS NULL) AS null_ga_session_id,
    COUNTIF(session_key IS NULL) AS null_session_key,
    COUNT(*) - COUNT(DISTINCT event_proxy_key) AS duplicate_proxy_rows,
    COUNTIF(is_negative_purchase_revenue = TRUE) AS negative_purchase_revenue_rows
  FROM `commercial-analytics-bq-dbx.commercial_analytics_us.stg_ga4_events`
)

SELECT
  total_rows,

  CASE
    WHEN null_event_date = 0
      AND null_event_timestamp_raw = 0
      AND null_event_name = 0
      AND null_user_pseudo_id = 0
      AND null_ga_session_id = 0
      AND null_session_key = 0
      AND duplicate_proxy_rows = 0
      AND negative_purchase_revenue_rows = 0
    THEN 'PASS'
    ELSE 'CHECK'
  END AS staging_validation_status,

  null_event_date,
  null_event_timestamp_raw,
  null_event_name,
  null_user_pseudo_id,
  null_ga_session_id,
  null_session_key,
  duplicate_proxy_rows,
  negative_purchase_revenue_rows
FROM checks;