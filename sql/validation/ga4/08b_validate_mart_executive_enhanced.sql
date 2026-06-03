-- ============================================================
-- 08b_validate_mart_executive_enhanced.sql
-- Purpose: Validate mart_executive_enhanced grain, date attributes, base reconciliation, rolling logic, WoW logic, and BI readiness.
--
-- Target:
-- commercial-analytics-bq-dbx.commercial_analytics_us.mart_executive_enhanced
--
-- Sources:
-- - commercial-analytics-bq-dbx.commercial_analytics_us.mart_executive_daily
-- - commercial-analytics-bq-dbx.commercial_analytics_us.dim_date
--
-- Grain:
-- One row per event_date
-- ============================================================


-- ============================================================
-- EEV1) Row count and date range validation
-- Purpose: Confirm the enhanced mart contains data and covers the expected reporting date range.
-- ============================================================

SELECT
  COUNT(*) AS total_rows,
  MIN(event_date) AS min_event_date,
  MAX(event_date) AS max_event_date,
  COUNT(DISTINCT event_date) AS distinct_dates
FROM
  `commercial-analytics-bq-dbx.commercial_analytics_us.mart_executive_enhanced`;



-- ============================================================
-- EEV2) Grain uniqueness validation
-- Purpose: Confirm the enhanced mart contains exactly one row per event_date.
-- ============================================================

SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT event_date) AS distinct_event_dates,
  COUNT(*) - COUNT(DISTINCT event_date) AS duplicate_event_date_rows,

  CASE
    WHEN COUNT(*) = COUNT(DISTINCT event_date)
    THEN 'PASS'
    ELSE 'CHECK'
  END AS grain_validation_status

FROM
  `commercial-analytics-bq-dbx.commercial_analytics_us.mart_executive_enhanced`;



-- ============================================================
-- EEV3) Critical null validation
-- Purpose: Check required base metrics, date attributes, rolling fields, and KPI fields for unexpected nulls.
-- ============================================================

SELECT
  COUNT(*) AS total_rows,

  COUNTIF(event_date IS NULL) AS null_event_date,
  COUNTIF(calendar_year IS NULL) AS null_calendar_year,
  COUNTIF(calendar_month IS NULL) AS null_calendar_month,
  COUNTIF(year_month IS NULL) AS null_year_month,

  COUNTIF(sessions IS NULL) AS null_sessions,
  COUNTIF(users IS NULL) AS null_users,
  COUNTIF(total_events IS NULL) AS null_total_events,
  COUNTIF(transactions IS NULL) AS null_transactions,
  COUNTIF(revenue IS NULL) AS null_revenue,

  COUNTIF(rolling_7d_days IS NULL) AS null_rolling_7d_days,
  COUNTIF(rolling_7d_sessions IS NULL) AS null_rolling_7d_sessions,
  COUNTIF(rolling_7d_transactions IS NULL) AS null_rolling_7d_transactions,
  COUNTIF(rolling_7d_revenue IS NULL) AS null_rolling_7d_revenue,

  COUNTIF(session_conversion_rate IS NULL AND sessions > 0)
    AS null_session_conversion_rate_when_sessions_exist,

  COUNTIF(user_conversion_rate IS NULL AND users > 0)
    AS null_user_conversion_rate_when_users_exist,

  COUNTIF(revenue_per_session IS NULL AND sessions > 0)
    AS null_revenue_per_session_when_sessions_exist,

  COUNTIF(average_order_value IS NULL AND transactions > 0)
    AS null_aov_when_transactions_exist

FROM
  `commercial-analytics-bq-dbx.commercial_analytics_us.mart_executive_enhanced`;



-- ============================================================
-- EEV4) Date attribute reconciliation with dim_date
-- Purpose: Confirm enhanced mart date attributes match the validated date dimension.
-- ============================================================

SELECT
  e.event_date,

  e.calendar_year AS enhanced_calendar_year,
  d.calendar_year AS dim_calendar_year,

  e.calendar_quarter AS enhanced_calendar_quarter,
  d.calendar_quarter AS dim_calendar_quarter,

  e.calendar_month AS enhanced_calendar_month,
  d.calendar_month AS dim_calendar_month,

  e.calendar_week AS enhanced_calendar_week,
  d.calendar_week AS dim_calendar_week,

  e.year_month AS enhanced_year_month,
  d.year_month AS dim_year_month,

  e.day_name AS enhanced_day_name,
  d.day_name AS dim_day_name,

  e.is_weekend AS enhanced_is_weekend,
  d.is_weekend AS dim_is_weekend,

  e.is_weekday AS enhanced_is_weekday,
  d.is_weekday AS dim_is_weekday

