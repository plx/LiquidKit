import Testing
@testable import LiquidKit

@Suite("RoundFilter", .tags(.filter, .roundFilter))
struct RoundFilterTests {
    
    // MARK: - Basic Rounding (No Precision)
    
    @Test("Positive decimals round to nearest integer")
    func testPositiveDecimalsBasicRounding() throws {
        // Standard rounding rules
        try validateEvaluation(of: .decimal(1.2), by: RoundFilter(), yields: .integer(1))
        try validateEvaluation(of: .decimal(2.7), by: RoundFilter(), yields: .integer(3))
        try validateEvaluation(of: .decimal(5.5), by: RoundFilter(), yields: .integer(6))
        try validateEvaluation(of: .decimal(5.4), by: RoundFilter(), yields: .integer(5))
        try validateEvaluation(of: .decimal(5.6), by: RoundFilter(), yields: .integer(6))
    }
    
    @Test("Negative decimals round to nearest integer")
    func testNegativeDecimalsBasicRounding() throws {
        // Standard rounding rules for negative numbers
        try validateEvaluation(of: .decimal(-1.2), by: RoundFilter(), yields: .integer(-1))
        try validateEvaluation(of: .decimal(-2.7), by: RoundFilter(), yields: .integer(-3))
        try validateEvaluation(of: .decimal(-5.5), by: RoundFilter(), yields: .integer(-6))
        try validateEvaluation(of: .decimal(-5.4), by: RoundFilter(), yields: .integer(-5))
        try validateEvaluation(of: .decimal(-5.6), by: RoundFilter(), yields: .integer(-6))
    }
    
    @Test("Integers remain unchanged")
    func testIntegersUnchanged() throws {
        // Integers should remain unchanged
        try validateEvaluation(of: .integer(5), by: RoundFilter(), yields: .integer(5))
        try validateEvaluation(of: .integer(-5), by: RoundFilter(), yields: .integer(-5))
        try validateEvaluation(of: .integer(0), by: RoundFilter(), yields: .integer(0))
        try validateEvaluation(of: .integer(100), by: RoundFilter(), yields: .integer(100))
        try validateEvaluation(of: .integer(-100), by: RoundFilter(), yields: .integer(-100))
    }
    
    @Test("Decimals with no fractional part")
    func testWholeNumberDecimals() throws {
        // Decimals that are whole numbers
        try validateEvaluation(of: .decimal(2.0), by: RoundFilter(), yields: .integer(2))
        try validateEvaluation(of: .decimal(-2.0), by: RoundFilter(), yields: .integer(-2))
        try validateEvaluation(of: .decimal(0.0), by: RoundFilter(), yields: .integer(0))
    }
    
    // MARK: - Rounding with Precision
    
    @Test("Positive precision rounds to decimal places")
    func testPositivePrecision() throws {
        // Round to specified decimal places
        try validateEvaluation(of: .decimal(183.357), with: [.integer(2)], by: RoundFilter(), yields: .decimal(183.36))
        try validateEvaluation(of: .decimal(5.666666), with: [.integer(2)], by: RoundFilter(), yields: .decimal(5.67))
        try validateEvaluation(of: .decimal(5.666), with: [.integer(1)], by: RoundFilter(), yields: .decimal(5.7))
        try validateEvaluation(of: .decimal(1.234567), with: [.integer(4)], by: RoundFilter(), yields: .decimal(1.2346))
        try validateEvaluation(of: .decimal(5.5), with: [.integer(1)], by: RoundFilter(), yields: .decimal(5.5))
    }
    
    @Test("Zero precision is same as no precision")
    func testZeroPrecision() throws {
        // Zero precision should round to integer
        try validateEvaluation(of: .decimal(5.6), with: [.integer(0)], by: RoundFilter(), yields: .integer(6))
        try validateEvaluation(of: .decimal(5.4), with: [.integer(0)], by: RoundFilter(), yields: .integer(5))
        try validateEvaluation(of: .decimal(-5.6), with: [.integer(0)], by: RoundFilter(), yields: .integer(-6))
    }
    
    @Test("Negative precision rounds to powers of 10")
    func testNegativePrecision() throws {
        // Negative precision rounds to tens, hundreds, etc.
        try validateEvaluation(of: .decimal(125.6), with: [.integer(-1)], by: RoundFilter(), yields: .integer(130))
        try validateEvaluation(of: .decimal(125.6), with: [.integer(-2)], by: RoundFilter(), yields: .integer(100))
        try validateEvaluation(of: .decimal(555.5), with: [.integer(-1)], by: RoundFilter(), yields: .integer(560))
        try validateEvaluation(of: .decimal(555.5), with: [.integer(-2)], by: RoundFilter(), yields: .integer(600))
        try validateEvaluation(of: .decimal(5.666), with: [.integer(-2)], by: RoundFilter(), yields: .integer(0))
        try validateEvaluation(of: .decimal(1234.5), with: [.integer(-3)], by: RoundFilter(), yields: .integer(1000))
    }
    
