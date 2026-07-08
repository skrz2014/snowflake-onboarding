-- Platform cost management: spending budgets, resource monitors, and cost allocation tags

-- ============================================================================
-- PLATFORM COST MANAGEMENT
-- Budget: 10,000 credits/month | Monitors: 500/warehouse | Tags: TEAM, COST_CENTER
-- ============================================================================

-- =============================================================================
-- STEP 1: Enable & Configure Spending Budget
-- =============================================================================
USE ROLE ACCOUNTADMIN;

-- Create a notification integration for email alerts
CREATE OR REPLACE NOTIFICATION INTEGRATION budget_notifications
  TYPE = EMAIL
  ENABLED = TRUE
  ALLOWED_RECIPIENTS = ('platform-team@company.com');

-- Activate the account budget
CALL SNOWFLAKE.LOCAL.ACCOUNT_ROOT_BUDGET!ACTIVATE();

-- Set monthly spending limit to 10,000 credits
CALL SNOWFLAKE.LOCAL.ACCOUNT_ROOT_BUDGET!SET_SPENDING_LIMIT(10000);

-- Configure email notifications
CALL SNOWFLAKE.LOCAL.ACCOUNT_ROOT_BUDGET!SET_EMAIL_NOTIFICATIONS('platform-team@company.com');

-- Set notification thresholds
CALL SNOWFLAKE.LOCAL.ACCOUNT_ROOT_BUDGET!SET_NOTIFICATION_THRESHOLDS(
  'MONTHLY_ACCOUNT_BUDGET',
  [50, 75, 90, 100]
);

-- =============================================================================
-- STEP 2: Configure Resource Monitors (Per-Warehouse)
-- =============================================================================
USE ROLE ACCOUNTADMIN;

-- Resource monitor for COMPUTE_WH
CREATE OR REPLACE RESOURCE MONITOR compute_wh_monitor
  WITH CREDIT_QUOTA = 500
  FREQUENCY = MONTHLY
  START_TIMESTAMP = IMMEDIATELY
  TRIGGERS
    ON 50 PERCENT DO NOTIFY
    ON 75 PERCENT DO NOTIFY
    ON 90 PERCENT DO NOTIFY
    ON 100 PERCENT DO NOTIFY;

ALTER WAREHOUSE COMPUTE_WH SET RESOURCE_MONITOR = compute_wh_monitor;

-- Resource monitor for FINANCE_S_ETL_WH
CREATE OR REPLACE RESOURCE MONITOR finance_etl_wh_monitor
  WITH CREDIT_QUOTA = 500
  FREQUENCY = MONTHLY
  START_TIMESTAMP = IMMEDIATELY
  TRIGGERS
    ON 50 PERCENT DO NOTIFY
    ON 75 PERCENT DO NOTIFY
    ON 90 PERCENT DO NOTIFY
    ON 100 PERCENT DO NOTIFY;

ALTER WAREHOUSE FINANCE_S_ETL_WH SET RESOURCE_MONITOR = finance_etl_wh_monitor;

-- Resource monitor for SNOWFLAKE_LEARNING_WH
CREATE OR REPLACE RESOURCE MONITOR learning_wh_monitor
  WITH CREDIT_QUOTA = 500
  FREQUENCY = MONTHLY
  START_TIMESTAMP = IMMEDIATELY
  TRIGGERS
    ON 50 PERCENT DO NOTIFY
    ON 75 PERCENT DO NOTIFY
    ON 90 PERCENT DO NOTIFY
    ON 100 PERCENT DO NOTIFY;

ALTER WAREHOUSE SNOWFLAKE_LEARNING_WH SET RESOURCE_MONITOR = learning_wh_monitor;

-- =============================================================================
-- STEP 3: Create Cost Allocation Tags
-- =============================================================================
USE ROLE ACCOUNTADMIN;

CREATE DATABASE IF NOT EXISTS GOVERNANCE;
CREATE SCHEMA IF NOT EXISTS GOVERNANCE.TAGS;

-- TEAM tag
CREATE OR REPLACE TAG GOVERNANCE.TAGS.TEAM
  ALLOWED_VALUES 'data-engineering', 'analytics', 'finance', 'platform', 'ml-ops', 'marketing'
  COMMENT = 'Cost allocation tag for team/department attribution';

-- COST_CENTER tag
CREATE OR REPLACE TAG GOVERNANCE.TAGS.COST_CENTER
  COMMENT = 'Cost allocation tag for cost center codes (format: CC-XXXX)';

-- =============================================================================
-- STEP 4: Apply Cost Allocation Tags to Warehouses
-- =============================================================================
USE ROLE ACCOUNTADMIN;

ALTER WAREHOUSE COMPUTE_WH SET TAG
  GOVERNANCE.TAGS.TEAM = 'platform',
  GOVERNANCE.TAGS.COST_CENTER = 'CC-1001';

ALTER WAREHOUSE FINANCE_S_ETL_WH SET TAG
  GOVERNANCE.TAGS.TEAM = 'finance',
  GOVERNANCE.TAGS.COST_CENTER = 'CC-1002';

ALTER WAREHOUSE SNOWFLAKE_LEARNING_WH SET TAG
  GOVERNANCE.TAGS.TEAM = 'platform',
  GOVERNANCE.TAGS.COST_CENTER = 'CC-1001';

-- =============================================================================
-- STEP 5: Verify Cost Attribution (run after tagging)
-- =============================================================================
SELECT
  tag_value AS cost_center,
  SUM(credits_used) AS total_credits
FROM SNOWFLAKE.ACCOUNT_USAGE.TAG_REFERENCES tr
JOIN SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY wmh
  ON tr.object_name = wmh.warehouse_name
WHERE tr.tag_name = 'TEAM'
  AND tr.tag_database = 'GOVERNANCE'
  AND tr.tag_schema = 'TAGS'
  AND wmh.start_time >= DATEADD(MONTH, -1, CURRENT_TIMESTAMP())
GROUP BY tag_value
ORDER BY total_credits DESC;