FROM
  `commercial-analytics-bq-dbx.commercial_analytics_us.mart_executive_enhanced` e

LEFT JOIN
  `commercial-analytics-bq-dbx.commercial_analytics_us.dim_date` d
  ON e.event_date = d.date_day

WHERE
  d.date_day IS NULL
  OR e.calendar_year != d.calendar_year
  OR e.calendar_quarter != d.calendar_quarter
  OR e.calendar_month != d.calendar_month
  OR e.calendar_week != d.calendar_week
  OR e.year_month != d.year_month
  OR e.day_name != d.day_name
  OR e.is_weekend != d.is_weekend
  OR e.is_weekday != d.is_weekday

ORDER BY
  e.event_date;



-- ============================================================
-- EEV5) Base metric reconciliation with mart_executive_daily
-- Purpose: Confirm enhanced mart preserves base daily executive metrics exactly.
-- ============================================================

SELECT
  e.event_date,

  e.sessions - d.sessions AS sessions_difference,
  e.users - d.users AS users_difference,
  e.total_events - d.total_events AS total_events_difference,
  e.page_view_events - d.page_view_events AS page_view_events_difference,
  e.engaged_sessions - d.engaged_sessions AS engaged_sessions_difference,
  e.transactions - d.transactions AS transactions_difference,
  ROUND(e.revenue - d.revenue, 2) AS revenue_difference,

  e.view_item_events - d.view_item_events AS view_item_events_difference,
  e.add_to_cart_events - d.add_to_cart_events AS add_to_cart_events_difference,
  e.begin_checkout_events - d.begin_checkout_events AS begin_checkout_events_difference,
  e.purchase_event_rows - d.purchase_event_rows AS purchase_event_rows_difference

FROM
  `commercial-analytics-bq-dbx.commercial_analytics_us.mart_executive_enhanced` e

LEFT JOIN
  `commercial-analytics-bq-dbx.commercial_analytics_us.mart_executive_daily` d
  ON e.event_date = d.event_date

WHERE
  d.event_date IS NULL
  OR e.sessions != d.sessions
  OR e.users != d.users
  OR e.total_events != d.total_events
  OR e.page_view_events != d.page_view_events
  OR e.engaged_sessions != d.engaged_sessions
  OR e.transactions != d.transactions
  OR ROUND(e.revenue - d.revenue, 2) != 0
  OR e.view_item_events != d.view_item_events
  OR e.add_to_cart_events != d.add_to_cart_events
  OR e.begin_checkout_events != d.begin_checkout_events
  OR e.purchase_event_rows != d.purchase_event_rows

ORDER BY
  e.event_date;



-- ============================================================
-- EEV6) Rolling 7-day window structure validation
-- Purpose: Confirm rolling window completeness and partial-window behavior.
-- ============================================================

SELECT
  COUNT(*) AS total_rows,

  COUNTIF(rolling_7d_days BETWEEN 1 AND 6)
    AS partial_rolling_7d_window_rows,

  COUNTIF(rolling_7d_days = 7)
    AS complete_rolling_7d_window_rows,

  COUNTIF(has_complete_rolling_7d_window = TRUE)
    AS flagged_complete_rolling_7d_window_rows,

  COUNTIF(
    rolling_7d_days = 7
    AND has_complete_rolling_7d_window = FALSE
  ) AS complete_window_flag_mismatch_rows,

  MIN(rolling_7d_days) AS min_rolling_7d_days,
  MAX(rolling_7d_days) AS max_rolling_7d_days

FROM
  `commercial-analytics-bq-dbx.commercial_analytics_us.mart_executive_enhanced`;



-- ============================================================
-- EEV7) Rolling 7-day metric recalculation validation
-- Purpose: Recalculate rolling 7-day metrics from mart_executive_daily and compare with stored values.
-- ============================================================

