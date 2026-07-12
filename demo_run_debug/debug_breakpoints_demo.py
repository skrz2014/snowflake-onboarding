"""
Snowflake Cortex Code — Debug with Breakpoints Demo
====================================================
This file has intentional logic to step through with the debugger.

How to test:
1. Set breakpoints on lines marked # <-- BREAKPOINT
2. Press F5 to start debugging
3. Use the Debug Toolbar:
   - Continue (F5): Run to next breakpoint
   - Step Over (F10): Execute line, move to next
   - Step Into (F11): Enter function calls
   - Step Out (Shift+F11): Exit current function
4. Watch the Variables panel update in real time
"""


def calculate_discount(amount, tier):
    """Calculate discount based on customer tier."""
    discount_rates = {  # <-- BREAKPOINT: Inspect discount_rates dict
        "PLATINUM": 0.20,
        "GOLD": 0.15,
        "SILVER": 0.10,
        "BRONZE": 0.05,
    }

    rate = discount_rates.get(tier, 0.0)  # <-- BREAKPOINT: Check rate value
    discount = amount * rate
    final_amount = amount - discount

    return {
        "original": amount,
        "discount_rate": rate,
        "discount_amount": discount,
        "final_amount": final_amount,
    }


def process_orders(orders):
    """Process a list of orders — step through this loop."""
    results = []

    for i, order in enumerate(orders):  # <-- BREAKPOINT: Watch 'i' and 'order' change each iteration
        print(f"  Processing order {i+1}/{len(orders)}: {order['customer']}")

        calc = calculate_discount(order["amount"], order["tier"])
        calc["customer"] = order["customer"]
        results.append(calc)

    return results


def generate_report(results):
    """Generate summary report from processed orders."""
    total_original = sum(r["original"] for r in results)
    total_discount = sum(r["discount_amount"] for r in results)
    total_final = sum(r["final_amount"] for r in results)

    report = {  # <-- BREAKPOINT: Inspect the complete report
        "order_count": len(results),
        "total_original": total_original,
        "total_discount": total_discount,
        "total_final": total_final,
        "avg_discount_pct": (total_discount / total_original * 100) if total_original > 0 else 0,
    }

    return report


def main():
    print("=" * 60)
    print("  Cortex Code — Breakpoint & Step-Through Demo")
    print("=" * 60)
    print()

    # Sample orders to process
    orders = [
        {"customer": "Acme Corp", "amount": 15000.00, "tier": "PLATINUM"},
        {"customer": "Beta Inc", "amount": 8500.00, "tier": "GOLD"},
        {"customer": "Gamma LLC", "amount": 3200.00, "tier": "SILVER"},
        {"customer": "Delta Co", "amount": 1200.00, "tier": "BRONZE"},
        {"customer": "Epsilon Ltd", "amount": 950.00, "tier": "BRONZE"},
    ]

    print(f"  Processing {len(orders)} orders...")
    print()

    # Process — Step Into (F11) here to enter the function
    results = process_orders(orders)  # <-- BREAKPOINT: Step Into to trace logic

    # Generate report
    report = generate_report(results)  # <-- BREAKPOINT: Step Into for report generation

    # Display results
    print()
    print("-" * 60)
    print(f"  {'CUSTOMER':<15} {'ORIGINAL':>10} {'DISCOUNT':>10} {'FINAL':>10}")
    print(f"  {'-'*15} {'-'*10} {'-'*10} {'-'*10}")

    for r in results:
        print(
            f"  {r['customer']:<15} "
            f"${r['original']:>9,.2f} "
            f"${r['discount_amount']:>9,.2f} "
            f"${r['final_amount']:>9,.2f}"
        )

    print(f"  {'-'*15} {'-'*10} {'-'*10} {'-'*10}")
    print(
        f"  {'TOTAL':<15} "
        f"${report['total_original']:>9,.2f} "
        f"${report['total_discount']:>9,.2f} "
        f"${report['total_final']:>9,.2f}"
    )
    print()
    print(f"  Average Discount: {report['avg_discount_pct']:.1f}%")
    print()
    print("  [SUCCESS] Debug demo completed!")
    print("=" * 60)


if __name__ == "__main__":
    main()
