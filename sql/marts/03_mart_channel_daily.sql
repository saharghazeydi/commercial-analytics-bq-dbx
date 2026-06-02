-- ============================================================
-- 03_mart_channel_daily.sql
-- Purpose:
-- Create daily channel-level commercial analytics mart
--
-- Grain:
-- One row per event_date + channel_key
--
-- Sources:
-- - fact_sessions_daily
-- - dim_channel
-- - dim_date
--
-- Business Use Cases:
-- - Channel performance reporting
-- - Daily acquisition monitoring
-- - Conversion and revenue KPI analysis
-- - BI dashboard layer
-- ============================================================

CREATE OR REPLACE TABLE
`commercial-analytics-bq-dbx.commercial_analytics_us.mart_channel_daily`
AS

WITH channel_daily AS (

  SELECT
    fs.event_date,
    dc.channel_key,
    dc.channel_group,
    dc.source,
    dc.medium,
    dc.campaign,

    dd.calendar_year,
    dd.calendar_quarter,
    dd.calendar_month,
    dd.calendar_week,
    dd.year_month,
    dd.day_name,
    dd.day_name_short,
    dd.is_weekend,
    dd.is_weekday,

    COUNT(*) AS sessions,

    COUNT(DISTINCT fs.user_pseudo_id) AS users,

    SUM(fs.event_count) AS total_events,

    SUM(fs.page_view_events) AS page_view_events,
    SUM(fs.user_engagement_events) AS user_engagement_events,
    SUM(fs.scroll_events) AS scroll_events,

    SUM(fs.ecommerce_funnel_events) AS ecommerce_funnel_events,
    SUM(fs.view_item_events) AS view_item_events,
    SUM(fs.add_to_cart_events) AS add_to_cart_events,
    SUM(fs.begin_checkout_events) AS begin_checkout_events,
    SUM(fs.purchase_event_rows) AS purchase_event_rows,

    SUM(fs.valid_transactions) AS transactions,

    SUM(fs.deduplicated_revenue) AS revenue,

    SUM(fs.total_engagement_time_msec) AS total_engagement_time_msec,

    SUM(fs.engaged_event_rows) AS engaged_event_rows,

    SUM(fs.is_engaged_session) AS engaged_sessions,

    SUM(fs.invalid_purchase_transaction_id_events)
      AS invalid_purchase_transaction_id_events,

    SUM(fs.missing_purchase_revenue_events)
      AS missing_purchase_revenue_events,

    SUM(fs.zero_purchase_revenue_events)
      AS zero_purchase_revenue_events,

    SUM(fs.negative_purchase_revenue_events)
      AS negative_purchase_revenue_events

  FROM `commercial-analytics-bq-dbx.commercial_analytics_us.fact_sessions_daily` fs

  LEFT JOIN `commercial-analytics-bq-dbx.commercial_analytics_us.dim_channel` dc
    ON COALESCE(fs.session_source, '(not set)') = dc.source
    AND COALESCE(fs.session_medium, '(not set)') = dc.medium
    AND COALESCE(fs.session_campaign, '(not set)') = dc.campaign

  LEFT JOIN `commercial-analytics-bq-dbx.commercial_analytics_us.dim_date` dd
    ON fs.event_date = dd.date_day

  GROUP BY
    fs.event_date,
    dc.channel_key,
    dc.channel_group,
    dc.source,
    dc.medium,
    dc.campaign,
    dd.calendar_year,
    dd.calendar_quarter,
    dd.calendar_month,
    dd.calendar_week,
    dd.year_month,
    dd.day_name,
    dd.day_name_short,
    dd.is_weekend,
    dd.is_weekday

)

SELECT
  event_date,
  channel_key,
  channel_group,
  source,
  medium,
  campaign,

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
  user_engagement_events,
  scroll_events,

  ecommerce_funnel_events,
  view_item_events,
  add_to_cart_events,
  begin_checkout_events,
  purchase_event_rows,

  transactions,
  revenue,

  engaged_sessions,
  engaged_event_rows,
  total_engagement_time_msec,

  invalid_purchase_transaction_id_events,
  missing_purchase_revenue_events,
  zero_purchase_revenue_events,
  negative_purchase_revenue_events,

  ROUND(SAFE_DIVIDE(users, sessions), 4)
    AS users_per_session,

  ROUND(SAFE_DIVIDE(total_events, sessions), 4)
    AS events_per_session,

  ROUND(SAFE_DIVIDE(page_view_events, sessions), 4)
    AS page_views_per_session,

  ROUND(SAFE_DIVIDE(engaged_sessions, sessions), 4)
    AS engaged_session_rate,

  ROUND(SAFE_DIVIDE(total_engagement_time_msec, sessions), 2)
    AS avg_engagement_time_msec_per_session,

  ROUND(SAFE_DIVIDE(view_item_events, sessions), 4)
    AS view_item_rate_per_session,

  ROUND(SAFE_DIVIDE(add_to_cart_events, sessions), 4)
    AS add_to_cart_rate_per_session,

  ROUND(SAFE_DIVIDE(begin_checkout_events, sessions), 4)
    AS begin_checkout_rate_per_session,

  ROUND(SAFE_DIVIDE(purchase_event_rows, sessions), 4)
    AS purchase_event_rate_per_session,

  ROUND(SAFE_DIVIDE(transactions, sessions), 4)
    AS session_conversion_rate,

  ROUND(SAFE_DIVIDE(transactions, users), 4)
    AS user_conversion_rate,

  ROUND(SAFE_DIVIDE(revenue, sessions), 2)
    AS revenue_per_session,

  ROUND(SAFE_DIVIDE(revenue, users), 2)
    AS revenue_per_user,

  ROUND(SAFE_DIVIDE(revenue, transactions), 2)
    AS average_order_value,

  ROUND(SAFE_DIVIDE(add_to_cart_events, view_item_events), 4)
    AS view_to_cart_rate,

  ROUND(SAFE_DIVIDE(begin_checkout_events, add_to_cart_events), 4)
    AS cart_to_checkout_rate,

  ROUND(SAFE_DIVIDE(transactions, begin_checkout_events), 4)
    AS checkout_to_purchase_rate,

  ROUND(SAFE_DIVIDE(transactions, view_item_events), 4)
    AS view_to_purchase_rate,

  CASE
    WHEN revenue > 0 THEN TRUE
    ELSE FALSE
  END AS has_revenue,

  CASE
    WHEN transactions > 0 THEN TRUE
    ELSE FALSE
  END AS has_transactions,

  CASE
    WHEN sessions > 0 THEN TRUE
    ELSE FALSE
  END AS has_sessions

FROM channel_daily

ORDER BY
  event_date,
  sessions DESC,
  channel_group;