-- 02_dim_channel.sql
-- Purpose: Channel dimension from GA4 session fact

CREATE OR REPLACE TABLE `nike-sql-practice.commercial_analytics_us.dim_channel` AS
SELECT
  -- stable key
  TO_HEX(MD5(CONCAT(
    COALESCE(traffic_source, ''), '|',
    COALESCE(traffic_medium, ''), '|',
    COALESCE(campaign_name, '')
  ))) AS channel_key,

  traffic_source,
  traffic_medium,
  campaign_name

FROM `nike-sql-practice.commercial_analytics_us.fact_sessions_daily`
GROUP BY 1,2,3,4;