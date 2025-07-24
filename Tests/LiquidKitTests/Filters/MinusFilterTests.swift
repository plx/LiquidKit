import Testing
import Foundation
@testable import LiquidKit

@Suite(.tags(.filter, .minusFilter))
struct MinusFilterTests {
    private let filter = MinusFilter()
    
    // MARK: - Basic Arithmetic
    
    @Test("Integer subtraction")
    func integerSubtraction() throws {
        try validateEvaluation(of: 10, with: [.integer(2)], by: filter, yields: 8)
        try validateEvaluation(of: 5, with: [.integer(10)], by: filter, yields: -5)
        try validateEvaluation(of: 100, with: [.integer(50)], by: filter, yields: 50)
        try validateEvaluation(of: 0, with: [.integer(5)], by: filter, yields: -5)
        try validateEvaluation(of: -10, with: [.integer(5)], by: filter, yields: -15)
        try validateEvaluation(of: -10, with: [.integer(-5)], by: filter, yields: -5)
    }
    
    @Test("Decimal subtraction")
    func decimalSubtraction() throws {
        try validateEvaluation(of: 10.1, with: [.decimal(2.2)], by: filter, yields: Token.Value.decimal(Decimal(string: "7.9")!))
        try validateEvaluation(of: 183.357, with: [.decimal(12)], by: filter, yields: Token.Value.decimal(Decimal(string: "171.357")!))
        try validateEvaluation(of: 5.5, with: [.decimal(10.5)], by: filter, yields: Token.Value.decimal(Decimal(-5.0)))
        try validateEvaluation(of: 0.0, with: [.decimal(3.14)], by: filter, yields: Token.Value.decimal(Decimal(-3.14)))
        try validateEvaluation(of: -5.5, with: [.decimal(2.5)], by: filter, yields: Token.Value.decimal(Decimal(-8.0)))
        try validateEvaluation(of: -5.5, with: [.decimal(-2.5)], by: filter, yields: Token.Value.decimal(Decimal(-3.0)))
    }
    
    @Test("Mixed integer and decimal subtraction")
    func mixedSubtraction() throws {
        // Integer minus decimal returns decimal
        try validateEvaluation(of: 10, with: [.decimal(2.0)], by: filter, yields: Token.Value.decimal(Decimal(8.0)))
        try validateEvaluation(of: 10, with: [.decimal(2.5)], by: filter, yields: Token.Value.decimal(Decimal(7.5)))
        
        // Decimal minus integer returns decimal
        try validateEvaluation(of: 10.0, with: [.integer(2)], by: filter, yields: Token.Value.decimal(Decimal(8.0)))
        try validateEvaluation(of: 10.5, with: [.integer(2)], by: filter, yields: Token.Value.decimal(Decimal(8.5)))
    }
    
    @Test("Zero handling")
    func zeroHandling() throws {
        try validateEvaluation(of: 0, with: [.integer(0)], by: filter, yields: 0)
        try validateEvaluation(of: 5, with: [.integer(0)], by: filter, yields: 5)
        try validateEvaluation(of: 0, with: [.integer(5)], by: filter, yields: -5)
        try validateEvaluation(of: 0.0, with: [.decimal(0.0)], by: filter, yields: Token.Value.decimal(Decimal(0.0)))
    }
    
    // MARK: - String Conversion
    
    @Test("String to number conversion")
    func stringConversion() throws {
        // Basic string numbers
        try validateEvaluation(of: "10", with: [.string("2")], by: filter, yields: 8)
        try validateEvaluation(of: "10.1", with: [.string("2.2")], by: filter, yields: Token.Value.decimal(Decimal(string: "7.9")!))
        try validateEvaluation(of: "16", with: [.integer(4)], by: filter, yields: 12)
        
        // Negative string numbers
        try validateEvaluation(of: "-10", with: [.string("5")], by: filter, yields: -15)
        try validateEvaluation(of: "10", with: [.string("-5")], by: filter, yields: 15)
        
        // Whitespace handling
        try validateEvaluation(of: " 10 ", with: [.string(" 2 ")], by: filter, yields: 8)
        try validateEvaluation(of: "\t10.5\n", with: [.string("0.5")], by: filter, yields: Token.Value.decimal(Decimal(10.0)))
    }
    
    @Test("Non-numeric string handling")
    func nonNumericStrings() throws {
        // Non-numeric strings treated as 0
        try validateEvaluation(of: "foo", with: [.string("2.0")], by: filter, yields: Token.Value.decimal(Decimal(-2.0)))
        try validateEvaluation(of: "hello", with: [.integer(10)], by: filter, yields: -10)
        try validateEvaluation(of: 10, with: [.string("bar")], by: filter, yields: 10)
        try validateEvaluation(of: "abc", with: [.string("xyz")], by: filter, yields: 0)
        
        // Empty strings
        try validateEvaluation(of: "", with: [.integer(5)], by: filter, yields: -5)
        try validateEvaluation(of: 5, with: [.string("")], by: filter, yields: 5)
        try validateEvaluation(of: "", with: [.string("")], by: filter, yields: 0)
        
        // Partially numeric strings
        try validateEvaluation(of: "123abc", with: [.integer(10)], by: filter, yields: -10)
        try validateEvaluation(of: "12.34.56", with: [.integer(5)], by: filter, yields: -5)
    }
    
    // MARK: - Nil Handling
    
