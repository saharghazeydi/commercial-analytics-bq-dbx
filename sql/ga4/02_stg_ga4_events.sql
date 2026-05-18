-- 02_stg_ga4_events.sql
-- Purpose: Create flattened GA4 staging view at event grain
-- Grain: one row per raw GA4 event
-- Source: bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*
-- Sample window: 2021-01-01 to 2021-01-31
--
-- Design notes:
-- - This view keeps event-level grain.
-- - Nested GA4 event_params are selectively flattened.
-- - Ecommerce fields are preserved for downstream modeling.
-- - Data quality flags are added, but rows are NOT filtered or deduplicated here.
-- - Transaction-level revenue deduplication should happen later in fact/mart logic.

CREATE OR REPLACE VIEW `commercial-analytics-bq-dbx.commercial_analytics_us.stg_ga4_events` AS

WITH base AS (
  SELECT
    -- ------------------------------------------------------------
    -- Source / audit fields
    -- ------------------------------------------------------------
    _TABLE_SUFFIX AS source_table_suffix,

    -- ------------------------------------------------------------
    -- Core event fields
    -- ------------------------------------------------------------
    SAFE.PARSE_DATE('%Y%m%d', event_date) AS event_date,
    event_date AS event_date_raw,
    TIMESTAMP_MICROS(event_timestamp) AS event_timestamp_utc,
    event_timestamp AS event_timestamp_raw,
    event_name,
    user_pseudo_id,

    -- ------------------------------------------------------------
    -- Session parameters
    -- ------------------------------------------------------------
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

    -- ------------------------------------------------------------
    -- Page / content parameters
    -- ------------------------------------------------------------
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

    -- ------------------------------------------------------------
    -- Engagement parameters
    -- ------------------------------------------------------------
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
          CAST(value.double_value AS STRING),
          CAST(value.float_value AS STRING)
        )
      )
      FROM UNNEST(event_params)
      WHERE key = 'session_engaged'
    ) AS session_engaged_raw,

    -- ------------------------------------------------------------
    -- Acquisition parameters
    -- Event-level source / medium / campaign are used here.
    -- Channel grouping should happen later in dim_channel or mart logic.
    -- ------------------------------------------------------------
    (
      SELECT ANY_VALUE(value.string_value)
      FROM UNNEST(event_params)
      WHERE key = 'source'
    ) AS source_raw,

    (
      SELECT ANY_VALUE(value.string_value)
      FROM UNNEST(event_params)
      WHERE key = 'medium'
    ) AS medium_raw,

    (
      SELECT ANY_VALUE(value.string_value)
      FROM UNNEST(event_params)
      WHERE key = 'campaign'
    ) AS campaign_raw,

    -- ------------------------------------------------------------
    -- Additional useful event parameters
    -- Kept because profiling showed event_params are event-aware.
    -- These support later funnel / behavior / search analysis if needed.
    -- ------------------------------------------------------------
    (
      SELECT ANY_VALUE(value.string_value)
      FROM UNNEST(event_params)
      WHERE key = 'search_term'
    ) AS search_term,

    (
      SELECT ANY_VALUE(value.int_value)
      FROM UNNEST(event_params)
      WHERE key = 'percent_scrolled'
    ) AS percent_scrolled,

    (
      SELECT ANY_VALUE(value.string_value)
      FROM UNNEST(event_params)
      WHERE key = 'coupon'
    ) AS coupon,

    (
      SELECT ANY_VALUE(value.string_value)
      FROM UNNEST(event_params)
      WHERE key = 'payment_type'
    ) AS payment_type,

    -- ------------------------------------------------------------
    -- Ecommerce fields
    -- ------------------------------------------------------------
    ecommerce.transaction_id AS transaction_id_raw,
    ecommerce.purchase_revenue AS purchase_revenue,
    ecommerce.total_item_quantity AS total_item_quantity,
    ecommerce.unique_items AS unique_items,

    -- ------------------------------------------------------------
    -- Item array metadata
    -- Do not unnest items in this event-level staging view.
    -- Product/item-level modeling should be done in a separate fact table.
    -- ------------------------------------------------------------
    ARRAY_LENGTH(items) AS item_array_length

  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _TABLE_SUFFIX BETWEEN '20210101' AND '20210131'
),

