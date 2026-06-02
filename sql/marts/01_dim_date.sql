-- ============================================================
-- DIMENSION: dim_date
--
-- Grain:
-- One row per calendar date
--
-- Purpose:
-- Central date dimension used by:
--
-- - fact_sessions_daily
-- - mart_channel_daily
-- - mart_executive_daily
-- - mart_executive_enhanced
--
-- Business Benefits:
--
-- - consistent calendar reporting
-- - time-series analysis
-- - rolling KPI calculations
-- - dashboard filtering
-- - period comparisons
--
-- ============================================================
CREATE OR REPLACE TABLE
`commercial-analytics-bq-dbx.commercial_analytics_us.dim_date`
AS

WITH date_spine AS (

  SELECT
    day AS date_day

  FROM UNNEST(
    GENERATE_DATE_ARRAY(
      DATE '2021-01-01',
      DATE '2021-01-31'
    )
  ) AS day

)

SELECT

  -- ========================================================
  -- Core Key
  -- ========================================================

  date_day,


  -- ========================================================
  -- Calendar Attributes
  -- ========================================================

  EXTRACT(YEAR FROM date_day)
    AS calendar_year,

  EXTRACT(QUARTER FROM date_day)
    AS calendar_quarter,

  EXTRACT(MONTH FROM date_day)
    AS calendar_month,

  EXTRACT(WEEK FROM date_day)
    AS calendar_week,

  EXTRACT(DAY FROM date_day)
    AS day_of_month,


  -- ========================================================
  -- Day Names
  -- ========================================================

  FORMAT_DATE('%A', date_day)
    AS day_name,

  FORMAT_DATE('%a', date_day)
    AS day_name_short,


  -- ========================================================
  -- Month Names
  -- ========================================================

  FORMAT_DATE('%B', date_day)
    AS month_name,

  FORMAT_DATE('%b', date_day)
    AS month_name_short,


  -- ========================================================
  -- Reporting Labels
  -- ========================================================

  FORMAT_DATE('%Y-%m', date_day)
    AS year_month,

  FORMAT_DATE('%Y-%m-%d', date_day)
    AS date_label,


  -- ========================================================
  -- Weekend Logic
  -- ========================================================

  CASE
    WHEN EXTRACT(DAYOFWEEK FROM date_day)
         IN (1,7)
    THEN TRUE
    ELSE FALSE
  END
    AS is_weekend,


  CASE
    WHEN EXTRACT(DAYOFWEEK FROM date_day)
         BETWEEN 2 AND 6
    THEN TRUE
    ELSE FALSE
  END
    AS is_weekday,


  -- ========================================================
  -- Period Boundaries
  -- ========================================================

  CASE
    WHEN date_day =
      DATE_TRUNC(date_day, MONTH)
    THEN TRUE
    ELSE FALSE
  END
    AS is_month_start,


  CASE
    WHEN date_day =
      LAST_DAY(date_day)
    THEN TRUE
    ELSE FALSE
  END
    AS is_month_end,


  CASE
    WHEN date_day =
      DATE_TRUNC(date_day, QUARTER)
    THEN TRUE
    ELSE FALSE
  END
    AS is_quarter_start,


  CASE
    WHEN date_day =
      LAST_DAY(date_day, QUARTER)
    THEN TRUE
    ELSE FALSE
  END
    AS is_quarter_end,


  CASE
    WHEN date_day =
      DATE_TRUNC(date_day, YEAR)
    THEN TRUE
    ELSE FALSE
  END
    AS is_year_start,


  CASE
    WHEN date_day =
      LAST_DAY(date_day, YEAR)
    THEN TRUE
    ELSE FALSE
  END
    AS is_year_end

FROM date_spine

ORDER BY date_day;