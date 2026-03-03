-- 03_mart_channel_daily.sql
-- Purpose: BI-ready daily channel performance mart

CREATE OR REPLACE TABLE `nike-sql-practice.commercial_analytics_us.mart_channel_daily` AS
WITH fact AS (
  SELECT
    event_date,
    traffic_source,
    traffic_medium,
    campaign_name,
    sessions,
    users,
    purchase_events,
    revenue
  FROM `nike-sql-practice.commercial_analytics_us.fact_sessions_daily`
),

fact_with_key AS (
  SELECT
    f.*,
    TO_HEX(MD5(CONCAT(
      COALESCE(traffic_source, ''), '|',
      COALESCE(traffic_medium, ''), '|',
      COALESCE(campaign_name, '')
    ))) AS channel_key
  FROM fact f
)

SELECT
  d.date AS event_date,
  d.year,
  d.month,
  d.week_of_year,
  d.day_of_week,
  d.is_weekend,

  c.channel_key,
  c.traffic_source,
  c.traffic_medium,
  c.campaign_name,

  fwk.sessions,
  fwk.users,
  fwk.purchase_events,
  fwk.revenue,

  SAFE_DIVIDE(fwk.purchase_events, fwk.sessions) AS conversion_rate,
  SAFE_DIVIDE(fwk.revenue, fwk.sessions) AS revenue_per_session

FROM fact_with_key fwk
JOIN `nike-sql-practice.commercial_analytics_us.dim_date` d
  ON fwk.event_date = d.date
JOIN `nike-sql-practice.commercial_analytics_us.dim_channel` c
  ON fwk.channel_key = c.channel_key;