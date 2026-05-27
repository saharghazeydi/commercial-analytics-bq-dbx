-- ============================================================
-- 03b_validate_fact_sessions_daily.sql
-- Purpose:
-- Validate session-level fact table quality, grain consistency,
-- revenue integrity, acquisition coverage, and KPI readiness
-- ============================================================



-- ============================================================
-- FSV1) Fact table row count
-- Purpose: confirm fact table contains rows
-- ============================================================

SELECT
  COUNT(*) AS total_fact_rows
FROM `commercial-analytics-bq-dbx.commercial_analytics_us.fact_sessions_daily`;



-- ============================================================
-- FSV2) Session grain uniqueness validation
-- Purpose:
-- confirm one row exists per event_date + session_key
-- ============================================================

SELECT
  COUNT(*) AS total_rows,

  COUNT(DISTINCT CONCAT(
    CAST(event_date AS STRING),
    session_key
  )) AS distinct_session_grain,

  COUNT(*) -
  COUNT(DISTINCT CONCAT(
    CAST(event_date AS STRING),
    session_key
  )) AS duplicate_session_grain_rows

FROM `commercial-analytics-bq-dbx.commercial_analytics_us.fact_sessions_daily`;



-- ============================================================
-- FSV3) Date coverage validation
-- Purpose:
-- confirm expected January 2021 coverage
-- ============================================================

SELECT
  MIN(event_date) AS min_event_date,
  MAX(event_date) AS max_event_date,
  COUNT(DISTINCT event_date) AS distinct_dates
FROM `commercial-analytics-bq-dbx.commercial_analytics_us.fact_sessions_daily`;



-- ============================================================
-- FSV4) Null critical field validation
-- Purpose:
-- validate required analytical fields
-- ============================================================

SELECT
  COUNT(*) AS total_rows,

  COUNTIF(event_date IS NULL) AS null_event_date,
  COUNTIF(session_key IS NULL) AS null_session_key,
  COUNTIF(user_pseudo_id IS NULL) AS null_user_pseudo_id,

  COUNTIF(session_start_timestamp_utc IS NULL) AS null_session_start,
  COUNTIF(session_end_timestamp_utc IS NULL) AS null_session_end,

  COUNTIF(session_source IS NULL) AS null_session_source,
  COUNTIF(session_medium IS NULL) AS null_session_medium,
  COUNTIF(session_campaign IS NULL) AS null_session_campaign

FROM `commercial-analytics-bq-dbx.commercial_analytics_us.fact_sessions_daily`;



-- ============================================================
-- FSV5) Session duration validation
-- Purpose:
-- inspect session duration distribution
-- ============================================================

SELECT
  MIN(session_duration_seconds) AS min_session_duration,
  MAX(session_duration_seconds) AS max_session_duration,
  ROUND(AVG(session_duration_seconds), 2) AS avg_session_duration,

  COUNTIF(session_duration_seconds < 0)
    AS negative_duration_sessions,

  COUNTIF(session_duration_seconds = 0)
    AS zero_duration_sessions

FROM `commercial-analytics-bq-dbx.commercial_analytics_us.fact_sessions_daily`;



-- ============================================================
-- FSV6) Event count validation
-- Purpose:
-- inspect event distribution per session
-- ============================================================

SELECT
  MIN(event_count) AS min_events_per_session,
  MAX(event_count) AS max_events_per_session,
  ROUND(AVG(event_count), 2) AS avg_events_per_session,

  COUNTIF(event_count = 0)
    AS zero_event_sessions

FROM `commercial-analytics-bq-dbx.commercial_analytics_us.fact_sessions_daily`;



-- ============================================================
-- FSV7) Acquisition distribution validation
-- Purpose:
-- inspect normalized session acquisition fields
-- ============================================================

SELECT
  session_source,
  session_medium,
  session_campaign,

  COUNT(*) AS sessions,
  ROUND(
    SAFE_DIVIDE(COUNT(*),
      SUM(COUNT(*)) OVER ()
    ),
    4
  ) AS session_share

FROM `commercial-analytics-bq-dbx.commercial_analytics_us.fact_sessions_daily`

GROUP BY
  session_source,
  session_medium,
  session_campaign

ORDER BY sessions DESC
LIMIT 50;



-- ============================================================
-- FSV8) "(not set)" acquisition rate
-- Purpose:
-- quantify attribution sparsity
-- ============================================================

SELECT
  COUNT(*) AS total_sessions,

  COUNTIF(session_source = '(not set)')
    AS not_set_source_sessions,

  ROUND(
    SAFE_DIVIDE(
      COUNTIF(session_source = '(not set)'),
      COUNT(*)
    ),
    4
  ) AS not_set_source_rate,

  COUNTIF(session_medium = '(not set)')
    AS not_set_medium_sessions,

  ROUND(
    SAFE_DIVIDE(
      COUNTIF(session_medium = '(not set)'),
      COUNT(*)
    ),
    4
  ) AS not_set_medium_rate,

  COUNTIF(session_campaign = '(not set)')
    AS not_set_campaign_sessions,

  ROUND(
    SAFE_DIVIDE(
      COUNTIF(session_campaign = '(not set)'),
      COUNT(*)
    ),
    4
  ) AS not_set_campaign_rate

FROM `commercial-analytics-bq-dbx.commercial_analytics_us.fact_sessions_daily`;



-- ============================================================
-- FSV9) Engagement validation
-- Purpose:
-- inspect engagement metric coverage
-- ============================================================

