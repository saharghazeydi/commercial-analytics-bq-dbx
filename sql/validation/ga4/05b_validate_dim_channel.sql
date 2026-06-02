-- ============================================================
-- 05b_validate_dim_channel.sql
-- Purpose:
-- Validate dim_channel grain, null safety, classification logic,
-- and readiness for mart joins
-- ============================================================



-- ============================================================
-- CV1) Channel row count validation
-- Purpose: confirm dim_channel contains rows
-- ============================================================

SELECT
  COUNT(*) AS total_channel_rows
FROM `commercial-analytics-bq-dbx.commercial_analytics_us.dim_channel`;



-- ============================================================
-- CV2) Channel grain uniqueness validation
-- Purpose: confirm one row per channel_key
-- ============================================================

SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT channel_key) AS distinct_channel_keys,
  COUNT(*) - COUNT(DISTINCT channel_key) AS duplicate_channel_key_rows
FROM `commercial-analytics-bq-dbx.commercial_analytics_us.dim_channel`;



-- ============================================================
-- CV3) Source / medium / campaign uniqueness validation
-- Purpose: confirm source + medium + campaign grain is unique
-- ============================================================

SELECT
  COUNT(*) AS total_rows,

  COUNT(DISTINCT CONCAT(
    source,
    ' | ',
    medium,
    ' | ',
    campaign
  )) AS distinct_source_medium_campaign,

  COUNT(*) -
  COUNT(DISTINCT CONCAT(
    source,
    ' | ',
    medium,
    ' | ',
    campaign
  )) AS duplicate_source_medium_campaign_rows

FROM `commercial-analytics-bq-dbx.commercial_analytics_us.dim_channel`;



-- ============================================================
-- CV4) Null critical field validation
-- Purpose: confirm required channel fields are populated
-- ============================================================

SELECT
  COUNT(*) AS total_rows,

  COUNTIF(channel_key IS NULL) AS null_channel_key,
  COUNTIF(source IS NULL) AS null_source,
  COUNTIF(medium IS NULL) AS null_medium,
  COUNTIF(campaign IS NULL) AS null_campaign,
  COUNTIF(channel_group IS NULL) AS null_channel_group

FROM `commercial-analytics-bq-dbx.commercial_analytics_us.dim_channel`;



-- ============================================================
-- CV5) Channel group distribution validation
-- Purpose: inspect assigned channel groups
-- ============================================================

SELECT
  channel_group,
  COUNT(*) AS channel_combinations,
  ROUND(
    SAFE_DIVIDE(
      COUNT(*),
      SUM(COUNT(*)) OVER ()
    ),
    4
  ) AS channel_combination_share

FROM `commercial-analytics-bq-dbx.commercial_analytics_us.dim_channel`

GROUP BY channel_group
ORDER BY channel_combinations DESC;



-- ============================================================
-- CV6) Join coverage validation against fact_sessions_daily
-- Purpose:
-- confirm every fact session can map to one dim_channel row
-- ============================================================

SELECT
  COUNT(*) AS fact_rows,

  COUNT(dc.channel_key) AS matched_channel_rows,

  COUNT(*) - COUNT(dc.channel_key) AS unmatched_fact_rows,

  ROUND(
    SAFE_DIVIDE(
      COUNT(dc.channel_key),
      COUNT(*)
    ),
    4
  ) AS match_rate

FROM `commercial-analytics-bq-dbx.commercial_analytics_us.fact_sessions_daily` fs

LEFT JOIN `commercial-analytics-bq-dbx.commercial_analytics_us.dim_channel` dc
  ON COALESCE(fs.session_source, '(not set)') = dc.source
  AND COALESCE(fs.session_medium, '(not set)') = dc.medium
  AND COALESCE(fs.session_campaign, '(not set)') = dc.campaign;



-- ============================================================
-- CV7) Session distribution by channel group
-- Purpose:
-- inspect session volume after joining fact_sessions_daily to dim_channel
-- ============================================================

SELECT
  dc.channel_group,
  COUNT(*) AS sessions,
  ROUND(
    SAFE_DIVIDE(
      COUNT(*),
      SUM(COUNT(*)) OVER ()
    ),
    4
  ) AS session_share

FROM `commercial-analytics-bq-dbx.commercial_analytics_us.fact_sessions_daily` fs

LEFT JOIN `commercial-analytics-bq-dbx.commercial_analytics_us.dim_channel` dc
  ON COALESCE(fs.session_source, '(not set)') = dc.source
  AND COALESCE(fs.session_medium, '(not set)') = dc.medium
  AND COALESCE(fs.session_campaign, '(not set)') = dc.campaign

GROUP BY dc.channel_group
ORDER BY sessions DESC;



-- ============================================================
-- CV8) Final dim_channel validation status
-- Purpose: high-level PASS/CHECK summary
-- ============================================================

WITH checks AS (

  SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT channel_key) AS distinct_channel_keys,

    COUNTIF(channel_key IS NULL) AS null_channel_key,
    COUNTIF(source IS NULL) AS null_source,
    COUNTIF(medium IS NULL) AS null_medium,
    COUNTIF(campaign IS NULL) AS null_campaign,
    COUNTIF(channel_group IS NULL) AS null_channel_group

  FROM `commercial-analytics-bq-dbx.commercial_analytics_us.dim_channel`

),

join_check AS (

  SELECT
    COUNT(*) - COUNT(dc.channel_key) AS unmatched_fact_rows

  FROM `commercial-analytics-bq-dbx.commercial_analytics_us.fact_sessions_daily` fs

  LEFT JOIN `commercial-analytics-bq-dbx.commercial_analytics_us.dim_channel` dc
    ON COALESCE(fs.session_source, '(not set)') = dc.source
    AND COALESCE(fs.session_medium, '(not set)') = dc.medium
    AND COALESCE(fs.session_campaign, '(not set)') = dc.campaign

)

SELECT
  c.total_rows,
  c.distinct_channel_keys,

  CASE
    WHEN c.total_rows = c.distinct_channel_keys
      AND c.null_channel_key = 0
      AND c.null_source = 0
      AND c.null_medium = 0
      AND c.null_campaign = 0
      AND c.null_channel_group = 0
      AND j.unmatched_fact_rows = 0
    THEN 'PASS'
    ELSE 'CHECK'
  END AS dim_channel_validation_status,

  c.null_channel_key,
  c.null_source,
  c.null_medium,
  c.null_campaign,
  c.null_channel_group,
  j.unmatched_fact_rows

FROM checks c
CROSS JOIN join_check j;