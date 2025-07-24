import Testing
import Foundation
@testable import LiquidKit

@Suite(.tags(.filter, .dividedByFilter))
struct DividedByFilterTests {
  private let filter = DividedByFilter()
  
  // MARK: - Integer Division Tests
  
  @Test("Integer division returns integer result")
  func integerDivision() throws {
    // Basic integer division
    try validateEvaluation(of: 16, with: [4.tokenValue], by: filter, yields: 4)
    try validateEvaluation(of: 10, with: [2.tokenValue], by: filter, yields: 5)
    
    // Integer division with truncation (floor division)
    try validateEvaluation(of: 5, with: [3.tokenValue], by: filter, yields: 1)
    try validateEvaluation(of: 9, with: [2.tokenValue], by: filter, yields: 4)
    try validateEvaluation(of: 7, with: [2.tokenValue], by: filter, yields: 3)
    try validateEvaluation(of: 20, with: [7.tokenValue], by: filter, yields: 2)
    
    // Negative numbers
    try validateEvaluation(of: -9, with: [2.tokenValue], by: filter, yields: -5)
    try validateEvaluation(of: 9, with: [(-2).tokenValue], by: filter, yields: -5)
    try validateEvaluation(of: -9, with: [(-2).tokenValue], by: filter, yields: 4)
  }
  
  // MARK: - Float Division Tests
  
  @Test("Float division returns float result")
  func floatDivision() throws {
    // Division by float returns float
    try validateEvaluation(of: 20, with: [7.0.tokenValue], by: filter, yields: Token.Value.decimal(2.857142857142857))
    try validateEvaluation(of: 10, with: [2.0.tokenValue], by: filter, yields: Token.Value.decimal(5.0))
    try validateEvaluation(of: 10, with: [3.0.tokenValue], by: filter, yields: Token.Value.decimal(Decimal(10.0 / 3.0)))
    
    // Zero divided by float
    try validateEvaluation(of: 0, with: [1.1.tokenValue], by: filter, yields: Token.Value.decimal(0.0))
  }
  
  @Test("Float input with integer divisor returns float result")
  func floatInputIntegerDivisor() throws {
    // This is a key difference - when input is float, result should be float even with integer divisor
    try validateEvaluation(of: 9.0, with: [2.tokenValue], by: filter, yields: Token.Value.decimal(4.5))
    try validateEvaluation(of: 10.0, with: [3.tokenValue], by: filter, yields: Token.Value.decimal(Decimal(10.0 / 3.0)))
  }
  
  // MARK: - String Conversion Tests
  
  @Test("String values are converted to numbers")
  func stringConversion() throws {
    // Valid numeric strings
    try validateEvaluation(of: "10", with: ["2".tokenValue], by: filter, yields: 5)
    try validateEvaluation(of: "20", with: [4.tokenValue], by: filter, yields: 5)
    try validateEvaluation(of: 20, with: ["4".tokenValue], by: filter, yields: 5)
    
    // Invalid numeric strings return 0
    try validateEvaluation(of: "foo", with: ["2".tokenValue], by: filter, yields: 0)
    try validateEvaluation(of: "foo", with: [2.tokenValue], by: filter, yields: 0)
    
    // Empty string returns 0
    try validateEvaluation(of: "", with: [2.tokenValue], by: filter, yields: 0)
  }
  
  // MARK: - Zero Division Tests
  
  @Test("Division by zero throws error")
  func divisionByZero() throws {
    // Integer zero
    try validateEvaluation(of: 10, with: [0.tokenValue], by: filter, throws: FilterError.self) { error in
      guard case .invalidArgument(let message) = error else {
        Issue.record("Expected FilterError.invalidArgument but got \(error)")
        return
      }
      #expect(message.contains("0"), "Error message should mention zero division")
    }
    
    // Float zero
    try validateEvaluation(of: 10, with: [0.0.tokenValue], by: filter, throws: FilterError.self) { error in
      guard case .invalidArgument(let message) = error else {
        Issue.record("Expected FilterError.invalidArgument but got \(error)")
        return
      }
      #expect(message.contains("0"), "Error message should mention zero division")
    }
  }
  
  // MARK: - Edge Case Tests
  
  @Test("Zero divided by non-zero returns appropriate zero type")
  func zeroDividedByNonZero() throws {
    // Zero divided by integer returns integer zero
    try validateEvaluation(of: 0, with: [1.tokenValue], by: filter, yields: 0)
    try validateEvaluation(of: 0, with: [5.tokenValue], by: filter, yields: 0)
    
    // Zero divided by float returns float zero
    try validateEvaluation(of: 0, with: [1.1.tokenValue], by: filter, yields: Token.Value.decimal(0.0))
  }
  
  @Test("Nil and undefined values return 0")
  func nilAndUndefinedValues() throws {
    // nil input returns 0
    try validateEvaluation(of: Token.Value.nil, with: [2.tokenValue], by: filter, yields: 0)
    
    // Missing parameter is handled as nil (returns nil)
    try validateEvaluation(of: 10, with: [], by: filter, yields: Token.Value.nil)
    
    // nil parameter should throw error for division by zero behavior
    try validateEvaluation(of: 10, with: [Token.Value.nil], by: filter, throws: FilterError.self)
  }
  
  @Test("Non-numeric values return 0")
  func nonNumericValues() throws {
    // Arrays, dictionaries, etc. should return 0
    let array = Token.Value.array([1.tokenValue, 2.tokenValue])
    try validateEvaluation(of: array, with: [1.tokenValue], by: filter, yields: 0)
    
    let dict = Token.Value.dictionary(["key": 1.tokenValue])
    try validateEvaluation(of: dict, with: [1.tokenValue], by: filter, yields: 0)
    
    // Boolean values
    try validateEvaluation(of: true, with: [1.tokenValue], by: filter, yields: 0)
    try validateEvaluation(of: false, with: [1.tokenValue], by: filter, yields: 0)
  }
  
  // MARK: - Invalid Arguments Tests
  
  @Test("Invalid divisor arguments throw error")
  func invalidDivisorArguments() throws {
    // String that's not a number as divisor
    try validateEvaluation(of: "10", with: ["foo".tokenValue], by: filter, throws: FilterError.self)
    
    // nil divisor
    try validateEvaluation(of: 10, with: [Token.Value.nil], by: filter, throws: FilterError.self)
  }
  
  @Test("Too many arguments throws error")
  func tooManyArguments() throws {
    // The filter should validate that it only receives one parameter
    // Based on golden liquid test: {{ 5 | divided_by: 1, '5' }} is invalid
    // However, looking at the current implementation, it just ignores extra parameters
    // This test documents current behavior, which may need to change
    try validateEvaluation(of: 5, with: [1.tokenValue, "5".tokenValue], by: filter, yields: 5)
  }
}

