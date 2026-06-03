-- ============================================================
-- 07b_validate_mart_executive_daily.sql
-- Purpose: Validate mart_executive_daily grain, coverage, reconciliation, KPI logic, and BI readiness.
--
-- Target:
-- commercial-analytics-bq-dbx.commercial_analytics_us.mart_executive_daily
--
-- Sources:
-- - commercial-analytics-bq-dbx.commercial_analytics_us.mart_channel_daily
-- - commercial-analytics-bq-dbx.commercial_analytics_us.fact_sessions_daily
-- - commercial-analytics-bq-dbx.commercial_analytics_us.dim_date
--
-- Grain:
-- One row per event_date
-- ============================================================


-- ============================================================
-- EV1) Row count and date range validation
-- Purpose: Confirm the mart contains data and covers the expected reporting date range.
-- ============================================================

SELECT
  COUNT(*) AS total_rows,
  MIN(event_date) AS min_event_date,
  MAX(event_date) AS max_event_date,
  COUNT(DISTINCT event_date) AS distinct_dates
FROM
  `commercial-analytics-bq-dbx.commercial_analytics_us.mart_executive_daily`;



-- ============================================================
-- EV2) Grain uniqueness validation
-- Purpose: Confirm the mart contains exactly one row per event_date.
-- ============================================================

SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT event_date) AS distinct_event_dates,
  COUNT(*) - COUNT(DISTINCT event_date) AS duplicate_event_date_rows,

  CASE
    WHEN COUNT(*) = COUNT(DISTINCT event_date)
    THEN 'PASS'
    ELSE 'CHECK'
  END AS grain_validation_status

FROM
  `commercial-analytics-bq-dbx.commercial_analytics_us.mart_executive_daily`;



-- ============================================================
-- EV3) Critical null validation
-- Purpose: Check required dimensions, base metrics, and KPI fields for unexpected nulls.
-- ============================================================

SELECT
  COUNT(*) AS total_rows,

  COUNTIF(event_date IS NULL) AS null_event_date,
  COUNTIF(sessions IS NULL) AS null_sessions,
  COUNTIF(users IS NULL) AS null_users,
  COUNTIF(total_events IS NULL) AS null_total_events,
  COUNTIF(transactions IS NULL) AS null_transactions,
  COUNTIF(revenue IS NULL) AS null_revenue,

  COUNTIF(session_conversion_rate IS NULL AND sessions > 0)
    AS null_session_conversion_rate_when_sessions_exist,

  COUNTIF(user_conversion_rate IS NULL AND users > 0)
    AS null_user_conversion_rate_when_users_exist,

  COUNTIF(revenue_per_session IS NULL AND sessions > 0)
    AS null_revenue_per_session_when_sessions_exist,

  COUNTIF(revenue_per_user IS NULL AND users > 0)
    AS null_revenue_per_user_when_users_exist,

  COUNTIF(average_order_value IS NULL AND transactions > 0)
    AS null_aov_when_transactions_exist

FROM
  `commercial-analytics-bq-dbx.commercial_analytics_us.mart_executive_daily`;



-- ============================================================
-- EV4) Date coverage validation against dim_date
-- Purpose: Confirm all expected calendar dates from dim_date exist in the executive mart.
-- ============================================================

WITH dim_dates AS (

  SELECT
    date_day

  FROM
    `commercial-analytics-bq-dbx.commercial_analytics_us.dim_date`

),

executive_dates AS (

  SELECT DISTINCT
    event_date

  FROM
    `commercial-analytics-bq-dbx.commercial_analytics_us.mart_executive_daily`

)

SELECT
  COUNT(d.date_day) AS expected_dates_from_dim_date,
  COUNT(e.event_date) AS dates_found_in_executive_mart,
  COUNTIF(e.event_date IS NULL) AS missing_dates_from_executive_mart,

  CASE
    WHEN COUNTIF(e.event_date IS NULL) = 0
    THEN 'PASS'
    ELSE 'CHECK'
  END AS date_coverage_status

FROM dim_dates d

LEFT JOIN executive_dates e
  ON d.date_day = e.event_date;



