import Testing
import Foundation
@testable import LiquidKit

@Suite(.tags(.filter, .timesFilter))
struct TimesFilterTests {
    private let filter = TimesFilter()
    
    // MARK: - Basic Arithmetic
    
    @Test("Integer multiplication")
    func integerMultiplication() throws {
        try validateEvaluation(of: 5, with: [.integer(2)], by: filter, yields: 10)
        try validateEvaluation(of: 3, with: [.integer(4)], by: filter, yields: 12)
        try validateEvaluation(of: 100, with: [.integer(5)], by: filter, yields: 500)
        try validateEvaluation(of: 0, with: [.integer(5)], by: filter, yields: 0)
        try validateEvaluation(of: -10, with: [.integer(5)], by: filter, yields: -50)
        try validateEvaluation(of: -10, with: [.integer(-5)], by: filter, yields: 50)
        try validateEvaluation(of: 7, with: [.integer(0)], by: filter, yields: 0)
    }
    
    @Test("Decimal multiplication")
    func decimalMultiplication() throws {
        try validateEvaluation(of: 5.0, with: [.decimal(2.1)], by: filter, yields: Token.Value.decimal(Decimal(10.5)))
        try validateEvaluation(of: 183.357, with: [.decimal(12)], by: filter, yields: Token.Value.decimal(Decimal(string: "2200.284")!))
        try validateEvaluation(of: 5.5, with: [.decimal(2.0)], by: filter, yields: Token.Value.decimal(Decimal(11.0)))
        try validateEvaluation(of: 0.0, with: [.decimal(3.14)], by: filter, yields: Token.Value.decimal(Decimal(0.0)))
        try validateEvaluation(of: -5.5, with: [.decimal(2.0)], by: filter, yields: Token.Value.decimal(Decimal(-11.0)))
        try validateEvaluation(of: -5.5, with: [.decimal(-2.0)], by: filter, yields: Token.Value.decimal(Decimal(11.0)))
        try validateEvaluation(of: 3.14, with: [.decimal(0.0)], by: filter, yields: Token.Value.decimal(Decimal(0.0)))
    }
    
    @Test("Mixed integer and decimal multiplication")
    func mixedMultiplication() throws {
        // Integer times decimal returns decimal
        try validateEvaluation(of: 5, with: [.decimal(2.0)], by: filter, yields: Token.Value.decimal(Decimal(10.0)))
        try validateEvaluation(of: 5, with: [.decimal(2.1)], by: filter, yields: Token.Value.decimal(Decimal(10.5)))
        
        // Decimal times integer returns decimal
        try validateEvaluation(of: 5.0, with: [.integer(2)], by: filter, yields: Token.Value.decimal(Decimal(10.0)))
        try validateEvaluation(of: 5.5, with: [.integer(2)], by: filter, yields: Token.Value.decimal(Decimal(11.0)))
    }
    
    @Test("Zero handling")
    func zeroHandling() throws {
        try validateEvaluation(of: 0, with: [.integer(0)], by: filter, yields: 0)
        try validateEvaluation(of: 5, with: [.integer(0)], by: filter, yields: 0)
        try validateEvaluation(of: 0, with: [.integer(5)], by: filter, yields: 0)
        try validateEvaluation(of: 0.0, with: [.decimal(0.0)], by: filter, yields: Token.Value.decimal(Decimal(0.0)))
        try validateEvaluation(of: 5.5, with: [.decimal(0.0)], by: filter, yields: Token.Value.decimal(Decimal(0.0)))
    }
    
    // MARK: - String Conversion
    
    @Test("String to number conversion")
    func stringConversion() throws {
        // Basic string numbers
        try validateEvaluation(of: "5", with: [.string("2")], by: filter, yields: 10)
        try validateEvaluation(of: "5.0", with: [.string("2.1")], by: filter, yields: Token.Value.decimal(Decimal(10.5)))
        try validateEvaluation(of: "3", with: [.integer(4)], by: filter, yields: 12)
        
        // Negative string numbers
        try validateEvaluation(of: "-10", with: [.string("5")], by: filter, yields: -50)
        try validateEvaluation(of: "10", with: [.string("-5")], by: filter, yields: -50)
        
        // Whitespace handling
        try validateEvaluation(of: " 5 ", with: [.string(" 2 ")], by: filter, yields: 10)
        try validateEvaluation(of: "\t5.0\n", with: [.string("2.0")], by: filter, yields: Token.Value.decimal(Decimal(10.0)))
    }
    