WITH recalculated AS (

  SELECT
    event_date,

    COUNT(*) OVER (
      ORDER BY event_date
      ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS recalculated_rolling_7d_days,

    SUM(sessions) OVER (
      ORDER BY event_date
      ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS recalculated_rolling_7d_sessions,

    SUM(transactions) OVER (
      ORDER BY event_date
      ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS recalculated_rolling_7d_transactions,

    ROUND(
      SUM(revenue) OVER (
        ORDER BY event_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
      ),
      2
    ) AS recalculated_rolling_7d_revenue,

    ROUND(
      AVG(users) OVER (
        ORDER BY event_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
      ),
      2
    ) AS recalculated_rolling_7d_avg_daily_users

  FROM
    `commercial-analytics-bq-dbx.commercial_analytics_us.mart_executive_daily`

)

SELECT
  e.event_date,

  e.rolling_7d_days,
  r.recalculated_rolling_7d_days,
  e.rolling_7d_days - r.recalculated_rolling_7d_days
    AS rolling_7d_days_difference,

  e.rolling_7d_sessions,
  r.recalculated_rolling_7d_sessions,
  e.rolling_7d_sessions - r.recalculated_rolling_7d_sessions
    AS rolling_7d_sessions_difference,

  e.rolling_7d_transactions,
  r.recalculated_rolling_7d_transactions,
  e.rolling_7d_transactions - r.recalculated_rolling_7d_transactions
    AS rolling_7d_transactions_difference,

  e.rolling_7d_revenue,
  r.recalculated_rolling_7d_revenue,
  ROUND(e.rolling_7d_revenue - r.recalculated_rolling_7d_revenue, 2)
    AS rolling_7d_revenue_difference,

  e.rolling_7d_avg_daily_users,
  r.recalculated_rolling_7d_avg_daily_users,
  ROUND(
    e.rolling_7d_avg_daily_users - r.recalculated_rolling_7d_avg_daily_users,
    2
  ) AS rolling_7d_avg_daily_users_difference,

  e.rolling_7d_session_conversion_rate,
  ROUND(
    SAFE_DIVIDE(e.rolling_7d_transactions, e.rolling_7d_sessions),
    4
  ) AS recalculated_rolling_7d_session_conversion_rate,

  ROUND(
    e.rolling_7d_session_conversion_rate
    - ROUND(SAFE_DIVIDE(e.rolling_7d_transactions, e.rolling_7d_sessions), 4),
    4
  ) AS rolling_7d_session_conversion_rate_difference,

  e.rolling_7d_revenue_per_session,
  ROUND(
    SAFE_DIVIDE(e.rolling_7d_revenue, e.rolling_7d_sessions),
    2
  ) AS recalculated_rolling_7d_revenue_per_session,

  ROUND(
    e.rolling_7d_revenue_per_session
    - ROUND(SAFE_DIVIDE(e.rolling_7d_revenue, e.rolling_7d_sessions), 2),
    2
  ) AS rolling_7d_revenue_per_session_difference,

  e.rolling_7d_average_order_value,
  ROUND(
    SAFE_DIVIDE(e.rolling_7d_revenue, e.rolling_7d_transactions),
    2
  ) AS recalculated_rolling_7d_average_order_value,

  ROUND(
    e.rolling_7d_average_order_value
    - ROUND(SAFE_DIVIDE(e.rolling_7d_revenue, e.rolling_7d_transactions), 2),
    2
  ) AS rolling_7d_average_order_value_difference

FROM
  `commercial-analytics-bq-dbx.commercial_analytics_us.mart_executive_enhanced` e

LEFT JOIN
  recalculated r
  ON e.event_date = r.event_date

ORDER BY
  e.event_date;



-- ============================================================
-- EEV8) Week-over-week availability validation
-- Purpose: Confirm WoW comparison flags align with seven-day lag availability.
-- ============================================================

SELECT
  COUNT(*) AS total_rows,

  COUNTIF(sessions_7d_ago IS NULL) AS rows_without_wow_comparison,
  COUNTIF(sessions_7d_ago IS NOT NULL) AS rows_with_wow_comparison,

  COUNTIF(has_wow_comparison = TRUE) AS flagged_wow_comparison_rows,

  COUNTIF(
    sessions_7d_ago IS NOT NULL
    AND has_wow_comparison = FALSE
  ) AS missing_wow_flag_rows,

  COUNTIF(
    sessions_7d_ago IS NULL
    AND has_wow_comparison = TRUE
  ) AS incorrect_wow_flag_rows

FROM
  `commercial-analytics-bq-dbx.commercial_analytics_us.mart_executive_enhanced`;



-- ============================================================
-- EEV9) Week-over-week metric recalculation validation
-- Purpose: Recalculate seven-day lag and WoW metrics from mart_executive_daily.
-- ============================================================

WITH recalculated AS (

  SELECT
    event_date,

    LAG(sessions, 7) OVER (
      ORDER BY event_date
    ) AS recalculated_sessions_7d_ago,

    LAG(users, 7) OVER (
      ORDER BY event_date
    ) AS recalculated_users_7d_ago,

    LAG(transactions, 7) OVER (
      ORDER BY event_date
    ) AS recalculated_transactions_7d_ago,

    LAG(revenue, 7) OVER (
      ORDER BY event_date
    ) AS recalculated_revenue_7d_ago,

    LAG(session_conversion_rate, 7) OVER (
      ORDER BY event_date
    ) AS recalculated_session_conversion_rate_7d_ago,

    LAG(revenue_per_session, 7) OVER (
      ORDER BY event_date
    ) AS recalculated_revenue_per_session_7d_ago

  FROM
    `commercial-analytics-bq-dbx.commercial_analytics_us.mart_executive_daily`

),

comparison AS (

  SELECT
    e.event_date,

    e.sessions_7d_ago,
    r.recalculated_sessions_7d_ago,

    e.users_7d_ago,
    r.recalculated_users_7d_ago,

    e.transactions_7d_ago,
    r.recalculated_transactions_7d_ago,

    e.revenue_7d_ago,
    r.recalculated_revenue_7d_ago,

    e.session_conversion_rate_7d_ago,
    r.recalculated_session_conversion_rate_7d_ago,

    e.revenue_per_session_7d_ago,
    r.recalculated_revenue_per_session_7d_ago,

    e.wow_sessions_change,
    e.sessions - r.recalculated_sessions_7d_ago
      AS recalculated_wow_sessions_change,

    e.wow_sessions_change_rate,
    ROUND(
      SAFE_DIVIDE(
        e.sessions - r.recalculated_sessions_7d_ago,
        r.recalculated_sessions_7d_ago
      ),
      4
    ) AS recalculated_wow_sessions_change_rate,

    e.wow_users_change,
    e.users - r.recalculated_users_7d_ago
      AS recalculated_wow_users_change,

    e.wow_users_change_rate,
    ROUND(
      SAFE_DIVIDE(
        e.users - r.recalculated_users_7d_ago,
        r.recalculated_users_7d_ago
      ),
      4
    ) AS recalculated_wow_users_change_rate,

    e.wow_transactions_change,
    e.transactions - r.recalculated_transactions_7d_ago
      AS recalculated_wow_transactions_change,

    e.wow_transactions_change_rate,
    ROUND(
      SAFE_DIVIDE(
        e.transactions - r.recalculated_transactions_7d_ago,
        r.recalculated_transactions_7d_ago
      ),
      4
    ) AS recalculated_wow_transactions_change_rate,

    e.wow_revenue_change,
    ROUND(e.revenue - r.recalculated_revenue_7d_ago, 2)
      AS recalculated_wow_revenue_change,

    e.wow_revenue_change_rate,
    ROUND(
      SAFE_DIVIDE(
        e.revenue - r.recalculated_revenue_7d_ago,
        r.recalculated_revenue_7d_ago
      ),
      4
    ) AS recalculated_wow_revenue_change_rate,

    e.wow_session_conversion_rate_change,
    ROUND(
      e.session_conversion_rate
      - r.recalculated_session_conversion_rate_7d_ago,
      4
    ) AS recalculated_wow_session_conversion_rate_change,

    e.wow_revenue_per_session_change,
    ROUND(
      e.revenue_per_session
      - r.recalculated_revenue_per_session_7d_ago,
      2
    ) AS recalculated_wow_revenue_per_session_change

  FROM
    `commercial-analytics-bq-dbx.commercial_analytics_us.mart_executive_enhanced` e

  LEFT JOIN
    recalculated r
    ON e.event_date = r.event_date

)

SELECT
  *
FROM
  comparison
WHERE
  sessions_7d_ago IS DISTINCT FROM recalculated_sessions_7d_ago
  OR users_7d_ago IS DISTINCT FROM recalculated_users_7d_ago
  OR transactions_7d_ago IS DISTINCT FROM recalculated_transactions_7d_ago
  OR revenue_7d_ago IS DISTINCT FROM recalculated_revenue_7d_ago
  OR session_conversion_rate_7d_ago IS DISTINCT FROM recalculated_session_conversion_rate_7d_ago
  OR revenue_per_session_7d_ago IS DISTINCT FROM recalculated_revenue_per_session_7d_ago

  OR wow_sessions_change IS DISTINCT FROM recalculated_wow_sessions_change
  OR wow_sessions_change_rate IS DISTINCT FROM recalculated_wow_sessions_change_rate
  OR wow_users_change IS DISTINCT FROM recalculated_wow_users_change
  OR wow_users_change_rate IS DISTINCT FROM recalculated_wow_users_change_rate
  OR wow_transactions_change IS DISTINCT FROM recalculated_wow_transactions_change
  OR wow_transactions_change_rate IS DISTINCT FROM recalculated_wow_transactions_change_rate
  OR wow_revenue_change IS DISTINCT FROM recalculated_wow_revenue_change
  OR wow_revenue_change_rate IS DISTINCT FROM recalculated_wow_revenue_change_rate
  OR wow_session_conversion_rate_change IS DISTINCT FROM recalculated_wow_session_conversion_rate_change
  OR wow_revenue_per_session_change IS DISTINCT FROM recalculated_wow_revenue_per_session_change

ORDER BY
  event_date;



-- ============================================================
-- EEV10) Impossible value validation
-- Purpose: Detect negative metrics, impossible core rates, and invalid rolling flags.
-- ============================================================

