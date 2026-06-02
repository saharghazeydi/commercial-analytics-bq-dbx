-- ============================================================
-- 02_dim_channel.sql
-- Purpose:
-- Create reusable acquisition channel dimension from session-level GA4 data
--
-- Grain:
-- One row per normalized source + medium + campaign combination
-- ============================================================

CREATE OR REPLACE TABLE
`commercial-analytics-bq-dbx.commercial_analytics_us.dim_channel`
AS

WITH channel_base AS (

  SELECT DISTINCT
    COALESCE(session_source, '(not set)') AS source,
    COALESCE(session_medium, '(not set)') AS medium,
    COALESCE(session_campaign, '(not set)') AS campaign

  FROM `commercial-analytics-bq-dbx.commercial_analytics_us.fact_sessions_daily`

),

classified AS (

  SELECT
    source,
    medium,
    campaign,

    CONCAT(
      source,
      ' | ',
      medium,
      ' | ',
      campaign
    ) AS channel_key,

    CASE
      WHEN source = '(not set)'
        AND medium = '(not set)'
      THEN 'Unattributed'

      WHEN source = '(data deleted)'
        OR medium = '(data deleted)'
        OR campaign = '(data deleted)'
      THEN 'Data Deleted'

      WHEN source = '(direct)'
        OR medium = '(none)'
      THEN 'Direct'

      WHEN medium = 'organic'
      THEN 'Organic Search'

      WHEN medium IN ('cpc', 'paid', 'ppc')
      THEN 'Paid Search'

      WHEN medium = 'email'
      THEN 'Email'

      WHEN medium = 'affiliate'
      THEN 'Affiliate'

      WHEN medium = 'referral'
      THEN 'Referral'

      WHEN source = '<Other>'
        OR medium = '<Other>'
        OR campaign = '<Other>'
      THEN 'Other'

      ELSE 'Other'
    END AS channel_group,

    CASE
      WHEN source = '(not set)'
        OR medium = '(not set)'
        OR campaign = '(not set)'
      THEN TRUE
      ELSE FALSE
    END AS has_not_set_value,

    CASE
      WHEN source = '(data deleted)'
        OR medium = '(data deleted)'
        OR campaign = '(data deleted)'
      THEN TRUE
      ELSE FALSE
    END AS has_data_deleted_value,

    CASE
      WHEN source = '<Other>'
        OR medium = '<Other>'
        OR campaign = '<Other>'
      THEN TRUE
      ELSE FALSE
    END AS has_other_value

  FROM channel_base

)

SELECT
  channel_key,
  source,
  medium,
  campaign,
  channel_group,
  has_not_set_value,
  has_data_deleted_value,
  has_other_value

FROM classified

ORDER BY
  channel_group,
  source,
  medium,
  campaign;