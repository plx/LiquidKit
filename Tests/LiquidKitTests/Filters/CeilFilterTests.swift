import Testing
import Foundation
@testable import LiquidKit

@Suite(.tags(.filter, .ceilFilter))
struct CeilFilterTests {
    private let filter = CeilFilter()
    
    // MARK: - Positive Numbers
    
    @Test("Positive integers remain unchanged")
    func positiveInteger() throws {
        try validateEvaluation(of: 42, by: filter, yields: 42)
        try validateEvaluation(of: 1, by: filter, yields: 1)
        try validateEvaluation(of: 999999, by: filter, yields: 999999)
        try validateEvaluation(of: 0, by: filter, yields: 0)
    }
    
    @Test("Positive decimals round up")
    func positiveDecimal() throws {
        try validateEvaluation(of: 5.1, by: filter, yields: 6)
        try validateEvaluation(of: 5.4, by: filter, yields: 6)
        try validateEvaluation(of: 5.5, by: filter, yields: 6)
        try validateEvaluation(of: 5.9, by: filter, yields: 6)
        try validateEvaluation(of: 0.1, by: filter, yields: 1)
        try validateEvaluation(of: 0.001, by: filter, yields: 1)
    }
    
    @Test("Whole decimal numbers remain unchanged")
    func wholeDecimalNumbers() throws {
        try validateEvaluation(of: 5.0, by: filter, yields: 5)
        try validateEvaluation(of: 10.0, by: filter, yields: 10)
        try validateEvaluation(of: 0.0, by: filter, yields: 0)
    }
    
    // MARK: - Negative Numbers
    
    @Test("Negative integers remain unchanged")
    func negativeInteger() throws {
        try validateEvaluation(of: -42, by: filter, yields: -42)
        try validateEvaluation(of: -1, by: filter, yields: -1)
        try validateEvaluation(of: -999999, by: filter, yields: -999999)
    }
    
    @Test("Negative decimals round toward zero")
    func negativeDecimal() throws {
        try validateEvaluation(of: -5.1, by: filter, yields: -5)
        try validateEvaluation(of: -5.4, by: filter, yields: -5)
        try validateEvaluation(of: -5.5, by: filter, yields: -5)
        try validateEvaluation(of: -5.9, by: filter, yields: -5)
        try validateEvaluation(of: -0.1, by: filter, yields: 0)
        try validateEvaluation(of: -0.9, by: filter, yields: 0)
    }
    
    @Test("Negative whole decimal numbers remain unchanged")
    func negativeWholeDecimalNumbers() throws {
        try validateEvaluation(of: -5.0, by: filter, yields: -5)
        try validateEvaluation(of: -10.0, by: filter, yields: -10)
    }
    
    // MARK: - String Conversion Cases
    
    @Test("Numeric strings are converted and ceiled")
    func numericStrings() throws {
        try validateEvaluation(of: "5.1", by: filter, yields: 6)
        try validateEvaluation(of: "5.4", by: filter, yields: 6)
        try validateEvaluation(of: "5", by: filter, yields: 5)
        try validateEvaluation(of: "-5.1", by: filter, yields: -5)
        try validateEvaluation(of: "-5", by: filter, yields: -5)
        try validateEvaluation(of: "0", by: filter, yields: 0)
        try validateEvaluation(of: "0.1", by: filter, yields: 1)
        try validateEvaluation(of: "-0.1", by: filter, yields: 0)
    }
    
    @Test("Numeric strings with whitespace")
    func numericStringsWithWhitespace() throws {
        try validateEvaluation(of: " 5.1 ", by: filter, yields: 6)
        try validateEvaluation(of: " -5.1 ", by: filter, yields: -5)
        try validateEvaluation(of: "\t5.4\n", by: filter, yields: 6)
    }
    
    // MARK: - Non-Numeric Cases (Should return 0)
    
    @Test("Non-numeric strings return 0")
    func nonNumericStrings() throws {
        try validateEvaluation(of: "hello", by: filter, yields: 0)
        try validateEvaluation(of: "abc123", by: filter, yields: 0)
        try validateEvaluation(of: "12.34.56", by: filter, yields: 0)
        try validateEvaluation(of: "", by: filter, yields: 0)
        try validateEvaluation(of: " ", by: filter, yields: 0)
    }
    