    @Test("Non-numeric string handling")
    func nonNumericStrings() throws {
        // Non-numeric strings treated as 0
        try validateEvaluation(of: "foo", with: [.string("2.0")], by: filter, yields: Token.Value.decimal(Decimal(0.0)))
        try validateEvaluation(of: "hello", with: [.integer(10)], by: filter, yields: 0)
        try validateEvaluation(of: 10, with: [.string("bar")], by: filter, yields: 0)
        try validateEvaluation(of: "abc", with: [.string("xyz")], by: filter, yields: 0)
        
        // Empty strings
        try validateEvaluation(of: "", with: [.integer(5)], by: filter, yields: 0)
        try validateEvaluation(of: 5, with: [.string("")], by: filter, yields: 0)
        try validateEvaluation(of: "", with: [.string("")], by: filter, yields: 0)
        
        // Partially numeric strings
        try validateEvaluation(of: "123abc", with: [.integer(10)], by: filter, yields: 0)
        try validateEvaluation(of: "12.34.56", with: [.integer(5)], by: filter, yields: 0)
    }
    
    // MARK: - Nil Handling
    
    @Test("Nil value handling")
    func nilHandling() throws {
        // Nil treated as 0
        try validateEvaluation(of: Token.Value.nil, with: [.integer(2)], by: filter, yields: 0)
        try validateEvaluation(of: 10, with: [.nil], by: filter, yields: 0)
        try validateEvaluation(of: Token.Value.nil, with: [.nil], by: filter, yields: 0)
        
        // Nil with decimals
        try validateEvaluation(of: Token.Value.nil, with: [.decimal(2.5)], by: filter, yields: Token.Value.decimal(Decimal(0.0)))
        try validateEvaluation(of: 10.5, with: [.nil], by: filter, yields: Token.Value.decimal(Decimal(0.0)))
    }
    
    // MARK: - Type Preservation
    
    @Test("Integer type preservation")
    func integerTypePreservation() throws {
        // Integer times integer with whole result preserves integer type
        try validateEvaluation(of: 10, with: [.integer(2)], by: filter, yields: Token.Value.integer(20))
        try validateEvaluation(of: -5, with: [.integer(-3)], by: filter, yields: Token.Value.integer(15))
        
        // Even when result could be represented as integer, decimal operands return decimal
        try validateEvaluation(of: 10.0, with: [.decimal(2.0)], by: filter, yields: Token.Value.decimal(20.0))
    }
    
    // MARK: - Edge Cases
    
    @Test("Large numbers")
    func largeNumbers() throws {
        let large = Decimal(string: "999999999999999")!
        let multiplier = Decimal(2)
        let expected = large * multiplier
        
        try validateEvaluation(
            of: Token.Value.decimal(large),
            with: [.decimal(multiplier)],
            by: filter,
            yields: Token.Value.decimal(expected)
        )
        
        // Large negative numbers
        let largeNegative = Decimal(string: "-999999999999999")!
        let expectedNegative = largeNegative * multiplier
        
        try validateEvaluation(
            of: Token.Value.decimal(largeNegative),
            with: [.decimal(multiplier)],
            by: filter,
            yields: Token.Value.decimal(expectedNegative)
        )
    }
    
    @Test("Scientific notation in strings")
    func scientificNotation() throws {
        try validateEvaluation(of: "1e3", with: [.string("2")], by: filter, yields: 2000)
        try validateEvaluation(of: "5e1", with: [.string("2e1")], by: filter, yields: 1000)
        try validateEvaluation(of: "-1e2", with: [.string("2")], by: filter, yields: -200)
    }
    
    @Test("Special numeric strings")
    func specialNumericStrings() throws {
        // These don't parse as valid numbers, so treated as 0
        try validateEvaluation(of: "Infinity", with: [.integer(5)], by: filter, yields: 0)
        try validateEvaluation(of: "-Infinity", with: [.integer(5)], by: filter, yields: 0)
        try validateEvaluation(of: "NaN", with: [.integer(5)], by: filter, yields: 0)
    }
    
