FROM mcr.microsoft.com/devcontainers/python:3.11-bookworm

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    unzip \
    git \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Install SnowSQL (Linux ARM64/AMD64 auto-detected)
RUN ARCH=$(dpkg --print-architecture) && \
    if [ "$ARCH" = "amd64" ]; then \
      curl -O https://sfc-repo.snowflakecomputing.com/snowsql/bootstrap/1.3/linux_x86_64/snowsql-1.3.1-linux_x86_64.bash && \
      SNOWSQL_DEST=/usr/local/bin SNOWSQL_LOGIN_SHELL=/dev/null bash snowsql-1.3.1-linux_x86_64.bash && \
      rm snowsql-1.3.1-linux_x86_64.bash; \
    else \
      echo "SnowSQL not available for $ARCH — use Snow CLI instead"; \
    fi

# Install Python packages
RUN pip install --no-cache-dir \
    snowflake-connector-python[pandas] \
    snowflake-cli \
    dbt-snowflake \
    snowflake-snowpark-python \
    pytest \
    black \
    ruff

# Verify installations
RUN python --version && \
    dbt --version && \
    snow --version
