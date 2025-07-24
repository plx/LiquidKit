import Testing
@testable import LiquidKit

/// Comprehensive tests for the `SliceFilter` implementation.
@Suite(.tags(.filter, .sliceFilter))
struct SliceFilterTests {
  private let filter = SliceFilter()
  
  // MARK: - String Slicing Tests
  
  @Test("Single character extraction from strings")
  func testStringSingleCharacterExtraction() throws {
    // Positive indices
    try validateEvaluation(of: "Liquid", with: [.integer(0)], by: filter, yields: "L")
    try validateEvaluation(of: "Liquid", with: [.integer(2)], by: filter, yields: "q")
    try validateEvaluation(of: "Liquid", with: [.integer(5)], by: filter, yields: "d")
    
    // Negative indices
    try validateEvaluation(of: "Liquid", with: [.integer(-1)], by: filter, yields: "d")
    try validateEvaluation(of: "Liquid", with: [.integer(-2)], by: filter, yields: "i")
    try validateEvaluation(of: "Liquid", with: [.integer(-6)], by: filter, yields: "L")
  }
  
  @Test("Substring extraction with length")
  func testStringSubstringExtraction() throws {
    // Positive start index
    try validateEvaluation(of: "Liquid", with: [.integer(0), .integer(3)], by: filter, yields: "Liq")
    try validateEvaluation(of: "Liquid", with: [.integer(2), .integer(3)], by: filter, yields: "qui")
    try validateEvaluation(of: "Liquid", with: [.integer(2), .integer(5)], by: filter, yields: "quid")
    
    // Negative start index
    try validateEvaluation(of: "Liquid", with: [.integer(-3), .integer(2)], by: filter, yields: "ui")
    try validateEvaluation(of: "Liquid", with: [.integer(-4), .integer(2)], by: filter, yields: "qu")
    
    // Length extends beyond string end
    try validateEvaluation(of: "Liquid", with: [.integer(2), .integer(99)], by: filter, yields: "quid")
    try validateEvaluation(of: "Liquid", with: [.integer(-2), .integer(99)], by: filter, yields: "id")
  }
  
  @Test("String edge cases")
  func testStringEdgeCases() throws {
    // Out of bounds indices
    try validateEvaluation(of: "hello", with: [.integer(99)], by: filter, yields: "")
    try validateEvaluation(of: "hello", with: [.integer(-99)], by: filter, yields: "")
    try validateEvaluation(of: "hello", with: [.integer(5)], by: filter, yields: "")
    try validateEvaluation(of: "hello", with: [.integer(-6)], by: filter, yields: "")
    
    // Zero or negative length
    try validateEvaluation(of: "hello", with: [.integer(1), .integer(0)], by: filter, yields: "")
    try validateEvaluation(of: "hello", with: [.integer(1), .integer(-1)], by: filter, yields: "")
    
    // Empty string
    try validateEvaluation(of: "", with: [.integer(0)], by: filter, yields: "")
    try validateEvaluation(of: "", with: [.integer(0), .integer(5)], by: filter, yields: "")
    
    // No parameters (should return original)
    try validateEvaluation(of: "hello", with: [], by: filter, yields: "hello")
  }
  
  // MARK: - Array Slicing Tests
  
  @Test("Single element extraction from arrays")
  func testArraySingleElementExtraction() throws {
    let beatles: Token.Value = .array(["John", "Paul", "George", "Ringo"].map { .string($0) })
    
    // Positive indices
    try validateEvaluation(of: beatles, with: [.integer(0)], by: filter, yields: "John")
    try validateEvaluation(of: beatles, with: [.integer(1)], by: filter, yields: "Paul")
    try validateEvaluation(of: beatles, with: [.integer(3)], by: filter, yields: "Ringo")
    
    // Negative indices
    try validateEvaluation(of: beatles, with: [.integer(-1)], by: filter, yields: "Ringo")
    try validateEvaluation(of: beatles, with: [.integer(-2)], by: filter, yields: "George")
    try validateEvaluation(of: beatles, with: [.integer(-4)], by: filter, yields: "John")
  }
  
  @Test("Subarray extraction with length")
  func testArraySubarrayExtraction() throws {
    let beatles: Token.Value = .array(["John", "Paul", "George", "Ringo"].map { .string($0) })
    
    // Positive start index
    try validateEvaluation(of: beatles, with: [.integer(0), .integer(2)], by: filter, yields: Token.Value.array(["John", "Paul"].map { .string($0) }))
    try validateEvaluation(of: beatles, with: [.integer(1), .integer(2)], by: filter, yields: Token.Value.array(["Paul", "George"].map { .string($0) }))
    try validateEvaluation(of: beatles, with: [.integer(2), .integer(3)], by: filter, yields: Token.Value.array(["George", "Ringo"].map { .string($0) }))
    
    // Negative start index
    try validateEvaluation(of: beatles, with: [.integer(-3), .integer(2)], by: filter, yields: Token.Value.array(["Paul", "George"].map { .string($0) }))
    try validateEvaluation(of: beatles, with: [.integer(-2), .integer(2)], by: filter, yields: Token.Value.array(["George", "Ringo"].map { .string($0) }))
    
    // Length extends beyond array end
    try validateEvaluation(of: beatles, with: [.integer(2), .integer(99)], by: filter, yields: Token.Value.array(["George", "Ringo"].map { .string($0) }))
    try validateEvaluation(of: beatles, with: [.integer(-2), .integer(99)], by: filter, yields: Token.Value.array(["George", "Ringo"].map { .string($0) }))
  }
  
