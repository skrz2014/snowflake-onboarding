#!/bin/bash
set -e

echo "=== Snowflake Dev Container Setup ==="

# Verify Snowflake tools
echo "Checking installed tools..."
echo "  Python: $(python --version 2>&1)"
echo "  dbt: $(dbt --version 2>&1 | head -1)"
echo "  Snow CLI: $(snow --version 2>&1)"

# Create dbt profiles.yml
mkdir -p ~/.dbt
cat > ~/.dbt/profiles.yml << 'EOF'
snowflake_pipeline:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: "{{ env_var('SNOWFLAKE_ACCOUNT', 'ychhvbl-dyb79201') }}"
      user: "{{ env_var('SNOWFLAKE_USER', 'satish') }}"
      authenticator: "{{ env_var('SNOWFLAKE_AUTHENTICATOR', 'snowflake') }}"
      role: "{{ env_var('SNOWFLAKE_ROLE', 'ACCOUNTADMIN') }}"
      warehouse: "{{ env_var('SNOWFLAKE_WAREHOUSE', 'COMPUTE_WH') }}"
      database: "{{ env_var('SNOWFLAKE_DATABASE', 'SNOWFLAKE_SAMPLE_DATA') }}"
      schema: "{{ env_var('SNOWFLAKE_SCHEMA', 'PUBLIC') }}"
      threads: 4
EOF

# Create Snow CLI connection config if not mounted
if [ ! -f ~/.snowflake/connections.toml ]; then
  mkdir -p ~/.snowflake
  cat > ~/.snowflake/connections.toml << 'EOF'
[default]
account = "ychhvbl-dyb79201"
user = "satish"
authenticator = "snowflake"
warehouse = "COMPUTE_WH"
database = "SNOWFLAKE_SAMPLE_DATA"
schema = "PUBLIC"
role = "ACCOUNTADMIN"
EOF
fi

# Create useful aliases
cat >> ~/.bashrc << 'EOF'

# Snowflake aliases
alias sf="snow sql -q"
alias dbtrun="dbt run"
alias dbttest="dbt test"
alias sfquery="snow sql -q"
EOF

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Next steps:"
echo "  1. Run 'snow connection test' to verify Snowflake connection"
echo "  2. Run 'dbt debug' to verify dbt setup"
echo "  3. Run 'snow sql -q \"SELECT CURRENT_USER()\"' to test a query"
