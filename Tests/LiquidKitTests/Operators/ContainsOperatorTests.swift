import Testing
@testable import LiquidKit

@Suite("ContainsOperator Tests", .tags(.operator, .containsOperator))
struct ContainsOperatorTests {
  let op = ContainsOperator()
  
  // MARK: - String Contains String
  
  @Test("String contains substring")
  func stringContainsSubstring() throws {
    // Basic substring matching
    try validateApplication(of: op, to: ("hello", "llo"), yields: true)
    try validateApplication(of: op, to: ("hello", "he"), yields: true)
    try validateApplication(of: op, to: ("hello", "o"), yields: true)
    try validateApplication(of: op, to: ("hello world", "world"), yields: true)
    try validateApplication(of: op, to: ("hello world", " "), yields: true)
    
    // No match
    try validateApplication(of: op, to: ("hello", "bye"), yields: false)
    try validateApplication(of: op, to: ("hello", "HELLO"), yields: false) // Case sensitive
    try validateApplication(of: op, to: ("", "hello"), yields: false)
    
    // Empty strings
    try validateApplication(of: op, to: ("hello", ""), yields: true) // Empty string is in every string
    try validateApplication(of: op, to: ("", ""), yields: true)
  }
  
  @Test("String contains number (stringified)")
  func stringContainsNumber() throws {
    // Numbers are stringified when used with contains
    try validateApplication(of: op, to: ("hel9lo", 9), yields: true)
    try validateApplication(of: op, to: ("123456", 23), yields: true)
    try validateApplication(of: op, to: ("price: $99.99", 99), yields: true)
    try validateApplication(of: op, to: ("hello", 9), yields: false)
    
    // Decimal numbers
    try validateApplication(of: op, to: ("price: 12.34", 12.34), yields: true)
    try validateApplication(of: op, to: ("pi=3.14159", 3.14), yields: true)
    try validateApplication(of: op, to: ("hello", 3.14), yields: false)
  }
  
  @Test("String contains nil or undefined")
  func stringContainsNilOrUndefined() throws {
    // String contains nil should be false
    try validateApplication(of: op, to: (.string("hello"), .nil), yields: .bool(false))
    try validateApplication(of: op, to: (.string(""), .nil), yields: .bool(false))
  }
  
  // MARK: - Array Contains
  
  @Test("Array contains string")
  func arrayContainsString() throws {
    // Basic array contains
    let fruits = Token.Value.array([.string("apple"), .string("banana"), .string("orange")])
    try validateApplication(of: op, to: (fruits, .string("banana")), yields: .bool(true))
    try validateApplication(of: op, to: (fruits, .string("apple")), yields: .bool(true))
    try validateApplication(of: op, to: (fruits, .string("grape")), yields: .bool(false))
    
    // Empty cases
    let empty = Token.Value.array([])
    try validateApplication(of: op, to: (empty, .string("anything")), yields: .bool(false))
    try validateApplication(of: op, to: (fruits, .string("")), yields: .bool(false)) // Empty string not in array
  }
  
  @Test("Array contains number (as string)")
  func arrayContainsNumber() throws {
    // Array with string representations of numbers
    let nums = Token.Value.array([.string("1"), .string("2"), .string("3")])
    try validateApplication(of: op, to: (nums, .string("2")), yields: .bool(true))
    try validateApplication(of: op, to: (nums, .integer(2)), yields: .bool(true)) // Number gets stringified
    
    // Array with actual numbers - should stringify for comparison
    let intArray = Token.Value.array([.integer(1), .integer(2), .integer(3)])
    try validateApplication(of: op, to: (intArray, .integer(2)), yields: .bool(true))
    try validateApplication(of: op, to: (intArray, .string("2")), yields: .bool(true))
  }
  
  @Test("Array contains non-string values")
  func arrayContainsNonStringValues() throws {
    // Based on golden liquid tests, arrays can't find non-string values
    let mixed = Token.Value.array([.integer(1), .integer(2), .integer(3), .bool(false)])
    
    // These should return false because contains only works with strings
    try validateApplication(of: op, to: (mixed, .bool(false)), yields: .bool(false))
    
    // But stringified numbers should work
    try validateApplication(of: op, to: (mixed, .integer(2)), yields: .bool(true))
  }
  
