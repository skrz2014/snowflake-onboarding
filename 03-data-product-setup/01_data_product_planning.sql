-- Data product planning: zones, schemas, warehouses, and data sharing blueprint

-- ============================================================================
-- DATA PRODUCT PLANNING: Customer Analytics
-- Domain: Finance | Purpose: External Data Sharing
-- Zones: Raw, Curated, Consumption, Sandbox (database-per-zone)
-- ============================================================================

-- =============================================================================
-- DATABASES (Zone-per-DB)
-- =============================================================================
CREATE DATABASE IF NOT EXISTS CUSTOMER_ANALYTICS_RAW
  COMMENT = 'Raw/Landing zone for Customer Analytics data product';

CREATE DATABASE IF NOT EXISTS CUSTOMER_ANALYTICS_CURATED
  COMMENT = 'Curated/Cleansed zone for Customer Analytics data product';

CREATE DATABASE IF NOT EXISTS CUSTOMER_ANALYTICS_CONSUMPTION
  COMMENT = 'Consumption/Analytics zone for Customer Analytics data product';

CREATE DATABASE IF NOT EXISTS CUSTOMER_ANALYTICS_SANDBOX
  COMMENT = 'Sandbox/Lab zone for Customer Analytics data product';

-- =============================================================================
-- SCHEMAS: RAW ZONE (by source system + data category)
-- =============================================================================
CREATE SCHEMA IF NOT EXISTS CUSTOMER_ANALYTICS_RAW.SALESFORCE
  COMMENT = 'Raw data from Salesforce';
CREATE SCHEMA IF NOT EXISTS CUSTOMER_ANALYTICS_RAW.STRIPE
  COMMENT = 'Raw data from Stripe';
CREATE SCHEMA IF NOT EXISTS CUSTOMER_ANALYTICS_RAW.SAP
  COMMENT = 'Raw data from SAP';
CREATE SCHEMA IF NOT EXISTS CUSTOMER_ANALYTICS_RAW.TRANSACTIONS
  COMMENT = 'Raw transactional data across sources';
CREATE SCHEMA IF NOT EXISTS CUSTOMER_ANALYTICS_RAW.EVENTS
  COMMENT = 'Raw event/activity data across sources';
CREATE SCHEMA IF NOT EXISTS CUSTOMER_ANALYTICS_RAW.ENTITIES
  COMMENT = 'Raw entity/master data across sources';

-- =============================================================================
-- SCHEMAS: CURATED ZONE
-- =============================================================================
CREATE SCHEMA IF NOT EXISTS CUSTOMER_ANALYTICS_CURATED.CONFORMED
  COMMENT = 'Standardized and deduplicated data';
CREATE SCHEMA IF NOT EXISTS CUSTOMER_ANALYTICS_CURATED.BUSINESS_ENTITIES
  COMMENT = 'Curated business entities (customers, accounts, products)';
CREATE SCHEMA IF NOT EXISTS CUSTOMER_ANALYTICS_CURATED.HISTORY
  COMMENT = 'SCD and historical tracking tables';

-- =============================================================================
-- SCHEMAS: CONSUMPTION ZONE (by business function + data product)
-- =============================================================================
CREATE SCHEMA IF NOT EXISTS CUSTOMER_ANALYTICS_CONSUMPTION.FINANCE
  COMMENT = 'Finance-ready metrics and aggregates';
CREATE SCHEMA IF NOT EXISTS CUSTOMER_ANALYTICS_CONSUMPTION.MARKETING
  COMMENT = 'Marketing-ready metrics and aggregates';
CREATE SCHEMA IF NOT EXISTS CUSTOMER_ANALYTICS_CONSUMPTION.CUSTOMER_360
  COMMENT = 'Customer 360 data product views';
CREATE SCHEMA IF NOT EXISTS CUSTOMER_ANALYTICS_CONSUMPTION.REVENUE_METRICS
  COMMENT = 'Revenue metrics data product views';
CREATE SCHEMA IF NOT EXISTS CUSTOMER_ANALYTICS_CONSUMPTION.SHARED
  COMMENT = 'Objects exposed via data sharing / marketplace';

-- =============================================================================
-- SCHEMAS: SANDBOX ZONE
-- =============================================================================
CREATE SCHEMA IF NOT EXISTS CUSTOMER_ANALYTICS_SANDBOX.DATA_SCIENCE
  COMMENT = 'Data science experimentation area';
CREATE SCHEMA IF NOT EXISTS CUSTOMER_ANALYTICS_SANDBOX.EXPLORATION
  COMMENT = 'Ad-hoc exploration and prototyping';

-- =============================================================================
-- WAREHOUSES (workload-isolated)
-- =============================================================================
CREATE WAREHOUSE IF NOT EXISTS CUSTOMER_ANALYTICS_LOADING_WH
  WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  MIN_CLUSTER_COUNT = 1
  MAX_CLUSTER_COUNT = 1
  COMMENT = 'Ingestion/Loading workloads for Customer Analytics';

CREATE WAREHOUSE IF NOT EXISTS CUSTOMER_ANALYTICS_TRANSFORM_WH
  WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  MIN_CLUSTER_COUNT = 1
  MAX_CLUSTER_COUNT = 1
  COMMENT = 'Transformation workloads (dbt, stored procs)';

CREATE WAREHOUSE IF NOT EXISTS CUSTOMER_ANALYTICS_REPORTING_WH
  WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  MIN_CLUSTER_COUNT = 1
  MAX_CLUSTER_COUNT = 3
  COMMENT = 'BI/Reporting queries (auto-scales 1-3)';

CREATE WAREHOUSE IF NOT EXISTS CUSTOMER_ANALYTICS_DS_WH
  WAREHOUSE_SIZE = 'SMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  MIN_CLUSTER_COUNT = 1
  MAX_CLUSTER_COUNT = 3
  COMMENT = 'Data Science/ML workloads (auto-scales 1-3)';

-- =============================================================================
-- DATA SHARING (for external purpose)
-- =============================================================================
CREATE SHARE IF NOT EXISTS CUSTOMER_ANALYTICS_SHARE
  COMMENT = 'External share for Customer Analytics data product';

GRANT USAGE ON DATABASE CUSTOMER_ANALYTICS_CONSUMPTION TO SHARE CUSTOMER_ANALYTICS_SHARE;
GRANT USAGE ON SCHEMA CUSTOMER_ANALYTICS_CONSUMPTION.SHARED TO SHARE CUSTOMER_ANALYTICS_SHARE;
