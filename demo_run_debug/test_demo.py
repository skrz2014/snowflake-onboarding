"""
Snowflake Cortex Code — Test File for Run Configuration Demo
=============================================================
Run with: "Run Tests" configuration in launch.json
Or: Ctrl+F5 with pytest module
"""

from demo_run_debug.debug_breakpoints_demo import calculate_discount, generate_report


def test_platinum_discount():
    """Test platinum tier gets 20% discount."""
    result = calculate_discount(1000, "PLATINUM")
    assert result["discount_rate"] == 0.20
    assert result["discount_amount"] == 200.0
    assert result["final_amount"] == 800.0


def test_gold_discount():
    """Test gold tier gets 15% discount."""
    result = calculate_discount(1000, "GOLD")
    assert result["discount_rate"] == 0.15
    assert result["final_amount"] == 850.0


def test_unknown_tier():
    """Test unknown tier gets 0% discount."""
    result = calculate_discount(500, "UNKNOWN")
    assert result["discount_rate"] == 0.0
    assert result["final_amount"] == 500.0


def test_generate_report():
    """Test report generation."""
    results = [
        {"original": 1000, "discount_amount": 200, "final_amount": 800, "customer": "A"},
        {"original": 500, "discount_amount": 50, "final_amount": 450, "customer": "B"},
    ]
    report = generate_report(results)
    assert report["order_count"] == 2
    assert report["total_original"] == 1500
    assert report["total_discount"] == 250
    assert report["total_final"] == 1250


def test_zero_amount():
    """Test zero amount doesn't cause division error."""
    result = calculate_discount(0, "GOLD")
    assert result["final_amount"] == 0.0