staged AS (
  SELECT
    -- ------------------------------------------------------------
    -- Source / audit fields
    -- ------------------------------------------------------------
    source_table_suffix,

    -- ------------------------------------------------------------
    -- Core event fields
    -- ------------------------------------------------------------
    event_date,
    event_date_raw,
    event_timestamp_utc,
    event_timestamp_raw,
    event_name,
    user_pseudo_id,

    -- ------------------------------------------------------------
    -- Session fields
    -- ------------------------------------------------------------
    ga_session_id,
    ga_session_number,

    CASE
      WHEN user_pseudo_id IS NOT NULL
        AND ga_session_id IS NOT NULL
      THEN CONCAT(user_pseudo_id, '|', CAST(ga_session_id AS STRING))
      ELSE NULL
    END AS session_key,

    -- ------------------------------------------------------------
    -- Page / content fields
    -- ------------------------------------------------------------
    page_location,
    page_title,
    page_referrer,

    -- ------------------------------------------------------------
    -- Engagement fields
    -- ------------------------------------------------------------
    engagement_time_msec,

    session_engaged_raw,

    CASE
      WHEN session_engaged_raw IN ('1', 'true', 'TRUE') THEN TRUE
      WHEN session_engaged_raw IN ('0', 'false', 'FALSE') THEN FALSE
      ELSE NULL
    END AS is_session_engaged,

    -- ------------------------------------------------------------
    -- Acquisition fields
    -- Normalize NULL / blank values only.
    -- Do not create business channel groups here.
    -- ------------------------------------------------------------
    COALESCE(NULLIF(TRIM(source_raw), ''), '(not set)') AS source,
    COALESCE(NULLIF(TRIM(medium_raw), ''), '(not set)') AS medium,
    COALESCE(NULLIF(TRIM(campaign_raw), ''), '(not set)') AS campaign,

    -- Raw acquisition values preserved for debugging
    source_raw,
    medium_raw,
    campaign_raw,

    -- ------------------------------------------------------------
    -- Additional event parameters
    -- ------------------------------------------------------------
    search_term,
    percent_scrolled,
    coupon,
    payment_type,

    -- ------------------------------------------------------------
    -- Ecommerce fields
    -- ------------------------------------------------------------
    transaction_id_raw,

    NULLIF(TRIM(transaction_id_raw), '(not set)') AS transaction_id,

    purchase_revenue,
    total_item_quantity,
    unique_items,

    item_array_length,

    CASE
      WHEN item_array_length > 0 THEN TRUE
      ELSE FALSE
    END AS has_items,

    -- ------------------------------------------------------------
    -- Event classification flags
    -- ------------------------------------------------------------
    CASE
      WHEN event_name = 'purchase' THEN TRUE
      ELSE FALSE
    END AS is_purchase_event,

    CASE
      WHEN event_name IN (
        'view_item',
        'add_to_cart',
        'begin_checkout',
        'purchase'
      )
      THEN TRUE
      ELSE FALSE
    END AS is_ecommerce_funnel_event,

    -- ------------------------------------------------------------
    -- Data quality flags
    -- These flags do not filter records.
    -- They make downstream validation and modeling safer.
    -- ------------------------------------------------------------
    CASE
      WHEN event_date IS NULL THEN TRUE
      ELSE FALSE
    END AS is_invalid_event_date,

    CASE
      WHEN user_pseudo_id IS NULL THEN TRUE
      ELSE FALSE
    END AS is_missing_user_pseudo_id,

    CASE
      WHEN ga_session_id IS NULL THEN TRUE
      ELSE FALSE
    END AS is_missing_ga_session_id,

    CASE
      WHEN user_pseudo_id IS NULL
        OR ga_session_id IS NULL
      THEN TRUE
      ELSE FALSE
    END AS is_missing_session_key,

    CASE
      WHEN event_name = 'purchase'
        AND (
          transaction_id_raw IS NULL
          OR TRIM(transaction_id_raw) = ''
          OR transaction_id_raw = '(not set)'
        )
      THEN TRUE
      ELSE FALSE
    END AS is_invalid_purchase_transaction_id,

    CASE
      WHEN event_name = 'purchase'
        AND purchase_revenue IS NULL
      THEN TRUE
      ELSE FALSE
    END AS is_missing_purchase_revenue,

    CASE
      WHEN event_name = 'purchase'
        AND purchase_revenue = 0
      THEN TRUE
      ELSE FALSE
    END AS is_zero_purchase_revenue,

    CASE
      WHEN event_name = 'purchase'
        AND purchase_revenue < 0
      THEN TRUE
      ELSE FALSE
    END AS is_negative_purchase_revenue,

    -- ------------------------------------------------------------
    -- Event proxy key
    -- Useful for downstream duplicate validation.
    -- This is not guaranteed to be a perfect natural key.
    -- ------------------------------------------------------------
    CASE
      WHEN user_pseudo_id IS NOT NULL
        AND event_timestamp_raw IS NOT NULL
        AND event_name IS NOT NULL
      THEN CONCAT(
        user_pseudo_id,
        '|',
        CAST(event_timestamp_raw AS STRING),
        '|',
        event_name
      )
      ELSE NULL
    END AS event_proxy_key

  FROM base
)

SELECT
  source_table_suffix,

  event_date,
  event_date_raw,
  event_timestamp_utc,
  event_timestamp_raw,
  event_name,
  user_pseudo_id,

  ga_session_id,
  ga_session_number,
  session_key,

  page_location,
  page_title,
  page_referrer,

  engagement_time_msec,
  session_engaged_raw,
  is_session_engaged,

  source,
  medium,
  campaign,
  source_raw,
  medium_raw,
  campaign_raw,

  search_term,
  percent_scrolled,
  coupon,
  payment_type,

  transaction_id_raw,
  transaction_id,
  purchase_revenue,
  total_item_quantity,
  unique_items,

  item_array_length,
  has_items,

  is_purchase_event,
  is_ecommerce_funnel_event,

  is_invalid_event_date,
  is_missing_user_pseudo_id,
  is_missing_ga_session_id,
  is_missing_session_key,
  is_invalid_purchase_transaction_id,
  is_missing_purchase_revenue,
  is_zero_purchase_revenue,
  is_negative_purchase_revenue,

  event_proxy_key

FROM staged;