import Testing
@testable import LiquidKit

@Suite("FloorFilter", .tags(.filter, .floorFilter))
struct FloorFilterTests {
    
    // MARK: - Numeric Values
    
    @Test("Positive integers remain unchanged")
    func testPositiveIntegers() throws {
        // Integers should remain unchanged
        try validateEvaluation(of: .integer(5), by: FloorFilter(), yields: .integer(5))
        try validateEvaluation(of: .integer(100), by: FloorFilter(), yields: .integer(100))
        try validateEvaluation(of: .integer(0), by: FloorFilter(), yields: .integer(0))
    }
    
    @Test("Negative integers remain unchanged")
    func testNegativeIntegers() throws {
        // Negative integers should remain unchanged
        try validateEvaluation(of: .integer(-5), by: FloorFilter(), yields: .integer(-5))
        try validateEvaluation(of: .integer(-100), by: FloorFilter(), yields: .integer(-100))
    }
    
    @Test("Positive decimals round down")
    func testPositiveDecimals() throws {
        // Positive decimals should round down (toward zero)
        try validateEvaluation(of: .decimal(5.4), by: FloorFilter(), yields: .integer(5))
        try validateEvaluation(of: .decimal(5.9), by: FloorFilter(), yields: .integer(5))
        try validateEvaluation(of: .decimal(1.2), by: FloorFilter(), yields: .integer(1))
        try validateEvaluation(of: .decimal(183.357), by: FloorFilter(), yields: .integer(183))
        try validateEvaluation(of: .decimal(0.9), by: FloorFilter(), yields: .integer(0))
    }
    
    @Test("Negative decimals round down (away from zero)")
    func testNegativeDecimals() throws {
        // Negative decimals should round down (away from zero)
        try validateEvaluation(of: .decimal(-5.4), by: FloorFilter(), yields: .integer(-6))
        try validateEvaluation(of: .decimal(-5.1), by: FloorFilter(), yields: .integer(-6))
        try validateEvaluation(of: .decimal(-0.1), by: FloorFilter(), yields: .integer(-1))
        try validateEvaluation(of: .decimal(-3.1), by: FloorFilter(), yields: .integer(-4))
    }
    
    @Test("Decimals with no fractional part")
    func testDecimalsWithoutFraction() throws {
        // Decimals that are whole numbers
        try validateEvaluation(of: .decimal(2.0), by: FloorFilter(), yields: .integer(2))
        try validateEvaluation(of: .decimal(-2.0), by: FloorFilter(), yields: .integer(-2))
        try validateEvaluation(of: .decimal(0.0), by: FloorFilter(), yields: .integer(0))
    }
    
    // MARK: - String Conversion
    
    @Test("Numeric strings are converted")
    func testNumericStrings() throws {
        // Strings representing numbers should be converted
        try validateEvaluation(of: .string("5.4"), by: FloorFilter(), yields: .integer(5))
        try validateEvaluation(of: .string("3.5"), by: FloorFilter(), yields: .integer(3))
        try validateEvaluation(of: .string("-5.4"), by: FloorFilter(), yields: .integer(-6))
        try validateEvaluation(of: .string("100"), by: FloorFilter(), yields: .integer(100))
        try validateEvaluation(of: .string("-100"), by: FloorFilter(), yields: .integer(-100))
        try validateEvaluation(of: .string("0"), by: FloorFilter(), yields: .integer(0))
    }
    
    @Test("Numeric strings with whitespace")
    func testNumericStringsWithWhitespace() throws {
        // Strings with leading/trailing whitespace
        try validateEvaluation(of: .string(" 5.4 "), by: FloorFilter(), yields: .integer(5))
        try validateEvaluation(of: .string("\t-3.1\n"), by: FloorFilter(), yields: .integer(-4))
        try validateEvaluation(of: .string("  100  "), by: FloorFilter(), yields: .integer(100))
    }
    
    @Test("Scientific notation strings")
    func testScientificNotationStrings() throws {
        // Scientific notation should be supported
        try validateEvaluation(of: .string("1e2"), by: FloorFilter(), yields: .integer(100))
        try validateEvaluation(of: .string("1.5e2"), by: FloorFilter(), yields: .integer(150))
        try validateEvaluation(of: .string("-1.5e2"), by: FloorFilter(), yields: .integer(-150))
    }
    
