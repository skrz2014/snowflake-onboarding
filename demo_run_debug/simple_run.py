"""
Snowflake Cortex Code — RUN Demo (Simple Python)
=================================================
This file demonstrates the basic RUN (Ctrl+F5) functionality.
No Snowflake connection required — just pure Python execution.

How to test:
1. Open this file in Cortex Code
2. Press Ctrl+F5 (or Cmd+F5 on Mac) to Run Without Debugging
3. See output in the Integrated Terminal
"""

import os
import sys
from datetime import datetime


def main():
    print("=" * 60)
    print("  Snowflake Cortex Code — RUN Demo")
    print("=" * 60)
    print()

    # Basic info
    print(f"  Python Version : {sys.version.split()[0]}")
    print(f"  Platform       : {sys.platform}")
    print(f"  Working Dir    : {os.getcwd()}")
    print(f"  Timestamp      : {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print()

    # Demonstrate output types
    print("-" * 60)
    print("  DEMO: Data Processing Simulation")
    print("-" * 60)

    sample_data = [
        {"region": "NORTH_AMERICA", "revenue": 4523891, "orders": 12847},
        {"region": "EUROPE", "revenue": 3891204, "orders": 10234},
        {"region": "ASIA_PACIFIC", "revenue": 2145678, "orders": 8912},
        {"region": "SOUTH_AMERICA", "revenue": 1234567, "orders": 5432},
    ]

    print()
    print(f"  {'REGION':<20} {'REVENUE':>12} {'ORDERS':>10} {'AVG ORDER':>12}")
    print(f"  {'-'*20} {'-'*12} {'-'*10} {'-'*12}")

    total_revenue = 0
    total_orders = 0

    for row in sample_data:
        avg_order = row["revenue"] / row["orders"]
        total_revenue += row["revenue"]
        total_orders += row["orders"]
        print(
            f"  {row['region']:<20} "
            f"${row['revenue']:>11,} "
            f"{row['orders']:>10,} "
            f"${avg_order:>11,.2f}"
        )

    print(f"  {'-'*20} {'-'*12} {'-'*10} {'-'*12}")
    print(
        f"  {'TOTAL':<20} "
        f"${total_revenue:>11,} "
        f"{total_orders:>10,} "
        f"${total_revenue/total_orders:>11,.2f}"
    )
    print()
    print("  [SUCCESS] Run completed successfully!")
    print("=" * 60)


if __name__ == "__main__":
    main()
