/*
GA4 Data Profiling (Sample window: 2021-01-01 to 2021-01-31)
Project: nike-sql-practice (Sandbox)
Source: bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*
*/

-- A1) sample rows (structure sanity)
SELECT *
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20210101' AND '20210131'
LIMIT 10;

-- B1) date coverage (sample window)
SELECT
  MIN(PARSE_DATE('%Y%m%d', event_date)) AS min_date,
  MAX(PARSE_DATE('%Y%m%d', event_date)) AS max_date,
  COUNT(*) AS total_events
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20210101' AND '20210131';

-- B1b) date coverage (global)
SELECT
  MIN(PARSE_DATE('%Y%m%d', event_date)) AS global_min_date,
  MAX(PARSE_DATE('%Y%m%d', event_date)) AS global_max_date
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`;

-- C1) null rates for core identifiers (sample window)
SELECT
  COUNT(*) AS total_rows,
  SUM(CASE WHEN event_date IS NULL THEN 1 ELSE 0 END) AS null_event_date,
  SUM(CASE WHEN event_timestamp IS NULL THEN 1 ELSE 0 END) AS null_event_timestamp,
  SUM(CASE WHEN event_name IS NULL THEN 1 ELSE 0 END) AS null_event_name,
  SUM(CASE WHEN user_pseudo_id IS NULL THEN 1 ELSE 0 END) AS null_user_pseudo_id
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20210101' AND '20210131';

-- C2) approximate duplicate events (proxy key)
WITH base AS (
  SELECT
    user_pseudo_id,
    event_timestamp,
    event_name
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _TABLE_SUFFIX BETWEEN '20210101' AND '20210131'
)
SELECT
  COUNT(*) AS row_count,
  COUNT(DISTINCT CONCAT(user_pseudo_id,'|',CAST(event_timestamp AS STRING),'|',event_name)) AS distinct_proxy,
  COUNT(*) - COUNT(DISTINCT CONCAT(user_pseudo_id,'|',CAST(event_timestamp AS STRING),'|',event_name)) AS duplicate_proxy_rows
FROM base;

-- C3) invalid event_date format check
SELECT
  COUNT(*) AS total_rows,
  SUM(CASE WHEN SAFE.PARSE_DATE('%Y%m%d', event_date) IS NULL THEN 1 ELSE 0 END) AS invalid_event_date
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20210101' AND '20210131';

-- D1) top events (sample window)
SELECT event_name, COUNT(*) AS cnt
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20210101' AND '20210131'
GROUP BY 1
ORDER BY cnt DESC
LIMIT 20;

-- D2) purchase presence + revenue (sample window)
SELECT
  COUNTIF(event_name = 'purchase') AS purchase_events,
  SUM(CASE WHEN event_name = 'purchase' THEN COALESCE(ecommerce.purchase_revenue, 0) ELSE 0 END) AS total_purchase_revenue,
  COUNT(DISTINCT ecommerce.transaction_id) AS distinct_transaction_ids
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20210101' AND '20210131';

-- D3) explain items sparsity by event type (sample window)
SELECT
  event_name,
  COUNT(*) AS row_count,
  SUM(CASE WHEN ARRAY_LENGTH(items) IS NULL OR ARRAY_LENGTH(items) = 0 THEN 1 ELSE 0 END) AS no_items_row_count,
  SUM(CASE WHEN ARRAY_LENGTH(items) > 0 THEN 1 ELSE 0 END) AS has_items_row_count
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20210101' AND '20210131'
GROUP BY 1
ORDER BY has_items_row_count DESC, row_count DESC
LIMIT 30;