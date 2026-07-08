-- Platform foundation: organization, infrastructure database, and naming conventions

-- ============================================================================
-- PLATFORM FOUNDATION SETUP
-- Organization: CONTOSO | Strategy: Multi-Account (Dev, QA, Staging, Prod)
-- Domains: FINANCE | Naming: DOMAIN_PREFIX style
-- ============================================================================

-- =============================================================================
-- STEP 1: Configure Organization & Enable Multi-Account
-- =============================================================================
USE ROLE ORGADMIN;

-- Set the organization name for connectivity
-- URLs will follow pattern: CONTOSO-<account_name>.snowflakecomputing.com
ALTER ACCOUNT SET ORGANIZATION_NAME = 'CONTOSO';

-- Verify organization is enabled
SHOW ORGANIZATION ACCOUNTS;

-- =============================================================================
-- STEP 2: Create Organization Accounts
-- =============================================================================
USE ROLE ORGADMIN;

-- Create DEV account
CREATE ACCOUNT CONTOSO_DEV
  ADMIN_NAME = 'admin'
  ADMIN_PASSWORD = '<CHANGE_ME>'
  EMAIL = '<admin_email>'
  EDITION = 'ENTERPRISE'
  REGION = 'AWS_US_EAST_1'
  COMMENT = 'Development environment for CONTOSO data platform';

-- Create QA account
CREATE ACCOUNT CONTOSO_QA
  ADMIN_NAME = 'admin'
  ADMIN_PASSWORD = '<CHANGE_ME>'
  EMAIL = '<admin_email>'
  EDITION = 'ENTERPRISE'
  REGION = 'AWS_US_EAST_1'
  COMMENT = 'QA environment for CONTOSO data platform';

-- Create STAGING account
CREATE ACCOUNT CONTOSO_STAGING
  ADMIN_NAME = 'admin'
  ADMIN_PASSWORD = '<CHANGE_ME>'
  EMAIL = '<admin_email>'
  EDITION = 'ENTERPRISE'
  REGION = 'AWS_US_EAST_1'
  COMMENT = 'Staging environment for CONTOSO data platform';

-- Production is your current account (primary)
ALTER ACCOUNT SET COMMENT = 'Production environment for CONTOSO data platform';

-- =============================================================================
-- STEP 3: Create Infrastructure Database
-- =============================================================================
USE ROLE SYSADMIN;

CREATE DATABASE IF NOT EXISTS INFRA_PLATFORM
  COMMENT = 'Platform infrastructure: monitoring, utilities, and metadata';

CREATE SCHEMA IF NOT EXISTS INFRA_PLATFORM.MONITORING
  COMMENT = 'Query history, resource monitors, cost tracking';
CREATE SCHEMA IF NOT EXISTS INFRA_PLATFORM.UTILITIES
  COMMENT = 'Shared UDFs, stored procedures, and helper functions';
CREATE SCHEMA IF NOT EXISTS INFRA_PLATFORM.METADATA
  COMMENT = 'Object metadata, lineage tracking, and data catalog extensions';
CREATE SCHEMA IF NOT EXISTS INFRA_PLATFORM.AUDIT
  COMMENT = 'Audit logs, access tracking, and compliance records';

-- =============================================================================
-- STEP 4: Define Domain Databases & Naming Conventions
-- =============================================================================
USE ROLE SYSADMIN;

-- ============================================================
-- FINANCE domain databases (DOMAIN_PREFIX naming convention)
-- Pattern: <DOMAIN>_<LAYER>
-- Layers: RAW (ingestion), CURATED (cleansed), ANALYTICS (consumption)
-- ============================================================

-- Raw/landing zone for finance data
CREATE DATABASE IF NOT EXISTS FINANCE_RAW
  COMMENT = 'Finance domain: raw ingestion layer (EL landing zone)';
CREATE SCHEMA IF NOT EXISTS FINANCE_RAW.INGESTION
  COMMENT = 'Landing area for raw finance data loads';
CREATE SCHEMA IF NOT EXISTS FINANCE_RAW.STAGING
  COMMENT = 'Staging transforms before curation';

-- Curated/conformed finance data
CREATE DATABASE IF NOT EXISTS FINANCE_CURATED
  COMMENT = 'Finance domain: curated and conformed data';
CREATE SCHEMA IF NOT EXISTS FINANCE_CURATED.DIMENSIONS
  COMMENT = 'Finance dimension tables (accounts, cost centers, entities)';
CREATE SCHEMA IF NOT EXISTS FINANCE_CURATED.FACTS
  COMMENT = 'Finance fact tables (transactions, journal entries)';

-- Analytics/consumption layer
CREATE DATABASE IF NOT EXISTS FINANCE_ANALYTICS
  COMMENT = 'Finance domain: analytics and reporting consumption layer';
CREATE SCHEMA IF NOT EXISTS FINANCE_ANALYTICS.REPORTS
  COMMENT = 'Reporting views and aggregations';
CREATE SCHEMA IF NOT EXISTS FINANCE_ANALYTICS.MODELS
  COMMENT = 'Analytical models and forecasts';

-- =============================================================================
-- STEP 5: Configure Database Replication (Multi-Account)
-- =============================================================================
USE ROLE ACCOUNTADMIN;

ALTER DATABASE INFRA_PLATFORM ENABLE REPLICATION TO ACCOUNTS
  CONTOSO.CONTOSO_DEV, CONTOSO.CONTOSO_QA, CONTOSO.CONTOSO_STAGING;

ALTER DATABASE FINANCE_ANALYTICS ENABLE REPLICATION TO ACCOUNTS
  CONTOSO.CONTOSO_STAGING;

-- =============================================================================
-- NAMING CONVENTION REFERENCE
-- =============================================================================
-- Object Type    | Pattern                          | Example
-- -------------- | -------------------------------- | ----------------------------
-- Database       | <DOMAIN>_<LAYER>                 | FINANCE_RAW, FINANCE_ANALYTICS
-- Schema         | <PURPOSE>                        | INGESTION, DIMENSIONS, REPORTS
-- Table          | <ENTITY>                         | TRANSACTIONS, GL_ENTRIES
-- View           | V_<ENTITY>                       | V_MONTHLY_REVENUE
-- Warehouse      | <DOMAIN>_<SIZE>_<PURPOSE>_WH     | FINANCE_M_ETL_WH
-- Role           | <DOMAIN>_<ACCESS_LEVEL>          | FINANCE_READER, FINANCE_WRITER
-- Stage          | <DOMAIN>_<SOURCE>_STG            | FINANCE_SAP_STG
-- Task           | <DOMAIN>_<ACTION>_TASK           | FINANCE_LOAD_DAILY_TASK
-- =============================================================================
