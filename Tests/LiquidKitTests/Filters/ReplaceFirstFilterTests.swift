import Testing
@testable import LiquidKit

/// Comprehensive tests for the ReplaceFirstFilter implementation.
/// These tests validate that ReplaceFirstFilter matches the behavior of liquidjs and python-liquid.
@Suite(.tags(.filter, .replaceFirstFilter))
struct ReplaceFirstFilterTests {
  
  // MARK: - Basic Functionality
  
  @Test("Basic string replacement - first occurrence only")
  func testBasicReplacement() throws {
    let filter = ReplaceFirstFilter()
    
    // Basic replacement of first occurrence
    try validateEvaluation(
      of: "Hello world world",
      with: [.string("world"), .string("Liquid")],
      by: filter,
      yields: "Hello Liquid world"
    )
    
    // Multiple occurrences - only first replaced
    try validateEvaluation(
      of: "red, red, red",
      with: [.string("red"), .string("blue")],
      by: filter,
      yields: "blue, red, red"
    )
    
    // Replace first occurrence in the middle
    try validateEvaluation(
      of: "Take my protein pills and put my helmet on",
      with: [.string("my"), .string("your")],
      by: filter,
      yields: "Take your protein pills and put my helmet on"
    )
  }
  
  @Test("No occurrence - string unchanged")
  func testNoOccurrence() throws {
    let filter = ReplaceFirstFilter()
    
    // Search string doesn't exist
    try validateEvaluation(
      of: "Hello world",
      with: [.string("foo"), .string("bar")],
      by: filter,
      yields: "Hello world"
    )
    
    // Case sensitive - no match
    try validateEvaluation(
      of: "Hello WORLD",
      with: [.string("world"), .string("liquid")],
      by: filter,
      yields: "Hello WORLD"
    )
  }
  
  @Test("Empty string handling")
  func testEmptyStrings() throws {
    let filter = ReplaceFirstFilter()
    
    // Remove first space
    try validateEvaluation(
      of: "Hello world world",
      with: [.string(" "), .string("")],
      by: filter,
      yields: "Helloworld world"
    )
    
    // Empty search string should insert replacement at the beginning
    try validateEvaluation(
      of: "test",
      with: [.string(""), .string("X")],
      by: filter,
      yields: "Xtest"
    )
    
    // Empty input string
    try validateEvaluation(
      of: "",
      with: [.string("x"), .string("y")],
      by: filter,
      yields: ""
    )
  }
  
  // MARK: - Parameter Handling
  
  @Test("Missing second parameter - should default to empty string")
  func testMissingSecondParameter() throws {
    let filter = ReplaceFirstFilter()
    
    // Missing replacement parameter should remove the first occurrence
    try validateEvaluation(
      of: "hello",
      with: [.string("ll")],
      by: filter,
      yields: "heo"
    )
    
    try validateEvaluation(
      of: "Take my protein pills and put my helmet on",
      with: [.string("my")],
      by: filter,
      yields: "Take  protein pills and put my helmet on"
    )
    
    // Multiple occurrences - only first removed
    try validateEvaluation(
      of: "hello hello world",
      with: [.string("hello")],
      by: filter,
      yields: " hello world"
    )
  }
  
  @Test("Nil/undefined parameters")
  func testNilParameters() throws {
    let filter = ReplaceFirstFilter()
    
    // Nil first parameter should be treated as empty string
    try validateEvaluation(
      of: "Take my protein",
      with: [.nil, .string("#")],
      by: filter,
      yields: "#Take my protein"
    )
    
    // Nil second parameter should be treated as empty string
    try validateEvaluation(
      of: "Take my protein pills and put my helmet on",
      with: [.string("my"), .nil],
      by: filter,
      yields: "Take  protein pills and put my helmet on"
    )
  }
  
  // MARK: - Type Conversion
  
