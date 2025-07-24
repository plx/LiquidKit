import Testing
@testable import LiquidKit

/// Comprehensive tests for the RemoveFirstFilter implementation.
/// These tests validate that RemoveFirstFilter matches the behavior of liquidjs and python-liquid.
@Suite(.tags(.filter, .removeFirstFilter))
struct RemoveFirstFilterTests {
  
  // MARK: - Basic Functionality
  
  @Test("Basic string removal - removes only first occurrence")
  func testBasicRemoval() throws {
    let filter = RemoveFirstFilter()
    
    // Example from documentation
    try validateEvaluation(
      of: "I strained to see the train through the rain",
      with: [.string("rain")],
      by: filter,
      yields: "I sted to see the train through the rain"
    )
    
    // Multiple occurrences - only first removed
    try validateEvaluation(
      of: "aaabbbccc",
      with: [.string("b")],
      by: filter,
      yields: "aaabbccc"
    )
    
    // Multiple words
    try validateEvaluation(
      of: "one, two, one, three, one",
      with: [.string("one")],
      by: filter,
      yields: ", two, one, three, one"
    )
    
    // URL example
    try validateEvaluation(
      of: "http://http://example.com",
      with: [.string("http://")],
      by: filter,
      yields: "http://example.com"
    )
  }
  
  @Test("No match found - returns original string")
  func testNoMatch() throws {
    let filter = RemoveFirstFilter()
    
    try validateEvaluation(
      of: "Hello, world!",
      with: [.string("xyz")],
      by: filter,
      yields: "Hello, world!"
    )
    
    try validateEvaluation(
      of: "testing",
      with: [.string("not found")],
      by: filter,
      yields: "testing"
    )
  }
  
  @Test("Empty string handling")
  func testEmptyStrings() throws {
    let filter = RemoveFirstFilter()
    
    // Remove from empty string
    try validateEvaluation(
      of: "",
      with: [.string("test")],
      by: filter,
      yields: ""
    )
    
    // Remove empty string (should return original)
    try validateEvaluation(
      of: "Hello world",
      with: [.string("")],
      by: filter,
      yields: "Hello world"
    )
    
    // Both empty
    try validateEvaluation(
      of: "",
      with: [.string("")],
      by: filter,
      yields: ""
    )
  }
  
  @Test("Special characters and edge cases")
  func testSpecialCharacters() throws {
    let filter = RemoveFirstFilter()
    
    // Newlines
    try validateEvaluation(
      of: "Line 1\nLine 2\nLine 3",
      with: [.string("\n")],
      by: filter,
      yields: "Line 1Line 2\nLine 3"
    )
    
    // Tabs
    try validateEvaluation(
      of: "A\tB\tC\tD",
      with: [.string("\t")],
      by: filter,
      yields: "AB\tC\tD"
    )
    
    // Unicode
    try validateEvaluation(
      of: "🎉 Party 🎉 Time 🎉",
      with: [.string("🎉")],
      by: filter,
      yields: " Party 🎉 Time 🎉"
    )
    
    // Special regex characters (should be treated literally)
    try validateEvaluation(
      of: "test.* and test.* again",
      with: [.string("test.*")],
      by: filter,
      yields: " and test.* again"
    )
  }
  
  @Test("Substring at different positions")
  func testSubstringPositions() throws {
    let filter = RemoveFirstFilter()
    
    // At beginning
    try validateEvaluation(
      of: "hello world",
      with: [.string("hello")],
      by: filter,
      yields: " world"
    )
    
    // At end (only first occurrence)
    try validateEvaluation(
      of: "world hello hello",
      with: [.string("hello")],
      by: filter,
      yields: "world  hello"
    )
    
    // Entire string
    try validateEvaluation(
      of: "test",
      with: [.string("test")],
      by: filter,
      yields: ""
    )
    
    // Overlapping patterns
    try validateEvaluation(
      of: "aaaa",
      with: [.string("aa")],
      by: filter,
      yields: "aa"
    )
  }
  
  // MARK: - Non-String Input Handling
  
