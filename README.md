# Snowflake Account Onboarding

Complete SQL scripts for setting up a new Snowflake account from scratch — covering platform infrastructure, account creation, and data product configuration using Cortex Code.

**Organization:** CONTOSO | **Region:** AWS US East 1 | **Strategy:** Multi-Account (Dev, QA, Staging, Prod)

---

## Folder Structure

```
snowflake-onboarding/
├── README.md
├── .gitignore
├── LICENSE
│
├── 01-platform-foundation-setup/
│   ├── 01_platform_foundation.sql       # Organization, infra DB, naming conventions
│   ├── 02_platform_security.sql         # Identity (SCIM), SSO, network policies, MFA
│   └── 03_platform_cost_management.sql  # Budgets, resource monitors, cost tags
│
├── 02-account-creation/
│   ├── 01_account_provisioning.sql      # Create accounts, replication setup
│   ├── 02_account_security.sql          # SCIM, admins, SSO, break-glass, auth policies
│   └── 03_account_cost_management.sql   # Account budget, monitors, cost allocation tags
│
└── 03-data-product-setup/
    ├── 01_data_product_planning.sql     # Zones, schemas, warehouses blueprint
    ├── 02_core_roles_databases.sql      # Roles, databases, schemas with access roles
    ├── 03_warehouse_access.sql          # Warehouses, access roles, role hierarchy
    ├── 04_consumer_access.sql           # Custom read roles, database grants
    └── 05_cost_management.sql           # Resource monitors, alerts, notifications
```

---

## Prerequisites

- Snowflake account with **ACCOUNTADMIN** and **ORGADMIN** access
- Okta tenant (for SCIM and SAML SSO configuration)
- Corporate IP CIDR ranges for network policies

---

## Execution Order

| Phase | Folder | Run As | Description |
|-------|--------|--------|-------------|
| 1 | `01-platform-foundation-setup/` | ORGADMIN / ACCOUNTADMIN | Org config, infra DB, security, cost controls |
| 2 | `02-account-creation/` | ORGADMIN / ACCOUNTADMIN | Provision new accounts with security & budgets |
| 3 | `03-data-product-setup/` | SYSADMIN / SECURITYADMIN | Build data products with RBAC & monitoring |

Within each folder, execute scripts in numeric order (`01_` → `02_` → `03_` ...).

---

## Before You Run

1. **Replace all `<PLACEHOLDER>` values** — search for `<` in any file to find them
2. **Verify your IP** before activating network policies (or risk lockout)
3. **Test SSO** end-to-end before enforcing SSO-only authentication
4. **Store break-glass credentials** in a secure vault separate from your IdP

---

## All Placeholders to Replace

> **Quick find:** Run `grep -rn '<' --include="*.sql"` in this folder to locate every placeholder.

### 01-platform-foundation-setup/01_platform_foundation.sql

| Placeholder | Line(s) | Description | Example Value |
|-------------|---------|-------------|---------------|
| `<CHANGE_ME>` | 30, 39, 48 | Admin password for DEV/QA/STAGING accounts | `S3cur3P@ssw0rd!2025` |
| `<admin_email>` | 31, 40, 49 | Admin email for each account | `platform-admin@contoso.com` |

### 01-platform-foundation-setup/02_platform_security.sql

| Placeholder | Line(s) | Description | Example Value |
|-------------|---------|-------------|---------------|
| `<OKTA_ENTITY_ID>` | 80 | Okta app Entity ID (Sign On tab → Identity Provider Issuer) | `exk1abc2def3ghi4j5k6` |
| `<YOUR_ORG>` | 81 | Okta organization subdomain | `contoso` (from contoso.okta.com) |
| `<APP_ID>` | 81 | Okta Snowflake app ID (from embed link) | `0oa1abc2def3ghi4j5k6` |
| `<BASE64_ENCODED_CERTIFICATE>` | 83 | X.509 cert from Okta SAML app (no BEGIN/END headers) | `MIIDpDCCAoygAwIBAgI...` |
| `<ACCOUNT_IDENTIFIER>` | 86, 87 | Snowflake account locator with region | `zec52956.us-east-1` |
| `<STRONG_RANDOM_PASSWORD_MIN_32_CHARS>` | 100 | Break-glass emergency admin password (store in vault) | `xK9#mP2$vL7@nQ4wR...` |

### 02-account-creation/01_account_provisioning.sql

| Placeholder | Line(s) | Description | Example Value |
|-------------|---------|-------------|---------------|
| `<SET_STRONG_PASSWORD>` | 16 | Initial admin password for PROD_DATASCIENCE account | `D@t@Sc1ence#Pr0d!` |
| `<your_org_name>` | 43 | Your Snowflake organization name | `CONTOSO` |
| `<source_account_name>` | 43 | Source account for replication | `CONTOSO_PROD` |

### 02-account-creation/02_account_security.sql

