-- ============================================================
-- 04_mart_executive_daily.sql
-- Purpose:
-- Create daily executive-level commercial analytics mart
--
-- Grain:
-- One row per event_date
--
-- Sources:
-- - mart_channel_daily
-- - fact_sessions_daily
--
-- Business Use Cases:
-- - Executive KPI reporting
-- - Daily commercial performance monitoring
-- - BI dashboard summary layer
-- - Conversion and revenue performance tracking
--
-- Important Modeling Note:
-- - Most metrics are additive and can be aggregated from mart_channel_daily.
-- - Users are NOT safely additive across channels.
-- - Therefore, true daily users are calculated directly from fact_sessions_daily
--   using COUNT(DISTINCT user_pseudo_id).
--
-- Notes:
-- - Revenue is already deduplicated upstream in fact_sessions_daily.
-- - Rolling and WoW metrics should be built later in mart_executive_enhanced.
-- ============================================================

CREATE OR REPLACE TABLE
`commercial-analytics-bq-dbx.commercial_analytics_us.mart_executive_daily`
AS

WITH channel_daily AS (

  SELECT
    event_date,

    -- Traffic Metrics
    SUM(sessions) AS sessions,

    -- Engagement Metrics
    SUM(total_events) AS total_events,
    SUM(page_view_events) AS page_view_events,
    SUM(user_engagement_events) AS user_engagement_events,
    SUM(scroll_events) AS scroll_events,
    SUM(engaged_sessions) AS engaged_sessions,
    SUM(engaged_event_rows) AS engaged_event_rows,
    SUM(total_engagement_time_msec) AS total_engagement_time_msec,

    -- Ecommerce Funnel Metrics
    SUM(ecommerce_funnel_events) AS ecommerce_funnel_events,
    SUM(view_item_events) AS view_item_events,
    SUM(add_to_cart_events) AS add_to_cart_events,
    SUM(begin_checkout_events) AS begin_checkout_events,
    SUM(purchase_event_rows) AS purchase_event_rows,

    -- Commercial Outcome Metrics
    SUM(transactions) AS transactions,
    ROUND(SUM(revenue), 2) AS revenue,

    -- Data Quality Metrics
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

),

daily_users AS (

  SELECT
    event_date,
    COUNT(DISTINCT user_pseudo_id) AS users

  FROM
    `commercial-analytics-bq-dbx.commercial_analytics_us.fact_sessions_daily`

  GROUP BY
    event_date

)

SELECT
  cd.event_date,

  -- Traffic Metrics
  cd.sessions,
  du.users,

  -- Engagement Metrics
  cd.total_events,
  cd.page_view_events,
  cd.user_engagement_events,
  cd.scroll_events,
  cd.engaged_sessions,
  cd.engaged_event_rows,
  cd.total_engagement_time_msec,

  -- Ecommerce Funnel Metrics
  cd.ecommerce_funnel_events,
  cd.view_item_events,
  cd.add_to_cart_events,
  cd.begin_checkout_events,
  cd.purchase_event_rows,

  -- Commercial Outcome Metrics
  cd.transactions,
  cd.revenue,

  -- Data Quality Metrics
  cd.invalid_purchase_transaction_id_events,
  cd.missing_purchase_revenue_events,
  cd.zero_purchase_revenue_events,
  cd.negative_purchase_revenue_events,

  -- Traffic Efficiency KPIs
  ROUND(SAFE_DIVIDE(du.users, cd.sessions), 4)
    AS users_per_session,

  ROUND(SAFE_DIVIDE(cd.total_events, cd.sessions), 4)
    AS events_per_session,

  ROUND(SAFE_DIVIDE(cd.page_view_events, cd.sessions), 4)
    AS page_views_per_session,

  -- Engagement KPIs
  ROUND(SAFE_DIVIDE(cd.engaged_sessions, cd.sessions), 4)
    AS engaged_session_rate,

  ROUND(SAFE_DIVIDE(cd.total_engagement_time_msec, cd.sessions), 2)
    AS avg_engagement_time_msec_per_session,

  -- Funnel KPIs
  ROUND(SAFE_DIVIDE(cd.view_item_events, cd.sessions), 4)
    AS view_item_rate_per_session,

  ROUND(SAFE_DIVIDE(cd.add_to_cart_events, cd.sessions), 4)
    AS add_to_cart_rate_per_session,

  ROUND(SAFE_DIVIDE(cd.begin_checkout_events, cd.sessions), 4)
    AS begin_checkout_rate_per_session,

  ROUND(SAFE_DIVIDE(cd.purchase_event_rows, cd.sessions), 4)
    AS purchase_event_rate_per_session,

  -- Conversion KPIs
  ROUND(SAFE_DIVIDE(cd.transactions, cd.sessions), 4)
    AS session_conversion_rate,

  ROUND(SAFE_DIVIDE(cd.transactions, du.users), 4)
    AS user_conversion_rate,

  -- Revenue KPIs
  ROUND(SAFE_DIVIDE(cd.revenue, cd.sessions), 2)
    AS revenue_per_session,

  ROUND(SAFE_DIVIDE(cd.revenue, du.users), 2)
    AS revenue_per_user,

  ROUND(SAFE_DIVIDE(cd.revenue, cd.transactions), 2)
    AS average_order_value,

  -- Funnel Step Conversion KPIs
  ROUND(SAFE_DIVIDE(cd.add_to_cart_events, cd.view_item_events), 4)
    AS view_to_cart_rate,

  ROUND(SAFE_DIVIDE(cd.begin_checkout_events, cd.add_to_cart_events), 4)
    AS cart_to_checkout_rate,

  ROUND(SAFE_DIVIDE(cd.transactions, cd.begin_checkout_events), 4)
    AS checkout_to_purchase_rate,

  ROUND(SAFE_DIVIDE(cd.transactions, cd.view_item_events), 4)
    AS view_to_purchase_rate,

  -- Executive Flags
  CASE
    WHEN cd.sessions > 0 THEN TRUE
    ELSE FALSE
  END AS has_sessions,

  CASE
    WHEN cd.transactions > 0 THEN TRUE
    ELSE FALSE
  END AS has_transactions,

  CASE
    WHEN cd.revenue > 0 THEN TRUE
    ELSE FALSE
  END AS has_revenue,

  CASE
    WHEN cd.invalid_purchase_transaction_id_events > 0
      OR cd.missing_purchase_revenue_events > 0
      OR cd.zero_purchase_revenue_events > 0
      OR cd.negative_purchase_revenue_events > 0
    THEN TRUE
    ELSE FALSE
  END AS has_purchase_quality_issue

FROM
  channel_daily cd

LEFT JOIN daily_users du
  ON cd.event_date = du.event_date

ORDER BY
  cd.event_date;