SELECT
  *
FROM
  `commercial-analytics-bq-dbx.commercial_analytics_us.mart_executive_enhanced`
WHERE
  sessions < 0
  OR users < 0
  OR total_events < 0
  OR page_view_events < 0
  OR engaged_sessions < 0
  OR transactions < 0
  OR revenue < 0

  OR rolling_7d_days < 1
  OR rolling_7d_days > 7
  OR rolling_7d_sessions < 0
  OR rolling_7d_transactions < 0
  OR rolling_7d_revenue < 0
  OR rolling_7d_avg_daily_users < 0

  OR session_conversion_rate > 1
  OR user_conversion_rate > 1
  OR engaged_session_rate > 1
  OR rolling_7d_session_conversion_rate > 1

  OR (
    rolling_7d_days = 7
    AND has_complete_rolling_7d_window = FALSE
  )

  OR (
    rolling_7d_days < 7
    AND has_complete_rolling_7d_window = TRUE
  )

  OR (
    sessions_7d_ago IS NOT NULL
    AND has_wow_comparison = FALSE
  )

  OR (
    sessions_7d_ago IS NULL
    AND has_wow_comparison = TRUE
  );



-- ============================================================
-- EEV11) Enhanced daily trend inspection
-- Purpose: Inspect daily base, rolling, and WoW KPI movement for BI readiness.
-- ============================================================

