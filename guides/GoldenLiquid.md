# Golden Liquid Test Suite Integration Guide

This guide documents the integration of the [golden-liquid](https://github.com/jg-rp/golden-liquid) test suite into LiquidKit. It's intended for future development sessions to quickly understand the test infrastructure.

## Overview

Golden-liquid is a comprehensive, standardized test suite for Liquid template engine implementations. We've integrated all 1012 test cases to measure and improve LiquidKit's spec compliance.

## Repository Structure

The golden-liquid repository contains:
- `golden_liquid.json` - Main test suite with 1012 test cases
- `golden_liquid.schema.json` - JSON schema for test case validation
- `benchmark_fixtures/` - Performance testing scenarios (not yet integrated)

## Test Case Format

Each test case in `golden_liquid.json` follows this structure:

```json
{
  "name": "unique test identifier",
  "template": "{{ liquid template string }}",
  "data": {
    // Optional: Context variables for rendering
  },
  "templates": {
    // Optional: Additional named templates (for include/render tags)
    "partial_name": "partial template content"
  },
  // One of these three outcomes:
  "result": "expected output string",
  "results": ["acceptable output 1", "acceptable output 2"],
  "invalid": true,
  
  "tags": ["filter_name", "tag_name", "category"]
}
```

### Key Points:
- Every test has `name` and `template`
- Exactly one outcome field must be present: `result`, `results`, or `invalid`
- `data` contains arbitrary JSON that becomes the template's context
- `templates` provides named partials for include/render tags
- `tags` categorize tests (59 filters, 20 tags, plus special categories)

## Integration Architecture

### 1. Data Model (`GoldenLiquidTestCase.swift`)
- Swift struct that mirrors the JSON format
- Converts JSON data to LiquidKit's `Token.Value` types
- Provides an `Outcome` enum for the three result types
- Includes helper methods for validation and context creation

### 2. Test Infrastructure

#### Parse Tests (`GoldenLiquidParseTests.swift`)
- 13 tests validating JSON parsing
- Covers all data types and edge cases
- Ensures our model correctly represents the test format

#### Data Tests (`GoldenLiquidDataTests.swift`)
- Verifies resource loading from bundle
- Confirms all 1012 tests load correctly
- Tests tag filtering functionality

#### Validation Tests (`GoldenLiquidValidationTests.swift`)
- Data-driven tests using Swift Testing
- Organized by tag categories
- Runs actual Liquid rendering and validates output
- Provides detailed failure diagnostics

#### Quick Tests (`GoldenLiquidQuickTests.swift`)
- Safe test runner that catches crashes
- Samples tests from each category
- Good for quick compatibility checks

#### Summary Test (`GoldenLiquidSummaryTest.swift`)
- Analyzes test distribution without execution
- Identifies missing features
- Provides implementation roadmap

## Test Categories

The suite uses 81 unique tags, including:

### Filters (59 total)
Common ones: `abs`, `append`, `capitalize`, `date`, `downcase`, `escape`, `first`, `join`, `last`, `map`, `plus`, `remove`, `replace`, `reverse`, `size`, `sort`, `split`, `strip`, `times`, `truncate`, `uniq`, `upcase`, etc.

### Tags (20 total)
- Control flow: `if tag`, `unless tag`, `elsif tag`, `else tag`, `case tag`, `when tag`
- Loops: `for tag`, `break tag`, `continue tag`
- Variables: `assign tag`, `capture tag`
- Output: `echo tag` (missing), `liquid tag` (missing)
- Templates: `include tag`, `render tag` (missing)
- Counters: `increment tag` (missing), `decrement tag` (missing)
- Others: `comment tag`, `raw tag`, `ifchanged tag` (missing), `tablerow tag` (missing), `cycle tag` (missing)

### Special Categories
- `strict` - Tests that require strict error handling
- `absent` - Tests handling missing/nil values
- `utc` - Date tests requiring UTC timezone

## Known Gaps in LiquidKit

Based on test analysis, LiquidKit is missing:

1. **Tags**: echo, liquid, render, increment, decrement, ifchanged, tablerow, cycle
2. **Features**:
   - Variable array indexing (e.g., `array[i]` where i is a variable)
   - Bracket notation for objects (e.g., `obj['key']`)
   - Proper filter argument validation
   - Some edge cases in existing filters

## Usage

### Run All Tests
```bash
swift test --filter GoldenLiquidValidationTests
```

### Run Specific Category
```bash
swift test --filter "GoldenLiquidValidationTests/testDateFilter"
```

### Check Quick Compatibility
```bash
swift test --filter GoldenLiquidQuickTests
```

### Analyze Test Distribution
```bash
swift test --filter GoldenLiquidSummaryTest
```

## Adding New Features

When implementing missing features:

1. Run the summary test to see which tests cover the feature
2. Run those specific validation tests to see current failures
3. Implement the feature
4. Re-run tests to verify compliance
5. The detailed error messages show exactly what's expected

## Performance Considerations

- Loading all 1012 tests takes ~12ms
- Individual test execution varies by complexity
- Benchmark fixtures available for performance testing (not yet integrated)

## Future Enhancements

1. Integrate benchmark fixtures for performance testing
2. Add continuous tracking of compliance percentage
3. Generate compatibility reports
4. Add visual test result browser

## Resources

- [Golden Liquid Repository](https://github.com/jg-rp/golden-liquid)
- [Liquid Documentation](https://shopify.github.io/liquid/)
- [Swift Testing Documentation](https://developer.apple.com/documentation/testing)