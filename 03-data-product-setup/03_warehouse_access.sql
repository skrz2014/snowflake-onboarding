-- Warehouse and access configuration: create warehouses, access roles, and wire hierarchy

-- ============================================================================
-- WAREHOUSE & ACCESS CONFIGURATION
-- Warehouses: ETL_WH (L), ANALYTICS_WH (M), DEV_WH (XS)
-- ============================================================================

-- =============================================================================
-- STEP 1: Create Warehouses
-- =============================================================================
USE ROLE SYSADMIN;

CREATE WAREHOUSE IF NOT EXISTS ETL_WH
  WAREHOUSE_SIZE = 'LARGE'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  INITIALLY_SUSPENDED = TRUE
  COMMENT = 'Warehouse for ETL/data loading workloads';

CREATE WAREHOUSE IF NOT EXISTS ANALYTICS_WH
  WAREHOUSE_SIZE = 'MEDIUM'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  INITIALLY_SUSPENDED = TRUE
  COMMENT = 'Warehouse for analytics/query workloads';

CREATE WAREHOUSE IF NOT EXISTS DEV_WH
  WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  INITIALLY_SUSPENDED = TRUE
  COMMENT = 'Warehouse for development/testing workloads';

-- =============================================================================
-- STEP 2: Create Warehouse Access Roles
-- =============================================================================
USE ROLE USERADMIN;

CREATE ROLE IF NOT EXISTS ETL_WH_USAGE
  COMMENT = 'Grants USAGE privilege on ETL_WH';

CREATE ROLE IF NOT EXISTS ANALYTICS_WH_USAGE
  COMMENT = 'Grants USAGE privilege on ANALYTICS_WH';

CREATE ROLE IF NOT EXISTS DEV_WH_USAGE
  COMMENT = 'Grants USAGE privilege on DEV_WH';

-- Grant USAGE privilege on each warehouse to its access role
USE ROLE SYSADMIN;

GRANT USAGE ON WAREHOUSE ETL_WH TO ROLE ETL_WH_USAGE;
GRANT USAGE ON WAREHOUSE ANALYTICS_WH TO ROLE ANALYTICS_WH_USAGE;
GRANT USAGE ON WAREHOUSE DEV_WH TO ROLE DEV_WH_USAGE;

-- =============================================================================
-- STEP 3: Transfer Ownership & Wire Role Hierarchy
-- =============================================================================
USE ROLE ACCOUNTADMIN;

GRANT OWNERSHIP ON WAREHOUSE ETL_WH TO ROLE SYSADMIN COPY CURRENT GRANTS;
GRANT OWNERSHIP ON WAREHOUSE ANALYTICS_WH TO ROLE SYSADMIN COPY CURRENT GRANTS;
GRANT OWNERSHIP ON WAREHOUSE DEV_WH TO ROLE SYSADMIN COPY CURRENT GRANTS;

-- Wire access roles into the hierarchy under SYSADMIN
GRANT ROLE ETL_WH_USAGE TO ROLE SYSADMIN;
GRANT ROLE ANALYTICS_WH_USAGE TO ROLE SYSADMIN;
GRANT ROLE DEV_WH_USAGE TO ROLE SYSADMIN;
