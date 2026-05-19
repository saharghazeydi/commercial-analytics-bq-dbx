-- 03_fact_sessions_daily.sql
-- Purpose: Build daily session-level fact table from validated GA4 staging view
-- Grain: one row per event_date + session_key
-- Source: commercial-analytics-bq-dbx.commercial_analytics_us.stg_ga4_events
-- Notes:
-- - Uses validated staging layer
-- - Preserves session grain
-- - Does NOT naively sum duplicated transaction revenue
-- - Revenue is deduplicated at transaction level inside each session

CREATE OR REPLACE TABLE `commercial-analytics-bq-dbx.commercial_analytics_us.fact_sessions_daily` AS

WITH session_base AS (
  SELECT
    event_date,
    session_key,
    user_pseudo_id,

    MIN(event_timestamp_utc) AS session_start_timestamp_utc,
    MAX(event_timestamp_utc) AS session_end_timestamp_utc,

    ANY_VALUE(ga_session_id) AS ga_session_id,
    ANY_VALUE(ga_session_number) AS ga_session_number,

    ARRAY_AGG(source IGNORE NULLS ORDER BY event_timestamp_utc LIMIT 1)[SAFE_OFFSET(0)] AS session_source,
    ARRAY_AGG(medium IGNORE NULLS ORDER BY event_timestamp_utc LIMIT 1)[SAFE_OFFSET(0)] AS session_medium,
    ARRAY_AGG(campaign IGNORE NULLS ORDER BY event_timestamp_utc LIMIT 1)[SAFE_OFFSET(0)] AS session_campaign,

    COUNT(*) AS event_count,

    COUNTIF(event_name = 'page_view') AS page_view_events,
    COUNTIF(event_name = 'user_engagement') AS user_engagement_events,
    COUNTIF(event_name = 'scroll') AS scroll_events,

    COUNTIF(is_ecommerce_funnel_event = TRUE) AS ecommerce_funnel_events,
    COUNTIF(event_name = 'view_item') AS view_item_events,
    COUNTIF(event_name = 'add_to_cart') AS add_to_cart_events,
    COUNTIF(event_name = 'begin_checkout') AS begin_checkout_events,
    COUNTIF(is_purchase_event = TRUE) AS purchase_event_rows,

    COUNTIF(is_session_engaged = TRUE) AS engaged_event_rows,
    SUM(COALESCE(engagement_time_msec, 0)) AS total_engagement_time_msec,

    MAX(CASE WHEN is_session_engaged = TRUE THEN 1 ELSE 0 END) AS is_engaged_session,
    MAX(CASE WHEN event_name = 'view_item' THEN 1 ELSE 0 END) AS has_view_item,
    MAX(CASE WHEN event_name = 'add_to_cart' THEN 1 ELSE 0 END) AS has_add_to_cart,
    MAX(CASE WHEN event_name = 'begin_checkout' THEN 1 ELSE 0 END) AS has_begin_checkout,
    MAX(CASE WHEN is_purchase_event = TRUE THEN 1 ELSE 0 END) AS has_purchase_event,

    COUNTIF(is_invalid_purchase_transaction_id = TRUE) AS invalid_purchase_transaction_id_events,
    COUNTIF(is_missing_purchase_revenue = TRUE) AS missing_purchase_revenue_events,
    COUNTIF(is_zero_purchase_revenue = TRUE) AS zero_purchase_revenue_events,
    COUNTIF(is_negative_purchase_revenue = TRUE) AS negative_purchase_revenue_events

  FROM `commercial-analytics-bq-dbx.commercial_analytics_us.stg_ga4_events`
  WHERE session_key IS NOT NULL
  GROUP BY
    event_date,
    session_key,
    user_pseudo_id
),

transaction_revenue AS (
  SELECT
    event_date,
    session_key,
    transaction_id,
    MAX(purchase_revenue) AS deduplicated_transaction_revenue
  FROM `commercial-analytics-bq-dbx.commercial_analytics_us.stg_ga4_events`
  WHERE is_purchase_event = TRUE
    AND transaction_id IS NOT NULL
    AND purchase_revenue IS NOT NULL
  GROUP BY
    event_date,
    session_key,
    transaction_id
),

session_revenue AS (
  SELECT
    event_date,
    session_key,
    COUNT(DISTINCT transaction_id) AS valid_transactions,
    SUM(deduplicated_transaction_revenue) AS deduplicated_revenue
  FROM transaction_revenue
  GROUP BY
    event_date,
    session_key
)

SELECT
  sb.event_date,
  sb.session_key,
  sb.user_pseudo_id,

  sb.ga_session_id,
  sb.ga_session_number,

  sb.session_start_timestamp_utc,
  sb.session_end_timestamp_utc,

  TIMESTAMP_DIFF(
    sb.session_end_timestamp_utc,
    sb.session_start_timestamp_utc,
    SECOND
  ) AS session_duration_seconds,

  COALESCE(sb.session_source, '(not set)') AS session_source,
  COALESCE(sb.session_medium, '(not set)') AS session_medium,
  COALESCE(sb.session_campaign, '(not set)') AS session_campaign,

  sb.event_count,
  sb.page_view_events,
  sb.user_engagement_events,
  sb.scroll_events,

  sb.ecommerce_funnel_events,
  sb.view_item_events,
  sb.add_to_cart_events,
  sb.begin_checkout_events,
  sb.purchase_event_rows,

  sb.engaged_event_rows,
  sb.total_engagement_time_msec,
  ROUND(SAFE_DIVIDE(sb.total_engagement_time_msec, 1000), 2) AS total_engagement_time_seconds,

  sb.is_engaged_session,
  sb.has_view_item,
  sb.has_add_to_cart,
  sb.has_begin_checkout,
  sb.has_purchase_event,

  COALESCE(sr.valid_transactions, 0) AS valid_transactions,
  COALESCE(sr.deduplicated_revenue, 0) AS deduplicated_revenue,

  sb.invalid_purchase_transaction_id_events,
  sb.missing_purchase_revenue_events,
  sb.zero_purchase_revenue_events,
  sb.negative_purchase_revenue_events,

  CASE
    WHEN sb.has_purchase_event = 1
      AND COALESCE(sr.valid_transactions, 0) = 0
    THEN 1
    ELSE 0
  END AS has_purchase_event_without_valid_transaction,

  CASE
    WHEN COALESCE(sr.valid_transactions, 0) > 0 THEN 1
    ELSE 0
  END AS has_valid_transaction,

  CASE
    WHEN COALESCE(sr.deduplicated_revenue, 0) > 0 THEN 1
    ELSE 0
  END AS has_revenue

FROM session_base sb
LEFT JOIN session_revenue sr
  ON sb.event_date = sr.event_date
  AND sb.session_key = sr.session_key;