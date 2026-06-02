-- ============================================================
-- 04b_validate_dim_date.sql
-- Purpose:
-- Validate dim_date structure, coverage, uniqueness, and calendar logic
-- ============================================================



-- ============================================================
-- DV1) Date range validation
-- Purpose: confirm expected January 2021 coverage
-- ============================================================

SELECT
  COUNT(*) AS total_dates,
  MIN(date_day) AS min_date,
  MAX(date_day) AS max_date,
  COUNT(DISTINCT date_day) AS distinct_dates
FROM `commercial-analytics-bq-dbx.commercial_analytics_us.dim_date`;



-- ============================================================
-- DV2) Date grain uniqueness validation
-- Purpose: confirm one row per date_day
-- ============================================================

SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT date_day) AS distinct_date_days,
  COUNT(*) - COUNT(DISTINCT date_day) AS duplicate_date_rows
FROM `commercial-analytics-bq-dbx.commercial_analytics_us.dim_date`;



-- ============================================================
-- DV3) Null critical field validation
-- Purpose: confirm required date attributes are populated
-- ============================================================

SELECT
  COUNT(*) AS total_rows,

  COUNTIF(date_day IS NULL) AS null_date_day,
  COUNTIF(calendar_year IS NULL) AS null_calendar_year,
  COUNTIF(calendar_quarter IS NULL) AS null_calendar_quarter,
  COUNTIF(calendar_month IS NULL) AS null_calendar_month,
  COUNTIF(day_of_month IS NULL) AS null_day_of_month,
  COUNTIF(day_name IS NULL) AS null_day_name,
  COUNTIF(month_name IS NULL) AS null_month_name,
  COUNTIF(year_month IS NULL) AS null_year_month

FROM `commercial-analytics-bq-dbx.commercial_analytics_us.dim_date`;



-- ============================================================
-- DV4) Weekend / weekday logic validation
-- Purpose: confirm weekend and weekday flags are mutually consistent
-- ============================================================

SELECT
  COUNT(*) AS total_rows,

  COUNTIF(is_weekend = TRUE) AS weekend_days,
  COUNTIF(is_weekday = TRUE) AS weekday_days,

  COUNTIF(is_weekend = TRUE AND is_weekday = TRUE)
    AS conflicting_weekend_weekday_rows,

  COUNTIF(is_weekend = FALSE AND is_weekday = FALSE)
    AS unclassified_days

FROM `commercial-analytics-bq-dbx.commercial_analytics_us.dim_date`;



-- ============================================================
-- DV5) Period boundary validation
-- Purpose: inspect month / quarter / year boundary flags
-- ============================================================

SELECT
  COUNTIF(is_month_start = TRUE) AS month_start_days,
  COUNTIF(is_month_end = TRUE) AS month_end_days,
  COUNTIF(is_quarter_start = TRUE) AS quarter_start_days,
  COUNTIF(is_quarter_end = TRUE) AS quarter_end_days,
  COUNTIF(is_year_start = TRUE) AS year_start_days,
  COUNTIF(is_year_end = TRUE) AS year_end_days

FROM `commercial-analytics-bq-dbx.commercial_analytics_us.dim_date`;



-- ============================================================
-- DV6) Final dim_date validation status
-- Purpose: high-level PASS/CHECK summary
-- ============================================================

WITH checks AS (
  SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT date_day) AS distinct_date_days,
    MIN(date_day) AS min_date,
    MAX(date_day) AS max_date,

    COUNTIF(date_day IS NULL) AS null_date_day,

    COUNTIF(is_weekend = TRUE AND is_weekday = TRUE)
      AS conflicting_weekend_weekday_rows,

    COUNTIF(is_weekend = FALSE AND is_weekday = FALSE)
      AS unclassified_days

  FROM `commercial-analytics-bq-dbx.commercial_analytics_us.dim_date`
)

SELECT
  total_rows,
  distinct_date_days,
  min_date,
  max_date,

  CASE
    WHEN total_rows = 31
      AND distinct_date_days = 31
      AND min_date = DATE '2021-01-01'
      AND max_date = DATE '2021-01-31'
      AND null_date_day = 0
      AND conflicting_weekend_weekday_rows = 0
      AND unclassified_days = 0
    THEN 'PASS'
    ELSE 'CHECK'
  END AS dim_date_validation_status,

  null_date_day,
  conflicting_weekend_weekday_rows,
  unclassified_days

FROM checks;