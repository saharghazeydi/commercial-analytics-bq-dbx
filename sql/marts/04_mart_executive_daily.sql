-- 04_mart_executive_daily.sql
-- Purpose: Executive-level daily KPIs

CREATE OR REPLACE TABLE `nike-sql-practice.commercial_analytics_us.mart_executive_daily` AS
SELECT
  event_date,

  SUM(sessions) AS total_sessions,
  SUM(users) AS total_users,
  SUM(purchase_events) AS total_purchases,
  SUM(revenue) AS total_revenue,

  SAFE_DIVIDE(SUM(purchase_events), SUM(sessions)) AS conversion_rate,
  SAFE_DIVIDE(SUM(revenue), SUM(sessions)) AS revenue_per_session,

  SUM(SUM(revenue)) OVER (ORDER BY event_date) AS cumulative_revenue

FROM `nike-sql-practice.commercial_analytics_us.mart_channel_daily`
GROUP BY event_date
ORDER BY event_date;