-- Account security and identity: SCIM, admins, SSO, break-glass, network, auth policies, MFA

-- ============================================================================
-- ACCOUNT SECURITY & IDENTITY
-- IdP: Okta | Break-glass: 2 users | Network: Corporate allowlist
-- ============================================================================

-- =============================================================================
-- STEP 1: CONFIGURE OKTA SCIM INTEGRATION
-- =============================================================================
USE ROLE ACCOUNTADMIN;

CREATE ROLE IF NOT EXISTS OKTA_PROVISIONER;
GRANT CREATE USER ON ACCOUNT TO ROLE OKTA_PROVISIONER;
GRANT CREATE ROLE ON ACCOUNT TO ROLE OKTA_PROVISIONER;
GRANT ROLE OKTA_PROVISIONER TO ROLE ACCOUNTADMIN;

CREATE OR REPLACE SECURITY INTEGRATION okta_provisioning
  TYPE = SCIM
  SCIM_CLIENT = 'OKTA'
  RUN_AS_ROLE = 'OKTA_PROVISIONER'
  ENABLED = TRUE;

-- =============================================================================
-- STEP 2: CREATE ACCOUNT ADMINISTRATORS
-- =============================================================================
CREATE USER IF NOT EXISTS ADMIN_USER
  LOGIN_NAME = 'ADMIN_USER'
  DISPLAY_NAME = 'Account Administrator'
  EMAIL = 'admin@yourcompany.com'
  FIRST_NAME = 'Admin'
  LAST_NAME = 'User'
  MUST_CHANGE_PASSWORD = TRUE
  DEFAULT_ROLE = 'ACCOUNTADMIN';

GRANT ROLE ACCOUNTADMIN TO USER ADMIN_USER;
GRANT ROLE SYSADMIN TO USER ADMIN_USER;
GRANT ROLE SECURITYADMIN TO USER ADMIN_USER;

-- =============================================================================
-- STEP 3: CONFIGURE SAML SSO (OKTA)
-- =============================================================================
CREATE OR REPLACE SECURITY INTEGRATION okta_saml_sso
  TYPE = SAML2
  ENABLED = TRUE
  SAML2_ISSUER = '<OKTA_ISSUER_URL>'
  SAML2_SSO_URL = '<OKTA_SSO_URL>'
  SAML2_PROVIDER = 'OKTA'
  SAML2_X509_CERT = '<BASE64_ENCODED_CERT>'
  SAML2_SP_INITIATED_LOGIN_PAGE_LABEL = 'Okta SSO Login'
  SAML2_ENABLE_SP_INITIATED = TRUE
  SAML2_SNOWFLAKE_ACS_URL = 'https://<ACCOUNT_IDENTIFIER>.snowflakecomputing.com/fed/login'
  SAML2_SNOWFLAKE_ISSUER_URL = 'https://<ACCOUNT_IDENTIFIER>.snowflakecomputing.com';

-- =============================================================================
-- STEP 4: CREATE BREAK-GLASS EMERGENCY ACCESS
-- =============================================================================
CREATE USER IF NOT EXISTS BREAK_GLASS_ADMIN_1
  LOGIN_NAME = 'BREAK_GLASS_ADMIN_1'
  DISPLAY_NAME = 'Break Glass Admin 1'
  EMAIL = 'breakglass1@yourcompany.com'
  MUST_CHANGE_PASSWORD = TRUE
  DEFAULT_ROLE = 'ACCOUNTADMIN'
  COMMENT = 'Emergency break-glass account';

CREATE USER IF NOT EXISTS BREAK_GLASS_ADMIN_2
  LOGIN_NAME = 'BREAK_GLASS_ADMIN_2'
  DISPLAY_NAME = 'Break Glass Admin 2'
  EMAIL = 'breakglass2@yourcompany.com'
  MUST_CHANGE_PASSWORD = TRUE
  DEFAULT_ROLE = 'ACCOUNTADMIN'
  COMMENT = 'Emergency break-glass account';

GRANT ROLE ACCOUNTADMIN TO USER BREAK_GLASS_ADMIN_1;
GRANT ROLE ACCOUNTADMIN TO USER BREAK_GLASS_ADMIN_2;

