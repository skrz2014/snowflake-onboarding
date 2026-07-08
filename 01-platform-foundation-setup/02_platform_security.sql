-- Platform security and identity: SCIM, SSO, network policies, authentication, MFA

-- ============================================================================
-- PLATFORM SECURITY & IDENTITY MANAGEMENT
-- IdP: Okta | MFA: Duo/TOTP | Network: Corporate IP Allowlist
-- ============================================================================

-- =============================================================================
-- STEP 1: CONFIGURE OKTA SCIM INTEGRATION
-- =============================================================================
USE ROLE ACCOUNTADMIN;

-- Create the SCIM provisioner role
CREATE ROLE IF NOT EXISTS OKTA_PROVISIONER;
GRANT CREATE USER ON ACCOUNT TO ROLE OKTA_PROVISIONER;
GRANT CREATE ROLE ON ACCOUNT TO ROLE OKTA_PROVISIONER;
GRANT ROLE OKTA_PROVISIONER TO ROLE ACCOUNTADMIN;

-- Create the SCIM security integration
CREATE OR REPLACE SECURITY INTEGRATION okta_provisioning
  TYPE = SCIM
  SCIM_CLIENT = 'OKTA'
  RUN_AS_ROLE = 'OKTA_PROVISIONER'
  ENABLED = TRUE;

-- Restrict SCIM access to Okta IPs
CREATE OR REPLACE NETWORK RULE okta_scim_network_rule
  MODE = INGRESS
  TYPE = IPV4
  VALUE_LIST = ('100.94.0.0/11', '185.29.108.0/22', '192.161.144.0/20');

CREATE OR REPLACE NETWORK POLICY okta_scim_network_policy
  ALLOWED_NETWORK_RULE_LIST = ('okta_scim_network_rule');

ALTER SECURITY INTEGRATION okta_provisioning SET NETWORK_POLICY = 'okta_scim_network_policy';

-- Retrieve SCIM endpoint and token for Okta configuration
SELECT SYSTEM$GENERATE_SCIM_ACCESS_TOKEN('okta_provisioning');
DESC SECURITY INTEGRATION okta_provisioning;

-- =============================================================================
-- STEP 2: PROVISION ACCOUNT ADMINISTRATORS
-- =============================================================================
USE ROLE ACCOUNTADMIN;

CREATE USER IF NOT EXISTS ADMIN_USER_1
  LOGIN_NAME = 'admin1@company.com'
  DISPLAY_NAME = 'Account Admin 1'
  EMAIL = 'admin1@company.com'
  MUST_CHANGE_PASSWORD = FALSE
  DEFAULT_ROLE = 'ACCOUNTADMIN';

CREATE USER IF NOT EXISTS ADMIN_USER_2
  LOGIN_NAME = 'admin2@company.com'
  DISPLAY_NAME = 'Account Admin 2'
  EMAIL = 'admin2@company.com'
  MUST_CHANGE_PASSWORD = FALSE
  DEFAULT_ROLE = 'ACCOUNTADMIN';

GRANT ROLE ACCOUNTADMIN TO USER ADMIN_USER_1;
GRANT ROLE ACCOUNTADMIN TO USER ADMIN_USER_2;
GRANT ROLE SECURITYADMIN TO USER ADMIN_USER_1;
GRANT ROLE SECURITYADMIN TO USER ADMIN_USER_2;
GRANT ROLE SYSADMIN TO USER ADMIN_USER_1;
GRANT ROLE SYSADMIN TO USER ADMIN_USER_2;

-- Grant ORGADMIN
GRANT ROLE ORGADMIN TO USER ADMIN_USER_1;
GRANT ROLE ORGADMIN TO USER ADMIN_USER_2;

-- =============================================================================
-- STEP 3: CONFIGURE SAML SSO (OKTA)
-- =============================================================================
USE ROLE ACCOUNTADMIN;

CREATE OR REPLACE SECURITY INTEGRATION okta_saml_integration
  TYPE = SAML2
  ENABLED = TRUE
  SAML2_ISSUER = 'http://www.okta.com/<OKTA_ENTITY_ID>'
  SAML2_SSO_URL = 'https://<YOUR_ORG>.okta.com/app/snowflake/<APP_ID>/sso/saml'
  SAML2_PROVIDER = 'OKTA'
  SAML2_X509_CERT = '<BASE64_ENCODED_CERTIFICATE>'
  SAML2_SP_INITIATED_LOGIN_PAGE_LABEL = 'Okta SSO Login'
  SAML2_ENABLE_SP_INITIATED = TRUE
  SAML2_SNOWFLAKE_ACS_URL = 'https://<ACCOUNT_IDENTIFIER>.snowflakecomputing.com/fed/login'
  SAML2_SNOWFLAKE_ISSUER_URL = 'https://<ACCOUNT_IDENTIFIER>.snowflakecomputing.com';

DESC SECURITY INTEGRATION okta_saml_integration;

-- =============================================================================
-- STEP 4: CREATE BREAK-GLASS EMERGENCY ACCESS
-- =============================================================================
USE ROLE ACCOUNTADMIN;

