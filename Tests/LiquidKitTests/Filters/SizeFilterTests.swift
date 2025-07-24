import Testing
import Foundation
@testable import LiquidKit

@Suite(.tags(.filter, .sizeFilter))
struct SizeFilterTests {
  private let filter = SizeFilter()
  
  // MARK: - String Size Tests
  
  @Test("String size returns character count")
  func stringSize() throws {
    // Basic strings
    try validateEvaluation(of: "hello", by: filter, yields: 5)
    try validateEvaluation(of: "Ground control to Major Tom.", by: filter, yields: 28)
    
    // Empty string
    try validateEvaluation(of: "", by: filter, yields: 0)
    
    // Single character
    try validateEvaluation(of: "a", by: filter, yields: 1)
    
    // Unicode characters (emoji)
    try validateEvaluation(of: "👋", by: filter, yields: 1, "Single emoji should count as 1")
    try validateEvaluation(of: "Hello 👋 World", by: filter, yields: 13, "String with emoji")
    try validateEvaluation(of: "🏳️‍🌈", by: filter, yields: 1, "Complex emoji (rainbow flag) should count as 1")
    
    // Multi-byte Unicode characters
    try validateEvaluation(of: "café", by: filter, yields: 4)
    try validateEvaluation(of: "こんにちは", by: filter, yields: 5, "Japanese characters")
    try validateEvaluation(of: "🇺🇸", by: filter, yields: 1, "Flag emoji should count as 1")
    
    // Whitespace
    try validateEvaluation(of: "   ", by: filter, yields: 3, "Spaces count as characters")
    try validateEvaluation(of: "\t\n", by: filter, yields: 2, "Tab and newline count as characters")
  }
  
  // MARK: - Array Size Tests
  
  @Test("Array size returns element count")
  func arraySize() throws {
    // Basic arrays
    try validateEvaluation(of: ["apple", "banana", "cherry"], by: filter, yields: 3)
    try validateEvaluation(of: [1, 2, 3, 4, 5], by: filter, yields: 5)
    
    // Empty array
    try validateEvaluation(of: Token.Value.array([]), by: filter, yields: 0)
    
    // Single element array
    try validateEvaluation(of: ["single"], by: filter, yields: 1)
    
    // Mixed type array
    let mixedArray: [Token.Value] = [
      .string("text"),
      .integer(42),
      .bool(true),
      .nil
    ]
    try validateEvaluation(of: Token.Value.array(mixedArray), by: filter, yields: 4)
    
    // Nested arrays (counts as 1 element each)
    let nestedArray: [Token.Value] = [
      .array([.integer(1), .integer(2)]),
      .array([.integer(3), .integer(4)]),
      .string("not an array")
    ]
    try validateEvaluation(of: Token.Value.array(nestedArray), by: filter, yields: 3)
  }
  
  // MARK: - Dictionary Size Tests
  
  @Test("Dictionary size returns key-value pair count")
  func dictionarySize() throws {
    // Basic dictionaries
    let dict1: [String: Token.Value] = [
      "name": .string("John"),
      "age": .integer(30)
    ]
    try validateEvaluation(of: Token.Value.dictionary(dict1), by: filter, yields: 2)
    
    // Empty dictionary
    try validateEvaluation(of: Token.Value.dictionary([:]), by: filter, yields: 0)
    
    // Single key-value pair
    let singleDict: [String: Token.Value] = ["key": .string("value")]
    try validateEvaluation(of: Token.Value.dictionary(singleDict), by: filter, yields: 1)
    
    // Larger dictionary
    let largeDict: [String: Token.Value] = [
      "first": .string("1"),
      "second": .string("2"),
      "third": .string("3"),
      "fourth": .string("4"),
      "fifth": .string("5")
    ]
    try validateEvaluation(of: Token.Value.dictionary(largeDict), by: filter, yields: 5)
    
    // Dictionary with various value types
    let mixedDict: [String: Token.Value] = [
      "string": .string("text"),
      "number": .integer(42),
      "boolean": .bool(true),
      "null": .nil,
      "array": .array([.integer(1), .integer(2)]),
      "nested": .dictionary(["inner": .string("value")])
    ]
    try validateEvaluation(of: Token.Value.dictionary(mixedDict), by: filter, yields: 6)
  }
  
  // MARK: - Non-Collection Type Tests
  
  @Test("Non-collection types return 0")
  func nonCollectionSize() throws {
    // Numbers
    try validateEvaluation(of: 123, by: filter, yields: 0, "Integer should return 0")
    try validateEvaluation(of: 456.789, by: filter, yields: 0, "Decimal should return 0")
    try validateEvaluation(of: Token.Value.integer(0), by: filter, yields: 0, "Zero should return 0")
    try validateEvaluation(of: Token.Value.integer(-42), by: filter, yields: 0, "Negative integer should return 0")
    
    // Booleans
    try validateEvaluation(of: true, by: filter, yields: 0, "Boolean true should return 0")
    try validateEvaluation(of: false, by: filter, yields: 0, "Boolean false should return 0")
    
    // Nil
    try validateEvaluation(of: Token.Value.nil, by: filter, yields: 0, "Nil should return 0")
    
    // Range (not a collection in this context)
    try validateEvaluation(of: Token.Value.range(1...10), by: filter, yields: 0, "Range should return 0")
  }
  
  // MARK: - Parameter Handling Tests
  
  @Test("Size filter ignores parameters")
  func parameterHandling() throws {
    // The size filter should ignore any parameters passed to it
    // Testing with various input types and parameters
    
    // String with parameters
    try validateEvaluation(
      of: "hello",
      with: [.string("ignored"), .integer(42)],
      by: filter,
      yields: 5,
      "Parameters should be ignored for strings"
    )
    
    // Array with parameters
    try validateEvaluation(
      of: [1, 2, 3],
      with: [.bool(true)],
      by: filter,
      yields: 3,
      "Parameters should be ignored for arrays"
    )
    
    // Dictionary with parameters
    let dict: [String: Token.Value] = ["key": .string("value")]
    try validateEvaluation(
      of: Token.Value.dictionary(dict),
      with: [.nil, .string("test")],
      by: filter,
      yields: 1,
      "Parameters should be ignored for dictionaries"
    )
  }
  
  // MARK: - Edge Cases
  
  @Test("Size filter edge cases")
  func edgeCases() throws {
    // Very long string
    let longString = String(repeating: "a", count: 1000)
    try validateEvaluation(of: longString, by: filter, yields: 1000, "Long string size")
    
    // Large array
    let largeArray = Array(repeating: Token.Value.integer(1), count: 100)
    try validateEvaluation(of: Token.Value.array(largeArray), by: filter, yields: 100, "Large array size")
    
    // String with null characters (should still count)
    let stringWithNull = "hello\0world"
    try validateEvaluation(of: stringWithNull, by: filter, yields: 11, "String with null character")
    
    // Combining characters in Unicode
    let combiningChar = "e\u{0301}" // e + combining acute accent = é
    try validateEvaluation(of: combiningChar, by: filter, yields: 1, "Combining character should count as 1")
  }
}