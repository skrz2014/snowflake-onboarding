"""
Cortex Code — Deliberate Failures for Show Output Demo
=======================================================
These tests intentionally fail to demonstrate error log output.
"""

from demo_run_debug.debug_breakpoints_demo import calculate_discount, generate_report


def test_wrong_discount_rate():
    """This test has a wrong expected value — will show assertion diff."""
    result = calculate_discount(1000, "GOLD")
    # Intentionally wrong: expecting 0.20 but GOLD is 0.15
    assert result["discount_rate"] == 0.20, (
        f"Expected 20% discount for GOLD tier, got {result['discount_rate']}"
    )


def test_key_error_in_result():
    """This test accesses a non-existent key — will show KeyError traceback."""
    result = calculate_discount(500, "SILVER")
    # 'savings' key doesn't exist in the result dict
    _ = result["savings"]


def test_type_mismatch():
    """This test compares wrong types — will show type error in diff."""
    result = calculate_discount(2000, "PLATINUM")
    # Comparing float to string — always fails
    assert result["final_amount"] == "1600.0"


def test_report_with_empty_list():
    """This test passes empty list causing ZeroDivisionError in generate_report."""
    results = []
    report = generate_report(results)
    assert report["avg_discount_pct"] == 0


def test_passing_for_contrast():
    """This test passes — shown for contrast in the output."""
    result = calculate_discount(1000, "BRONZE")
    assert result["discount_rate"] == 0.05
    assert result["final_amount"] == 950.0
