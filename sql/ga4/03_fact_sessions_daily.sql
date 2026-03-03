-- 03_fact_sessions_daily.sql
-- Purpose: Daily session-level fact for acquisition + conversion KPIs

CREATE OR REPLACE TABLE `nike-sql-practice.commercial_analytics_us.fact_sessions_daily` AS
WITH base AS (
  SELECT
    event_date,
    user_pseudo_id,
    traffic_source,
    traffic_medium,
    campaign_name,
    ga_session_id,
    event_name,
    purchase_revenue
  FROM `nike-sql-practice.commercial_analytics_us.stg_ga4_events`
  WHERE ga_session_id IS NOT NULL
)

SELECT
  event_date,
  traffic_source,
  traffic_medium,
  campaign_name,

  COUNT(DISTINCT CONCAT(CAST(user_pseudo_id AS STRING), '-', CAST(ga_session_id AS STRING))) AS sessions,
  COUNT(DISTINCT user_pseudo_id) AS users,

  COUNTIF(event_name = 'purchase') AS purchase_events,
  SUM(COALESCE(purchase_revenue, 0)) AS revenue

FROM base
GROUP BY 1,2,3,4;