    @Test("Nil value handling")
    func nilHandling() throws {
        // Nil treated as 0
        try validateEvaluation(of: Token.Value.nil, with: [.integer(2)], by: filter, yields: -2)
        try validateEvaluation(of: 10, with: [.nil], by: filter, yields: 10)
        try validateEvaluation(of: Token.Value.nil, with: [.nil], by: filter, yields: 0)
        
        // Nil with decimals
        try validateEvaluation(of: Token.Value.nil, with: [.decimal(2.5)], by: filter, yields: Token.Value.decimal(Decimal(-2.5)))
        try validateEvaluation(of: 10.5, with: [.nil], by: filter, yields: Token.Value.decimal(Decimal(10.5)))
    }
    
    // MARK: - Type Preservation
    
    @Test("Integer type preservation")
    func integerTypePreservation() throws {
        // Integer minus integer with whole result preserves integer type
        try validateEvaluation(of: 10, with: [.integer(2)], by: filter, yields: Token.Value.integer(8))
        try validateEvaluation(of: -5, with: [.integer(-3)], by: filter, yields: Token.Value.integer(-2))
        
        // Even when result could be represented as integer, decimal operands return decimal
        try validateEvaluation(of: 10.0, with: [.decimal(2.0)], by: filter, yields: Token.Value.decimal(8.0))
    }
    
    // MARK: - Edge Cases
    
    @Test("Large numbers")
    func largeNumbers() throws {
        let largePositive = Decimal(string: "999999999999999999999999999999")!
        let largeNegative = Decimal(string: "-999999999999999999999999999999")!
        let small = Decimal(1)
        
        try validateEvaluation(
            of: Token.Value.decimal(largePositive),
            with: [.decimal(small)],
            by: filter,
            yields: Token.Value.decimal(largePositive - small)
        )
        
        try validateEvaluation(
            of: Token.Value.decimal(largeNegative),
            with: [.decimal(small)],
            by: filter,
            yields: Token.Value.decimal(largeNegative - small)
        )
    }
    
    @Test("Scientific notation in strings")
    func scientificNotation() throws {
        try validateEvaluation(of: "1e3", with: [.string("2e2")], by: filter, yields: 800)
        try validateEvaluation(of: "5.5e1", with: [.string("5e0")], by: filter, yields: Token.Value.decimal(Decimal(50)))
        try validateEvaluation(of: "-1e2", with: [.string("1e1")], by: filter, yields: -110)
    }
    
    @Test("Special numeric strings")
    func specialNumericStrings() throws {
        // These don't parse as valid numbers, so treated as 0
        try validateEvaluation(of: "Infinity", with: [.integer(5)], by: filter, yields: -5)
        try validateEvaluation(of: "-Infinity", with: [.integer(5)], by: filter, yields: -5)
        try validateEvaluation(of: "NaN", with: [.integer(5)], by: filter, yields: -5)
    }
    
    // MARK: - Non-Numeric Types
    
    @Test("Boolean values treated as 0")
    func booleanValues() throws {
        try validateEvaluation(of: true, with: [.integer(5)], by: filter, yields: -5)
        try validateEvaluation(of: false, with: [.integer(3)], by: filter, yields: -3)
        try validateEvaluation(of: 10, with: [.bool(true)], by: filter, yields: 10)
        try validateEvaluation(of: 10, with: [.bool(false)], by: filter, yields: 10)
    }
    
    @Test("Array values treated as 0")
    func arrayValues() throws {
        try validateEvaluation(of: [1, 2, 3], with: [.integer(5)], by: filter, yields: -5)
        try validateEvaluation(of: 10, with: [.array([.integer(1), .integer(2)])], by: filter, yields: 10)
        try validateEvaluation(of: Token.Value.array([]), with: [.integer(3)], by: filter, yields: -3)
    }
    
    @Test("Dictionary values treated as 0")
    func dictionaryValues() throws {
        try validateEvaluation(of: ["key": "value"], with: [.integer(5)], by: filter, yields: -5)
        try validateEvaluation(of: 10, with: [.dictionary(["a": .integer(1)])], by: filter, yields: 10)
        try validateEvaluation(of: Token.Value.dictionary([:]), with: [.integer(3)], by: filter, yields: -3)
    }
    
    @Test("Range values treated as 0")
    func rangeValues() throws {
        try validateEvaluation(of: Token.Value.range(1...5), with: [.integer(3)], by: filter, yields: -3)
        try validateEvaluation(of: 10, with: [.range(1...5)], by: filter, yields: 10)
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
        try validateEvaluation(of: 10, with: [.integer(3), .integer(5), .integer(7)], by: filter, yields: 7)
        try validateEvaluation(of: 10.5, with: [.decimal(0.5), .string("ignored")], by: filter, yields: Token.Value.decimal(Decimal(10.0)))
    }
    
    // MARK: - Real-World Examples
    
    @Test("Examples from documentation")
    func documentationExamples() throws {
        // From LiquidJS docs
        try validateEvaluation(of: 4, with: [.integer(2)], by: filter, yields: 2)
        try validateEvaluation(of: 16, with: [.integer(4)], by: filter, yields: 12)
        try validateEvaluation(of: 183.357, with: [.integer(12)], by: filter, yields: Token.Value.decimal(Decimal(string: "171.357")!))
        
        // From Python Liquid docs
        try validateEvaluation(of: "16", with: [.integer(4)], by: filter, yields: 12)
        try validateEvaluation(of: 183.357, with: [.decimal(12.2)], by: filter, yields: Token.Value.decimal(Decimal(string: "171.157")!))
        try validateEvaluation(of: "hello", with: [.integer(10)], by: filter, yields: -10)
    }
}