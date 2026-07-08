-- Account provisioning: define purpose, configure parameters, create account, set up replication

-- ============================================================================
-- ACCOUNT PROVISIONING
-- Account: PROD_DATASCIENCE | Domain: Data Science/AI | Edition: Business Critical
-- ============================================================================

-- =============================================================================
-- STEP 1: Create the Account (run as ORGADMIN)
-- =============================================================================
USE ROLE ORGADMIN;

CREATE ACCOUNT PROD_DATASCIENCE
  ADMIN_NAME = 'ADMIN'
  ADMIN_PASSWORD = '<SET_STRONG_PASSWORD>'
  EMAIL = 'datascience-admins@company.com'
  EDITION = 'BUSINESS_CRITICAL'
  REGION = 'AWS_US_EAST_1'
  COMMENT = 'Production account for Data Science/AI workloads';

-- =============================================================================
-- STEP 2: Verify Account Creation
-- =============================================================================
SHOW ACCOUNTS LIKE 'PROD_DATASCIENCE';
SHOW ORGANIZATION ACCOUNTS;

-- =============================================================================
-- STEP 3: Enable Replication on Source Database (run in source account)
-- =============================================================================
USE ROLE ACCOUNTADMIN;

ALTER DATABASE INFRASTRUCTURE ENABLE REPLICATION TO ACCOUNTS PROD_DATASCIENCE;
ALTER DATABASE INFRASTRUCTURE ENABLE FAILOVER TO ACCOUNTS PROD_DATASCIENCE;

-- =============================================================================
-- STEP 4: Create Replica in New Account (run in PROD_DATASCIENCE)
-- =============================================================================
-- Run this in the NEW account (PROD_DATASCIENCE) as ACCOUNTADMIN
USE ROLE ACCOUNTADMIN;

CREATE DATABASE INFRASTRUCTURE
  AS REPLICA OF <your_org_name>.<source_account_name>.INFRASTRUCTURE;

ALTER DATABASE INFRASTRUCTURE REFRESH;

-- =============================================================================
-- STEP 5: Set Up Scheduled Replication Refresh (in new account)
-- =============================================================================
CREATE OR REPLACE TASK INFRASTRUCTURE_REPLICATION_REFRESH
  WAREHOUSE = 'COMPUTE_WH'
  SCHEDULE = 'USING CRON 0 */1 * * * America/New_York'
AS
  ALTER DATABASE INFRASTRUCTURE REFRESH;

ALTER TASK INFRASTRUCTURE_REPLICATION_REFRESH RESUME;
