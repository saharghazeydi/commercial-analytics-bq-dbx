-- 02_stg_ga4_events.sql
-- Purpose: Create flattened GA4 staging view at event grain
-- Grain: one row per raw GA4 event

CREATE OR REPLACE VIEW `commercial-analytics-bq-dbx.commercial_analytics_us.stg_ga4_events` AS

WITH base AS (
  SELECT
    PARSE_DATE('%Y%m%d', event_date) AS event_date,
    TIMESTAMP_MICROS(event_timestamp) AS event_timestamp_utc,
    event_timestamp AS event_timestamp_raw,
    event_name,
    user_pseudo_id,

    (
      SELECT ANY_VALUE(value.int_value)
      FROM UNNEST(event_params)
      WHERE key = 'ga_session_id'
    ) AS ga_session_id,

    (
      SELECT ANY_VALUE(value.int_value)
      FROM UNNEST(event_params)
      WHERE key = 'ga_session_number'
    ) AS ga_session_number,

    (
      SELECT ANY_VALUE(value.string_value)
      FROM UNNEST(event_params)
      WHERE key = 'page_location'
    ) AS page_location,

    (
      SELECT ANY_VALUE(value.string_value)
      FROM UNNEST(event_params)
      WHERE key = 'page_title'
    ) AS page_title,

    (
      SELECT ANY_VALUE(value.string_value)
      FROM UNNEST(event_params)
      WHERE key = 'page_referrer'
    ) AS page_referrer,

    (
      SELECT ANY_VALUE(value.int_value)
      FROM UNNEST(event_params)
      WHERE key = 'engagement_time_msec'
    ) AS engagement_time_msec,

    (
      SELECT ANY_VALUE(
        COALESCE(
          value.string_value,
          CAST(value.int_value AS STRING),
          CAST(value.double_value AS STRING)
        )
      )
      FROM UNNEST(event_params)
      WHERE key = 'session_engaged'
    ) AS session_engaged,

    (
      SELECT ANY_VALUE(value.string_value)
      FROM UNNEST(event_params)
      WHERE key = 'source'
    ) AS source,

    (
      SELECT ANY_VALUE(value.string_value)
      FROM UNNEST(event_params)
      WHERE key = 'medium'
    ) AS medium,

    (
      SELECT ANY_VALUE(value.string_value)
      FROM UNNEST(event_params)
      WHERE key = 'campaign'
    ) AS campaign,

    ecommerce.transaction_id AS transaction_id_raw,
    ecommerce.purchase_revenue AS purchase_revenue,
    ecommerce.total_item_quantity AS total_item_quantity,
    ecommerce.unique_items AS unique_items,

    ARRAY_LENGTH(items) AS item_array_length,
    _TABLE_SUFFIX AS source_table_suffix

  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _TABLE_SUFFIX BETWEEN '20210101' AND '20210131'
)

SELECT
  event_date,
  event_timestamp_utc,
  event_timestamp_raw,
  event_name,
  user_pseudo_id,

  ga_session_id,
  ga_session_number,

  CASE
    WHEN user_pseudo_id IS NOT NULL
      AND ga_session_id IS NOT NULL
    THEN CONCAT(user_pseudo_id, '|', CAST(ga_session_id AS STRING))
    ELSE NULL
  END AS session_key,

  page_location,
  page_title,
  page_referrer,

  engagement_time_msec,
  session_engaged,

  COALESCE(source, '(not set)') AS source,
  COALESCE(medium, '(not set)') AS medium,
  COALESCE(campaign, '(not set)') AS campaign,

  transaction_id_raw,
  NULLIF(transaction_id_raw, '(not set)') AS transaction_id,

  CASE
    WHEN event_name = 'purchase'
      AND (
        transaction_id_raw IS NULL
        OR transaction_id_raw = '(not set)'
      )
    THEN TRUE
    ELSE FALSE
  END AS is_invalid_purchase_transaction_id,

  purchase_revenue,

  CASE
    WHEN event_name = 'purchase'
      AND purchase_revenue IS NULL
    THEN TRUE
    ELSE FALSE
  END AS is_missing_purchase_revenue,

  total_item_quantity,
  unique_items,
  item_array_length,

  CASE
    WHEN item_array_length > 0 THEN TRUE
    ELSE FALSE
  END AS has_items,

  CASE
    WHEN event_name = 'purchase' THEN TRUE
    ELSE FALSE
  END AS is_purchase_event,

  source_table_suffix

FROM base;