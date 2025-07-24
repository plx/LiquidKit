import Testing
import Foundation
@testable import LiquidKit

@Suite(.tags(.filter, .absFilter))
struct AbsFilterTests {
    private let filter = AbsFilter()
    
    // MARK: - Positive Cases
    
    @Test("Positive integers remain unchanged")
    func positiveInteger() throws {
        try validateEvaluation(of: 42, by: filter, yields: 42)
        try validateEvaluation(of: 1, by: filter, yields: 1)
        try validateEvaluation(of: 999999, by: filter, yields: 999999)
    }
    
    @Test("Negative integers become positive")
    func negativeInteger() throws {
        try validateEvaluation(of: -42, by: filter, yields: 42)
        try validateEvaluation(of: -1, by: filter, yields: 1)
        try validateEvaluation(of: -999999, by: filter, yields: 999999)
    }
    
    @Test("Zero remains zero")
    func zero() throws {
        try validateEvaluation(of: 0, by: filter, yields: 0)
        try validateEvaluation(of: -0, by: filter, yields: 0)
    }
    
    @Test("Positive decimals remain unchanged")
    func positiveDecimal() throws {
        try validateEvaluation(of: 3.14, by: filter, yields: 3.14)
        try validateEvaluation(of: 0.5, by: filter, yields: 0.5)
        try validateEvaluation(of: 99.99, by: filter, yields: 99.99)
    }
    
    @Test("Negative decimals become positive")
    func negativeDecimal() throws {
        try validateEvaluation(of: -3.14, by: filter, yields: 3.14)
        try validateEvaluation(of: -0.5, by: filter, yields: 0.5)
        try validateEvaluation(of: -99.99, by: filter, yields: 99.99)
    }
    
    // MARK: - String Conversion Cases
    
    @Test("Numeric strings are converted")
    func numericStrings() throws {
        try validateEvaluation(of: "42", by: filter, yields: 42)
        try validateEvaluation(of: "-42", by: filter, yields: 42)
        try validateEvaluation(of: "3.14", by: filter, yields: 3.14)
        try validateEvaluation(of: "-3.14", by: filter, yields: 3.14)
        try validateEvaluation(of: "0", by: filter, yields: 0)
        try validateEvaluation(of: "-0", by: filter, yields: 0)
    }
    
    @Test("Numeric strings with whitespace")
    func numericStringsWithWhitespace() throws {
        // Note: Decimal(string:) handles leading/trailing whitespace
        try validateEvaluation(of: " 42 ", by: filter, yields: 42)
        try validateEvaluation(of: " -42 ", by: filter, yields: 42)
        try validateEvaluation(of: "\t3.14\n", by: filter, yields: 3.14)
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
        let largePositive = Decimal(string: "999999999999999999999999999999")!
        let largeNegative = Decimal(string: "-999999999999999999999999999999")!
        
        try validateEvaluation(of: Token.Value.decimal(largePositive), by: filter, yields: Token.Value.decimal(largePositive))
        try validateEvaluation(of: Token.Value.decimal(largeNegative), by: filter, yields: Token.Value.decimal(largePositive))
    }
    
    @Test("Very small decimals")
    func smallDecimals() throws {
        let smallPositive = Decimal(string: "0.000000000001")!
        let smallNegative = Decimal(string: "-0.000000000001")!
        
        try validateEvaluation(of: Token.Value.decimal(smallPositive), by: filter, yields: Token.Value.decimal(smallPositive))
        try validateEvaluation(of: Token.Value.decimal(smallNegative), by: filter, yields: Token.Value.decimal(smallPositive))
    }
    
    // MARK: - Parameter Handling
    
    @Test("Extra parameters are ignored")
    func extraParameters() throws {
        // The abs filter should ignore extra parameters (not throw an error in this implementation)
        try validateEvaluation(of: -42, with: [.integer(10)], by: filter, yields: 42)
        try validateEvaluation(of: -3.14, with: [.string("ignored"), .integer(5)], by: filter, yields: 3.14)
    }
    
    // MARK: - Special Number Cases
    
    @Test("Scientific notation strings")
    func scientificNotation() throws {
        // Decimal(string:) can handle scientific notation
        try validateEvaluation(of: "1e5", by: filter, yields: 100000)
        try validateEvaluation(of: "-1e5", by: filter, yields: 100000)
        try validateEvaluation(of: "3.14e2", by: filter, yields: 314)
        try validateEvaluation(of: "-3.14e2", by: filter, yields: 314)
    }
    
    @Test("Infinity and NaN handling")
    func specialFloatingPointValues() throws {
        // Note: Decimal doesn't support infinity/NaN, so these strings won't parse
        try validateEvaluation(of: "Infinity", by: filter, yields: 0)
        try validateEvaluation(of: "-Infinity", by: filter, yields: 0)
        try validateEvaluation(of: "NaN", by: filter, yields: 0)
    }
}

