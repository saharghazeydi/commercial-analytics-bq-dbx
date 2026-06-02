-- ============================================================
-- 06b_validate_mart_channel_daily.sql
-- Purpose:
-- Validate mart_channel_daily grain, coverage, join completeness,
-- KPI logic, revenue integrity, and BI readiness
-- ============================================================



-- ============================================================
-- MCV1) Mart row count validation
-- Purpose: confirm mart_channel_daily contains rows
-- ============================================================

SELECT
  COUNT(*) AS total_mart_rows
FROM `commercial-analytics-bq-dbx.commercial_analytics_us.mart_channel_daily`;



-- ============================================================
-- MCV2) Mart grain uniqueness validation
-- Purpose: confirm one row per event_date + channel_key
-- ============================================================

SELECT
  COUNT(*) AS total_rows,

  COUNT(DISTINCT CONCAT(
    CAST(event_date AS STRING),
    ' | ',
    channel_key
  )) AS distinct_date_channel_keys,

  COUNT(*) -
  COUNT(DISTINCT CONCAT(
    CAST(event_date AS STRING),
    ' | ',
    channel_key
  )) AS duplicate_date_channel_rows

FROM `commercial-analytics-bq-dbx.commercial_analytics_us.mart_channel_daily`;



-- ============================================================
-- MCV3) Date coverage validation
-- Purpose: confirm expected January 2021 coverage
-- ============================================================

SELECT
  MIN(event_date) AS min_event_date,
  MAX(event_date) AS max_event_date,
  COUNT(DISTINCT event_date) AS distinct_dates
FROM `commercial-analytics-bq-dbx.commercial_analytics_us.mart_channel_daily`;



-- ============================================================
-- MCV4) Critical null validation
-- Purpose: confirm required mart fields are populated
-- ============================================================

SELECT
  COUNT(*) AS total_rows,

  COUNTIF(event_date IS NULL) AS null_event_date,
  COUNTIF(channel_key IS NULL) AS null_channel_key,
  COUNTIF(channel_group IS NULL) AS null_channel_group,
  COUNTIF(source IS NULL) AS null_source,
  COUNTIF(medium IS NULL) AS null_medium,
  COUNTIF(campaign IS NULL) AS null_campaign,

  COUNTIF(calendar_year IS NULL) AS null_calendar_year,
  COUNTIF(calendar_month IS NULL) AS null_calendar_month,
  COUNTIF(year_month IS NULL) AS null_year_month,

  COUNTIF(sessions IS NULL) AS null_sessions,
  COUNTIF(users IS NULL) AS null_users,
  COUNTIF(transactions IS NULL) AS null_transactions,
  COUNTIF(revenue IS NULL) AS null_revenue

FROM `commercial-analytics-bq-dbx.commercial_analytics_us.mart_channel_daily`;



-- ============================================================
-- MCV5) Fact-to-mart reconciliation
-- Purpose:
-- confirm key totals reconcile back to fact_sessions_daily
-- ============================================================

WITH fact_totals AS (

  SELECT
    COUNT(*) AS fact_sessions,
    COUNT(DISTINCT user_pseudo_id) AS fact_users,
    SUM(event_count) AS fact_total_events,
    SUM(valid_transactions) AS fact_transactions,
    SUM(deduplicated_revenue) AS fact_revenue

  FROM `commercial-analytics-bq-dbx.commercial_analytics_us.fact_sessions_daily`

),

mart_totals AS (

  SELECT
    SUM(sessions) AS mart_sessions,
    COUNT(DISTINCT CONCAT(CAST(event_date AS STRING), ' | ', source, ' | ', medium, ' | ', campaign)) AS mart_channel_rows,
    SUM(total_events) AS mart_total_events,
    SUM(transactions) AS mart_transactions,
    SUM(revenue) AS mart_revenue

  FROM `commercial-analytics-bq-dbx.commercial_analytics_us.mart_channel_daily`

)

SELECT
  fact_sessions,
  mart_sessions,
  fact_sessions - mart_sessions AS session_difference,

  fact_total_events,
  mart_total_events,
  fact_total_events - mart_total_events AS event_difference,

  fact_transactions,
  mart_transactions,
  fact_transactions - mart_transactions AS transaction_difference,

  fact_revenue,
  mart_revenue,
  fact_revenue - mart_revenue AS revenue_difference

FROM fact_totals
CROSS JOIN mart_totals;



-- ============================================================
-- MCV6) Channel distribution validation
-- Purpose: inspect sessions and revenue by channel group
-- ============================================================

SELECT
  channel_group,

  SUM(sessions) AS sessions,
  ROUND(
    SAFE_DIVIDE(
      SUM(sessions),
      SUM(SUM(sessions)) OVER ()
    ),
    4
  ) AS session_share,

  SUM(transactions) AS transactions,
  SUM(revenue) AS revenue,

  ROUND(SAFE_DIVIDE(SUM(transactions), SUM(sessions)), 4)
    AS session_conversion_rate,

  ROUND(SAFE_DIVIDE(SUM(revenue), SUM(transactions)), 2)
    AS average_order_value

FROM `commercial-analytics-bq-dbx.commercial_analytics_us.mart_channel_daily`

GROUP BY channel_group
ORDER BY sessions DESC;



-- ============================================================
-- MCV7) KPI boundary validation
-- Purpose:
-- confirm calculated KPI rates are within reasonable bounds
-- ============================================================