SELECT
  event_date,

  sessions,
  users,
  transactions,
  revenue,

  session_conversion_rate,
  revenue_per_session,
  average_order_value,

  rolling_7d_days,
  rolling_7d_sessions,
  rolling_7d_transactions,
  rolling_7d_revenue,
  rolling_7d_session_conversion_rate,
  rolling_7d_revenue_per_session,
  rolling_7d_average_order_value,

  sessions_7d_ago,
  transactions_7d_ago,
  revenue_7d_ago,

  wow_sessions_change,
  wow_sessions_change_rate,
  wow_transactions_change,
  wow_transactions_change_rate,
  wow_revenue_change,
  wow_revenue_change_rate,

  has_complete_rolling_7d_window,
  has_wow_comparison

FROM
  `commercial-analytics-bq-dbx.commercial_analytics_us.mart_executive_enhanced`

ORDER BY
  event_date;



-- ============================================================
-- EEV12) Final enhanced mart validation status
-- Purpose: Produce a consolidated PASS/CHECK status for the enhanced executive mart.
-- ============================================================

WITH grain_summary AS (

  SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT event_date) AS distinct_event_dates,
    COUNT(*) - COUNT(DISTINCT event_date) AS duplicate_event_date_rows,

    COUNTIF(event_date IS NULL) AS null_event_date,
    COUNTIF(sessions IS NULL) AS null_sessions,
    COUNTIF(users IS NULL) AS null_users,
    COUNTIF(transactions IS NULL) AS null_transactions,
    COUNTIF(revenue IS NULL) AS null_revenue,

    COUNTIF(revenue < 0) AS negative_revenue_rows,
    COUNTIF(transactions < 0) AS negative_transaction_rows,
    COUNTIF(sessions < 0) AS negative_session_rows,
    COUNTIF(users < 0) AS negative_user_rows,

    COUNTIF(session_conversion_rate > 1) AS impossible_session_conversion_rows,
    COUNTIF(user_conversion_rate > 1) AS impossible_user_conversion_rows,
    COUNTIF(engaged_session_rate > 1) AS impossible_engaged_session_rate_rows,
    COUNTIF(rolling_7d_session_conversion_rate > 1)
      AS impossible_rolling_conversion_rows,

    COUNTIF(rolling_7d_days < 1 OR rolling_7d_days > 7)
      AS invalid_rolling_window_rows,

    COUNTIF(
      rolling_7d_days = 7
      AND has_complete_rolling_7d_window = FALSE
    ) AS complete_rolling_flag_mismatch_rows,

    COUNTIF(
      rolling_7d_days < 7
      AND has_complete_rolling_7d_window = TRUE
    ) AS partial_rolling_flag_mismatch_rows,

    COUNTIF(
      sessions_7d_ago IS NOT NULL
      AND has_wow_comparison = FALSE
    ) AS missing_wow_flag_rows,

    COUNTIF(
      sessions_7d_ago IS NULL
      AND has_wow_comparison = TRUE
    ) AS incorrect_wow_flag_rows

  FROM
    `commercial-analytics-bq-dbx.commercial_analytics_us.mart_executive_enhanced`

),

