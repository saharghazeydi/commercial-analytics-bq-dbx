-- 01_dim_date.sql
-- Purpose: Create date dimension table

CREATE OR REPLACE TABLE `nike-sql-practice.commercial_analytics_us.dim_date` AS
WITH dates AS (
  SELECT
    date
  FROM UNNEST(
    GENERATE_DATE_ARRAY(
      DATE('2021-01-01'),
      DATE('2021-01-31'),
      INTERVAL 1 DAY
    )
  ) AS date
)

SELECT
  date,
  EXTRACT(YEAR FROM date) AS year,
  EXTRACT(MONTH FROM date) AS month,
  FORMAT_DATE('%B', date) AS month_name,
  EXTRACT(WEEK FROM date) AS week_of_year,
  EXTRACT(DAY FROM date) AS day_of_month,
  EXTRACT(DAYOFWEEK FROM date) AS day_of_week,
  CASE
    WHEN EXTRACT(DAYOFWEEK FROM date) IN (1,7) THEN TRUE
    ELSE FALSE
  END AS is_weekend
FROM dates;