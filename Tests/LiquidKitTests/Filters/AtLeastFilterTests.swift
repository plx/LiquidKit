import Testing
import Foundation
@testable import LiquidKit

@Suite(.tags(.filter, .atLeastFilter))
struct AtLeastFilterTests {
    private let filter = AtLeastFilter()
    
    // MARK: - Basic Numeric Comparisons
    
    @Test("Returns parameter when input is less than parameter")
    func inputLessThanParameter() throws {
        try validateEvaluation(of: 5, with: [.integer(8)], by: filter, yields: 8)
        try validateEvaluation(of: -8, with: [.integer(5)], by: filter, yields: 5)
        try validateEvaluation(of: 0, with: [.integer(10)], by: filter, yields: 10)
    }
    
    @Test("Returns input when input is greater than parameter")
    func inputGreaterThanParameter() throws {
        try validateEvaluation(of: 8, with: [.integer(5)], by: filter, yields: 8)
        try validateEvaluation(of: 100, with: [.integer(50)], by: filter, yields: 100)
        try validateEvaluation(of: -5, with: [.integer(-10)], by: filter, yields: -5)
    }
    
    @Test("Returns input when input equals parameter")
    func inputEqualsParameter() throws {
        try validateEvaluation(of: 5, with: [.integer(5)], by: filter, yields: 5)
        try validateEvaluation(of: 0, with: [.integer(0)], by: filter, yields: 0)
        try validateEvaluation(of: -10, with: [.integer(-10)], by: filter, yields: -10)
    }
    
    // MARK: - Decimal Comparisons
    
    @Test("Decimal comparisons")
    func decimalComparisons() throws {
        try validateEvaluation(of: 5.4, with: [.decimal(8.9)], by: filter, yields: 8.9)
        try validateEvaluation(of: 8.9, with: [.decimal(5.4)], by: filter, yields: 8.9)
        try validateEvaluation(of: 3.14, with: [.decimal(3.14)], by: filter, yields: 3.14)
        try validateEvaluation(of: -5.5, with: [.decimal(2.5)], by: filter, yields: 2.5)
    }
    
    // MARK: - String Conversion
    
    @Test("Numeric strings are converted")
    func numericStringConversion() throws {
        // Input string, numeric parameter
        try validateEvaluation(of: "9", with: [.integer(8)], by: filter, yields: 9)
        try validateEvaluation(of: "5", with: [.integer(8)], by: filter, yields: 8)
        
        // Numeric input, parameter string
        try validateEvaluation(of: 5, with: [.string("8")], by: filter, yields: 8)
        try validateEvaluation(of: 9, with: [.string("8")], by: filter, yields: 9)
        
        // Both strings
        try validateEvaluation(of: "5", with: [.string("8")], by: filter, yields: 8)
        try validateEvaluation(of: "9", with: [.string("8")], by: filter, yields: 9)
    }
    
    @Test("Decimal strings are converted")
    func decimalStringConversion() throws {
        try validateEvaluation(of: "5.4", with: [.decimal(8.9)], by: filter, yields: 8.9)
        try validateEvaluation(of: 5.4, with: [.string("8.9")], by: filter, yields: 8.9)
        try validateEvaluation(of: "5.4", with: [.string("8.9")], by: filter, yields: 8.9)
    }
    
    // MARK: - Non-Numeric Values (Python Liquid behavior - use 0)
    
    @Test("Non-numeric input with numeric parameter")
    func nonNumericInputNumericParameter() throws {
        // Python Liquid behavior: non-numeric values become 0
        try validateEvaluation(of: "abc", with: [.integer(2)], by: filter, yields: 2)
        try validateEvaluation(of: "hello", with: [.integer(5)], by: filter, yields: 5)
        try validateEvaluation(of: "abc", with: [.integer(-2)], by: filter, yields: 0)  // max(0, -2) = 0
        try validateEvaluation(of: "", with: [.integer(10)], by: filter, yields: 10)
    }
    
    @Test("Numeric input with non-numeric parameter")
    func numericInputNonNumericParameter() throws {
        // Python Liquid behavior: non-numeric parameter becomes 0
        try validateEvaluation(of: -1, with: [.string("abc")], by: filter, yields: 0)  // max(-1, 0) = 0
        try validateEvaluation(of: 5, with: [.string("hello")], by: filter, yields: 5)  // max(5, 0) = 5
        try validateEvaluation(of: -10, with: [.string("")], by: filter, yields: 0)  // max(-10, 0) = 0
    }
    
    @Test("Both non-numeric values")
    func bothNonNumeric() throws {
        // Python Liquid behavior: both become 0, result is 0
        try validateEvaluation(of: "abc", with: [.string("xyz")], by: filter, yields: 0)
        try validateEvaluation(of: "hello", with: [.string("world")], by: filter, yields: 0)
        try validateEvaluation(of: "", with: [.string("")], by: filter, yields: 0)
    }
    
    // MARK: - Nil Values
    
    @Test("Nil input with numeric parameter")
    func nilInputNumericParameter() throws {
        try validateEvaluation(of: Token.Value.nil, with: [.integer(5)], by: filter, yields: 5)
        try validateEvaluation(of: Token.Value.nil, with: [.integer(-5)], by: filter, yields: 0)  // max(0, -5) = 0
        try validateEvaluation(of: Token.Value.nil, with: [.integer(0)], by: filter, yields: 0)
    }
    