CREATE USER IF NOT EXISTS BREAK_GLASS_ADMIN
  LOGIN_NAME = 'break_glass_admin'
  DISPLAY_NAME = 'Break Glass Emergency Admin'
  EMAIL = 'security-team@company.com'
  PASSWORD = '<STRONG_RANDOM_PASSWORD_MIN_32_CHARS>'
  MUST_CHANGE_PASSWORD = FALSE
  DEFAULT_ROLE = 'ACCOUNTADMIN';

GRANT ROLE ACCOUNTADMIN TO USER BREAK_GLASS_ADMIN;
GRANT ROLE SECURITYADMIN TO USER BREAK_GLASS_ADMIN;
GRANT ROLE SYSADMIN TO USER BREAK_GLASS_ADMIN;
GRANT ROLE ORGADMIN TO USER BREAK_GLASS_ADMIN;

CREATE OR REPLACE AUTHENTICATION POLICY break_glass_auth_policy
  AUTHENTICATION_METHODS = ('PASSWORD')
  MFA_AUTHENTICATION_METHODS = ('TOTP')
  CLIENT_TYPES = ('SNOWFLAKE_UI')
  SECURITY_INTEGRATIONS = ()
  COMMENT = 'Break-glass: password + TOTP MFA, UI-only access';

ALTER USER BREAK_GLASS_ADMIN SET AUTHENTICATION POLICY break_glass_auth_policy;

-- Unrestricted network for emergency access (protected by MFA)
CREATE OR REPLACE NETWORK RULE break_glass_network_rule
  MODE = INGRESS
  TYPE = IPV4
  VALUE_LIST = ('0.0.0.0/0');

CREATE OR REPLACE NETWORK POLICY break_glass_network_policy
  ALLOWED_NETWORK_RULE_LIST = ('break_glass_network_rule')
  COMMENT = 'Unrestricted network for break-glass emergency access';

ALTER USER BREAK_GLASS_ADMIN SET NETWORK_POLICY = 'break_glass_network_policy';

-- =============================================================================
-- STEP 5: CONFIGURE NETWORK RULES AND POLICIES
-- =============================================================================
USE ROLE ACCOUNTADMIN;

CREATE OR REPLACE NETWORK RULE corporate_ingress_rule
  MODE = INGRESS
  TYPE = IPV4
  VALUE_LIST = (
    '203.0.113.0/24',       -- Replace: Corporate office range 1
    '198.51.100.0/24',      -- Replace: Corporate office range 2
    '192.0.2.0/24'          -- Replace: VPN egress range
  )
  COMMENT = 'Corporate and VPN IP ranges';

CREATE OR REPLACE NETWORK POLICY account_network_policy
  ALLOWED_NETWORK_RULE_LIST = ('corporate_ingress_rule')
  COMMENT = 'Restricts all account access to corporate IP ranges';

-- IMPORTANT: Verify your IP before activating!
SELECT CURRENT_IP_ADDRESS();

-- Uncomment when ready:
-- ALTER ACCOUNT SET NETWORK_POLICY = 'account_network_policy';

-- =============================================================================
-- STEP 6: CONFIGURE AUTHENTICATION POLICIES
-- =============================================================================
USE ROLE ACCOUNTADMIN;

-- SSO-only for regular human users
CREATE OR REPLACE AUTHENTICATION POLICY human_sso_auth_policy
  AUTHENTICATION_METHODS = ('SAML')
  MFA_AUTHENTICATION_METHODS = ('TOTP')
  CLIENT_TYPES = ('SNOWFLAKE_UI', 'SNOWFLAKE_CLI', 'DRIVERS')
  SECURITY_INTEGRATIONS = ('okta_saml_integration')
  COMMENT = 'SSO-only authentication for human users via Okta';

-- Key-pair only for service accounts
CREATE OR REPLACE AUTHENTICATION POLICY service_account_auth_policy
  AUTHENTICATION_METHODS = ('KEYPAIR')
  CLIENT_TYPES = ('SNOWFLAKE_CLI', 'DRIVERS')
  SECURITY_INTEGRATIONS = ()
  COMMENT = 'Key-pair authentication only for service accounts';

-- Apply SSO-only as the account-level default
ALTER ACCOUNT SET AUTHENTICATION POLICY human_sso_auth_policy;

-- =============================================================================
-- STEP 7: ENABLE MULTI-FACTOR AUTHENTICATION
-- =============================================================================
USE ROLE ACCOUNTADMIN;

-- Update policies to use Duo MFA
ALTER AUTHENTICATION POLICY human_sso_auth_policy SET MFA_AUTHENTICATION_METHODS = ('DUO');
ALTER AUTHENTICATION POLICY break_glass_auth_policy SET MFA_AUTHENTICATION_METHODS = ('DUO');

-- Enforce MFA account-wide
ALTER ACCOUNT SET REQUIRE_MFA = TRUE;

-- Verify
SHOW PARAMETERS LIKE 'REQUIRE_MFA' IN ACCOUNT;

-- Audit MFA enrollment
SELECT NAME, LOGIN_NAME, DEFAULT_ROLE, HAS_MFA, EXT_AUTHN_DUO, LAST_SUCCESS_LOGIN
FROM SNOWFLAKE.ACCOUNT_USAGE.USERS
WHERE DELETED_ON IS NULL
ORDER BY HAS_MFA ASC, NAME;