-- ============================================================
-- EV5) Additive metric reconciliation with mart_channel_daily
-- Purpose: Confirm additive executive metrics reconcile with the validated channel mart.
--
-- Note:
-- Users are excluded because distinct users are not safely additive across channel rows.
-- ============================================================

WITH executive AS (

  SELECT
    SUM(sessions) AS executive_sessions,
    SUM(total_events) AS executive_total_events,
    SUM(transactions) AS executive_transactions,
    ROUND(SUM(revenue), 2) AS executive_revenue,
    SUM(engaged_sessions) AS executive_engaged_sessions,
    SUM(view_item_events) AS executive_view_item_events,
    SUM(add_to_cart_events) AS executive_add_to_cart_events,
    SUM(begin_checkout_events) AS executive_begin_checkout_events,
    SUM(purchase_event_rows) AS executive_purchase_event_rows

  FROM
    `commercial-analytics-bq-dbx.commercial_analytics_us.mart_executive_daily`

),

channel AS (

  SELECT
    SUM(sessions) AS channel_sessions,
    SUM(total_events) AS channel_total_events,
    SUM(transactions) AS channel_transactions,
    ROUND(SUM(revenue), 2) AS channel_revenue,
    SUM(engaged_sessions) AS channel_engaged_sessions,
    SUM(view_item_events) AS channel_view_item_events,
    SUM(add_to_cart_events) AS channel_add_to_cart_events,
    SUM(begin_checkout_events) AS channel_begin_checkout_events,
    SUM(purchase_event_rows) AS channel_purchase_event_rows

  FROM
    `commercial-analytics-bq-dbx.commercial_analytics_us.mart_channel_daily`

)

SELECT
  executive_sessions,
  channel_sessions,
  executive_sessions - channel_sessions AS sessions_difference,

  executive_total_events,
  channel_total_events,
  executive_total_events - channel_total_events AS total_events_difference,

  executive_transactions,
  channel_transactions,
  executive_transactions - channel_transactions AS transactions_difference,

  executive_revenue,
  channel_revenue,
  ROUND(executive_revenue - channel_revenue, 2) AS revenue_difference,

  executive_engaged_sessions,
  channel_engaged_sessions,
  executive_engaged_sessions - channel_engaged_sessions AS engaged_sessions_difference,

  executive_view_item_events,
  channel_view_item_events,
  executive_view_item_events - channel_view_item_events AS view_item_events_difference,

  executive_add_to_cart_events,
  channel_add_to_cart_events,
  executive_add_to_cart_events - channel_add_to_cart_events AS add_to_cart_events_difference,

  executive_begin_checkout_events,
  channel_begin_checkout_events,
  executive_begin_checkout_events - channel_begin_checkout_events AS begin_checkout_events_difference,

  executive_purchase_event_rows,
  channel_purchase_event_rows,
  executive_purchase_event_rows - channel_purchase_event_rows AS purchase_event_rows_difference

FROM executive
CROSS JOIN channel;



-- ============================================================
-- EV6) True daily users reconciliation with fact_sessions_daily
-- Purpose: Confirm executive users match true distinct daily users from the session fact.
-- ============================================================

WITH executive_users AS (

  SELECT
    event_date,
    users AS executive_users

  FROM
    `commercial-analytics-bq-dbx.commercial_analytics_us.mart_executive_daily`

),

fact_users AS (

  SELECT
    event_date,
    COUNT(DISTINCT user_pseudo_id) AS fact_daily_users

  FROM
    `commercial-analytics-bq-dbx.commercial_analytics_us.fact_sessions_daily`

  GROUP BY
    event_date

)

SELECT
  e.event_date,
  e.executive_users,
  f.fact_daily_users,
  e.executive_users - f.fact_daily_users AS users_difference

FROM executive_users e

LEFT JOIN fact_users f
  ON e.event_date = f.event_date

WHERE
  e.executive_users != f.fact_daily_users
  OR f.fact_daily_users IS NULL

ORDER BY
  e.event_date;



-- ============================================================
-- EV7) Daily additive metric reconciliation with mart_channel_daily
-- Purpose: Confirm each executive row reconciles with daily channel aggregation.
--
-- Note:
-- Users are validated separately against fact_sessions_daily.
-- ============================================================

