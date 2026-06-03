-- ============================================================
-- 05_mart_executive_enhanced.sql
-- Purpose:
-- Create enhanced executive KPI mart with rolling and WoW metrics
--
-- Grain:
-- One row per event_date
--
-- Sources:
-- - mart_executive_daily
-- - dim_date
--
-- Notes:
-- - Rolling metrics are calculated only for additive metrics.
-- - Rolling users are not calculated as true unique users because
--   daily distinct users are not safely additive across days.
-- - WoW users compare daily distinct users to the same weekday
--   seven days earlier.
-- ============================================================

CREATE OR REPLACE TABLE
`commercial-analytics-bq-dbx.commercial_analytics_us.mart_executive_enhanced`
AS

WITH base AS (

  SELECT
    ed.event_date,

    dd.calendar_year,
    dd.calendar_quarter,
    dd.calendar_month,
    dd.calendar_week,
    dd.year_month,
    dd.day_name,
    dd.day_name_short,
    dd.is_weekend,
    dd.is_weekday,

    ed.sessions,
    ed.users,
    ed.total_events,
    ed.page_view_events,
    ed.engaged_sessions,
    ed.transactions,
    ed.revenue,

    ed.session_conversion_rate,
    ed.user_conversion_rate,
    ed.revenue_per_session,
    ed.revenue_per_user,
    ed.average_order_value,
    ed.engaged_session_rate,

    ed.view_item_events,
    ed.add_to_cart_events,
    ed.begin_checkout_events,
    ed.purchase_event_rows,

    ed.view_to_cart_rate,
    ed.cart_to_checkout_rate,
    ed.checkout_to_purchase_rate,
    ed.view_to_purchase_rate,

    ed.has_sessions,
    ed.has_transactions,
    ed.has_revenue,
    ed.has_purchase_quality_issue

  FROM
    `commercial-analytics-bq-dbx.commercial_analytics_us.mart_executive_daily` ed

  LEFT JOIN
    `commercial-analytics-bq-dbx.commercial_analytics_us.dim_date` dd
    ON ed.event_date = dd.date_day

),

windowed AS (

  SELECT
    *,

    COUNT(*) OVER (
      ORDER BY event_date
      ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS rolling_7d_days,

    SUM(sessions) OVER (
      ORDER BY event_date
      ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS rolling_7d_sessions,

    SUM(transactions) OVER (
      ORDER BY event_date
      ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS rolling_7d_transactions,

    ROUND(
      SUM(revenue) OVER (
        ORDER BY event_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
      ),
      2
    ) AS rolling_7d_revenue,

    ROUND(
      AVG(users) OVER (
        ORDER BY event_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
      ),
      2
    ) AS rolling_7d_avg_daily_users,

    LAG(sessions, 7) OVER (
      ORDER BY event_date
    ) AS sessions_7d_ago,

    LAG(users, 7) OVER (
      ORDER BY event_date
    ) AS users_7d_ago,

    LAG(transactions, 7) OVER (
      ORDER BY event_date
    ) AS transactions_7d_ago,

    LAG(revenue, 7) OVER (
      ORDER BY event_date
    ) AS revenue_7d_ago,

    LAG(session_conversion_rate, 7) OVER (
      ORDER BY event_date
    ) AS session_conversion_rate_7d_ago,

    LAG(revenue_per_session, 7) OVER (
      ORDER BY event_date
    ) AS revenue_per_session_7d_ago

  FROM base

)

SELECT
  event_date,

  calendar_year,
  calendar_quarter,
  calendar_month,
  calendar_week,
  year_month,
  day_name,
  day_name_short,
  is_weekend,
  is_weekday,

  sessions,
  users,
  total_events,
  page_view_events,
  engaged_sessions,
  transactions,
  revenue,

  session_conversion_rate,
  user_conversion_rate,
  revenue_per_session,
  revenue_per_user,
  average_order_value,
  engaged_session_rate,

  view_item_events,
  add_to_cart_events,
  begin_checkout_events,
  purchase_event_rows,

  view_to_cart_rate,
  cart_to_checkout_rate,
  checkout_to_purchase_rate,
  view_to_purchase_rate,

  rolling_7d_days,
  rolling_7d_sessions,
  rolling_7d_transactions,
  rolling_7d_revenue,
  rolling_7d_avg_daily_users,

  ROUND(
    SAFE_DIVIDE(rolling_7d_transactions, rolling_7d_sessions),
    4
  ) AS rolling_7d_session_conversion_rate,

  ROUND(
    SAFE_DIVIDE(rolling_7d_revenue, rolling_7d_sessions),
    2
  ) AS rolling_7d_revenue_per_session,

  ROUND(
    SAFE_DIVIDE(rolling_7d_revenue, rolling_7d_transactions),
    2
  ) AS rolling_7d_average_order_value,

  sessions_7d_ago,
  users_7d_ago,
  transactions_7d_ago,
  revenue_7d_ago,
  session_conversion_rate_7d_ago,
  revenue_per_session_7d_ago,

  sessions - sessions_7d_ago AS wow_sessions_change,

  ROUND(
    SAFE_DIVIDE(sessions - sessions_7d_ago, sessions_7d_ago),
    4
  ) AS wow_sessions_change_rate,

  users - users_7d_ago AS wow_users_change,

  ROUND(
    SAFE_DIVIDE(users - users_7d_ago, users_7d_ago),
    4
  ) AS wow_users_change_rate,

  transactions - transactions_7d_ago AS wow_transactions_change,

  ROUND(
    SAFE_DIVIDE(transactions - transactions_7d_ago, transactions_7d_ago),
    4
  ) AS wow_transactions_change_rate,

  ROUND(revenue - revenue_7d_ago, 2) AS wow_revenue_change,

  ROUND(
    SAFE_DIVIDE(revenue - revenue_7d_ago, revenue_7d_ago),
    4
  ) AS wow_revenue_change_rate,

  ROUND(
    session_conversion_rate - session_conversion_rate_7d_ago,
    4
  ) AS wow_session_conversion_rate_change,

  ROUND(
    revenue_per_session - revenue_per_session_7d_ago,
    2
  ) AS wow_revenue_per_session_change,

  CASE
    WHEN rolling_7d_days = 7 THEN TRUE
    ELSE FALSE
  END AS has_complete_rolling_7d_window,

  CASE
    WHEN sessions_7d_ago IS NOT NULL THEN TRUE
    ELSE FALSE
  END AS has_wow_comparison,

  has_sessions,
  has_transactions,
  has_revenue,
  has_purchase_quality_issue

FROM windowed

ORDER BY
  event_date;