    @Test("Nil returns 0")
    func nilValue() throws {
        try validateEvaluation(of: Token.Value.nil, by: filter, yields: Token.Value.integer(0))
    }
    
    @Test("Boolean values return 0")
    func booleanValues() throws {
        try validateEvaluation(of: true, by: filter, yields: 0)
        try validateEvaluation(of: false, by: filter, yields: 0)
    }
    
    @Test("Arrays return 0")
    func arrayValues() throws {
        try validateEvaluation(of: [1, 2, 3], by: filter, yields: 0)
        try validateEvaluation(of: ["a", "b", "c"], by: filter, yields: 0)
        try validateEvaluation(of: Token.Value.array([]), by: filter, yields: Token.Value.integer(0))
    }
    
    @Test("Dictionaries return 0")
    func dictionaryValues() throws {
        try validateEvaluation(of: ["key": "value"], by: filter, yields: 0)
        try validateEvaluation(of: Token.Value.dictionary([:]), by: filter, yields: Token.Value.integer(0))
    }
    
    @Test("Ranges return 0")
    func rangeValues() throws {
        try validateEvaluation(of: Token.Value.range(1...5), by: filter, yields: Token.Value.integer(0))
        try validateEvaluation(of: Token.Value.range(-5...(-1)), by: filter, yields: Token.Value.integer(0))
    }
    
    // MARK: - Edge Cases
    
    @Test("Very large numbers")
    func largeNumbers() throws {
        let largePositive = 999999999999.1
        let largeNegative = -999999999999.1
        
        try validateEvaluation(of: largePositive, by: filter, yields: 1000000000000)
        try validateEvaluation(of: largeNegative, by: filter, yields: -999999999999)
    }
    
    @Test("Very small decimals")
    func smallDecimals() throws {
        try validateEvaluation(of: 0.000000000001, by: filter, yields: 1)
        try validateEvaluation(of: -0.000000000001, by: filter, yields: 0)
    }
    
    // MARK: - Parameter Handling
    
    @Test("Extra parameters are ignored")
    func extraParameters() throws {
        // The ceil filter should ignore extra parameters (not throw an error in this implementation)
        try validateEvaluation(of: 5.1, with: [.integer(10)], by: filter, yields: 6)
        try validateEvaluation(of: -5.1, with: [.string("ignored"), .integer(5)], by: filter, yields: -5)
    }
    
    // MARK: - Special Number Cases
    
    @Test("Scientific notation strings")
    func scientificNotation() throws {
        // Decimal(string:) can handle scientific notation
        try validateEvaluation(of: "1.1e2", by: filter, yields: 110)  // 110.0 -> 110
        try validateEvaluation(of: "-1.1e2", by: filter, yields: -110)  // -110.0 -> -110
        try validateEvaluation(of: "3.14e0", by: filter, yields: 4)  // 3.14 -> 4
    }
    
    @Test("Infinity and NaN handling")
    func specialFloatingPointValues() throws {
        // Note: Decimal doesn't support infinity/NaN, so these strings won't parse
        try validateEvaluation(of: "Infinity", by: filter, yields: 0)
        try validateEvaluation(of: "-Infinity", by: filter, yields: 0)
        try validateEvaluation(of: "NaN", by: filter, yields: 0)
    }
    
    // MARK: - Consistency with Other Implementations
    
    @Test("Python Liquid examples")
    func pythonLiquidExamples() throws {
        // From Python Liquid documentation
        try validateEvaluation(of: 5.1, by: filter, yields: 6)
        try validateEvaluation(of: 5.0, by: filter, yields: 5)
        try validateEvaluation(of: "5.4", by: filter, yields: 6)
        try validateEvaluation(of: "hello", by: filter, yields: 0)
        // nosuchthing would be nil in our case
        try validateEvaluation(of: Token.Value.nil, by: filter, yields: Token.Value.integer(0))
    }
    
    @Test("LiquidJS examples")
    func liquidJSExamples() throws {
        // From LiquidJS documentation
        try validateEvaluation(of: 1.2, by: filter, yields: 2)
        try validateEvaluation(of: 2.0, by: filter, yields: 2)
        try validateEvaluation(of: "3.5", by: filter, yields: 4)
    }
}