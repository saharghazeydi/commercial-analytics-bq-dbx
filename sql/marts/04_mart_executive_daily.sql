-- ============================================================
-- 04_mart_executive_daily.sql
-- Purpose:
-- Create daily executive-level commercial analytics mart
--
-- Grain:
-- One row per event_date
--
-- Source:
-- - mart_channel_daily
--
-- Business Use Cases:
-- - Executive KPI reporting
-- - Daily commercial performance monitoring
-- - BI dashboard summary layer
-- - Conversion and revenue performance tracking
--
-- Notes:
-- - Revenue is already deduplicated upstream in fact_sessions_daily.
-- - mart_channel_daily is the validated source for this executive mart.
-- - This table intentionally removes channel-level detail.
-- - Rolling and WoW metrics should be built later in mart_executive_enhanced.
-- ============================================================

CREATE OR REPLACE TABLE
`commercial-analytics-bq-dbx.commercial_analytics_us.mart_executive_daily`
AS

WITH executive_daily AS (

  SELECT
    event_date,

    -- ========================================================
    -- Traffic Metrics
    -- ========================================================

    SUM(sessions) AS sessions,

    SUM(users) AS users,


    -- ========================================================
    -- Engagement Metrics
    -- ========================================================

    SUM(total_events) AS total_events,

    SUM(page_view_events) AS page_view_events,

    SUM(user_engagement_events) AS user_engagement_events,

    SUM(scroll_events) AS scroll_events,

    SUM(engaged_sessions) AS engaged_sessions,

    SUM(engaged_event_rows) AS engaged_event_rows,

    SUM(total_engagement_time_msec)
      AS total_engagement_time_msec,


    -- ========================================================
    -- Ecommerce Funnel Metrics
    -- ========================================================

    SUM(ecommerce_funnel_events) AS ecommerce_funnel_events,

    SUM(view_item_events) AS view_item_events,

    SUM(add_to_cart_events) AS add_to_cart_events,

    SUM(begin_checkout_events) AS begin_checkout_events,

    SUM(purchase_event_rows) AS purchase_event_rows,


    -- ========================================================
    -- Commercial Outcome Metrics
    -- ========================================================

    SUM(transactions) AS transactions,

    ROUND(SUM(revenue), 2) AS revenue,


    -- ========================================================
    -- Data Quality Metrics
    -- ========================================================

    SUM(invalid_purchase_transaction_id_events)
      AS invalid_purchase_transaction_id_events,

    SUM(missing_purchase_revenue_events)
      AS missing_purchase_revenue_events,

    SUM(zero_purchase_revenue_events)
      AS zero_purchase_revenue_events,

    SUM(negative_purchase_revenue_events)
      AS negative_purchase_revenue_events

  FROM
    `commercial-analytics-bq-dbx.commercial_analytics_us.mart_channel_daily`

  GROUP BY
    event_date

)

SELECT
  event_date,

  -- ========================================================
  -- Traffic Metrics
  -- ========================================================

  sessions,
  users,


  -- ========================================================
  -- Engagement Metrics
  -- ========================================================

  total_events,
  page_view_events,
  user_engagement_events,
  scroll_events,

  engaged_sessions,
  engaged_event_rows,
  total_engagement_time_msec,


  -- ========================================================
  -- Ecommerce Funnel Metrics
  -- ========================================================

  ecommerce_funnel_events,
  view_item_events,
  add_to_cart_events,
  begin_checkout_events,
  purchase_event_rows,


  -- ========================================================
  -- Commercial Outcome Metrics
  -- ========================================================

  transactions,
  revenue,


  -- ========================================================
  -- Data Quality Metrics
  -- ========================================================

  invalid_purchase_transaction_id_events,
  missing_purchase_revenue_events,
  zero_purchase_revenue_events,
  negative_purchase_revenue_events,


  -- ========================================================
  -- Traffic Efficiency KPIs
  -- ========================================================

  ROUND(SAFE_DIVIDE(users, sessions), 4)
    AS users_per_session,

  ROUND(SAFE_DIVIDE(total_events, sessions), 4)
    AS events_per_session,

  ROUND(SAFE_DIVIDE(page_view_events, sessions), 4)
    AS page_views_per_session,


  -- ========================================================
  -- Engagement KPIs
  -- ========================================================

  ROUND(SAFE_DIVIDE(engaged_sessions, sessions), 4)
    AS engaged_session_rate,

  ROUND(SAFE_DIVIDE(total_engagement_time_msec, sessions), 2)
    AS avg_engagement_time_msec_per_session,


  -- ========================================================
  -- Funnel KPIs
  -- ========================================================

  ROUND(SAFE_DIVIDE(view_item_events, sessions), 4)
    AS view_item_rate_per_session,

  ROUND(SAFE_DIVIDE(add_to_cart_events, sessions), 4)
    AS add_to_cart_rate_per_session,

  ROUND(SAFE_DIVIDE(begin_checkout_events, sessions), 4)
    AS begin_checkout_rate_per_session,

  ROUND(SAFE_DIVIDE(purchase_event_rows, sessions), 4)
    AS purchase_event_rate_per_session,


  -- ========================================================
  -- Conversion KPIs
  -- ========================================================

  ROUND(SAFE_DIVIDE(transactions, sessions), 4)
    AS session_conversion_rate,

  ROUND(SAFE_DIVIDE(transactions, users), 4)
    AS user_conversion_rate,


  -- ========================================================
  -- Revenue KPIs
  -- ========================================================

  ROUND(SAFE_DIVIDE(revenue, sessions), 2)
    AS revenue_per_session,

  ROUND(SAFE_DIVIDE(revenue, users), 2)
    AS revenue_per_user,

  ROUND(SAFE_DIVIDE(revenue, transactions), 2)
    AS average_order_value,


  -- ========================================================
  -- Funnel Step Conversion KPIs
  -- ========================================================

  ROUND(SAFE_DIVIDE(add_to_cart_events, view_item_events), 4)
    AS view_to_cart_rate,

  ROUND(SAFE_DIVIDE(begin_checkout_events, add_to_cart_events), 4)
    AS cart_to_checkout_rate,

  ROUND(SAFE_DIVIDE(transactions, begin_checkout_events), 4)
    AS checkout_to_purchase_rate,

  ROUND(SAFE_DIVIDE(transactions, view_item_events), 4)
    AS view_to_purchase_rate,


  -- ========================================================
  -- Executive Flags
  -- ========================================================

  CASE
    WHEN sessions > 0 THEN TRUE
    ELSE FALSE
  END AS has_sessions,

  CASE
    WHEN transactions > 0 THEN TRUE
    ELSE FALSE
  END AS has_transactions,

  CASE
    WHEN revenue > 0 THEN TRUE
    ELSE FALSE
  END AS has_revenue,

  CASE
    WHEN invalid_purchase_transaction_id_events > 0
      OR missing_purchase_revenue_events > 0
      OR zero_purchase_revenue_events > 0
      OR negative_purchase_revenue_events > 0
    THEN TRUE
    ELSE FALSE
  END AS has_purchase_quality_issue

FROM
  executive_daily

ORDER BY
  event_date;