  @Test("Non-string input coercion - matches python-liquid")
  func testNonStringInputCoercion() throws {
    let filter = RemoveFirstFilter()
    
    // Integer - coerced to string
    try validateEvaluation(
      of: 123,
      with: [.string("2")],
      by: filter,
      yields: "13"  // "123" -> "13"
    )
    
    // Decimal - coerced to string
    try validateEvaluation(
      of: 45.67,
      with: [.string("5")],
      by: filter,
      yields: "4.67"  // "45.67" -> "4.67"
    )
    
    // Boolean - coerced to "true" or "false"
    try validateEvaluation(
      of: true,
      with: [.string("true")],
      by: filter,
      yields: ""  // "true" -> ""
    )
    
    try validateEvaluation(
      of: false,
      with: [.string("al")],
      by: filter,
      yields: "fse"  // "false" -> "fse"
    )
    
    // Nil - coerced to empty string
    try validateEvaluation(
      of: Token.Value.nil,
      with: [.string("test")],
      by: filter,
      yields: ""  // "" -> ""
    )
    
    // Array - not coerced, returns unchanged
    try validateEvaluation(
      of: ["a", "b", "c"],
      with: [.string("b")],
      by: filter,
      yields: ["a", "b", "c"]
    )
    
    // Dictionary - not coerced, returns unchanged
    try validateEvaluation(
      of: ["key": "value"],
      with: [.string("key")],
      by: filter,
      yields: ["key": "value"]
    )
  }
  
  // MARK: - Parameter Validation
  
  @Test("Missing or invalid parameters")
  func testInvalidParameters() throws {
    let filter = RemoveFirstFilter()
    
    // No parameters - returns original
    try validateEvaluation(
      of: "Hello world",
      with: [],
      by: filter,
      yields: "Hello world"
    )
    
    // Integer parameter - coerced to string
    try validateEvaluation(
      of: "Hello 123 world",
      with: [.integer(123)],
      by: filter,
      yields: "Hello  world"
    )
    
    // Nil parameter - returns original
    try validateEvaluation(
      of: "Hello world",
      with: [.nil],
      by: filter,
      yields: "Hello world"
    )
    
    // Extra parameters (should be ignored)
    try validateEvaluation(
      of: "red red red",
      with: [.string("red"), .string("blue"), .string("green")],
      by: filter,
      yields: " red red"
    )
  }
  
  @Test("Parameter coercion - matches python-liquid")
  func testParameterCoercion() throws {
    let filter = RemoveFirstFilter()
    
    // Integer parameter
    try validateEvaluation(
      of: "Price is 99 dollars",
      with: [.integer(99)],
      by: filter,
      yields: "Price is  dollars"
    )
    
    // Decimal parameter
    try validateEvaluation(
      of: "Value: 3.14159",
      with: [.decimal(3.14159)],
      by: filter,
      yields: "Value: "
    )
    
    // Boolean parameter
    try validateEvaluation(
      of: "This is true",
      with: [.bool(true)],
      by: filter,
      yields: "This is "
    )
    
    // Array parameter - not coerced
    try validateEvaluation(
      of: "test array",
      with: [.array([.string("test")])],
      by: filter,
      yields: "test array"
    )
  }
  
  @Test("Case sensitivity")
  func testCaseSensitivity() throws {
    let filter = RemoveFirstFilter()
    
    // Case sensitive - no match
    try validateEvaluation(
      of: "Hello WORLD",
      with: [.string("world")],
      by: filter,
      yields: "Hello WORLD"
    )
    
    // Case sensitive - match
    try validateEvaluation(
      of: "Hello WORLD world",
      with: [.string("WORLD")],
      by: filter,
      yields: "Hello  world"
    )
  }
  
  @Test("Complex patterns")
  func testComplexPatterns() throws {
    let filter = RemoveFirstFilter()
    
    // Multi-word substring
    try validateEvaluation(
      of: "The quick brown fox jumps over the quick brown dog",
      with: [.string("quick brown")],
      by: filter,
      yields: "The  fox jumps over the quick brown dog"
    )
    
    // Substring with punctuation
    try validateEvaluation(
      of: "Hello, world! Hello, universe!",
      with: [.string("Hello,")],
      by: filter,
      yields: " world! Hello, universe!"
    )
    
    // Repeated characters
    try validateEvaluation(
      of: "aaabbbaaabbb",
      with: [.string("aaa")],
      by: filter,
      yields: "bbbaaabbb"
    )
  }
}

