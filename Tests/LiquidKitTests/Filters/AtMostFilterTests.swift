import Testing
@testable import LiquidKit

@Suite(.tags(.filter, .atMostFilter))
struct AtMostFilterTests {
    let filter = AtMostFilter()
    
    // MARK: - Basic Numeric Comparisons
    
    @Test("Returns input when less than maximum")
    func inputLessThanMaximum() throws {
        try validateEvaluation(of: 4, with: [Token.Value.integer(5)], by: filter, yields: 4)
        try validateEvaluation(of: -8, with: [Token.Value.integer(5)], by: filter, yields: -8)
        try validateEvaluation(of: 0, with: [Token.Value.integer(10)], by: filter, yields: 0)
    }
    
    @Test("Returns maximum when input exceeds it")
    func inputGreaterThanMaximum() throws {
        try validateEvaluation(of: 8, with: [Token.Value.integer(5)], by: filter, yields: 5)
        try validateEvaluation(of: 100, with: [Token.Value.integer(10)], by: filter, yields: 10)
        try validateEvaluation(of: 5, with: [Token.Value.integer(-2)], by: filter, yields: -2)
    }
    
    @Test("Returns value when equal to maximum")
    func inputEqualToMaximum() throws {
        try validateEvaluation(of: 5, with: [Token.Value.integer(5)], by: filter, yields: 5)
        try validateEvaluation(of: 0, with: [Token.Value.integer(0)], by: filter, yields: 0)
        try validateEvaluation(of: -3, with: [Token.Value.integer(-3)], by: filter, yields: -3)
    }
    
    // MARK: - Decimal Values
    
    @Test("Handles decimal values correctly")
    func decimalValues() throws {
        try validateEvaluation(of: 8.4, with: [Token.Value.decimal(5.9)], by: filter, yields: 5.9)
        try validateEvaluation(of: 3.14, with: [Token.Value.decimal(10.5)], by: filter, yields: 3.14)
        try validateEvaluation(of: 5.5, with: [Token.Value.decimal(5.5)], by: filter, yields: 5.5)
    }
    
    // MARK: - String Conversion
    
    @Test("Converts numeric strings to numbers")
    func numericStringConversion() throws {
        // String input with numeric parameter
        try validateEvaluation(of: "9", with: [Token.Value.integer(8)], by: filter, yields: 8)
        try validateEvaluation(of: "3", with: [Token.Value.integer(5)], by: filter, yields: 3)
        
        // Numeric input with string parameter
        try validateEvaluation(of: 5, with: [Token.Value.string("8")], by: filter, yields: 5)
        try validateEvaluation(of: 10, with: [Token.Value.string("6")], by: filter, yields: 6)
        
        // Both strings
        try validateEvaluation(of: "9", with: [Token.Value.string("8")], by: filter, yields: 8)
        try validateEvaluation(of: "3", with: [Token.Value.string("7")], by: filter, yields: 3)
    }
    
    @Test("Handles decimal strings")
    func decimalStringConversion() throws {
        try validateEvaluation(of: "8.5", with: [Token.Value.integer(5)], by: filter, yields: 5)
        try validateEvaluation(of: 3, with: [Token.Value.string("5.5")], by: filter, yields: 3)
        try validateEvaluation(of: "4.2", with: [Token.Value.string("6.7")], by: filter, yields: 4.2)
    }
    
    // MARK: - Non-Numeric Values
    
    @Test("Handles non-numeric input - should use 0")
    func nonNumericInput() throws {
        // Non-numeric input with numeric parameter
        try validateEvaluation(of: "abc", with: [Token.Value.integer(5)], by: filter, yields: 0)
        try validateEvaluation(of: "hello", with: [Token.Value.integer(2)], by: filter, yields: 0)
        try validateEvaluation(of: "xyz", with: [Token.Value.integer(-2)], by: filter, yields: -2)
        
        // Arrays and dictionaries as input
        try validateEvaluation(of: ["a", "b"], with: [Token.Value.integer(5)], by: filter, yields: 0)
        try validateEvaluation(of: ["key": "value"], with: [Token.Value.integer(10)], by: filter, yields: 0)
    }
    
    @Test("Handles non-numeric parameter - should use 0")
    func nonNumericParameter() throws {
        // Numeric input with non-numeric parameter
        try validateEvaluation(of: 5, with: [Token.Value.string("abc")], by: filter, yields: 0)
        try validateEvaluation(of: -1, with: [Token.Value.string("xyz")], by: filter, yields: 0)
        try validateEvaluation(of: 10, with: [Token.Value.array([Token.Value.string("a"), Token.Value.string("b")])], by: filter, yields: 0)
    }
    
    @Test("Both non-numeric - should return 0")
    func bothNonNumeric() throws {
        try validateEvaluation(of: "abc", with: [Token.Value.string("xyz")], by: filter, yields: 0)
        try validateEvaluation(of: ["a"], with: [Token.Value.array([Token.Value.string("b")])], by: filter, yields: 0)
    }
    
    // MARK: - Nil Values
    
    @Test("Handles nil input - should use 0")
    func nilInput() throws {
        try validateEvaluation(of: Token.Value.nil, with: [Token.Value.integer(5)], by: filter, yields: 0)
        try validateEvaluation(of: Token.Value.nil, with: [Token.Value.integer(-3)], by: filter, yields: -3)
    }
    
    @Test("Handles nil parameter - should use 0")
    func nilParameter() throws {
        try validateEvaluation(of: 5, with: [Token.Value.nil], by: filter, yields: 0)
        try validateEvaluation(of: -2, with: [Token.Value.nil], by: filter, yields: -2)
    }
    
    @Test("Both nil - should return 0")
    func bothNil() throws {
        try validateEvaluation(of: Token.Value.nil, with: [Token.Value.nil], by: filter, yields: 0)
    }
    
    // MARK: - Edge Cases
    
    @Test("Handles missing parameter - should use 0")
    func missingParameter() throws {
        try validateEvaluation(of: 5, with: [], by: filter, yields: 0)
        try validateEvaluation(of: -3, with: [], by: filter, yields: -3)
    }
    
    @Test("Handles multiple parameters - uses only first")
    func multipleParameters() throws {
        try validateEvaluation(of: 8, with: [Token.Value.integer(5), Token.Value.integer(10)], by: filter, yields: 5)
        try validateEvaluation(of: 3, with: [Token.Value.integer(10), Token.Value.integer(1)], by: filter, yields: 3)
    }
    
    @Test("Handles very large and small numbers")
    func extremeValues() throws {
        try validateEvaluation(of: 1_000_000, with: [Token.Value.integer(999_999)], by: filter, yields: 999_999)
        try validateEvaluation(of: -1_000_000, with: [Token.Value.integer(-999_999)], by: filter, yields: -1_000_000)
        try validateEvaluation(of: 0.000001, with: [Token.Value.decimal(0.000002)], by: filter, yields: 0.000001)
    }
    
    // MARK: - Boolean Values
    
    @Test("Handles boolean values - should use numeric representation")
    func booleanValues() throws {
        // true = 1, false = 0
        try validateEvaluation(of: true, with: [Token.Value.integer(5)], by: filter, yields: 1)
        try validateEvaluation(of: false, with: [Token.Value.integer(5)], by: filter, yields: 0)
        try validateEvaluation(of: 10, with: [Token.Value.bool(true)], by: filter, yields: 1)
        try validateEvaluation(of: -5, with: [Token.Value.bool(false)], by: filter, yields: -5)
    }
}