| Placeholder | Line(s) | Description | Example Value |
|-------------|---------|-------------|---------------|
| `<OKTA_ISSUER_URL>` | 47 | Okta SAML issuer URL | `http://www.okta.com/exk1abc2def` |
| `<OKTA_SSO_URL>` | 48 | Okta SAML SSO endpoint | `https://contoso.okta.com/app/snowflake/exk.../sso/saml` |
| `<BASE64_ENCODED_CERT>` | 50 | X.509 certificate (same as platform security) | `MIIDpDCCAoygAwIBAgI...` |
| `<ACCOUNT_IDENTIFIER>` | 53, 54 | Snowflake account locator with region | `zec52956.us-east-1` |
| `<BREAK_GLASS_IP_1>` | 81 | First emergency access IP address | `203.0.113.10` |
| `<BREAK_GLASS_IP_2>` | 81 | Second emergency access IP address | `198.51.100.20` |
| `<CORPORATE_CIDR_1>` | 105 | Corporate office IP range 1 | `10.0.0.0/8` |
| `<CORPORATE_CIDR_2>` | 106 | Corporate office IP range 2 | `172.16.0.0/12` |
| `<VPN_GATEWAY_IP>` | 107 | VPN gateway egress IP | `203.0.113.50` |

### 03-data-product-setup/ (no placeholders)

All scripts in the data product setup folder use concrete values and require no placeholder replacement. Adjust warehouse sizes, role names, or database names as needed for your environment.

### Summary: Placeholder Checklist

- [ ] `<CHANGE_ME>` — Set passwords for DEV, QA, STAGING accounts
- [ ] `<admin_email>` — Set admin email for each account
- [ ] `<OKTA_ENTITY_ID>` — Get from Okta → App → Sign On → Identity Provider Issuer
- [ ] `<YOUR_ORG>` — Your Okta subdomain (e.g., `contoso`)
- [ ] `<APP_ID>` — Okta Snowflake app ID from embed link
- [ ] `<BASE64_ENCODED_CERTIFICATE>` — Download from Okta → App → Sign On → SAML Signing Certificates
- [ ] `<ACCOUNT_IDENTIFIER>` — Your Snowflake account locator (e.g., `zec52956.us-east-1`)
- [ ] `<STRONG_RANDOM_PASSWORD_MIN_32_CHARS>` — Generate and store in secure vault
- [ ] `<SET_STRONG_PASSWORD>` — Initial admin password for new account
- [ ] `<your_org_name>` — Snowflake organization name (e.g., `CONTOSO`)
- [ ] `<source_account_name>` — Source account for DB replication
- [ ] `<OKTA_ISSUER_URL>` — Full Okta issuer URL
- [ ] `<OKTA_SSO_URL>` — Full Okta SSO endpoint URL
- [ ] `<BREAK_GLASS_IP_1>` / `<BREAK_GLASS_IP_2>` — Emergency access IPs
- [ ] `<CORPORATE_CIDR_1>` / `<CORPORATE_CIDR_2>` — Corporate network ranges
- [ ] `<VPN_GATEWAY_IP>` — VPN egress IP address

---

## What Gets Created

### Platform Foundation
- **Organization:** CONTOSO with multi-account strategy
- **Accounts:** DEV, QA, STAGING, PROD
- **Infrastructure DB:** `INFRA_PLATFORM` (MONITORING, UTILITIES, METADATA, AUDIT schemas)
- **Domain DBs:** `FINANCE_RAW`, `FINANCE_CURATED`, `FINANCE_ANALYTICS`

### Security & Identity
- **SCIM:** Okta provisioning with IP-restricted network policy
- **SSO:** SAML2 integration with Okta
- **Break-glass:** Dedicated emergency admin with password + TOTP MFA
- **Network:** Account-level allowlist for corporate IPs
- **Auth policies:** SSO-only for humans, key-pair for service accounts
- **MFA:** Account-wide Duo enforcement

### Cost Management
- **Budget:** 10,000 credits/month with email alerts
- **Resource monitors:** 500 credits/warehouse (notify at 50/75/90/100%)
- **Cost tags:** `TEAM` and `COST_CENTER` in `GOVERNANCE.TAGS`

### Data Product (Customer Analytics)
- **Zones:** RAW → CURATED → CONSUMPTION → SANDBOX
- **Roles:** ADMIN > ENGINEER > ANALYST with per-zone READ/WRITE access roles
- **Warehouses:** Loading, Transform, Reporting, Data Science (workload-isolated)
- **Consumer access:** ANALYTICS_READER role with future grants
- **Data sharing:** External share for marketplace publishing

---

## Naming Conventions

| Object Type | Pattern | Example |
|-------------|---------|---------|
| Database | `<DOMAIN>_<LAYER>` | `FINANCE_RAW` |
| Schema | `<PURPOSE>` | `INGESTION`, `DIMENSIONS` |
| Table | `<ENTITY>` | `TRANSACTIONS` |
| View | `V_<ENTITY>` | `V_MONTHLY_REVENUE` |
| Warehouse | `<DOMAIN>_<SIZE>_<PURPOSE>_WH` | `FINANCE_M_ETL_WH` |
| Role | `<DOMAIN>_<ACCESS_LEVEL>` | `FINANCE_READER` |
| Stage | `<DOMAIN>_<SOURCE>_STG` | `FINANCE_SAP_STG` |
| Task | `<DOMAIN>_<ACTION>_TASK` | `FINANCE_LOAD_DAILY_TASK` |

---

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/add-marketing-domain`)
3. Follow the naming conventions above
4. Submit a pull request

---

## License

MIT License — see [LICENSE](LICENSE) for details.