    @Test("High precision values")
    func testHighPrecision() throws {
        // Test with high precision values
        try validateEvaluation(of: .decimal(1.23456789), with: [.integer(6)], by: RoundFilter(), yields: .decimal(1.234568))
        try validateEvaluation(of: .decimal(1.23456789), with: [.integer(8)], by: RoundFilter(), yields: .decimal(1.23456789))
    }
    
    // MARK: - String Conversion
    
    @Test("Numeric strings are converted and rounded")
    func testNumericStrings() throws {
        // Strings representing numbers should be converted
        try validateEvaluation(of: .string("5.6"), by: RoundFilter(), yields: .integer(6))
        try validateEvaluation(of: .string("5.4"), by: RoundFilter(), yields: .integer(5))
        try validateEvaluation(of: .string("3.5"), by: RoundFilter(), yields: .integer(4))
        try validateEvaluation(of: .string("-5.6"), by: RoundFilter(), yields: .integer(-6))
        try validateEvaluation(of: .string("100"), by: RoundFilter(), yields: .integer(100))
        try validateEvaluation(of: .string("-100"), by: RoundFilter(), yields: .integer(-100))
        try validateEvaluation(of: .string("0"), by: RoundFilter(), yields: .integer(0))
    }
    
    @Test("Numeric strings with precision parameter")
    func testNumericStringsWithPrecision() throws {
        // String inputs with precision
        try validateEvaluation(of: .string("5.666"), with: [.integer(1)], by: RoundFilter(), yields: .decimal(5.7))
        try validateEvaluation(of: .string("5.666"), with: [.string("1")], by: RoundFilter(), yields: .decimal(5.7))
    }
    
    @Test("String precision parameters")
    func testStringPrecisionParameters() throws {
        // Precision parameter as string
        try validateEvaluation(of: .decimal(5.666), with: [.string("1")], by: RoundFilter(), yields: .decimal(5.7))
        try validateEvaluation(of: .decimal(5.666), with: [.string("2")], by: RoundFilter(), yields: .decimal(5.67))
        try validateEvaluation(of: .decimal(5.666), with: [.string("-1")], by: RoundFilter(), yields: .integer(10))
    }
    
    @Test("Numeric strings with whitespace")
    func testNumericStringsWithWhitespace() throws {
        // Strings with leading/trailing whitespace
        try validateEvaluation(of: .string(" 5.6 "), by: RoundFilter(), yields: .integer(6))
        try validateEvaluation(of: .string("\t-3.5\n"), by: RoundFilter(), yields: .integer(-4))
        try validateEvaluation(of: .string("  100  "), by: RoundFilter(), yields: .integer(100))
    }
    
    @Test("Scientific notation strings")
    func testScientificNotationStrings() throws {
        // Scientific notation should be supported
        try validateEvaluation(of: .string("1e2"), by: RoundFilter(), yields: .integer(100))
        try validateEvaluation(of: .string("1.5e2"), by: RoundFilter(), yields: .integer(150))
        try validateEvaluation(of: .string("-1.5e2"), by: RoundFilter(), yields: .integer(-150))
        try validateEvaluation(of: .string("1.234e3"), with: [.integer(1)], by: RoundFilter(), yields: .decimal(1234.0))
    }
    
    // MARK: - Non-Numeric Values
    
    @Test("Non-numeric strings return 0")
    func testNonNumericStrings() throws {
        // Non-numeric strings should return 0 (per python-liquid)
        try validateEvaluation(of: .string("hello"), by: RoundFilter(), yields: .integer(0))
        try validateEvaluation(of: .string("abc123"), by: RoundFilter(), yields: .integer(0))
        try validateEvaluation(of: .string(""), by: RoundFilter(), yields: .integer(0))
        try validateEvaluation(of: .string("  "), by: RoundFilter(), yields: .integer(0))
    }
    
    @Test("Invalid numeric formats return 0")
    func testInvalidNumericFormats() throws {
        // Invalid number formats should return 0
        try validateEvaluation(of: .string("12.34.56"), by: RoundFilter(), yields: .integer(0))
        try validateEvaluation(of: .string("infinity"), by: RoundFilter(), yields: .integer(0))
        try validateEvaluation(of: .string("Infinity"), by: RoundFilter(), yields: .integer(0))
        try validateEvaluation(of: .string("-infinity"), by: RoundFilter(), yields: .integer(0))
        try validateEvaluation(of: .string("nan"), by: RoundFilter(), yields: .integer(0))
        try validateEvaluation(of: .string("NaN"), by: RoundFilter(), yields: .integer(0))
    }
    
