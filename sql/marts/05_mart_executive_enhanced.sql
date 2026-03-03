-- 05_mart_executive_enhanced.sql
-- Purpose: Executive KPIs with rolling + WoW metrics

CREATE OR REPLACE TABLE `nike-sql-practice.commercial_analytics_us.mart_executive_enhanced` AS
WITH base AS (
  SELECT *
  FROM `nike-sql-practice.commercial_analytics_us.mart_executive_daily`
),

enhanced AS (
  SELECT
    event_date,
    total_sessions,
    total_users,
    total_purchases,
    total_revenue,
    conversion_rate,
    revenue_per_session,
    cumulative_revenue,

    -- 7-day rolling revenue
    SUM(total_revenue)
      OVER (ORDER BY event_date
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)
      AS revenue_7d,

    -- 7-day rolling conversion
    AVG(conversion_rate)
      OVER (ORDER BY event_date
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)
      AS conversion_7d,

    -- WoW absolute revenue change
    total_revenue -
      LAG(total_revenue, 7)
      OVER (ORDER BY event_date)
      AS revenue_wow_delta,

    -- WoW % revenue change
    SAFE_DIVIDE(
      total_revenue -
        LAG(total_revenue, 7)
        OVER (ORDER BY event_date),
      LAG(total_revenue, 7)
        OVER (ORDER BY event_date)
    ) AS revenue_wow_pct

  FROM base
)

SELECT *
FROM enhanced
ORDER BY event_date;