  @Test("Array contains nil or undefined")
  func arrayContainsNilOrUndefined() throws {
    let arrayWithNil = Token.Value.array([.integer(1), .integer(2), .nil])
    
    // Should return false for nil/undefined
    try validateApplication(of: op, to: (arrayWithNil, .nil), yields: .bool(false))
  }
  
  // MARK: - Edge Cases
  
  @Test("Number contains (always false)")
  func numberContains() throws {
    // Numbers as left operand should always return false
    try validateApplication(of: op, to: (.integer(123), .string("2")), yields: .bool(false))
    try validateApplication(of: op, to: (.integer(123), .integer(2)), yields: .bool(false))
    try validateApplication(of: op, to: (.decimal(123.456), .string("3")), yields: .bool(false))
    try validateApplication(of: op, to: (.decimal(123.456), .decimal(3.4)), yields: .bool(false))
  }
  
  @Test("Nil/undefined contains (always false)")
  func nilContains() throws {
    // Nil/undefined as left operand should always return false
    try validateApplication(of: op, to: (.nil, .string("hello")), yields: .bool(false))
    try validateApplication(of: op, to: (.nil, .integer(123)), yields: .bool(false))
    try validateApplication(of: op, to: (.nil, .nil), yields: .bool(false))
    try validateApplication(of: op, to: (.nil, .array([])), yields: .bool(false))
  }
  
  @Test("Dictionary/object contains (always false)")
  func dictionaryContains() throws {
    // Dictionaries/objects as left operand should always return false
    let dict = Token.Value.dictionary(["foo": .string("bar")])
    try validateApplication(of: op, to: (dict, .string("foo")), yields: .bool(false))
    try validateApplication(of: op, to: (dict, .string("bar")), yields: .bool(false))
    try validateApplication(of: op, to: (dict, .nil), yields: .bool(false))
  }
  
  @Test("Boolean contains (always false)")
  func booleanContains() throws {
    // Booleans as left operand should always return false
    try validateApplication(of: op, to: (.bool(true), .string("true")), yields: .bool(false))
    try validateApplication(of: op, to: (.bool(false), .string("false")), yields: .bool(false))
    try validateApplication(of: op, to: (.bool(true), .bool(true)), yields: .bool(false))
  }
  
  @Test("Range contains (always false)")
  func rangeContains() throws {
    // Ranges as left operand should always return false
    let range = Token.Value.range(1...5)
    try validateApplication(of: op, to: (range, .integer(3)), yields: .bool(false))
    try validateApplication(of: op, to: (range, .string("3")), yields: .bool(false))
  }
  
  // MARK: - Complex Cases
  
  @Test("Mixed type arrays")
  func mixedTypeArrays() throws {
    // Array with mixed types
    let mixed = Token.Value.array([
      .string("hello"),
      .integer(42),
      .decimal(3.14),
      .bool(true),
      .nil
    ])
    
    // String matches
    try validateApplication(of: op, to: (mixed, .string("hello")), yields: .bool(true))
    
    // Number matches (stringified)
    try validateApplication(of: op, to: (mixed, .integer(42)), yields: .bool(true))
    try validateApplication(of: op, to: (mixed, .string("42")), yields: .bool(true))
    try validateApplication(of: op, to: (mixed, .decimal(3.14)), yields: .bool(true))
    try validateApplication(of: op, to: (mixed, .string("3.14")), yields: .bool(true))
    
    // Boolean and nil don't match
    try validateApplication(of: op, to: (mixed, .bool(true)), yields: .bool(false))
    try validateApplication(of: op, to: (mixed, .string("true")), yields: .bool(false))
    try validateApplication(of: op, to: (mixed, .nil), yields: .bool(false))
  }
  
  @Test("Special string cases")
  func specialStringCases() throws {
    // Unicode and special characters
    try validateApplication(of: op, to: ("Hello 👋 World", "👋"), yields: true)
    try validateApplication(of: op, to: ("Line1\nLine2", "\n"), yields: true)
    try validateApplication(of: op, to: ("Tab\tSeparated", "\t"), yields: true)
    
    // Case sensitivity
    try validateApplication(of: op, to: ("Hello", "hello"), yields: false)
    try validateApplication(of: op, to: ("HELLO", "ello"), yields: false)
    try validateApplication(of: op, to: ("HeLLo", "LL"), yields: true)
  }
}