    @Test("Invalid precision parameters default to 0")
    func testInvalidPrecisionParameters() throws {
        // Non-numeric precision should default to 0
        try validateEvaluation(of: .decimal(5.6), with: [.string("abc")], by: RoundFilter(), yields: .integer(6))
        try validateEvaluation(of: .decimal(5.6), with: [.bool(true)], by: RoundFilter(), yields: .integer(6))
        try validateEvaluation(of: .decimal(5.6), with: [.nil], by: RoundFilter(), yields: .integer(6))
        try validateEvaluation(of: .decimal(5.6), with: [.array([])], by: RoundFilter(), yields: .integer(6))
    }
    
    @Test("Nil returns 0")
    func testNil() throws {
        // Nil should return 0 (per python-liquid)
        try validateEvaluation(of: .nil, by: RoundFilter(), yields: .integer(0))
        try validateEvaluation(of: .nil, with: [.integer(2)], by: RoundFilter(), yields: .integer(0))
    }
    
    @Test("Boolean values return 0")
    func testBooleans() throws {
        // Booleans should return 0
        try validateEvaluation(of: .bool(true), by: RoundFilter(), yields: .integer(0))
        try validateEvaluation(of: .bool(false), by: RoundFilter(), yields: .integer(0))
        try validateEvaluation(of: .bool(true), with: [.integer(2)], by: RoundFilter(), yields: .integer(0))
    }
    
    @Test("Arrays return 0")
    func testArrays() throws {
        // Arrays should return 0
        try validateEvaluation(of: .array([.integer(1), .integer(2)]), by: RoundFilter(), yields: .integer(0))
        try validateEvaluation(of: .array([]), by: RoundFilter(), yields: .integer(0))
    }
    
    @Test("Dictionaries return 0")
    func testDictionaries() throws {
        // Dictionaries should return 0
        try validateEvaluation(of: .dictionary(["key": .string("value")]), by: RoundFilter(), yields: .integer(0))
        try validateEvaluation(of: .dictionary([:]), by: RoundFilter(), yields: .integer(0))
    }
    
    @Test("Ranges return 0")
    func testRanges() throws {
        // Ranges should return 0
        try validateEvaluation(of: .range(1...5), by: RoundFilter(), yields: .integer(0))
    }
    
    // MARK: - Edge Cases
    
    @Test("Very large numbers")
    func testLargeNumbers() throws {
        // Test with large numbers
        try validateEvaluation(of: .decimal(999999999.5), by: RoundFilter(), yields: .integer(1000000000))
        try validateEvaluation(of: .decimal(-999999999.5), by: RoundFilter(), yields: .integer(-1000000000))
        try validateEvaluation(of: .decimal(999999999.4), by: RoundFilter(), yields: .integer(999999999))
    }
    
    @Test("Very small fractional parts")
    func testSmallFractions() throws {
        // Test with very small fractional parts
        try validateEvaluation(of: .decimal(5.00001), by: RoundFilter(), yields: .integer(5))
        try validateEvaluation(of: .decimal(-5.00001), by: RoundFilter(), yields: .integer(-5))
        try validateEvaluation(of: .decimal(0.00001), by: RoundFilter(), yields: .integer(0))
        try validateEvaluation(of: .decimal(-0.00001), by: RoundFilter(), yields: .integer(0))
    }
    
    @Test("Rounding 0.5 values")
    func testHalfValues() throws {
        // Test 0.5 rounding behavior (standard rounding, not banker's)
        try validateEvaluation(of: .decimal(0.5), by: RoundFilter(), yields: .integer(1))
        try validateEvaluation(of: .decimal(1.5), by: RoundFilter(), yields: .integer(2))
        try validateEvaluation(of: .decimal(2.5), by: RoundFilter(), yields: .integer(3))
        try validateEvaluation(of: .decimal(3.5), by: RoundFilter(), yields: .integer(4))
        try validateEvaluation(of: .decimal(-0.5), by: RoundFilter(), yields: .integer(-1))
        try validateEvaluation(of: .decimal(-1.5), by: RoundFilter(), yields: .integer(-2))
        try validateEvaluation(of: .decimal(-2.5), by: RoundFilter(), yields: .integer(-3))
    }
    
    // MARK: - Parameter Handling
    
    @Test("Extra parameters are ignored")
    func testExtraParameters() throws {
        // The filter should ignore extra parameters
        try validateEvaluation(of: .decimal(5.666), with: [.integer(1), .integer(2)], by: RoundFilter(), yields: .decimal(5.7))
        try validateEvaluation(of: .decimal(5.666), with: [.integer(2), .string("hello"), .integer(3)], by: RoundFilter(), yields: .decimal(5.67))
    }
}