    // MARK: - Non-Numeric Values
    
    @Test("Non-numeric strings return 0")
    func testNonNumericStrings() throws {
        // Non-numeric strings should return 0 (per python-liquid)
        try validateEvaluation(of: .string("hello"), by: FloorFilter(), yields: .integer(0))
        try validateEvaluation(of: .string("abc123"), by: FloorFilter(), yields: .integer(0))
        try validateEvaluation(of: .string(""), by: FloorFilter(), yields: .integer(0))
        try validateEvaluation(of: .string("  "), by: FloorFilter(), yields: .integer(0))
    }
    
    @Test("Invalid numeric formats return 0")
    func testInvalidNumericFormats() throws {
        // Invalid number formats should return 0
        try validateEvaluation(of: .string("12.34.56"), by: FloorFilter(), yields: .integer(0))
        try validateEvaluation(of: .string("infinity"), by: FloorFilter(), yields: .integer(0))
        try validateEvaluation(of: .string("Infinity"), by: FloorFilter(), yields: .integer(0))
        try validateEvaluation(of: .string("-infinity"), by: FloorFilter(), yields: .integer(0))
        try validateEvaluation(of: .string("nan"), by: FloorFilter(), yields: .integer(0))
        try validateEvaluation(of: .string("NaN"), by: FloorFilter(), yields: .integer(0))
    }
    
    @Test("Nil returns 0")
    func testNil() throws {
        // Nil should return 0 (per python-liquid)
        try validateEvaluation(of: .nil, by: FloorFilter(), yields: .integer(0))
    }
    
    @Test("Boolean values return 0")
    func testBooleans() throws {
        // Booleans should return 0
        try validateEvaluation(of: .bool(true), by: FloorFilter(), yields: .integer(0))
        try validateEvaluation(of: .bool(false), by: FloorFilter(), yields: .integer(0))
    }
    
    @Test("Arrays return 0")
    func testArrays() throws {
        // Arrays should return 0
        try validateEvaluation(of: .array([.integer(1), .integer(2)]), by: FloorFilter(), yields: .integer(0))
        try validateEvaluation(of: .array([]), by: FloorFilter(), yields: .integer(0))
    }
    
    @Test("Dictionaries return 0")
    func testDictionaries() throws {
        // Dictionaries should return 0
        try validateEvaluation(of: .dictionary(["key": .string("value")]), by: FloorFilter(), yields: .integer(0))
        try validateEvaluation(of: .dictionary([:]), by: FloorFilter(), yields: .integer(0))
    }
    
    @Test("Ranges return 0")
    func testRanges() throws {
        // Ranges should return 0
        try validateEvaluation(of: .range(1...5), by: FloorFilter(), yields: .integer(0))
    }
    
    // MARK: - Edge Cases
    
    @Test("Very large numbers")
    func testLargeNumbers() throws {
        // Test with large numbers
        try validateEvaluation(of: .decimal(999999999.9), by: FloorFilter(), yields: .integer(999999999))
        try validateEvaluation(of: .decimal(-999999999.1), by: FloorFilter(), yields: .integer(-1000000000))
    }
    
    @Test("Very small fractional parts")
    func testSmallFractions() throws {
        // Test with very small fractional parts
        try validateEvaluation(of: .decimal(5.00001), by: FloorFilter(), yields: .integer(5))
        try validateEvaluation(of: .decimal(-5.00001), by: FloorFilter(), yields: .integer(-6))
        try validateEvaluation(of: .decimal(0.00001), by: FloorFilter(), yields: .integer(0))
        try validateEvaluation(of: .decimal(-0.00001), by: FloorFilter(), yields: .integer(-1))
    }
    
    // MARK: - Parameter Handling
    
    @Test("Extra parameters are ignored")
    func testExtraParameters() throws {
        // The filter should ignore extra parameters
        try validateEvaluation(of: .decimal(5.4), with: [.integer(1)], by: FloorFilter(), yields: .integer(5))
        try validateEvaluation(of: .decimal(5.4), with: [.string("hello"), .integer(2)], by: FloorFilter(), yields: .integer(5))
    }
}