  @Test("Non-string input conversion")
  func testNonStringInputs() throws {
    let filter = ReplaceFirstFilter()
    
    // Integer input should be converted to string
    try validateEvaluation(
      of: 5,
      with: [.string("rain"), .string("foo")],
      by: filter,
      yields: "5"
    )
    
    // Integer with actual replacement
    try validateEvaluation(
      of: 12345,
      with: [.string("2"), .string("X")],
      by: filter,
      yields: "1X345"
    )
    
    // Dictionary input should be converted to string representation
    try validateEvaluation(
      of: Token.Value.dictionary([:]),
      with: [.string("{"), .string("!")],
      by: filter,
      yields: "!}"
    )
    
    // Array input
    try validateEvaluation(
      of: Token.Value.array([.integer(1), .integer(2), .integer(3)]),
      with: [.string(","), .string(";")],
      by: filter,
      yields: "[1; 2, 3]"
    )
  }
  
  @Test("Non-string parameter conversion")
  func testNonStringParameters() throws {
    let filter = ReplaceFirstFilter()
    
    // Integer search parameter
    try validateEvaluation(
      of: "hello5world5test",
      with: [.integer(5), .string("X")],
      by: filter,
      yields: "helloXworld5test"
    )
    
    // Integer replacement parameter
    try validateEvaluation(
      of: "hello world world",
      with: [.string("world"), .integer(42)],
      by: filter,
      yields: "hello 42 world"
    )
    
    // Boolean parameters
    try validateEvaluation(
      of: "true false true",
      with: [.bool(true), .string("YES")],
      by: filter,
      yields: "YES false true"
    )
  }
  
  // MARK: - Edge Cases
  
  @Test("Special characters")
  func testSpecialCharacters() throws {
    let filter = ReplaceFirstFilter()
    
    // Replace first dot only
    try validateEvaluation(
      of: "1.1.1.1",
      with: [.string("."), .string("-")],
      by: filter,
      yields: "1-1.1.1"
    )
    
    // Replace first bracket only
    try validateEvaluation(
      of: "[hello][world]",
      with: [.string("["), .string("(")],
      by: filter,
      yields: "(hello][world]"
    )
    
    // Replace first newline only
    try validateEvaluation(
      of: "line1\nline2\nline3",
      with: [.string("\n"), .string(" ")],
      by: filter,
      yields: "line1 line2\nline3"
    )
  }
  
  @Test("Replacement creates new match")
  func testReplacementCreatesNewMatch() throws {
    let filter = ReplaceFirstFilter()
    
    // Replacement doesn't trigger additional replacements
    try validateEvaluation(
      of: "abc",
      with: [.string("b"), .string("bb")],
      by: filter,
      yields: "abbc"
    )
    
    // Replacement that contains search string
    try validateEvaluation(
      of: "hello world",
      with: [.string("hello"), .string("hello hello")],
      by: filter,
      yields: "hello hello world"
    )
  }
  
  @Test("Overlapping patterns")
  func testOverlappingPatterns() throws {
    let filter = ReplaceFirstFilter()
    
    // Only first occurrence replaced
    try validateEvaluation(
      of: "aaaa",
      with: [.string("aa"), .string("b")],
      by: filter,
      yields: "baa"
    )
    
    // Pattern at the beginning
    try validateEvaluation(
      of: "test test test",
      with: [.string("test"), .string("X")],
      by: filter,
      yields: "X test test"
    )
  }
  
  // MARK: - Nil Input Handling
  
  @Test("Nil input value")
  func testNilInput() throws {
    let filter = ReplaceFirstFilter()
    
    // Nil input should be converted to empty string
    try validateEvaluation(
      of: Token.Value.nil,
      with: [.string("my"), .string("your")],
      by: filter,
      yields: ""
    )
  }
  
  // MARK: - Error Cases
  
  @Test("Missing all parameters - should return input unchanged")
  func testMissingAllParameters() throws {
    let filter = ReplaceFirstFilter()
    
    // No parameters - current implementation returns input unchanged
    // This matches liquidjs behavior
    try validateEvaluation(
      of: "hello",
      with: [],
      by: filter,
      yields: "hello"
    )
  }
  
  @Test("Extra parameters - should ignore extras")
  func testExtraParameters() throws {
    let filter = ReplaceFirstFilter()
    
    // Extra parameters should be ignored
    try validateEvaluation(
      of: "hello world world",
      with: [.string("world"), .string("Liquid"), .string("extra"), .string("params")],
      by: filter,
      yields: "hello Liquid world"
    )
  }
}