SELECT
  COUNT(*) AS total_rows,

  COUNTIF(session_conversion_rate < 0)
    AS negative_session_conversion_rate_rows,

  COUNTIF(user_conversion_rate < 0)
    AS negative_user_conversion_rate_rows,

  COUNTIF(engaged_session_rate < 0 OR engaged_session_rate > 1)
    AS invalid_engaged_session_rate_rows,

  COUNTIF(view_to_cart_rate < 0)
    AS negative_view_to_cart_rate_rows,

  COUNTIF(cart_to_checkout_rate < 0)
    AS negative_cart_to_checkout_rate_rows,

  COUNTIF(checkout_to_purchase_rate < 0)
    AS negative_checkout_to_purchase_rate_rows,

  COUNTIF(revenue < 0)
    AS negative_revenue_rows

FROM `commercial-analytics-bq-dbx.commercial_analytics_us.mart_channel_daily`;



-- ============================================================
-- MCV8) Daily trend validation
-- Purpose:
-- inspect daily sessions, transactions, revenue, and conversion
-- ============================================================

SELECT
  event_date,

  SUM(sessions) AS sessions,
  SUM(transactions) AS transactions,
  SUM(revenue) AS revenue,

  ROUND(SAFE_DIVIDE(SUM(transactions), SUM(sessions)), 4)
    AS session_conversion_rate,

  ROUND(SAFE_DIVIDE(SUM(revenue), SUM(sessions)), 2)
    AS revenue_per_session

FROM `commercial-analytics-bq-dbx.commercial_analytics_us.mart_channel_daily`

GROUP BY event_date
ORDER BY event_date;



-- ============================================================
-- MCV9) High revenue channel-date inspection
-- Purpose:
-- inspect highest revenue channel-date rows
-- ============================================================

SELECT
  event_date,
  channel_group,
  source,
  medium,
  campaign,

  sessions,
  transactions,
  revenue,
  session_conversion_rate,
  average_order_value

FROM `commercial-analytics-bq-dbx.commercial_analytics_us.mart_channel_daily`

WHERE revenue > 0

ORDER BY revenue DESC
LIMIT 50;



-- ============================================================
-- MCV10) Final mart_channel_daily validation status
-- Purpose: high-level PASS/CHECK summary
-- ============================================================

WITH mart_checks AS (

  SELECT
    COUNT(*) AS total_rows,

    COUNT(DISTINCT CONCAT(
      CAST(event_date AS STRING),
      ' | ',
      channel_key
    )) AS distinct_date_channel_keys,

    MIN(event_date) AS min_event_date,
    MAX(event_date) AS max_event_date,

    COUNTIF(event_date IS NULL) AS null_event_date,
    COUNTIF(channel_key IS NULL) AS null_channel_key,
    COUNTIF(channel_group IS NULL) AS null_channel_group,

    COUNTIF(sessions IS NULL OR sessions <= 0) AS invalid_sessions_rows,
    COUNTIF(revenue < 0) AS negative_revenue_rows,

    COUNTIF(engaged_session_rate < 0 OR engaged_session_rate > 1)
      AS invalid_engaged_session_rate_rows

  FROM `commercial-analytics-bq-dbx.commercial_analytics_us.mart_channel_daily`

),

reconciliation AS (

  SELECT
    (
      SELECT COUNT(*)
      FROM `commercial-analytics-bq-dbx.commercial_analytics_us.fact_sessions_daily`
    )
    -
    (
      SELECT SUM(sessions)
      FROM `commercial-analytics-bq-dbx.commercial_analytics_us.mart_channel_daily`
    ) AS session_difference,

    (
      SELECT SUM(valid_transactions)
      FROM `commercial-analytics-bq-dbx.commercial_analytics_us.fact_sessions_daily`
    )
    -
    (
      SELECT SUM(transactions)
      FROM `commercial-analytics-bq-dbx.commercial_analytics_us.mart_channel_daily`
    ) AS transaction_difference,

    (
      SELECT SUM(deduplicated_revenue)
      FROM `commercial-analytics-bq-dbx.commercial_analytics_us.fact_sessions_daily`
    )
    -
    (
      SELECT SUM(revenue)
      FROM `commercial-analytics-bq-dbx.commercial_analytics_us.mart_channel_daily`
    ) AS revenue_difference

)

SELECT
  m.total_rows,
  m.distinct_date_channel_keys,
  m.min_event_date,
  m.max_event_date,

  CASE
    WHEN m.total_rows = m.distinct_date_channel_keys
      AND m.min_event_date = DATE '2021-01-01'
      AND m.max_event_date = DATE '2021-01-31'
      AND m.null_event_date = 0
      AND m.null_channel_key = 0
      AND m.null_channel_group = 0
      AND m.invalid_sessions_rows = 0
      AND m.negative_revenue_rows = 0
      AND m.invalid_engaged_session_rate_rows = 0
      AND r.session_difference = 0
      AND r.transaction_difference = 0
      AND r.revenue_difference = 0
    THEN 'PASS'
    ELSE 'CHECK'
  END AS mart_channel_daily_validation_status,

  m.null_event_date,
  m.null_channel_key,
  m.null_channel_group,
  m.invalid_sessions_rows,
  m.negative_revenue_rows,
  m.invalid_engaged_session_rate_rows,

  r.session_difference,
  r.transaction_difference,
  r.revenue_difference

FROM mart_checks m
CROSS JOIN reconciliation r;