CREATE OR REPLACE NETWORK RULE break_glass_ip_rule
  MODE = INGRESS
  TYPE = IPV4
  VALUE_LIST = ('<BREAK_GLASS_IP_1>', '<BREAK_GLASS_IP_2>');

CREATE OR REPLACE NETWORK POLICY break_glass_network_policy
  ALLOWED_NETWORK_RULE_LIST = ('break_glass_ip_rule');

ALTER USER BREAK_GLASS_ADMIN_1 SET NETWORK_POLICY = 'break_glass_network_policy';
ALTER USER BREAK_GLASS_ADMIN_2 SET NETWORK_POLICY = 'break_glass_network_policy';

CREATE OR REPLACE AUTHENTICATION POLICY break_glass_auth_policy
  MFA_AUTHENTICATION_METHODS = ('TOTP')
  CLIENT_TYPES = ('SNOWFLAKE_UI', 'SNOWSIGHT')
  SECURITY_INTEGRATIONS = ()
  COMMENT = 'Break-glass auth policy: password + MFA only, no SSO';

ALTER USER BREAK_GLASS_ADMIN_1 SET AUTHENTICATION POLICY break_glass_auth_policy;
ALTER USER BREAK_GLASS_ADMIN_2 SET AUTHENTICATION POLICY break_glass_auth_policy;

-- =============================================================================
-- STEP 5: CONFIGURE NETWORK RULES AND POLICIES
-- =============================================================================
CREATE OR REPLACE NETWORK RULE corporate_ip_allowlist
  MODE = INGRESS
  TYPE = IPV4
  VALUE_LIST = (
    '<CORPORATE_CIDR_1>',
    '<CORPORATE_CIDR_2>',
    '<VPN_GATEWAY_IP>/32'
  );

CREATE OR REPLACE NETWORK POLICY account_network_policy
  ALLOWED_NETWORK_RULE_LIST = ('corporate_ip_allowlist')
  COMMENT = 'Account-level network policy';

-- CAUTION: Verify your IP is in the allowlist before uncommenting
-- ALTER ACCOUNT SET NETWORK_POLICY = 'account_network_policy';

-- =============================================================================
-- STEP 6: CONFIGURE AUTHENTICATION POLICIES
-- =============================================================================
CREATE OR REPLACE AUTHENTICATION POLICY standard_user_auth_policy
  AUTHENTICATION_METHODS = ('SAML')
  MFA_AUTHENTICATION_METHODS = ('TOTP')
  CLIENT_TYPES = ('SNOWSIGHT', 'SNOWFLAKE_UI', 'DRIVERS', 'SNOWPARK', 'SNOWSQL')
  SECURITY_INTEGRATIONS = ('okta_saml_sso')
  COMMENT = 'Standard users: SSO-only via Okta';

CREATE OR REPLACE AUTHENTICATION POLICY service_account_auth_policy
  AUTHENTICATION_METHODS = ('PASSWORD')
  MFA_AUTHENTICATION_METHODS = ()
  CLIENT_TYPES = ('DRIVERS', 'SNOWPARK')
  SECURITY_INTEGRATIONS = ()
  COMMENT = 'Service accounts: password auth, no MFA';

ALTER ACCOUNT SET AUTHENTICATION POLICY standard_user_auth_policy;
ALTER USER ADMIN_USER SET AUTHENTICATION POLICY standard_user_auth_policy;

-- =============================================================================
-- STEP 7: ENABLE MFA (ACCOUNT-WIDE)
-- =============================================================================
ALTER ACCOUNT SET REQUIRE_MFA = TRUE;

-- Verify
SHOW PARAMETERS LIKE 'REQUIRE_MFA' IN ACCOUNT;
DESC AUTHENTICATION POLICY standard_user_auth_policy;
DESC AUTHENTICATION POLICY break_glass_auth_policy;

-- Check MFA enrollment
SELECT NAME, LOGIN_NAME, HAS_MFA, DEFAULT_ROLE, LAST_SUCCESS_LOGIN
FROM SNOWFLAKE.ACCOUNT_USAGE.USERS
WHERE DELETED_ON IS NULL AND HAS_MFA = FALSE
ORDER BY DEFAULT_ROLE, NAME;