WITH executive_daily AS (

  SELECT
    event_date,
    sessions,
    total_events,
    transactions,
    revenue,
    engaged_sessions,
    view_item_events,
    add_to_cart_events,
    begin_checkout_events,
    purchase_event_rows

  FROM
    `commercial-analytics-bq-dbx.commercial_analytics_us.mart_executive_daily`

),

channel_daily AS (

  SELECT
    event_date,
    SUM(sessions) AS sessions,
    SUM(total_events) AS total_events,
    SUM(transactions) AS transactions,
    ROUND(SUM(revenue), 2) AS revenue,
    SUM(engaged_sessions) AS engaged_sessions,
    SUM(view_item_events) AS view_item_events,
    SUM(add_to_cart_events) AS add_to_cart_events,
    SUM(begin_checkout_events) AS begin_checkout_events,
    SUM(purchase_event_rows) AS purchase_event_rows

  FROM
    `commercial-analytics-bq-dbx.commercial_analytics_us.mart_channel_daily`

  GROUP BY
    event_date

)

SELECT
  e.event_date,

  e.sessions - c.sessions AS sessions_difference,
  e.total_events - c.total_events AS total_events_difference,
  e.transactions - c.transactions AS transactions_difference,
  ROUND(e.revenue - c.revenue, 2) AS revenue_difference,
  e.engaged_sessions - c.engaged_sessions AS engaged_sessions_difference,
  e.view_item_events - c.view_item_events AS view_item_events_difference,
  e.add_to_cart_events - c.add_to_cart_events AS add_to_cart_events_difference,
  e.begin_checkout_events - c.begin_checkout_events AS begin_checkout_events_difference,
  e.purchase_event_rows - c.purchase_event_rows AS purchase_event_rows_difference

FROM executive_daily e

LEFT JOIN channel_daily c
  ON e.event_date = c.event_date

WHERE
  e.sessions != c.sessions
  OR e.total_events != c.total_events
  OR e.transactions != c.transactions
  OR ROUND(e.revenue - c.revenue, 2) != 0
  OR e.engaged_sessions != c.engaged_sessions
  OR e.view_item_events != c.view_item_events
  OR e.add_to_cart_events != c.add_to_cart_events
  OR e.begin_checkout_events != c.begin_checkout_events
  OR e.purchase_event_rows != c.purchase_event_rows
  OR c.event_date IS NULL

ORDER BY
  e.event_date;



-- ============================================================
-- EV8) KPI recalculation validation
-- Purpose: Recalculate selected KPIs from base metrics and compare with stored values.
-- ============================================================

SELECT
  event_date,

  session_conversion_rate,
  ROUND(SAFE_DIVIDE(transactions, sessions), 4)
    AS recalculated_session_conversion_rate,
  ROUND(
    session_conversion_rate
    - ROUND(SAFE_DIVIDE(transactions, sessions), 4),
    4
  ) AS session_conversion_rate_difference,

  user_conversion_rate,
  ROUND(SAFE_DIVIDE(transactions, users), 4)
    AS recalculated_user_conversion_rate,
  ROUND(
    user_conversion_rate
    - ROUND(SAFE_DIVIDE(transactions, users), 4),
    4
  ) AS user_conversion_rate_difference,

  revenue_per_session,
  ROUND(SAFE_DIVIDE(revenue, sessions), 2)
    AS recalculated_revenue_per_session,
  ROUND(
    revenue_per_session
    - ROUND(SAFE_DIVIDE(revenue, sessions), 2),
    2
  ) AS revenue_per_session_difference,

  revenue_per_user,
  ROUND(SAFE_DIVIDE(revenue, users), 2)
    AS recalculated_revenue_per_user,
  ROUND(
    revenue_per_user
    - ROUND(SAFE_DIVIDE(revenue, users), 2),
    2
  ) AS revenue_per_user_difference,

  average_order_value,
  ROUND(SAFE_DIVIDE(revenue, transactions), 2)
    AS recalculated_average_order_value,
  ROUND(
    average_order_value
    - ROUND(SAFE_DIVIDE(revenue, transactions), 2),
    2
  ) AS average_order_value_difference