  @Test("Array edge cases")
  func testArrayEdgeCases() throws {
    let numbers: Token.Value = .array([1, 2, 3, 4, 5].map { .integer($0) })
    
    // Out of bounds indices
    try validateEvaluation(of: numbers, with: [.integer(99)], by: filter, yields: Token.Value.nil)
    try validateEvaluation(of: numbers, with: [.integer(-99)], by: filter, yields: Token.Value.nil)
    try validateEvaluation(of: numbers, with: [.integer(5)], by: filter, yields: Token.Value.nil)
    try validateEvaluation(of: numbers, with: [.integer(-6)], by: filter, yields: Token.Value.nil)
    
    // Zero or negative length
    try validateEvaluation(of: numbers, with: [.integer(1), .integer(0)], by: filter, yields: Token.Value.array([]))
    try validateEvaluation(of: numbers, with: [.integer(1), .integer(-1)], by: filter, yields: Token.Value.array([]))
    
    // Empty array
    let emptyArray: Token.Value = .array([])
    try validateEvaluation(of: emptyArray, with: [.integer(0)], by: filter, yields: Token.Value.nil)
    try validateEvaluation(of: emptyArray, with: [.integer(0), .integer(5)], by: filter, yields: Token.Value.array([]))
    
    // No parameters (should return original)
    try validateEvaluation(of: numbers, with: [], by: filter, yields: numbers)
  }
  
  // MARK: - Type Conversion Tests
  
  @Test("Non-string/array input handling")
  func testNonStringArrayInputs() throws {
    // Numbers converted to strings
    try validateEvaluation(of: 12345, with: [.integer(1)], by: filter, yields: "2")
    try validateEvaluation(of: 12345, with: [.integer(0), .integer(3)], by: filter, yields: "123")
    try validateEvaluation(of: 123.45, with: [.integer(4)], by: filter, yields: "4")
    
    // Boolean converted to string
    try validateEvaluation(of: true, with: [.integer(0)], by: filter, yields: "t")
    try validateEvaluation(of: false, with: [.integer(0), .integer(3)], by: filter, yields: "fal")
    
    // Nil returns empty
    try validateEvaluation(of: Token.Value.nil, with: [.integer(0)], by: filter, yields: "")
    try validateEvaluation(of: Token.Value.nil, with: [.integer(0), .integer(5)], by: filter, yields: "")
    
    // Dictionary returns empty (no string representation)
    let dict: Token.Value = .dictionary(["key": .string("value")])
    try validateEvaluation(of: dict, with: [.integer(0)], by: filter, yields: "")
  }
  
  @Test("Invalid parameter types")
  func testInvalidParameterTypes() throws {
    // Non-integer parameters should be ignored or use 0
    try validateEvaluation(of: "hello", with: [.string("abc")], by: filter, yields: "h")
    try validateEvaluation(of: "hello", with: [.decimal(2.7)], by: filter, yields: "l")
    try validateEvaluation(of: "hello", with: [.bool(true)], by: filter, yields: "h")
    
    // Second parameter non-integer
    try validateEvaluation(of: "hello", with: [.integer(1), .string("abc")], by: filter, yields: "")
    try validateEvaluation(of: "hello", with: [.integer(1), .decimal(2.7)], by: filter, yields: "el")
  }
  
  // MARK: - Compatibility Tests
  
  @Test("Liquidjs/Python-liquid compatibility examples")
  func testCompatibilityExamples() throws {
    // String examples from liquidjs docs
    try validateEvaluation(of: "Liquid", with: [.integer(0)], by: filter, yields: "L")
    try validateEvaluation(of: "Liquid", with: [.integer(2)], by: filter, yields: "q")
    try validateEvaluation(of: "Liquid", with: [.integer(2), .integer(5)], by: filter, yields: "quid")
    try validateEvaluation(of: "Liquid", with: [.integer(-3), .integer(2)], by: filter, yields: "ui")
    
    // Array example from python-liquid docs
    let beatles: Token.Value = .array(["John", "Paul", "George", "Ringo"].map { .string($0) })
    try validateEvaluation(of: beatles, with: [.integer(1), .integer(2)], by: filter, yields: Token.Value.array(["Paul", "George"].map { .string($0) }))
    
    // Negative index array example
    try validateEvaluation(of: "Liquid", with: [.integer(-3)], by: filter, yields: "u")
    try validateEvaluation(of: beatles, with: [.integer(-2), .integer(2)], by: filter, yields: Token.Value.array(["George", "Ringo"].map { .string($0) }))
  }
}