    @Test("Numeric input with nil parameter")
    func numericInputNilParameter() throws {
        try validateEvaluation(of: 5, with: [Token.Value.nil], by: filter, yields: 5)  // max(5, 0) = 5
        try validateEvaluation(of: -5, with: [Token.Value.nil], by: filter, yields: 0)  // max(-5, 0) = 0
        try validateEvaluation(of: 0, with: [Token.Value.nil], by: filter, yields: 0)
    }
    
    @Test("Both nil values")
    func bothNil() throws {
        try validateEvaluation(of: Token.Value.nil, with: [Token.Value.nil], by: filter, yields: 0)
    }
    
    // MARK: - Other Type Values
    
    @Test("Boolean values treated as 0")
    func booleanValues() throws {
        try validateEvaluation(of: true, with: [.integer(5)], by: filter, yields: 5)
        try validateEvaluation(of: false, with: [.integer(5)], by: filter, yields: 5)
        try validateEvaluation(of: 10, with: [.bool(true)], by: filter, yields: 10)
        try validateEvaluation(of: -5, with: [.bool(false)], by: filter, yields: 0)
    }
    
    @Test("Array values treated as 0")
    func arrayValues() throws {
        try validateEvaluation(of: [1, 2, 3], with: [.integer(5)], by: filter, yields: 5)
        try validateEvaluation(of: 10, with: [.array([.integer(1), .integer(2), .integer(3)])], by: filter, yields: 10)
        try validateEvaluation(of: -5, with: [.array([.string("a"), .string("b")])], by: filter, yields: 0)
    }
    
    @Test("Dictionary values treated as 0")
    func dictionaryValues() throws {
        try validateEvaluation(of: ["key": "value"], with: [.integer(5)], by: filter, yields: 5)
        try validateEvaluation(of: 10, with: [.dictionary(["key": .string("value")])], by: filter, yields: 10)
        try validateEvaluation(of: -5, with: [.dictionary(["a": .integer(1)])], by: filter, yields: 0)
    }
    
    @Test("Range values treated as 0")
    func rangeValues() throws {
        try validateEvaluation(of: Token.Value.range(1...5), with: [.integer(10)], by: filter, yields: 10)
        try validateEvaluation(of: 15, with: [Token.Value.range(1...5)], by: filter, yields: 15)
        try validateEvaluation(of: -5, with: [Token.Value.range(1...5)], by: filter, yields: 0)
    }
    
    // MARK: - Edge Cases
    
    @Test("Very large numbers")
    func largeNumbers() throws {
        let largePositive = Decimal(string: "999999999999999999999999999999")!
        let largeNegative = Decimal(string: "-999999999999999999999999999999")!
        
        try validateEvaluation(
            of: Token.Value.decimal(largeNegative),
            with: [Token.Value.decimal(largePositive)],
            by: filter,
            yields: Token.Value.decimal(largePositive)
        )
        
        try validateEvaluation(
            of: Token.Value.decimal(largePositive),
            with: [Token.Value.decimal(largeNegative)],
            by: filter,
            yields: Token.Value.decimal(largePositive)
        )
    }
    
    @Test("Very small decimals")
    func smallDecimals() throws {
        let small1 = Decimal(string: "0.000000000001")!
        let small2 = Decimal(string: "0.000000000002")!
        
        try validateEvaluation(
            of: Token.Value.decimal(small1),
            with: [Token.Value.decimal(small2)],
            by: filter,
            yields: Token.Value.decimal(small2)
        )
    }
    
    @Test("Scientific notation strings")
    func scientificNotation() throws {
        try validateEvaluation(of: "1e2", with: [.integer(50)], by: filter, yields: 100)  // 100 > 50
        try validateEvaluation(of: "1e2", with: [.integer(150)], by: filter, yields: 150)  // 100 < 150
        try validateEvaluation(of: 50, with: [.string("1e2")], by: filter, yields: 100)
    }
    
    // MARK: - Parameter Handling
    
    @Test("Missing parameter")
    func missingParameter() throws {
        // When no parameter is provided, should treat as 0
        try validateEvaluation(of: 5, with: [], by: filter, yields: 5)
        try validateEvaluation(of: -5, with: [], by: filter, yields: 0)  // max(-5, 0) = 0
        try validateEvaluation(of: 0, with: [], by: filter, yields: 0)
    }
    
    @Test("Extra parameters are ignored")
    func extraParameters() throws {
        // Only first parameter is used
        try validateEvaluation(of: 5, with: [.integer(8), .integer(10), .integer(20)], by: filter, yields: 8)
        try validateEvaluation(of: 10, with: [.integer(8), .integer(5), .integer(3)], by: filter, yields: 10)
    }
    
    // MARK: - Mixed Integer and Decimal
    
    @Test("Mixed integer and decimal comparisons")
    func mixedIntegerDecimal() throws {
        try validateEvaluation(of: 5, with: [.decimal(8.5)], by: filter, yields: 8.5)
        try validateEvaluation(of: 8.5, with: [.integer(5)], by: filter, yields: 8.5)
        try validateEvaluation(of: -10, with: [.decimal(5.5)], by: filter, yields: 5.5)
    }
}