FROM
  `commercial-analytics-bq-dbx.commercial_analytics_us.mart_executive_daily`

ORDER BY
  event_date;



-- ============================================================
-- EV9) Impossible value validation
-- Purpose: Detect negative metrics and impossible KPI rates.
-- ============================================================

SELECT
  *
FROM
  `commercial-analytics-bq-dbx.commercial_analytics_us.mart_executive_daily`

WHERE
  sessions < 0
  OR users < 0
  OR total_events < 0
  OR transactions < 0
  OR revenue < 0
  OR engaged_sessions < 0
  OR view_item_events < 0
  OR add_to_cart_events < 0
  OR begin_checkout_events < 0
  OR purchase_event_rows < 0

  OR session_conversion_rate > 1
  OR user_conversion_rate > 1
  OR engaged_session_rate > 1

  OR view_to_cart_rate > 1
  OR cart_to_checkout_rate > 1
  OR checkout_to_purchase_rate > 1
  OR view_to_purchase_rate > 1;



-- ============================================================
-- EV10) Daily trend inspection
-- Purpose: Inspect daily executive KPI movement for BI readiness.
-- ============================================================

SELECT
  event_date,

  sessions,
  users,
  transactions,
  revenue,

  session_conversion_rate,
  user_conversion_rate,
  revenue_per_session,
  revenue_per_user,
  average_order_value,

  engaged_session_rate,
  view_to_cart_rate,
  cart_to_checkout_rate,
  checkout_to_purchase_rate,
  view_to_purchase_rate

FROM
  `commercial-analytics-bq-dbx.commercial_analytics_us.mart_executive_daily`

ORDER BY
  event_date;



-- ============================================================
-- EV11) Final validation status
-- Purpose: Produce a consolidated PASS/CHECK status for the executive mart.
-- ============================================================

WITH validation_summary AS (

  SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT event_date) AS distinct_event_dates,

    COUNT(*) - COUNT(DISTINCT event_date)
      AS duplicate_event_date_rows,

    COUNTIF(event_date IS NULL) AS null_event_date,
    COUNTIF(sessions IS NULL) AS null_sessions,
    COUNTIF(users IS NULL) AS null_users,
    COUNTIF(transactions IS NULL) AS null_transactions,
    COUNTIF(revenue IS NULL) AS null_revenue,

    COUNTIF(revenue < 0) AS negative_revenue_rows,
    COUNTIF(transactions < 0) AS negative_transaction_rows,
    COUNTIF(sessions < 0) AS negative_session_rows,
    COUNTIF(users < 0) AS negative_user_rows,

    COUNTIF(session_conversion_rate > 1) AS impossible_session_conversion_rows,
    COUNTIF(user_conversion_rate > 1) AS impossible_user_conversion_rows,
    COUNTIF(engaged_session_rate > 1) AS impossible_engaged_session_rate_rows

  FROM
    `commercial-analytics-bq-dbx.commercial_analytics_us.mart_executive_daily`

)

SELECT
  total_rows,
  distinct_event_dates,
  duplicate_event_date_rows,

  null_event_date,
  null_sessions,
  null_users,
  null_transactions,
  null_revenue,

  negative_revenue_rows,
  negative_transaction_rows,
  negative_session_rows,
  negative_user_rows,

  impossible_session_conversion_rows,
  impossible_user_conversion_rows,
  impossible_engaged_session_rate_rows,

  CASE
    WHEN total_rows = distinct_event_dates
      AND duplicate_event_date_rows = 0
      AND null_event_date = 0
      AND null_sessions = 0
      AND null_users = 0
      AND null_transactions = 0
      AND null_revenue = 0
      AND negative_revenue_rows = 0
      AND negative_transaction_rows = 0
      AND negative_session_rows = 0
      AND negative_user_rows = 0
      AND impossible_session_conversion_rows = 0
      AND impossible_user_conversion_rows = 0
      AND impossible_engaged_session_rate_rows = 0
    THEN 'PASS'
    ELSE 'CHECK'
  END AS executive_mart_validation_status

FROM validation_summary;