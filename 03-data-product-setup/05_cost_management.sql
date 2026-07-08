-- Data product cost management: resource monitors, warehouse assignment, and alert notifications

-- ============================================================================
-- DATA PRODUCT COST MANAGEMENT
-- Monitor: WAREHOUSE_MONITOR (500 credits/month)
-- Warehouses: ANALYTICS_WH, ETL_WH, COMPUTE_WH, DATA_PRODUCT_WH
-- Alerts: Email to 4 recipients at 50/75/90/100%
-- ============================================================================

-- =============================================================================
-- STEP 1: Create Resource Monitor
-- =============================================================================
CREATE OR REPLACE RESOURCE MONITOR WAREHOUSE_MONITOR
  WITH CREDIT_QUOTA = 500
  FREQUENCY = MONTHLY
  START_TIMESTAMP = IMMEDIATELY
  TRIGGERS
    ON 50 PERCENT DO NOTIFY
    ON 75 PERCENT DO NOTIFY
    ON 90 PERCENT DO NOTIFY
    ON 100 PERCENT DO NOTIFY;

-- =============================================================================
-- STEP 2: Assign Monitor to Warehouses
-- =============================================================================
ALTER WAREHOUSE ANALYTICS_WH SET RESOURCE_MONITOR = WAREHOUSE_MONITOR;
ALTER WAREHOUSE ETL_WH SET RESOURCE_MONITOR = WAREHOUSE_MONITOR;
ALTER WAREHOUSE COMPUTE_WH SET RESOURCE_MONITOR = WAREHOUSE_MONITOR;
ALTER WAREHOUSE DATA_PRODUCT_WH SET RESOURCE_MONITOR = WAREHOUSE_MONITOR;

-- =============================================================================
-- STEP 3: Configure Email Alert Notifications
-- =============================================================================

-- Create notification integration for email alerts
CREATE OR REPLACE NOTIFICATION INTEGRATION WAREHOUSE_MONITOR_EMAIL_ALERTS
  TYPE = EMAIL
  ENABLED = TRUE
  ALLOWED_RECIPIENTS = (
    'admin1@yourcompany.com',
    'admin2@yourcompany.com',
    'admin3@yourcompany.com',
    'admin4@yourcompany.com'
  );

-- Create alert for resource monitor threshold notifications
CREATE OR REPLACE ALERT WAREHOUSE_MONITOR_ALERT
  WAREHOUSE = COMPUTE_WH
  SCHEDULE = '60 MINUTE'
  IF (EXISTS (
    SELECT *
    FROM TABLE(INFORMATION_SCHEMA.RESOURCE_MONITORS())
    WHERE NAME = 'WAREHOUSE_MONITOR'
      AND USED_CREDITS / CREDIT_QUOTA * 100 >= 50
  ))
  THEN
    CALL SYSTEM$SEND_EMAIL(
      'WAREHOUSE_MONITOR_EMAIL_ALERTS',
      'admin1@yourcompany.com,admin2@yourcompany.com,admin3@yourcompany.com,admin4@yourcompany.com',
      'Resource Monitor Alert: WAREHOUSE_MONITOR',
      'The WAREHOUSE_MONITOR resource monitor has exceeded a credit threshold. Please review usage.'
    );

-- Activate the alert
ALTER ALERT WAREHOUSE_MONITOR_ALERT RESUME;
