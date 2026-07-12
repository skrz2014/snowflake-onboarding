"""
Snowflake Cortex Code — Snowpark Debug Demo
============================================
This file demonstrates the DEBUG (F5) functionality with Snowflake.

How to test:
1. Open this file in Cortex Code
2. Set breakpoints by clicking the gutter (left margin) on lines marked # <-- BREAKPOINT
3. Press F5 to Start Debugging
4. Use Step Over (F10), Step Into (F11) to navigate
5. Inspect variables in the Variables panel

Alternatively:
- Press Ctrl+F5 to just RUN without debugging
"""

from snowflake.snowpark import Session
from snowflake.snowpark.functions import col, sum as sf_sum, count, avg


def get_session():
    """Create a Snowflake session using Cortex Code connection."""
    session = Session.builder.configs({"connection_name": "default"}).create()
    return session


def explore_account_info(session):
    """Query basic account information."""
    print("\n[1] Account Information")
    print("-" * 40)

    result = session.sql("SELECT CURRENT_ACCOUNT(), CURRENT_USER(), CURRENT_ROLE()").collect()
    row = result[0]  # <-- BREAKPOINT: Inspect 'row' to see account details

    print(f"  Account : {row[0]}")
    print(f"  User    : {row[1]}")
    print(f"  Role    : {row[2]}")

    return row


def list_databases(session):
    """List available databases."""
    print("\n[2] Available Databases")
    print("-" * 40)

    df = session.sql("SHOW DATABASES")  # <-- BREAKPOINT: Inspect 'df' DataFrame
    databases = df.collect()

    for i, db in enumerate(databases[:10]):
        print(f"  {i+1}. {db['name']}")

    total = len(databases)
    if total > 10:
        print(f"  ... and {total - 10} more")

    print(f"\n  Total databases: {total}")
    return total


def list_warehouses(session):
    """List available warehouses."""
    print("\n[3] Available Warehouses")
    print("-" * 40)

    df = session.sql("SHOW WAREHOUSES")
    warehouses = df.collect()  # <-- BREAKPOINT: Check warehouse list

    for wh in warehouses:
        state = wh['state']
        name = wh['name']
        size = wh['size']
        print(f"  {name:<25} Size: {size:<10} State: {state}")

    return len(warehouses)


def query_usage_metrics(session):
    """Query warehouse usage if accessible."""
    print("\n[4] Recent Query Count (last 7 days)")
    print("-" * 40)

    try:
        df = session.sql("""
            SELECT 
                COUNT(*) as query_count
            FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
            WHERE START_TIME >= DATEADD('day', -7, CURRENT_TIMESTAMP())
        """)
        result = df.collect()  # <-- BREAKPOINT: See query count
        query_count = result[0][0]
        print(f"  Queries in last 7 days: {query_count}")
        return query_count
    except Exception as e:
        print(f"  [SKIP] Cannot access query history: {e}")
        return 0


def main():
    """Main execution flow — set breakpoints and step through."""
    print("=" * 60)
    print("  Snowflake Cortex Code — Snowpark Debug Demo")
    print("=" * 60)

    # Step 1: Connect
    print("\n  Connecting to Snowflake...")
    session = get_session()  # <-- BREAKPOINT: Verify connection
    print("  Connected!")

    # Step 2: Explore
    account_info = explore_account_info(session)
    db_count = list_databases(session)
    wh_count = list_warehouses(session)

    # Step 3: Metrics
    query_count = query_usage_metrics(session)

    # Summary
    print("\n" + "=" * 60)
    print("  SUMMARY")
    print("=" * 60)
    print(f"  Databases   : {db_count}")  # <-- BREAKPOINT: Check final summary
    print(f"  Warehouses  : {wh_count}")
    print(f"  Queries (7d): {query_count}")
    print("=" * 60)
    print("\n  [SUCCESS] Demo completed!")

    session.close()


if __name__ == "__main__":
    main()
