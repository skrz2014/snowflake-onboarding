-- Account cost management: budget, resource monitor, and cost allocation tags

-- ============================================================================
-- ACCOUNT COST MANAGEMENT
-- Budget: 10,000 credits/month | Monitor: 8,000 credits | Tags: COST_CENTER
-- ============================================================================

-- =============================================================================
-- STEP 1: Configure Account Budget
-- =============================================================================
USE ROLE ACCOUNTADMIN;

CALL SNOWFLAKE.LOCAL.ACCOUNT_ROOT_BUDGET!ACTIVATE();
CALL SNOWFLAKE.LOCAL.ACCOUNT_ROOT_BUDGET!SET_SPENDING_LIMIT(10000);
CALL SNOWFLAKE.LOCAL.ACCOUNT_ROOT_BUDGET!SET_EMAIL_NOTIFICATIONS('admin@company.com');
CALL SNOWFLAKE.LOCAL.ACCOUNT_ROOT_BUDGET!SET_NOTIFICATION_THRESHOLDS(
  'MONTHLY_ACCOUNT_BUDGET',
  [50, 75, 90, 100]
);

-- =============================================================================
-- STEP 2: Configure Account-Level Resource Monitor
-- =============================================================================
USE ROLE ACCOUNTADMIN;

CREATE OR REPLACE RESOURCE MONITOR account_resource_monitor
  WITH CREDIT_QUOTA = 8000
  FREQUENCY = MONTHLY
  START_TIMESTAMP = IMMEDIATELY
  TRIGGERS
    ON 50 PERCENT DO NOTIFY
    ON 75 PERCENT DO NOTIFY
    ON 90 PERCENT DO NOTIFY
    ON 100 PERCENT DO NOTIFY;

ALTER ACCOUNT SET RESOURCE_MONITOR = account_resource_monitor;

-- =============================================================================
-- STEP 3: Create Cost Allocation Tags
-- =============================================================================
USE ROLE ACCOUNTADMIN;

CREATE DATABASE IF NOT EXISTS ADMIN;
CREATE SCHEMA IF NOT EXISTS ADMIN.TAGS;

CREATE TAG IF NOT EXISTS ADMIN.TAGS.COST_CENTER
  ALLOWED_VALUES 'ENGINEERING', 'MARKETING', 'FINANCE', 'OPERATIONS', 'DATA_ANALYTICS', 'SALES';

-- =============================================================================
-- STEP 4: Apply Tags to Warehouses (examples)
-- =============================================================================
-- ALTER WAREHOUSE my_warehouse SET TAG ADMIN.TAGS.COST_CENTER = 'ENGINEERING';
-- ALTER WAREHOUSE analytics_wh SET TAG ADMIN.TAGS.COST_CENTER = 'DATA_ANALYTICS';
-- ALTER WAREHOUSE marketing_wh SET TAG ADMIN.TAGS.COST_CENTER = 'MARKETING';
