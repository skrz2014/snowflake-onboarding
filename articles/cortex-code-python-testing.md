# Python Testing in Cortex Code Desktop

A complete guide to configuring, running, debugging, and managing Python tests in Cortex Code Desktop — with an end-to-end production-grade Snowflake data pipeline example.

---

## Table of Contents

1. [Configure Python Test](#configure-python-test)
2. [Install Additional Test Extensions](#install-additional-test-extensions)
3. [Refresh Tests](#refresh-tests)
4. [Run Tests](#run-tests)
5. [Debug Tests](#debug-tests)
6. [Run Tests with Coverage](#run-tests-with-coverage)
7. [Show Outputs](#show-outputs)
8. [Collapse All Tests](#collapse-all-tests)
9. [Clear All Tests](#clear-all-tests)
10. [Sort by Duration, Location, or Status](#sort-by-duration-location-or-status)
11. [View as List or Tree](#view-as-list-or-tree)
12. [End-to-End Production Example](#end-to-end-production-example)

---

## Configure Python Test

Setting up Python testing in Cortex Code Desktop involves three layers: the IDE test framework selection, the project-level pytest configuration, and workspace settings that control test discovery behavior.

### Step 1: Select the Test Framework

1. Open the **Command Palette** (`Cmd+Shift+P` on macOS / `Ctrl+Shift+P` on Windows/Linux).
2. Type **"Python: Configure Tests"** and select it.
3. A prompt asks you to choose the test framework:
   - **pytest** (recommended for Snowflake projects — supports fixtures, markers, parametrize, plugins)
   - **unittest** (stdlib, class-based, no plugins)
4. Select the root directory containing your tests (e.g., `demo_run_debug/` or `tests/`).
5. Cortex Code creates or updates `.vscode/settings.json` with your choices.

### Step 2: Workspace Settings (`.vscode/settings.json`)

This is the file Cortex Code reads to know how to discover and run tests. Here is the full configuration used in this project:

```json
{
  // ─── Python Testing Configuration ───────────────────────────────
  "python.testing.pytestEnabled": true,
  "python.testing.unittestEnabled": false,
  "python.testing.pytestArgs": [
    "demo_run_debug",
    "-v",
    "--tb=short"
  ],
  "python.testing.autoTestDiscoverOnSaveEnabled": true,

  // ─── Test Explorer Behavior ─────────────────────────────────────
  "testing.defaultGutterClickAction": "run",
  "testing.gutterEnabled": true,
  "testing.followRunningTest": true,
  "testing.showAllMessages": true,
  "testing.alwaysRevealTestOnStateChange": true,

  // ─── Coverage Gutters (requires Coverage Gutters extension) ─────
  "coverage-gutters.showLineCoverage": true,
  "coverage-gutters.showRulerCoverage": true,
  "coverage-gutters.coverageFileNames": [
    "coverage.xml",
    "lcov.info"
  ],

  // ─── Python Environment ─────────────────────────────────────────
  "python.envFile": "${workspaceFolder}/.env"
}
```

**Key settings explained:**

| Setting | Purpose |
|---------|---------|
| `python.testing.pytestEnabled` | Enables pytest as the test runner |
| `python.testing.pytestArgs` | Arguments passed to pytest on every discovery/run |
| `python.testing.autoTestDiscoverOnSaveEnabled` | Re-discovers tests automatically when you save a file |
| `testing.defaultGutterClickAction` | What happens when you click the gutter icon (`run` or `debug`) |
| `testing.gutterEnabled` | Shows play/debug icons in the editor margin next to test functions |
| `testing.followRunningTest` | Scrolls the Testing panel to the currently running test |
| `testing.alwaysRevealTestOnStateChange` | Auto-reveals a test in the panel when it passes/fails |

### Step 3: Project-Level pytest Configuration (`pyproject.toml`)

For portable, IDE-independent test configuration, define pytest settings in `pyproject.toml`:

```toml
[tool.pytest.ini_options]
testpaths = ["demo_run_debug"]
python_files = ["test_*.py"]
python_functions = ["test_*"]
markers = [
    "unit: Unit tests (no external dependencies)",
    "integration: Integration tests (requires Snowflake connection)",
    "slow: Tests that take >5 seconds",
]
addopts = [
    "-v",
    "--tb=short",
    "--strict-markers",
]
timeout = 30

[tool.coverage.run]
source = ["demo_run_debug"]
omit = ["*/__pycache__/*", "*/__init__.py"]
branch = true

[tool.coverage.report]
show_missing = true
exclude_lines = [
    "pragma: no cover",
    "if __name__ == .__main__.",
    "if TYPE_CHECKING:",
]
```

### Step 4: Select the Python Interpreter

1. `Cmd+Shift+P` > **"Python: Select Interpreter"**.
2. Choose the virtual environment or conda environment that has `pytest` installed.
3. If pytest is not installed, open the terminal and run:
   ```bash
   pip install pytest pytest-cov pytest-timeout pytest-mock
   ```

### Step 5: Verify Test Discovery

1. Open the **Testing** panel (flask icon in the Activity Bar, or `Cmd+Shift+P` > "Testing: Focus on Test Explorer View").
2. You should see your test files and functions listed in a tree.
3. If the tree is empty:
   - Check the Output panel (`Cmd+Shift+U` > select "Python") for errors.
   - Verify `pytestArgs` points to the correct directory.
   - Ensure test files match the `python_files` pattern (default: `test_*.py`).
   - Confirm pytest is installed in the selected interpreter.

### Troubleshooting Common Issues

| Problem | Solution |
|---------|----------|
| "No tests discovered" | Verify test file naming (`test_*.py`), check interpreter has pytest, check `pytestArgs` directory |
| "Module not found" in test imports | Add an `__init__.py` to your test directory, or install your package in editable mode (`pip install -e .`) |
| Tests run in terminal but not in IDE | Ensure `.vscode/settings.json` and `pyproject.toml` agree on test paths |
| "pytest not found" | Select the correct interpreter that has pytest installed |

---

## Install Additional Test Extensions

Cortex Code Desktop has built-in test support via the Python extension, but additional extensions unlock advanced features like inline coverage visualization, richer UI, and cross-framework adapters.

### Recommended Extensions

Open the **Extensions** panel (`Cmd+Shift+X`) and install:

| Extension | ID | Purpose |
|-----------|-----|---------|
| **Python** | `ms-python.python` | Core Python support — includes built-in test discovery and runner |
| **Debugpy** | `ms-python.debugpy` | Python debugging engine — required for Debug Tests |
| **Pylance** | `ms-python.vscode-pylance` | Type checking and IntelliSense — helps write correct test assertions |
| **Coverage Gutters** | `ryanluker.vscode-coverage-gutters` | Inline red/green coverage highlighting in the editor gutter |
| **Python Test Explorer** | `littlefoxteam.vscode-python-test-adapter` | Enhanced test tree UI with better filtering and grouping |
| **Test Explorer UI** | `hbenl.vscode-test-explorer` | Framework-agnostic test explorer sidebar (supports pytest, unittest, nose) |

### Using `.vscode/extensions.json` for Team Consistency

Create `.vscode/extensions.json` to recommend extensions to all team members. When someone opens the project, Cortex Code prompts them to install missing recommended extensions:

```json
{
  "recommendations": [
    "ms-python.python",
    "ms-python.debugpy",
    "ms-python.vscode-pylance",
    "ryanluker.vscode-coverage-gutters",
    "hbenl.vscode-test-explorer",
    "littlefoxteam.vscode-python-test-adapter"
  ]
}
```

This file is already configured in this project at `.vscode/extensions.json`.

### Post-Installation Setup

1. **Reload the window** after installing extensions: `Cmd+Shift+P` > "Developer: Reload Window".
2. **Verify the Testing panel** — the flask icon in the Activity Bar should now show discovered tests with play/debug icons.
3. **Enable Coverage Gutters** — after running tests with coverage, press `Cmd+Shift+P` > "Coverage Gutters: Display Coverage" to activate inline highlights.

### Extension Feature Matrix

| Feature | Built-in (Python ext) | + Coverage Gutters | + Test Explorer |
|---------|----------------------|-------------------|-----------------|
| Discover tests | Yes | — | Enhanced grouping |
| Run/debug from gutter | Yes | — | Yes |
| Run/debug from panel | Yes | — | Enhanced filtering |
| Coverage report (terminal) | With pytest-cov | — | — |
| Coverage inline in editor | No | Yes (red/green gutter) | — |
| Coverage ruler (scrollbar) | No | Yes | — |
| Test duration display | Basic | — | Yes |
| Test history/trends | No | — | Partial |

---

## Refresh Tests

When you add new test files or modify test functions, refresh the test tree:

- Click the **circular arrow** icon at the top of the Testing panel.
- Or use the Command Palette: **"Test: Refresh Tests"**.
- Or use the keyboard shortcut: `Cmd+Shift+P` > type "Refresh Tests".

**When to refresh:**
- After creating a new test file.
- After renaming test functions.
- After modifying `conftest.py` fixtures.
- After changing `pytestArgs` in settings.

Cortex Code re-discovers tests by running `pytest --collect-only` under the hood.

---

## Run Tests

Multiple ways to run tests:

### Run All Tests
- Click the **play** button (triangle icon) at the top of the Testing panel.
- Command Palette: **"Test: Run All Tests"**.

### Run a Single Test
- Click the **play** icon next to any individual test in the Testing panel.
- In the editor, click the green **play gutter icon** next to a `def test_*` function.

### Run Tests in a File
- Right-click a test file in the Explorer > **"Run Tests in File"**.
- In the Testing panel, click play on the file node.

### Run Tests by Pattern
- Command Palette: **"Test: Run Tests by Pattern"** > enter a keyword (e.g., `test_transform`).

### Keyboard Shortcuts
| Action | macOS | Windows/Linux |
|--------|-------|---------------|
| Run test at cursor | `Cmd+; Cmd+C` | `Ctrl+; Ctrl+C` |
| Run all tests | `Cmd+; A` | `Ctrl+; A` |
| Run failed tests | `Cmd+; Cmd+F` | `Ctrl+; Ctrl+F` |

---

## Debug Tests

Debugging tests allows you to set breakpoints and step through test execution:

1. Set breakpoints by clicking in the gutter (left margin) of your test file or source file.
2. In the Testing panel, click the **bug icon** (debug) next to a test.
3. Or right-click a test > **"Debug Test"**.
4. Or in the editor, click the **debug gutter icon** (bug + play) next to a test function.

**Debug controls:**
- **Continue** (`F5`) — Resume execution until next breakpoint.
- **Step Over** (`F10`) — Execute current line, move to next.
- **Step Into** (`F11`) — Enter the function call.
- **Step Out** (`Shift+F11`) — Exit current function.
- **Restart** (`Cmd+Shift+F5`) — Restart the debug session.
- **Stop** (`Shift+F5`) — Terminate the debug session.

**Debug console:** While paused, use the Debug Console to evaluate expressions, inspect variables, and call functions interactively.

**launch.json for test debugging (optional):**
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Debug Pytest",
      "type": "debugpy",
      "request": "launch",
      "module": "pytest",
      "args": ["tests/", "-v", "-s", "--no-header"],
      "justMyCode": false,
      "env": {
        "SNOWFLAKE_DEFAULT_CONNECTION_NAME": "testing"
      }
    }
  ]
}
```

Setting `"justMyCode": false` allows stepping into library code (e.g., Snowpark internals).

---

## Run Tests with Coverage

Code coverage identifies which lines of your source code are exercised by tests:

1. Install pytest-cov: `pip install pytest-cov`
2. Configure coverage in `pyproject.toml`:
   ```toml
   [tool.pytest.ini_options]
   addopts = "--cov=src --cov-report=term-missing --cov-report=xml:coverage.xml"

   [tool.coverage.run]
   source = ["src"]
   omit = ["tests/*", "*/__pycache__/*"]

   [tool.coverage.report]
   fail_under = 80
   show_missing = true
   ```
3. Run with coverage:
   - Click the **shield icon** (Run with Coverage) in the Testing panel.
   - Or Command Palette: **"Test: Run All Tests with Coverage"**.
4. Results appear in:
   - The **Test Results** output channel (line-by-line summary).
   - **Coverage Gutters** extension highlights covered (green), uncovered (red), and partially covered (yellow) lines inline.
   - A `coverage.xml` file for CI integration.

**View coverage inline:**
- After running with coverage, press `Cmd+Shift+P` > **"Coverage Gutters: Display Coverage"**.
- Green/red markers appear in the gutter showing covered/uncovered lines.

---

## Show Outputs

View detailed test output and logs when tests fail. This is essential for diagnosing assertion mismatches, unhandled exceptions, and type errors.

### How to Access Show Output

| Method | How |
|--------|-----|
| **Peek view (inline)** | Click a red X test in the Testing panel — error shows below the test name |
| **Output panel** | `Cmd+Shift+U` > dropdown > **"Python Test Log"** — full session log |
| **Terminal output** | If ran from integrated terminal, scroll up in the terminal tab |
| **Hover in editor** | Hover the red gutter marker next to the failing line — shows error summary |
| **Testing panel toolbar** | Click the **terminal/document icon** ("Show Output") |

### Demo: Deliberate Failures (`test_show_output_demo.py`)

This project includes a demo file that intentionally produces different types of errors to show what each looks like in the output:

```python
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
```

### Actual Error Log Output

Running with `pytest -v --tb=long -s` produces the following in the **Show Output** panel:

```
============================= test session starts ==============================
platform darwin -- Python 3.9.7, pytest-8.4.2
rootdir: /Users/satish/snowflake-onboarding
configfile: pyproject.toml
plugins: cov-7.1.0, timeout-2.4.0
timeout: 30.0s
collected 5 items

demo_run_debug/test_show_output_demo.py::test_wrong_discount_rate FAILED
demo_run_debug/test_show_output_demo.py::test_key_error_in_result FAILED
demo_run_debug/test_show_output_demo.py::test_type_mismatch FAILED
demo_run_debug/test_show_output_demo.py::test_report_with_empty_list PASSED
demo_run_debug/test_show_output_demo.py::test_passing_for_contrast PASSED

=================================== FAILURES ===================================
___________________________ test_wrong_discount_rate ___________________________

    def test_wrong_discount_rate():
        result = calculate_discount(1000, "GOLD")
>       assert result["discount_rate"] == 0.20
E       AssertionError: Expected 20% discount for GOLD tier, got 0.15
E       assert 0.15 == 0.2

demo_run_debug/test_show_output_demo.py:14: AssertionError
___________________________ test_key_error_in_result ___________________________

    def test_key_error_in_result():
        result = calculate_discount(500, "SILVER")
>       _ = result["savings"]
E       KeyError: 'savings'

demo_run_debug/test_show_output_demo.py:23: KeyError
______________________________ test_type_mismatch ______________________________

    def test_type_mismatch():
        result = calculate_discount(2000, "PLATINUM")
>       assert result["final_amount"] == "1600.0"
E       AssertionError: assert 1600.0 == '1600.0'

demo_run_debug/test_show_output_demo.py:30: AssertionError
=========================== short test summary info ============================
FAILED test_wrong_discount_rate - AssertionError: assert 0.15 == 0.2
FAILED test_key_error_in_result - KeyError: 'savings'
FAILED test_type_mismatch - AssertionError: assert 1600.0 == '1600.0'
========================= 3 failed, 2 passed in 0.14s =========================
```

### Error Types Explained

| Error Type | What You See in Output | How to Fix |
|------------|----------------------|------------|
| **AssertionError (value mismatch)** | `assert 0.15 == 0.2` with custom message | Check expected value — GOLD tier is 15%, not 20% |
| **KeyError (missing dict key)** | `KeyError: 'savings'` with full traceback | The result dict has `discount_amount`, not `savings` |
| **AssertionError (type mismatch)** | `assert 1600.0 == '1600.0'` — float vs string | Remove quotes: compare `== 1600.0` not `== "1600.0"` |

### Output Includes

- pytest's stdout/stderr capture
- Assertion failure diffs with expected vs. actual values
- Full exception tracebacks (KeyError, TypeError, ValueError, etc.)
- Fixture setup/teardown logs
- Print statements from your test code (when running with `-s` flag)
- Snowflake query IDs and timing (if logged)
- Short test summary with one-line error per failure

### Configuring Traceback Verbosity

Control how much detail appears in the output via `--tb` flag:

| Flag | Output Detail |
|------|--------------|
| `--tb=short` | Only the failing assertion line + error message |
| `--tb=long` | Full traceback including all stack frames (default for Show Output) |
| `--tb=line` | Single-line summary per failure |
| `--tb=no` | No traceback — only pass/fail status |

Set in `.vscode/settings.json`:
```json
"python.testing.pytestArgs": ["demo_run_debug", "-v", "--tb=long"]
```

**Tip:** Use `--tb=short` for quick scans and `--tb=long` when debugging specific failures.

---

## Collapse All Tests

When dealing with large test suites:

- Click the **collapse-all icon** (double up-arrow) in the Testing panel toolbar.
- This collapses the entire test tree to the top-level directories/files.
- Useful for navigating large projects with hundreds of tests.

**Keyboard:** No default shortcut, but you can assign one via Keybindings (`Cmd+K Cmd+S` > search "Testing: Collapse All").

---

## Clear All Tests

Reset the test results display:

- Click the **clear icon** (circle with X or eraser) in the Testing panel toolbar.
- Command Palette: **"Test: Clear All Results"**.

**What it does:**
- Removes pass/fail indicators from all tests.
- Clears the green/red decorations in the editor gutters.
- Does NOT delete test discovery — tests remain in the tree.
- Useful before a fresh test run to see only current results.

---

## Sort by Duration, Location, or Status

Organize the test tree to surface what matters:

Click the **sort icon** (or the `...` overflow menu) in the Testing panel toolbar and choose:

| Sort Mode | Behavior |
|-----------|----------|
| **By Location** (default) | Groups tests by file/directory structure. Matches your project layout. |
| **By Status** | Groups tests as: Failed > Running > Queued > Passed > Skipped. Failed tests surface to the top. |
| **By Duration** | Slowest tests appear first. Identifies performance bottlenecks. |

**Use cases:**
- **By Status** — After a test run, immediately see what failed without scrolling.
- **By Duration** — Find slow tests to optimize (especially integration tests hitting Snowflake).
- **By Location** — Default navigation when writing new tests.

---

## View as List or Tree

Toggle between two display modes:

### Tree View (default)
- Hierarchical: Project > Directory > File > Class > Test Function.
- Mirrors your filesystem structure.
- Best for navigating large test suites and understanding test organization.

### List View
- Flat list of all test functions.
- Each entry shows the full path: `tests/unit/test_transforms.py::TestRevenue::test_monthly_calc`.
- Best for searching/filtering specific tests and quick status overview.

**Toggle:** Click the **list/tree icon** in the Testing panel toolbar.

---

## End-to-End Production Example

Below is a complete, production-grade example: a Snowflake data pipeline with comprehensive tests covering unit, integration, and end-to-end scenarios.

### Project Structure

```
snowflake_revenue_pipeline/
├── src/
│   ├── __init__.py
│   ├── connectors.py          # Snowflake session management
│   ├── transforms.py          # Data transformation logic
│   ├── validators.py          # Data quality checks
│   ├── pipeline.py            # Orchestration
│   └── models.py              # Data models / schemas
├── tests/
│   ├── __init__.py
│   ├── conftest.py            # Shared fixtures
│   ├── unit/
│   │   ├── __init__.py
│   │   ├── test_transforms.py
│   │   ├── test_validators.py
│   │   └── test_models.py
│   ├── integration/
│   │   ├── __init__.py
│   │   ├── test_connectors.py
│   │   └── test_pipeline.py
│   └── e2e/
│       ├── __init__.py
│       └── test_full_pipeline.py
├── pyproject.toml
├── .vscode/
│   └── settings.json
└── coverage.xml
```

### pyproject.toml

```toml
[project]
name = "snowflake-revenue-pipeline"
version = "1.0.0"
requires-python = ">=3.9"
dependencies = [
    "snowflake-snowpark-python>=1.20.0",
    "pydantic>=2.0",
]

[project.optional-dependencies]
test = [
    "pytest>=8.0",
    "pytest-cov>=5.0",
    "pytest-xdist>=3.5",
    "pytest-timeout>=2.3",
    "pytest-mock>=3.14",
    "freezegun>=1.4",
]

[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py"]
python_functions = ["test_*"]
markers = [
    "unit: Unit tests (no external dependencies)",
    "integration: Integration tests (requires Snowflake connection)",
    "e2e: End-to-end tests (full pipeline execution)",
    "slow: Tests that take >5 seconds",
]
addopts = [
    "-v",
    "--tb=short",
    "--strict-markers",
    "--cov=src",
    "--cov-report=term-missing",
    "--cov-report=xml:coverage.xml",
    "--cov-fail-under=85",
    "-x",
]
timeout = 60

[tool.coverage.run]
source = ["src"]
omit = ["tests/*", "*/__pycache__/*", "src/__init__.py"]
branch = true

[tool.coverage.report]
fail_under = 85
show_missing = true
exclude_lines = [
    "pragma: no cover",
    "if TYPE_CHECKING:",
    "raise NotImplementedError",
]
```

### .vscode/settings.json

```json
{
  "python.testing.pytestEnabled": true,
  "python.testing.unittestEnabled": false,
  "python.testing.pytestArgs": [
    "tests",
    "-v",
    "--tb=short",
    "--strict-markers"
  ],
  "python.testing.autoTestDiscoverOnSaveEnabled": true,
  "python.envFile": "${workspaceFolder}/.env.test"
}
```

### Source Code

#### src/models.py

```python
from dataclasses import dataclass
from datetime import date
from decimal import Decimal
from enum import Enum


class RevenueType(Enum):
    SUBSCRIPTION = "SUBSCRIPTION"
    ONE_TIME = "ONE_TIME"
    USAGE_BASED = "USAGE_BASED"


@dataclass(frozen=True)
class RevenueRecord:
    customer_id: str
    revenue_date: date
    amount: Decimal
    revenue_type: RevenueType
    currency: str = "USD"

    def __post_init__(self):
        if self.amount < 0:
            raise ValueError(f"Revenue amount cannot be negative: {self.amount}")
        if not self.customer_id.strip():
            raise ValueError("Customer ID cannot be empty")


@dataclass(frozen=True)
class MonthlyRevenueSummary:
    year_month: str
    total_revenue: Decimal
    subscription_revenue: Decimal
    one_time_revenue: Decimal
    usage_revenue: Decimal
    customer_count: int
    avg_revenue_per_customer: Decimal
```

#### src/transforms.py

```python
from collections import defaultdict
from datetime import date
from decimal import Decimal, ROUND_HALF_UP
from typing import Sequence

from src.models import MonthlyRevenueSummary, RevenueRecord, RevenueType


def calculate_monthly_revenue(
    records: Sequence[RevenueRecord],
    target_month: str,
) -> MonthlyRevenueSummary:
    """Aggregate revenue records into a monthly summary.
    
    Args:
        records: Revenue records to aggregate.
        target_month: Format 'YYYY-MM'.
    """
    filtered = [
        r for r in records
        if r.revenue_date.strftime("%Y-%m") == target_month
    ]

    if not filtered:
        return MonthlyRevenueSummary(
            year_month=target_month,
            total_revenue=Decimal("0"),
            subscription_revenue=Decimal("0"),
            one_time_revenue=Decimal("0"),
            usage_revenue=Decimal("0"),
            customer_count=0,
            avg_revenue_per_customer=Decimal("0"),
        )

    by_type: dict[RevenueType, Decimal] = defaultdict(Decimal)
    customers: set[str] = set()

    for record in filtered:
        by_type[record.revenue_type] += record.amount
        customers.add(record.customer_id)

    total = sum(by_type.values(), Decimal("0"))
    customer_count = len(customers)
    avg = (total / customer_count).quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)

    return MonthlyRevenueSummary(
        year_month=target_month,
        total_revenue=total,
        subscription_revenue=by_type.get(RevenueType.SUBSCRIPTION, Decimal("0")),
        one_time_revenue=by_type.get(RevenueType.ONE_TIME, Decimal("0")),
        usage_revenue=by_type.get(RevenueType.USAGE_BASED, Decimal("0")),
        customer_count=customer_count,
        avg_revenue_per_customer=avg,
    )


def apply_currency_conversion(
    records: Sequence[RevenueRecord],
    rates: dict[str, Decimal],
    target_currency: str = "USD",
) -> list[RevenueRecord]:
    """Convert all records to target currency."""
    converted = []
    for record in records:
        if record.currency == target_currency:
            converted.append(record)
        else:
            rate_key = f"{record.currency}_{target_currency}"
            if rate_key not in rates:
                raise KeyError(
                    f"No conversion rate found for {rate_key}. "
                    f"Available: {list(rates.keys())}"
                )
            new_amount = (record.amount * rates[rate_key]).quantize(
                Decimal("0.01"), rounding=ROUND_HALF_UP
            )
            converted.append(
                RevenueRecord(
                    customer_id=record.customer_id,
                    revenue_date=record.revenue_date,
                    amount=new_amount,
                    revenue_type=record.revenue_type,
                    currency=target_currency,
                )
            )
    return converted


def detect_anomalies(
    records: Sequence[RevenueRecord],
    std_threshold: float = 2.0,
) -> list[RevenueRecord]:
    """Flag records where amount exceeds mean + threshold * stddev."""
    if len(records) < 3:
        return []

    amounts = [float(r.amount) for r in records]
    mean = sum(amounts) / len(amounts)
    variance = sum((x - mean) ** 2 for x in amounts) / len(amounts)
    std = variance ** 0.5

    upper_bound = Decimal(str(mean + std_threshold * std))
    return [r for r in records if r.amount > upper_bound]
```

#### src/validators.py

```python
from datetime import date, timedelta
from decimal import Decimal
from typing import Sequence

from src.models import RevenueRecord


class ValidationError(Exception):
    def __init__(self, errors: list[str]):
        self.errors = errors
        super().__init__(f"{len(errors)} validation error(s): {'; '.join(errors[:5])}")


def validate_revenue_batch(
    records: Sequence[RevenueRecord],
    max_amount: Decimal = Decimal("1000000"),
    max_age_days: int = 90,
) -> list[str]:
    """Validate a batch of revenue records. Returns list of error messages."""
    errors: list[str] = []
    seen_keys: set[tuple] = set()
    today = date.today()
    cutoff = today - timedelta(days=max_age_days)

    for i, record in enumerate(records):
        key = (record.customer_id, record.revenue_date, record.amount, record.revenue_type)
        if key in seen_keys:
            errors.append(f"Row {i}: Duplicate record for {record.customer_id} on {record.revenue_date}")
        seen_keys.add(key)

        if record.amount > max_amount:
            errors.append(
                f"Row {i}: Amount {record.amount} exceeds maximum {max_amount} "
                f"for customer {record.customer_id}"
            )

        if record.revenue_date > today:
            errors.append(f"Row {i}: Future date {record.revenue_date} for {record.customer_id}")

        if record.revenue_date < cutoff:
            errors.append(
                f"Row {i}: Date {record.revenue_date} is older than {max_age_days} days "
                f"for {record.customer_id}"
            )

    return errors


def validate_or_raise(
    records: Sequence[RevenueRecord],
    **kwargs,
) -> None:
    """Validate and raise if any errors found."""
    errors = validate_revenue_batch(records, **kwargs)
    if errors:
        raise ValidationError(errors)
```

#### src/connectors.py

```python
import os
from contextlib import contextmanager

from snowflake.snowpark import Session


def get_snowpark_session(connection_name: str | None = None) -> Session:
    """Create a Snowpark session from connection config."""
    if connection_name:
        return Session.builder.config("connection_name", connection_name).create()

    return Session.builder.configs({
        "account": os.environ["SNOWFLAKE_ACCOUNT"],
        "user": os.environ["SNOWFLAKE_USER"],
        "password": os.environ["SNOWFLAKE_PASSWORD"],
        "warehouse": os.environ.get("SNOWFLAKE_WAREHOUSE", "COMPUTE_WH"),
        "database": os.environ.get("SNOWFLAKE_DATABASE", "REVENUE_DB"),
        "schema": os.environ.get("SNOWFLAKE_SCHEMA", "PIPELINE"),
    }).create()


@contextmanager
def snowpark_session(connection_name: str | None = None):
    """Context manager for Snowpark session lifecycle."""
    session = get_snowpark_session(connection_name)
    try:
        yield session
    finally:
        session.close()
```

#### src/pipeline.py

```python
from datetime import date
from decimal import Decimal
from typing import Sequence

from snowflake.snowpark import Session, DataFrame
from snowflake.snowpark.functions import col, sum as sf_sum, count_distinct, lit

from src.connectors import snowpark_session
from src.models import MonthlyRevenueSummary, RevenueRecord, RevenueType
from src.transforms import apply_currency_conversion, calculate_monthly_revenue
from src.validators import validate_or_raise


class RevenuePipeline:
    def __init__(self, session: Session):
        self.session = session

    def extract_records(self, source_table: str, target_month: str) -> list[RevenueRecord]:
        """Pull raw revenue data from Snowflake."""
        df = self.session.table(source_table).filter(
            col("REVENUE_DATE").between(
                f"{target_month}-01",
                f"{target_month}-31",
            )
        )
        rows = df.collect()
        return [
            RevenueRecord(
                customer_id=row["CUSTOMER_ID"],
                revenue_date=row["REVENUE_DATE"],
                amount=Decimal(str(row["AMOUNT"])),
                revenue_type=RevenueType(row["REVENUE_TYPE"]),
                currency=row["CURRENCY"],
            )
            for row in rows
        ]

    def load_summary(self, summary: MonthlyRevenueSummary, target_table: str) -> None:
        """Write monthly summary back to Snowflake."""
        df = self.session.create_dataframe([{
            "YEAR_MONTH": summary.year_month,
            "TOTAL_REVENUE": float(summary.total_revenue),
            "SUBSCRIPTION_REVENUE": float(summary.subscription_revenue),
            "ONE_TIME_REVENUE": float(summary.one_time_revenue),
            "USAGE_REVENUE": float(summary.usage_revenue),
            "CUSTOMER_COUNT": summary.customer_count,
            "AVG_REVENUE_PER_CUSTOMER": float(summary.avg_revenue_per_customer),
        }])
        df.write.mode("append").save_as_table(target_table)

    def run(
        self,
        source_table: str,
        target_table: str,
        target_month: str,
        fx_rates: dict[str, Decimal] | None = None,
    ) -> MonthlyRevenueSummary:
        """Execute the full pipeline: extract -> validate -> transform -> load."""
        records = self.extract_records(source_table, target_month)

        validate_or_raise(records)

        if fx_rates:
            records = apply_currency_conversion(records, fx_rates)

        summary = calculate_monthly_revenue(records, target_month)
        self.load_summary(summary, target_table)

        return summary
```

### Test Code

#### tests/conftest.py

```python
import os
from datetime import date
from decimal import Decimal

import pytest
from snowflake.snowpark import Session

from src.models import RevenueRecord, RevenueType


# --- Markers for selective test execution ---
def pytest_configure(config):
    config.addinivalue_line("markers", "unit: Unit tests (no external deps)")
    config.addinivalue_line("markers", "integration: Requires Snowflake connection")
    config.addinivalue_line("markers", "e2e: Full pipeline execution")
    config.addinivalue_line("markers", "slow: Takes >5 seconds")


# --- Fixtures ---

@pytest.fixture
def sample_records() -> list[RevenueRecord]:
    """Standard set of revenue records for testing."""
    return [
        RevenueRecord(
            customer_id="CUST_001",
            revenue_date=date(2024, 11, 5),
            amount=Decimal("1500.00"),
            revenue_type=RevenueType.SUBSCRIPTION,
        ),
        RevenueRecord(
            customer_id="CUST_002",
            revenue_date=date(2024, 11, 12),
            amount=Decimal("750.50"),
            revenue_type=RevenueType.ONE_TIME,
        ),
        RevenueRecord(
            customer_id="CUST_003",
            revenue_date=date(2024, 11, 20),
            amount=Decimal("3200.00"),
            revenue_type=RevenueType.USAGE_BASED,
        ),
        RevenueRecord(
            customer_id="CUST_001",
            revenue_date=date(2024, 11, 28),
            amount=Decimal("1500.00"),
            revenue_type=RevenueType.SUBSCRIPTION,
        ),
        RevenueRecord(
            customer_id="CUST_004",
            revenue_date=date(2024, 12, 3),
            amount=Decimal("900.00"),
            revenue_type=RevenueType.SUBSCRIPTION,
        ),
    ]


@pytest.fixture
def fx_rates() -> dict[str, Decimal]:
    """Currency conversion rates."""
    return {
        "EUR_USD": Decimal("1.08"),
        "GBP_USD": Decimal("1.27"),
        "JPY_USD": Decimal("0.0067"),
        "CAD_USD": Decimal("0.74"),
    }


@pytest.fixture
def multi_currency_records() -> list[RevenueRecord]:
    """Records in various currencies."""
    return [
        RevenueRecord("CUST_EU", date(2024, 11, 1), Decimal("1000.00"), RevenueType.SUBSCRIPTION, "EUR"),
        RevenueRecord("CUST_UK", date(2024, 11, 1), Decimal("800.00"), RevenueType.ONE_TIME, "GBP"),
        RevenueRecord("CUST_US", date(2024, 11, 1), Decimal("1200.00"), RevenueType.USAGE_BASED, "USD"),
    ]


@pytest.fixture(scope="session")
def snowpark_test_session() -> Session:
    """Shared Snowpark session for integration tests."""
    session = Session.builder.config(
        "connection_name", os.environ.get("SNOWFLAKE_TEST_CONNECTION", "testing")
    ).create()
    yield session
    session.close()


@pytest.fixture
def test_schema(snowpark_test_session):
    """Create an ephemeral schema for test isolation."""
    import uuid
    schema_name = f"TEST_{uuid.uuid4().hex[:8].upper()}"
    snowpark_test_session.sql(f"CREATE SCHEMA IF NOT EXISTS {schema_name}").collect()
    snowpark_test_session.use_schema(schema_name)
    yield schema_name
    snowpark_test_session.sql(f"DROP SCHEMA IF EXISTS {schema_name} CASCADE").collect()
```

#### tests/unit/test_transforms.py

```python
from datetime import date
from decimal import Decimal

import pytest

from src.models import RevenueRecord, RevenueType
from src.transforms import (
    apply_currency_conversion,
    calculate_monthly_revenue,
    detect_anomalies,
)


@pytest.mark.unit
class TestCalculateMonthlyRevenue:
    """Tests for monthly revenue aggregation."""

    def test_aggregates_single_month(self, sample_records):
        result = calculate_monthly_revenue(sample_records, "2024-11")

        assert result.year_month == "2024-11"
        assert result.total_revenue == Decimal("6950.50")
        assert result.subscription_revenue == Decimal("3000.00")
        assert result.one_time_revenue == Decimal("750.50")
        assert result.usage_revenue == Decimal("3200.00")
        assert result.customer_count == 3

    def test_excludes_other_months(self, sample_records):
        result = calculate_monthly_revenue(sample_records, "2024-12")

        assert result.total_revenue == Decimal("900.00")
        assert result.customer_count == 1

    def test_empty_month_returns_zeros(self, sample_records):
        result = calculate_monthly_revenue(sample_records, "2025-01")

        assert result.total_revenue == Decimal("0")
        assert result.customer_count == 0
        assert result.avg_revenue_per_customer == Decimal("0")

    def test_average_revenue_rounds_correctly(self):
        records = [
            RevenueRecord("A", date(2024, 1, 1), Decimal("100.00"), RevenueType.SUBSCRIPTION),
            RevenueRecord("B", date(2024, 1, 1), Decimal("100.00"), RevenueType.SUBSCRIPTION),
            RevenueRecord("C", date(2024, 1, 1), Decimal("100.00"), RevenueType.SUBSCRIPTION),
        ]
        result = calculate_monthly_revenue(records, "2024-01")

        assert result.avg_revenue_per_customer == Decimal("100.00")

    def test_single_customer_multiple_records(self):
        records = [
            RevenueRecord("SAME", date(2024, 3, 1), Decimal("500.00"), RevenueType.SUBSCRIPTION),
            RevenueRecord("SAME", date(2024, 3, 15), Decimal("200.00"), RevenueType.USAGE_BASED),
        ]
        result = calculate_monthly_revenue(records, "2024-03")

        assert result.customer_count == 1
        assert result.total_revenue == Decimal("700.00")
        assert result.avg_revenue_per_customer == Decimal("700.00")


@pytest.mark.unit
class TestCurrencyConversion:
    """Tests for FX conversion logic."""

    def test_converts_eur_to_usd(self, multi_currency_records, fx_rates):
        result = apply_currency_conversion(multi_currency_records, fx_rates)

        eur_record = next(r for r in result if r.customer_id == "CUST_EU")
        assert eur_record.amount == Decimal("1080.00")
        assert eur_record.currency == "USD"

    def test_keeps_usd_unchanged(self, multi_currency_records, fx_rates):
        result = apply_currency_conversion(multi_currency_records, fx_rates)

        usd_record = next(r for r in result if r.customer_id == "CUST_US")
        assert usd_record.amount == Decimal("1200.00")

    def test_raises_on_missing_rate(self):
        records = [
            RevenueRecord("X", date(2024, 1, 1), Decimal("100"), RevenueType.ONE_TIME, "CHF"),
        ]
        with pytest.raises(KeyError, match="No conversion rate found for CHF_USD"):
            apply_currency_conversion(records, {"EUR_USD": Decimal("1.08")})

    def test_preserves_record_metadata(self, multi_currency_records, fx_rates):
        result = apply_currency_conversion(multi_currency_records, fx_rates)

        for original, converted in zip(multi_currency_records, result):
            assert converted.customer_id == original.customer_id
            assert converted.revenue_date == original.revenue_date
            assert converted.revenue_type == original.revenue_type


@pytest.mark.unit
class TestAnomalyDetection:
    """Tests for statistical anomaly detection."""

    def test_detects_high_outlier(self):
        records = [
            RevenueRecord("A", date(2024, 1, i), Decimal("100"), RevenueType.SUBSCRIPTION)
            for i in range(1, 11)
        ] + [
            RevenueRecord("B", date(2024, 1, 15), Decimal("10000"), RevenueType.ONE_TIME),
        ]
        anomalies = detect_anomalies(records, std_threshold=2.0)

        assert len(anomalies) == 1
        assert anomalies[0].customer_id == "B"

    def test_no_anomalies_in_uniform_data(self):
        records = [
            RevenueRecord(f"C{i}", date(2024, 1, i), Decimal("100"), RevenueType.SUBSCRIPTION)
            for i in range(1, 20)
        ]
        anomalies = detect_anomalies(records)
        assert anomalies == []

    def test_returns_empty_for_small_dataset(self):
        records = [
            RevenueRecord("A", date(2024, 1, 1), Decimal("100"), RevenueType.SUBSCRIPTION),
            RevenueRecord("B", date(2024, 1, 2), Decimal("99999"), RevenueType.ONE_TIME),
        ]
        assert detect_anomalies(records) == []

    def test_custom_threshold(self):
        records = [
            RevenueRecord(f"C{i}", date(2024, 1, i), Decimal("100"), RevenueType.SUBSCRIPTION)
            for i in range(1, 10)
        ] + [
            RevenueRecord("X", date(2024, 1, 20), Decimal("250"), RevenueType.ONE_TIME),
        ]
        strict = detect_anomalies(records, std_threshold=1.0)
        lenient = detect_anomalies(records, std_threshold=3.0)

        assert len(strict) >= len(lenient)
```

#### tests/unit/test_validators.py

```python
from datetime import date, timedelta
from decimal import Decimal

import pytest
from freezegun import freeze_time

from src.models import RevenueRecord, RevenueType
from src.validators import ValidationError, validate_or_raise, validate_revenue_batch


@pytest.mark.unit
class TestValidateRevenueBatch:

    @freeze_time("2024-11-30")
    def test_valid_batch_returns_no_errors(self, sample_records):
        errors = validate_revenue_batch(sample_records)
        assert errors == []

    @freeze_time("2024-11-30")
    def test_detects_duplicate_records(self):
        record = RevenueRecord("CUST_1", date(2024, 11, 1), Decimal("100"), RevenueType.SUBSCRIPTION)
        errors = validate_revenue_batch([record, record])

        assert len(errors) == 1
        assert "Duplicate" in errors[0]

    @freeze_time("2024-11-30")
    def test_detects_excessive_amount(self):
        record = RevenueRecord("CUST_1", date(2024, 11, 1), Decimal("2000000"), RevenueType.ONE_TIME)
        errors = validate_revenue_batch([record])

        assert len(errors) == 1
        assert "exceeds maximum" in errors[0]

    @freeze_time("2024-11-30")
    def test_detects_future_date(self):
        future = date(2024, 12, 15)
        record = RevenueRecord("CUST_1", future, Decimal("100"), RevenueType.SUBSCRIPTION)
        errors = validate_revenue_batch([record])

        assert len(errors) == 1
        assert "Future date" in errors[0]

    @freeze_time("2024-11-30")
    def test_detects_stale_record(self):
        old_date = date(2024, 7, 1)  # >90 days before 2024-11-30
        record = RevenueRecord("CUST_1", old_date, Decimal("100"), RevenueType.SUBSCRIPTION)
        errors = validate_revenue_batch([record])

        assert len(errors) == 1
        assert "older than" in errors[0]

    @freeze_time("2024-11-30")
    def test_custom_max_amount(self):
        record = RevenueRecord("CUST_1", date(2024, 11, 1), Decimal("5000"), RevenueType.ONE_TIME)

        errors_default = validate_revenue_batch([record], max_amount=Decimal("1000000"))
        errors_strict = validate_revenue_batch([record], max_amount=Decimal("1000"))

        assert len(errors_default) == 0
        assert len(errors_strict) == 1

    @freeze_time("2024-11-30")
    def test_validate_or_raise_throws(self):
        record = RevenueRecord("CUST_1", date(2024, 11, 1), Decimal("9999999"), RevenueType.ONE_TIME)

        with pytest.raises(ValidationError) as exc_info:
            validate_or_raise([record])

        assert len(exc_info.value.errors) == 1

    @freeze_time("2024-11-30")
    def test_multiple_errors_collected(self):
        records = [
            RevenueRecord("CUST_1", date(2024, 11, 1), Decimal("9999999"), RevenueType.ONE_TIME),
            RevenueRecord("CUST_2", date(2025, 6, 1), Decimal("100"), RevenueType.SUBSCRIPTION),
        ]
        errors = validate_revenue_batch(records)
        assert len(errors) == 2
```

#### tests/unit/test_models.py

```python
from datetime import date
from decimal import Decimal

import pytest

from src.models import RevenueRecord, RevenueType


@pytest.mark.unit
class TestRevenueRecord:

    def test_valid_record_creation(self):
        record = RevenueRecord(
            customer_id="CUST_001",
            revenue_date=date(2024, 11, 1),
            amount=Decimal("1500.00"),
            revenue_type=RevenueType.SUBSCRIPTION,
        )
        assert record.customer_id == "CUST_001"
        assert record.amount == Decimal("1500.00")
        assert record.currency == "USD"

    def test_rejects_negative_amount(self):
        with pytest.raises(ValueError, match="cannot be negative"):
            RevenueRecord("CUST_1", date(2024, 1, 1), Decimal("-100"), RevenueType.ONE_TIME)

    def test_rejects_empty_customer_id(self):
        with pytest.raises(ValueError, match="cannot be empty"):
            RevenueRecord("   ", date(2024, 1, 1), Decimal("100"), RevenueType.SUBSCRIPTION)

    def test_zero_amount_allowed(self):
        record = RevenueRecord("CUST_1", date(2024, 1, 1), Decimal("0"), RevenueType.USAGE_BASED)
        assert record.amount == Decimal("0")

    def test_frozen_dataclass_immutable(self):
        record = RevenueRecord("CUST_1", date(2024, 1, 1), Decimal("100"), RevenueType.SUBSCRIPTION)
        with pytest.raises(AttributeError):
            record.amount = Decimal("200")

    def test_enum_values(self):
        assert RevenueType.SUBSCRIPTION.value == "SUBSCRIPTION"
        assert RevenueType.ONE_TIME.value == "ONE_TIME"
        assert RevenueType.USAGE_BASED.value == "USAGE_BASED"
```

#### tests/integration/test_pipeline.py

```python
from datetime import date
from decimal import Decimal

import pytest
from snowflake.snowpark import Session

from src.models import RevenueType
from src.pipeline import RevenuePipeline


@pytest.mark.integration
@pytest.mark.slow
class TestRevenuePipelineIntegration:
    """Integration tests that execute against a real Snowflake instance."""

    @pytest.fixture(autouse=True)
    def setup_test_data(self, snowpark_test_session: Session, test_schema: str):
        """Seed test tables with known data."""
        self.session = snowpark_test_session
        self.schema = test_schema

        self.session.sql(f"""
            CREATE OR REPLACE TABLE {test_schema}.RAW_REVENUE (
                CUSTOMER_ID VARCHAR,
                REVENUE_DATE DATE,
                AMOUNT NUMBER(18,2),
                REVENUE_TYPE VARCHAR,
                CURRENCY VARCHAR DEFAULT 'USD'
            )
        """).collect()

        self.session.sql(f"""
            INSERT INTO {test_schema}.RAW_REVENUE VALUES
            ('CUST_001', '2024-11-05', 1500.00, 'SUBSCRIPTION', 'USD'),
            ('CUST_002', '2024-11-12', 750.50, 'ONE_TIME', 'USD'),
            ('CUST_003', '2024-11-20', 3200.00, 'USAGE_BASED', 'USD'),
            ('CUST_001', '2024-11-28', 1500.00, 'SUBSCRIPTION', 'USD')
        """).collect()

        self.session.sql(f"""
            CREATE OR REPLACE TABLE {test_schema}.MONTHLY_SUMMARY (
                YEAR_MONTH VARCHAR,
                TOTAL_REVENUE FLOAT,
                SUBSCRIPTION_REVENUE FLOAT,
                ONE_TIME_REVENUE FLOAT,
                USAGE_REVENUE FLOAT,
                CUSTOMER_COUNT INT,
                AVG_REVENUE_PER_CUSTOMER FLOAT
            )
        """).collect()

    def test_extract_returns_correct_records(self):
        pipeline = RevenuePipeline(self.session)
        records = pipeline.extract_records(f"{self.schema}.RAW_REVENUE", "2024-11")

        assert len(records) == 4
        assert all(r.revenue_date.month == 11 for r in records)

    def test_full_pipeline_run(self):
        pipeline = RevenuePipeline(self.session)
        summary = pipeline.run(
            source_table=f"{self.schema}.RAW_REVENUE",
            target_table=f"{self.schema}.MONTHLY_SUMMARY",
            target_month="2024-11",
        )

        assert summary.total_revenue == Decimal("6950.50")
        assert summary.customer_count == 3

        rows = self.session.table(f"{self.schema}.MONTHLY_SUMMARY").collect()
        assert len(rows) == 1
        assert rows[0]["YEAR_MONTH"] == "2024-11"

    def test_pipeline_with_fx_conversion(self):
        self.session.sql(f"""
            INSERT INTO {self.schema}.RAW_REVENUE VALUES
            ('CUST_EU', '2024-11-10', 1000.00, 'SUBSCRIPTION', 'EUR')
        """).collect()

        pipeline = RevenuePipeline(self.session)
        summary = pipeline.run(
            source_table=f"{self.schema}.RAW_REVENUE",
            target_table=f"{self.schema}.MONTHLY_SUMMARY",
            target_month="2024-11",
            fx_rates={"EUR_USD": Decimal("1.08")},
        )

        assert summary.customer_count == 4
        assert summary.total_revenue > Decimal("6950.50")
```

#### tests/e2e/test_full_pipeline.py

```python
from datetime import date
from decimal import Decimal

import pytest
from snowflake.snowpark import Session

from src.connectors import snowpark_session
from src.pipeline import RevenuePipeline


@pytest.mark.e2e
@pytest.mark.slow
class TestEndToEndPipeline:
    """Full end-to-end tests simulating production execution."""

    @pytest.fixture(autouse=True)
    def setup_production_like_env(self, snowpark_test_session: Session, test_schema: str):
        self.session = snowpark_test_session
        self.schema = test_schema

        self.session.sql(f"""
            CREATE OR REPLACE TABLE {test_schema}.RAW_REVENUE AS
            SELECT
                'CUST_' || LPAD(SEQ4()::VARCHAR, 4, '0') AS CUSTOMER_ID,
                DATEADD(DAY, MOD(SEQ4(), 30), '2024-11-01')::DATE AS REVENUE_DATE,
                ROUND(UNIFORM(50, 5000, RANDOM())::NUMERIC(18,2), 2) AS AMOUNT,
                CASE MOD(SEQ4(), 3)
                    WHEN 0 THEN 'SUBSCRIPTION'
                    WHEN 1 THEN 'ONE_TIME'
                    ELSE 'USAGE_BASED'
                END AS REVENUE_TYPE,
                'USD' AS CURRENCY
            FROM TABLE(GENERATOR(ROWCOUNT => 1000))
        """).collect()

        self.session.sql(f"""
            CREATE OR REPLACE TABLE {test_schema}.MONTHLY_SUMMARY (
                YEAR_MONTH VARCHAR,
                TOTAL_REVENUE FLOAT,
                SUBSCRIPTION_REVENUE FLOAT,
                ONE_TIME_REVENUE FLOAT,
                USAGE_REVENUE FLOAT,
                CUSTOMER_COUNT INT,
                AVG_REVENUE_PER_CUSTOMER FLOAT
            )
        """).collect()

    def test_pipeline_handles_1000_records(self):
        pipeline = RevenuePipeline(self.session)
        summary = pipeline.run(
            source_table=f"{self.schema}.RAW_REVENUE",
            target_table=f"{self.schema}.MONTHLY_SUMMARY",
            target_month="2024-11",
        )

        assert summary.customer_count > 0
        assert summary.total_revenue > Decimal("0")
        assert summary.year_month == "2024-11"

        result = self.session.table(f"{self.schema}.MONTHLY_SUMMARY").collect()
        assert len(result) == 1

    def test_idempotent_reruns_append(self):
        pipeline = RevenuePipeline(self.session)

        pipeline.run(
            source_table=f"{self.schema}.RAW_REVENUE",
            target_table=f"{self.schema}.MONTHLY_SUMMARY",
            target_month="2024-11",
        )
        pipeline.run(
            source_table=f"{self.schema}.RAW_REVENUE",
            target_table=f"{self.schema}.MONTHLY_SUMMARY",
            target_month="2024-11",
        )

        rows = self.session.table(f"{self.schema}.MONTHLY_SUMMARY").collect()
        assert len(rows) == 2  # Append mode creates duplicates — verify behavior

    def test_empty_month_produces_zero_summary(self):
        pipeline = RevenuePipeline(self.session)
        summary = pipeline.run(
            source_table=f"{self.schema}.RAW_REVENUE",
            target_table=f"{self.schema}.MONTHLY_SUMMARY",
            target_month="2025-06",
        )

        assert summary.total_revenue == Decimal("0")
        assert summary.customer_count == 0
```

---

## Running the Example

### Step 1: Configure Tests

1. Open Cortex Code Desktop and open the `snowflake_revenue_pipeline/` folder.
2. `Cmd+Shift+P` > **"Python: Configure Tests"** > select **pytest** > select `tests/`.

### Step 2: Run Unit Tests Only

```bash
# From terminal, or use the Testing panel with filter:
pytest tests/unit/ -m unit -v
```

In the Testing panel, you can right-click the `unit/` folder > "Run Tests".

### Step 3: Debug a Failing Test

1. Set a breakpoint inside `calculate_monthly_revenue` in `src/transforms.py`.
2. In the Testing panel, find `test_aggregates_single_month`.
3. Click the **bug icon** to start debugging.
4. Step through the aggregation logic, inspect `by_type` and `customers` variables.

### Step 4: Run with Coverage

1. Click the **shield icon** in the Testing panel.
2. Review the terminal output for coverage percentage.
3. `Cmd+Shift+P` > **"Coverage Gutters: Display Coverage"** to see inline highlights.

### Step 5: Sort and Triage

1. After running all tests, click **Sort by Status** — any failures surface to the top.
2. Switch to **Sort by Duration** — identify if integration tests are the bottleneck.
3. Use **List View** to quickly scan all 25+ tests in a flat format.

### Step 6: Run Integration Tests (requires Snowflake connection)

```bash
pytest tests/integration/ -m integration -v --timeout=120
```

Ensure your `.env.test` has `SNOWFLAKE_TEST_CONNECTION=testing` pointing to a valid connection in `~/.snowflake/connections.toml`.

---

## Summary of Testing Panel Actions

| Icon/Action | What It Does |
|-------------|--------------|
| Play (triangle) | Run selected test(s) |
| Bug (beetle) | Debug selected test(s) with breakpoints |
| Shield | Run with code coverage |
| Circular arrow | Refresh / re-discover tests |
| Collapse (double arrow) | Collapse all tree nodes |
| Clear (eraser) | Clear all pass/fail results |
| Sort dropdown | Switch between Duration / Location / Status |
| List/Tree toggle | Switch between flat list and hierarchical tree |
| Output (terminal) | Show detailed test output and logs |

---

## Best Practices

1. **Mark tests with markers** (`@pytest.mark.unit`, `@pytest.mark.integration`) so you can run subsets from the Testing panel.
2. **Use ephemeral schemas** for integration tests to ensure full isolation.
3. **Freeze time** in unit tests with `freezegun` to avoid flaky date-dependent assertions.
4. **Set timeouts** to prevent hung Snowflake queries from blocking your test suite.
5. **Run unit tests continuously** (auto-discover on save) and integration tests before PRs.
6. **Use coverage thresholds** (`fail_under = 85`) to prevent coverage regression.
7. **Sort by duration** periodically to catch tests that have become slow over time.
