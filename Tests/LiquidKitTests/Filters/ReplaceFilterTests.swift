import Testing
@testable import LiquidKit

/// Comprehensive tests for the ReplaceFilter implementation.
/// These tests validate that ReplaceFilter matches the behavior of liquidjs and python-liquid.
@Suite(.tags(.filter, .replaceFilter))
struct ReplaceFilterTests {
  
  // MARK: - Basic Functionality
  
  @Test("Basic string replacement")
  func testBasicReplacement() throws {
    let filter = ReplaceFilter()
    
    // Basic replacement
    try validateEvaluation(
      of: "Hello world",
      with: [.string("world"), .string("Liquid")],
      by: filter,
      yields: "Hello Liquid"
    )
    
    // Multiple occurrences
    try validateEvaluation(
      of: "red, red, red",
      with: [.string("red"), .string("blue")],
      by: filter,
      yields: "blue, blue, blue"
    )
    
    // Replace in the middle
    try validateEvaluation(
      of: "Take my protein pills and put my helmet on",
      with: [.string("my"), .string("your")],
      by: filter,
      yields: "Take your protein pills and put your helmet on"
    )
  }
  
  @Test("Empty string handling")
  func testEmptyStrings() throws {
    let filter = ReplaceFilter()
    
    // Remove spaces
    try validateEvaluation(
      of: "Hello world",
      with: [.string(" "), .string("")],
      by: filter,
      yields: "Helloworld"
    )
    
    // Empty search string should insert replacement between every character
    try validateEvaluation(
      of: "test",
      with: [.string(""), .string("X")],
      by: filter,
      yields: "XtXeXsXtX"
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
    let filter = ReplaceFilter()
    
    // Missing replacement parameter should remove the substring
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
      yields: "Take  protein pills and put  helmet on"
    )
  }
  
  @Test("Nil/undefined parameters")
  func testNilParameters() throws {
    let filter = ReplaceFilter()
    
    // Nil first parameter should be treated as empty string
    try validateEvaluation(
      of: "Take my protein",
      with: [.nil, .string("#")],
      by: filter,
      yields: "#T#a#k#e# #m#y# #p#r#o#t#e#i#n#"
    )
    
    // Nil second parameter should be treated as empty string
    try validateEvaluation(
      of: "Take my protein pills and put my helmet on",
      with: [.string("my"), .nil],
      by: filter,
      yields: "Take  protein pills and put  helmet on"
    )
  }
  
  // MARK: - Type Conversion
  
  @Test("Non-string input conversion")
  func testNonStringInputs() throws {
    let filter = ReplaceFilter()
    
    // Integer input should be converted to string
    try validateEvaluation(
      of: 5,
      with: [.string("rain"), .string("foo")],
      by: filter,
      yields: "5"
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
      yields: "[1; 2; 3]"
    )
  }
  
  @Test("Non-string parameter conversion")
  func testNonStringParameters() throws {
    let filter = ReplaceFilter()
    
    // Integer search parameter
    try validateEvaluation(
      of: "hello5world",
      with: [.integer(5), .string("your")],
      by: filter,
      yields: "helloyourworld"
    )
    
    // Integer replacement parameter
    try validateEvaluation(
      of: "hello world",
      with: [.string("world"), .integer(42)],
      by: filter,
      yields: "hello 42"
    )
  }
  
  // MARK: - Edge Cases
  
  @Test("Special characters")
  func testSpecialCharacters() throws {
    let filter = ReplaceFilter()
    
    // Replace dots
    try validateEvaluation(
      of: "1.1.1.1",
      with: [.string("."), .string("-")],
      by: filter,
      yields: "1-1-1-1"
    )
    
    // Replace brackets
    try validateEvaluation(
      of: "[hello]",
      with: [.string("["), .string("(")],
      by: filter,
      yields: "(hello]"
    )
    
    // Replace newlines
    try validateEvaluation(
      of: "line1\nline2",
      with: [.string("\n"), .string(" ")],
      by: filter,
      yields: "line1 line2"
    )
  }
  
  @Test("Overlapping replacements")
  func testOverlappingReplacements() throws {
    let filter = ReplaceFilter()
    
    // Non-overlapping occurrences
    try validateEvaluation(
      of: "aaaa",
      with: [.string("aa"), .string("b")],
      by: filter,
      yields: "bb"
    )
    
    // Replacement doesn't create new matches
    try validateEvaluation(
      of: "abc",
      with: [.string("b"), .string("bb")],
      by: filter,
      yields: "abbc"
    )
  }
  
  // MARK: - Error Cases
  
  @Test("Missing all parameters - should throw error")
  func testMissingAllParameters() throws {
    let filter = ReplaceFilter()
    
    // No parameters should throw an error
    try validateEvaluation(
      of: "hello",
      with: [],
      by: filter,
      throws: TemplateSyntaxError.self
    )
  }
  
  @Test("Too many parameters - should throw error")
  func testTooManyParameters() throws {
    let filter = ReplaceFilter()
    
    // More than 2 parameters should throw an error
    try validateEvaluation(
      of: "hello",
      with: [.string("how"), .string("are"), .string("you")],
      by: filter,
      throws: TemplateSyntaxError.self
    )
  }
  
  // MARK: - Nil Input Handling
  
  @Test("Nil input value")
  func testNilInput() throws {
    let filter = ReplaceFilter()
    
    // Nil input should be converted to empty string
    try validateEvaluation(
      of: Token.Value.nil,
      with: [.string("my"), .string("your")],
      by: filter,
      yields: ""
    )
  }
}