    // MARK: - Non-Numeric Types
    
    @Test("Boolean values treated as 0")
    func booleanValues() throws {
        try validateEvaluation(of: true, with: [.integer(5)], by: filter, yields: 0)
        try validateEvaluation(of: false, with: [.integer(3)], by: filter, yields: 0)
        try validateEvaluation(of: 10, with: [.bool(true)], by: filter, yields: 0)
        try validateEvaluation(of: 10, with: [.bool(false)], by: filter, yields: 0)
    }
    
    @Test("Array values treated as 0")
    func arrayValues() throws {
        try validateEvaluation(of: [1, 2, 3], with: [.integer(5)], by: filter, yields: 0)
        try validateEvaluation(of: 10, with: [.array([.integer(1), .integer(2)])], by: filter, yields: 0)
        try validateEvaluation(of: Token.Value.array([]), with: [.integer(3)], by: filter, yields: 0)
    }
    
    @Test("Dictionary values treated as 0")
    func dictionaryValues() throws {
        try validateEvaluation(of: ["key": "value"], with: [.integer(5)], by: filter, yields: 0)
        try validateEvaluation(of: 10, with: [.dictionary(["a": .integer(1)])], by: filter, yields: 0)
        try validateEvaluation(of: Token.Value.dictionary([:]), with: [.integer(3)], by: filter, yields: 0)
    }
    
    @Test("Range values treated as 0")
    func rangeValues() throws {
        try validateEvaluation(of: Token.Value.range(1...5), with: [.integer(3)], by: filter, yields: 0)
        try validateEvaluation(of: 10, with: [.range(1...5)], by: filter, yields: 0)
    }
    
    // MARK: - Parameter Handling
    
    @Test("No parameters returns input unchanged")
    func noParameters() throws {
        try validateEvaluation(of: 42, by: filter, yields: 42)
        try validateEvaluation(of: -42, by: filter, yields: -42)
        try validateEvaluation(of: 3.14, by: filter, yields: 3.14)
        try validateEvaluation(of: "hello", by: filter, yields: "hello")
        try validateEvaluation(of: Token.Value.nil, by: filter, yields: Token.Value.nil)
    }
    
    @Test("Extra parameters are ignored")
    func extraParameters() throws {
        // Only first parameter is used
        try validateEvaluation(of: 10, with: [.integer(3), .integer(5), .integer(7)], by: filter, yields: 30)
        try validateEvaluation(of: 5.0, with: [.decimal(2.0), .string("ignored")], by: filter, yields: Token.Value.decimal(Decimal(10.0)))
    }
    
    // MARK: - Real-World Examples
    
    @Test("Examples from documentation")
    func documentationExamples() throws {
        // From the filter documentation
        try validateEvaluation(of: 5, with: [.integer(2)], by: filter, yields: 10)
        try validateEvaluation(of: 5.0, with: [.decimal(2.1)], by: filter, yields: Token.Value.decimal(Decimal(10.5)))
        try validateEvaluation(of: 5, with: [.decimal(2.1)], by: filter, yields: Token.Value.decimal(Decimal(10.5)))
        
        // String conversion
        try validateEvaluation(of: "5.0", with: [.string("2.1")], by: filter, yields: Token.Value.decimal(Decimal(10.5)))
        
        // Negative numbers
        try validateEvaluation(of: -5, with: [.integer(2)], by: filter, yields: -10)
        
        // Nil handling
        try validateEvaluation(of: Token.Value.nil, with: [.integer(2)], by: filter, yields: 0)
        
        // From LiquidJS docs
        try validateEvaluation(of: 3, with: [.integer(2)], by: filter, yields: 6)
        try validateEvaluation(of: 183.357, with: [.integer(12)], by: filter, yields: Token.Value.decimal(Decimal(string: "2200.284")!))
    }
    
    @Test("Fractional results")
    func fractionalResults() throws {
        // Testing cases where integer multiplication would produce fractional results
        // This tests the type preservation logic
        try validateEvaluation(of: 7, with: [.decimal(0.5)], by: filter, yields: Token.Value.decimal(Decimal(3.5)))
        try validateEvaluation(of: 3, with: [.decimal(0.333333)], by: filter, yields: Token.Value.decimal(Decimal(string: "0.999999")!))
    }
}