SELECT
  COUNT(*) AS total_sessions,

  COUNTIF(is_engaged_session = 1)
    AS engaged_sessions,

  ROUND(
    SAFE_DIVIDE(
      COUNTIF(is_engaged_session = 1),
      COUNT(*)
    ),
    4
  ) AS engaged_session_rate,

  ROUND(
    AVG(total_engagement_time_msec),
    2
  ) AS avg_engagement_time_msec,

  MAX(total_engagement_time_msec)
    AS max_engagement_time_msec

FROM `commercial-analytics-bq-dbx.commercial_analytics_us.fact_sessions_daily`;



-- ============================================================
-- FSV10) Funnel event validation
-- Purpose:
-- inspect ecommerce funnel event distribution
-- ============================================================

SELECT
  SUM(view_item_events) AS total_view_item_events,
  SUM(add_to_cart_events) AS total_add_to_cart_events,
  SUM(begin_checkout_events) AS total_begin_checkout_events,
  SUM(purchase_event_rows) AS total_purchase_events

FROM `commercial-analytics-bq-dbx.commercial_analytics_us.fact_sessions_daily`;



-- ============================================================
-- FSV11) Purchase session validation
-- Purpose:
-- inspect purchase session behavior
-- ============================================================

SELECT
  COUNT(*) AS purchase_sessions,

  ROUND(
    AVG(valid_transactions),
    2
  ) AS avg_transactions_per_purchase_session,

  ROUND(
    AVG(deduplicated_revenue),
    2
  ) AS avg_purchase_session_revenue,

  MAX(deduplicated_revenue)
    AS max_purchase_session_revenue

FROM `commercial-analytics-bq-dbx.commercial_analytics_us.fact_sessions_daily`

WHERE has_purchase_event = 1;


-- ============================================================
-- FSV12) Revenue integrity validation
-- Purpose:
-- validate deduplicated transaction logic
-- ============================================================

SELECT
  SUM(valid_transactions) AS total_valid_transactions,
  SUM(deduplicated_revenue) AS total_deduplicated_revenue,

  COUNTIF(deduplicated_revenue < 0)
    AS negative_revenue_sessions,

  COUNTIF(
    has_purchase_event = 1
    AND deduplicated_revenue = 0
  ) AS zero_revenue_purchase_sessions

FROM `commercial-analytics-bq-dbx.commercial_analytics_us.fact_sessions_daily`;



-- ============================================================
-- FSV13) Revenue outlier inspection
-- Purpose:
-- inspect highest revenue sessions
-- ============================================================

SELECT
  event_date,
  session_key,
  session_source,
  session_medium,

  valid_transactions,
  deduplicated_revenue

FROM `commercial-analytics-bq-dbx.commercial_analytics_us.fact_sessions_daily`

WHERE deduplicated_revenue > 0

ORDER BY deduplicated_revenue DESC
LIMIT 50;



-- ============================================================
-- FSV14) Purchase quality flag validation
-- Purpose:
-- inspect purchase-related quality issues
-- ============================================================

SELECT
  SUM(invalid_purchase_transaction_id_events)
    AS invalid_transaction_id_events,

  SUM(missing_purchase_revenue_events)
    AS missing_purchase_revenue_events,

  SUM(zero_purchase_revenue_events)
    AS zero_purchase_revenue_events,

  SUM(negative_purchase_revenue_events)
    AS negative_purchase_revenue_events

FROM `commercial-analytics-bq-dbx.commercial_analytics_us.fact_sessions_daily`;



-- ============================================================
-- FSV15) Daily session trend validation
-- Purpose:
-- inspect daily session behavior
-- ============================================================

SELECT
  event_date,

  COUNT(*) AS sessions,

  SUM(valid_transactions) AS transactions,

  SUM(deduplicated_revenue) AS revenue,

  ROUND(
    SAFE_DIVIDE(
      SUM(valid_transactions),
      COUNT(*)
    ),
    4
  ) AS transactions_per_session

FROM `commercial-analytics-bq-dbx.commercial_analytics_us.fact_sessions_daily`

GROUP BY event_date
ORDER BY event_date;



-- ============================================================
-- FSV16) Final fact validation status
-- Purpose:
-- high-level PASS/CHECK summary
-- ============================================================

WITH checks AS (

  SELECT
    COUNT(*) AS total_rows,

    COUNTIF(event_date IS NULL)
      AS null_event_date,

    COUNTIF(session_key IS NULL)
      AS null_session_key,

    COUNTIF(user_pseudo_id IS NULL)
      AS null_user_pseudo_id,

    COUNT(*) -
    COUNT(DISTINCT CONCAT(
      CAST(event_date AS STRING),
      session_key
    )) AS duplicate_session_grain_rows,

    COUNTIF(deduplicated_revenue < 0)
      AS negative_revenue_sessions

  FROM `commercial-analytics-bq-dbx.commercial_analytics_us.fact_sessions_daily`

)

SELECT
  total_rows,

  CASE
    WHEN null_event_date = 0
      AND null_session_key = 0
      AND null_user_pseudo_id = 0
      AND duplicate_session_grain_rows = 0
      AND negative_revenue_sessions = 0
    THEN 'PASS'
    ELSE 'CHECK'
  END AS fact_validation_status,

  null_event_date,
  null_session_key,
  null_user_pseudo_id,
  duplicate_session_grain_rows,
  negative_revenue_sessions

FROM checks;