date_attribute_mismatches AS (

  SELECT
    COUNT(*) AS date_attribute_mismatch_rows

  FROM
    `commercial-analytics-bq-dbx.commercial_analytics_us.mart_executive_enhanced` e

  LEFT JOIN
    `commercial-analytics-bq-dbx.commercial_analytics_us.dim_date` d
    ON e.event_date = d.date_day

  WHERE
    d.date_day IS NULL
    OR e.calendar_year != d.calendar_year
    OR e.calendar_quarter != d.calendar_quarter
    OR e.calendar_month != d.calendar_month
    OR e.calendar_week != d.calendar_week
    OR e.year_month != d.year_month
    OR e.day_name != d.day_name
    OR e.is_weekend != d.is_weekend
    OR e.is_weekday != d.is_weekday

),

base_metric_mismatches AS (

  SELECT
    COUNT(*) AS base_metric_mismatch_rows

  FROM
    `commercial-analytics-bq-dbx.commercial_analytics_us.mart_executive_enhanced` e

  LEFT JOIN
    `commercial-analytics-bq-dbx.commercial_analytics_us.mart_executive_daily` d
    ON e.event_date = d.event_date

  WHERE
    d.event_date IS NULL
    OR e.sessions != d.sessions
    OR e.users != d.users
    OR e.total_events != d.total_events
    OR e.page_view_events != d.page_view_events
    OR e.engaged_sessions != d.engaged_sessions
    OR e.transactions != d.transactions
    OR ROUND(e.revenue - d.revenue, 2) != 0

),

rolling_mismatches AS (

  WITH recalculated AS (

    SELECT
      event_date,

      COUNT(*) OVER (
        ORDER BY event_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
      ) AS rolling_7d_days,

      SUM(sessions) OVER (
        ORDER BY event_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
      ) AS rolling_7d_sessions,

      SUM(transactions) OVER (
        ORDER BY event_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
      ) AS rolling_7d_transactions,

      ROUND(
        SUM(revenue) OVER (
          ORDER BY event_date
          ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ),
        2
      ) AS rolling_7d_revenue,

      ROUND(
        AVG(users) OVER (
          ORDER BY event_date
          ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ),
        2
      ) AS rolling_7d_avg_daily_users

    FROM
      `commercial-analytics-bq-dbx.commercial_analytics_us.mart_executive_daily`

  )

  SELECT
    COUNT(*) AS rolling_mismatch_rows

  FROM
    `commercial-analytics-bq-dbx.commercial_analytics_us.mart_executive_enhanced` e

  LEFT JOIN
    recalculated r
    ON e.event_date = r.event_date

  WHERE
    e.rolling_7d_days != r.rolling_7d_days
    OR e.rolling_7d_sessions != r.rolling_7d_sessions
    OR e.rolling_7d_transactions != r.rolling_7d_transactions
    OR ROUND(e.rolling_7d_revenue - r.rolling_7d_revenue, 2) != 0
    OR ROUND(
      e.rolling_7d_avg_daily_users - r.rolling_7d_avg_daily_users,
      2
    ) != 0

),

