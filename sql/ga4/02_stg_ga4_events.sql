-- 02_stg_ga4_events.sql
-- Purpose: Create flattened GA4 staging view (event-level)

CREATE OR REPLACE VIEW `nike-sql-practice.commercial_analytics.stg_ga4_events` AS
SELECT
  PARSE_DATE('%Y%m%d', event_date) AS event_date,
  event_timestamp,
  user_pseudo_id,
  event_name,

  -- session id
  (SELECT value.int_value
   FROM UNNEST(event_params)
   WHERE key = 'ga_session_id') AS ga_session_id,

  -- ecommerce signals
  ecommerce.purchase_revenue AS purchase_revenue,
  ecommerce.total_item_quantity AS total_item_quantity,
  ecommerce.transaction_id AS transaction_id,

  -- acquisition dimensions
  traffic_source.source AS traffic_source,
  traffic_source.medium AS traffic_medium,
  traffic_source.name AS campaign_name

FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20210101' AND '20210131';