wow_mismatches AS (

  WITH recalculated AS (

    SELECT
      event_date,

      LAG(sessions, 7) OVER (
        ORDER BY event_date
      ) AS sessions_7d_ago,

      LAG(users, 7) OVER (
        ORDER BY event_date
      ) AS users_7d_ago,

      LAG(transactions, 7) OVER (
        ORDER BY event_date
      ) AS transactions_7d_ago,

      LAG(revenue, 7) OVER (
        ORDER BY event_date
      ) AS revenue_7d_ago

    FROM
      `commercial-analytics-bq-dbx.commercial_analytics_us.mart_executive_daily`

  )

  SELECT
    COUNT(*) AS wow_mismatch_rows

  FROM
    `commercial-analytics-bq-dbx.commercial_analytics_us.mart_executive_enhanced` e

  LEFT JOIN
    recalculated r
    ON e.event_date = r.event_date

  WHERE
    e.sessions_7d_ago IS DISTINCT FROM r.sessions_7d_ago
    OR e.users_7d_ago IS DISTINCT FROM r.users_7d_ago
    OR e.transactions_7d_ago IS DISTINCT FROM r.transactions_7d_ago
    OR e.revenue_7d_ago IS DISTINCT FROM r.revenue_7d_ago

)

SELECT
  gs.total_rows,
  gs.distinct_event_dates,
  gs.duplicate_event_date_rows,

  gs.null_event_date,
  gs.null_sessions,
  gs.null_users,
  gs.null_transactions,
  gs.null_revenue,

  gs.negative_revenue_rows,
  gs.negative_transaction_rows,
  gs.negative_session_rows,
  gs.negative_user_rows,

  gs.impossible_session_conversion_rows,
  gs.impossible_user_conversion_rows,
  gs.impossible_engaged_session_rate_rows,
  gs.impossible_rolling_conversion_rows,

  gs.invalid_rolling_window_rows,
  gs.complete_rolling_flag_mismatch_rows,
  gs.partial_rolling_flag_mismatch_rows,
  gs.missing_wow_flag_rows,
  gs.incorrect_wow_flag_rows,

  dm.date_attribute_mismatch_rows,
  bm.base_metric_mismatch_rows,
  rm.rolling_mismatch_rows,
  wm.wow_mismatch_rows,

  CASE
    WHEN gs.total_rows = gs.distinct_event_dates
      AND gs.duplicate_event_date_rows = 0

      AND gs.null_event_date = 0
      AND gs.null_sessions = 0
      AND gs.null_users = 0
      AND gs.null_transactions = 0
      AND gs.null_revenue = 0

      AND gs.negative_revenue_rows = 0
      AND gs.negative_transaction_rows = 0
      AND gs.negative_session_rows = 0
      AND gs.negative_user_rows = 0

      AND gs.impossible_session_conversion_rows = 0
      AND gs.impossible_user_conversion_rows = 0
      AND gs.impossible_engaged_session_rate_rows = 0
      AND gs.impossible_rolling_conversion_rows = 0

      AND gs.invalid_rolling_window_rows = 0
      AND gs.complete_rolling_flag_mismatch_rows = 0
      AND gs.partial_rolling_flag_mismatch_rows = 0
      AND gs.missing_wow_flag_rows = 0
      AND gs.incorrect_wow_flag_rows = 0

      AND dm.date_attribute_mismatch_rows = 0
      AND bm.base_metric_mismatch_rows = 0
      AND rm.rolling_mismatch_rows = 0
      AND wm.wow_mismatch_rows = 0

    THEN 'PASS'
    ELSE 'CHECK'
  END AS enhanced_mart_validation_status

FROM grain_summary gs
CROSS JOIN date_attribute_mismatches dm
CROSS JOIN base_metric_mismatches bm
CROSS JOIN rolling_mismatches rm
CROSS JOIN wow_mismatches wm;