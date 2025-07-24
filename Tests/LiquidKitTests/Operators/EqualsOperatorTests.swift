import Testing
@testable import LiquidKit

@Suite(.tags(.operator, .equalsOperator))
struct EqualsOperatorTests {
  
  private let op = EqualsOperator()
  
  // MARK: - Basic Type Equality
  
  @Test("String equality")
  func stringEquality() throws {
    // Same strings are equal
    try validateApplication(of: op, to: ("hello", "hello"), yields: true)
    try validateApplication(of: op, to: ("", ""), yields: true)
    try validateApplication(of: op, to: ("with spaces", "with spaces"), yields: true)
    
    // Different strings are not equal
    try validateApplication(of: op, to: ("hello", "world"), yields: false)
    try validateApplication(of: op, to: ("Hello", "hello"), yields: false) // case sensitive
    try validateApplication(of: op, to: ("", " "), yields: false)
  }
  
  @Test("Integer equality")
  func integerEquality() throws {
    // Same integers are equal
    try validateApplication(of: op, to: (42, 42), yields: true)
    try validateApplication(of: op, to: (0, 0), yields: true)
    try validateApplication(of: op, to: (-5, -5), yields: true)
    
    // Different integers are not equal
    try validateApplication(of: op, to: (42, 43), yields: false)
    try validateApplication(of: op, to: (0, 1), yields: false)
    try validateApplication(of: op, to: (-5, 5), yields: false)
  }
  
  @Test("Boolean equality")
  func booleanEquality() throws {
    // Same booleans are equal
    try validateApplication(of: op, to: (true, true), yields: true)
    try validateApplication(of: op, to: (false, false), yields: true)
    
    // Different booleans are not equal
    try validateApplication(of: op, to: (true, false), yields: false)
    try validateApplication(of: op, to: (false, true), yields: false)
  }
  
  @Test("Decimal equality")
  func decimalEquality() throws {
    // Same decimals are equal
    try validateApplication(of: op, to: (3.14, 3.14), yields: true)
    try validateApplication(of: op, to: (0.0, 0.0), yields: true)
    try validateApplication(of: op, to: (-2.5, -2.5), yields: true)
    
    // Different decimals are not equal
    try validateApplication(of: op, to: (3.14, 3.15), yields: false)
    try validateApplication(of: op, to: (0.0, 0.1), yields: false)
  }
  
  // MARK: - Type Coercion Tests
  
  @Test("No type coercion between string and number")
  func noStringNumberCoercion() throws {
    // String "1" is NOT equal to integer 1
    try validateApplication(of: op, to: ("1", 1), yields: false)
    try validateApplication(of: op, to: (1, "1"), yields: false)
    
    // String "0" is NOT equal to integer 0
    try validateApplication(of: op, to: ("0", 0), yields: false)
    try validateApplication(of: op, to: (0, "0"), yields: false)
    
    // String "1.0" is NOT equal to decimal 1.0
    try validateApplication(of: op, to: ("1.0", 1.0), yields: false)
    try validateApplication(of: op, to: (1.0, "1.0"), yields: false)
  }
  
  @Test("No type coercion between number and boolean")
  func noNumberBooleanCoercion() throws {
    // Integer 0 is NOT equal to false
    try validateApplication(of: op, to: (0, false), yields: false)
    try validateApplication(of: op, to: (false, 0), yields: false)
    
    // Integer 1 is NOT equal to true
    try validateApplication(of: op, to: (1, true), yields: false)
    try validateApplication(of: op, to: (true, 1), yields: false)
    
    // Decimal 0.0 is NOT equal to false
    try validateApplication(of: op, to: (0.0, false), yields: false)
    try validateApplication(of: op, to: (false, 0.0), yields: false)
  }
  
  @Test("Numeric type coercion")
  func numericTypeCoercion() throws {
    // Integer and decimal with same value ARE equal
    try validateApplication(of: op, to: (1, 1.0), yields: true)
    try validateApplication(of: op, to: (1.0, 1), yields: true)
    try validateApplication(of: op, to: (0, 0.0), yields: true)
    try validateApplication(of: op, to: (-5, -5.0), yields: true)
    
    // But not when values differ
    try validateApplication(of: op, to: (1, 1.1), yields: false)
    try validateApplication(of: op, to: (1.5, 1), yields: false)
  }
  
  // MARK: - nil/null/undefined Tests
  
  @Test("nil equality")
  func nilEquality() throws {
    // nil equals nil
    try validateApplication(of: op, to: (Token.Value.nil, Token.Value.nil), yields: Token.Value.bool(true))
    
    // nil does not equal other types
    try validateApplication(of: op, to: (Token.Value.nil, Token.Value.string("")), yields: Token.Value.bool(false))
    try validateApplication(of: op, to: (Token.Value.nil, Token.Value.integer(0)), yields: Token.Value.bool(false))
    try validateApplication(of: op, to: (Token.Value.nil, Token.Value.bool(false)), yields: Token.Value.bool(false))
    try validateApplication(of: op, to: (Token.Value.nil, Token.Value.array([])), yields: Token.Value.bool(false))
    try validateApplication(of: op, to: (Token.Value.nil, Token.Value.dictionary([:])), yields: Token.Value.bool(false))
  }
  
  // MARK: - Collection Tests
  
  @Test("Array equality")
  func arrayEquality() throws {
    // Empty arrays are equal
    try validateApplication(of: op, to: ([] as [Int], [] as [Int]), yields: true)
    
    // Arrays with same elements in same order are equal
    try validateApplication(of: op, to: ([1, 2, 3], [1, 2, 3]), yields: true)
    try validateApplication(of: op, to: (["a", "b"], ["a", "b"]), yields: true)
    
    // Arrays with different elements are not equal
    try validateApplication(of: op, to: ([1, 2, 3], [1, 2, 4]), yields: false)
    try validateApplication(of: op, to: ([1, 2], [1, 2, 3]), yields: false)
    try validateApplication(of: op, to: ([1, 2, 3], [1, 2]), yields: false)
    
    // Arrays with same elements in different order are not equal
    try validateApplication(of: op, to: ([1, 2, 3], [3, 2, 1]), yields: false)
    
    // Mixed type arrays - use Token.Value directly
    let mixedArray1 = Token.Value.array([.integer(1), .string("2"), .bool(true)])
    let mixedArray2 = Token.Value.array([.integer(1), .string("2"), .bool(true)])
    let mixedArray3 = Token.Value.array([.integer(1), .integer(2), .bool(true)])
    try validateApplication(of: op, to: (mixedArray1, mixedArray2), yields: Token.Value.bool(true))
    try validateApplication(of: op, to: (mixedArray1, mixedArray3), yields: Token.Value.bool(false))
  }
  
  @Test("Dictionary equality")
  func dictionaryEquality() throws {
    // Empty dictionaries are equal
    try validateApplication(of: op, to: (Token.Value.dictionary([:]), Token.Value.dictionary([:])), yields: Token.Value.bool(true))
    
    // Dictionaries with same key-value pairs are equal
    try validateApplication(of: op, to: (["a": 1, "b": 2], ["a": 1, "b": 2]), yields: true)
    try validateApplication(of: op, to: (["x": "hello"], ["x": "hello"]), yields: true)
    
    // Order doesn't matter for dictionaries
    try validateApplication(of: op, to: (["a": 1, "b": 2], ["b": 2, "a": 1]), yields: true)
    
    // Different values are not equal
    try validateApplication(of: op, to: (["a": 1], ["a": 2]), yields: false)
    try validateApplication(of: op, to: (["a": 1], ["b": 1]), yields: false)
    try validateApplication(of: op, to: (["a": 1], ["a": 1, "b": 2]), yields: false)
  }
  
  @Test("Range equality")
  func rangeEquality() throws {
    // Same ranges are equal
    try validateApplication(of: op, to: (1...3, 1...3), yields: true)
    try validateApplication(of: op, to: (0...0, 0...0), yields: true)
    try validateApplication(of: op, to: (-5...(-1), -5...(-1)), yields: true)
    
    // Different ranges are not equal
    try validateApplication(of: op, to: (1...3, 1...4), yields: false)
    try validateApplication(of: op, to: (1...3, 2...3), yields: false)
    try validateApplication(of: op, to: (1...3, 1...2), yields: false)
  }
  
  // MARK: - Cross-type Comparisons
  
  @Test("Different types are not equal")
  func differentTypesNotEqual() throws {
    // String vs other types
    try validateApplication(of: op, to: ("true", true), yields: false)
    try validateApplication(of: op, to: ("false", false), yields: false)
    try validateApplication(of: op, to: (Token.Value.string("[]"), Token.Value.array([])), yields: Token.Value.bool(false))
    try validateApplication(of: op, to: (Token.Value.string("{}"), Token.Value.dictionary([:])), yields: Token.Value.bool(false))
    
    // Array vs other types
    try validateApplication(of: op, to: ([1], 1), yields: false)
    try validateApplication(of: op, to: (Token.Value.array([]), Token.Value.bool(false)), yields: Token.Value.bool(false))
    try validateApplication(of: op, to: (Token.Value.array([]), Token.Value.string("")), yields: Token.Value.bool(false))
    
    // Range vs other types
    try validateApplication(of: op, to: (Token.Value.range(1...3), Token.Value.array([.integer(1), .integer(2), .integer(3)])), yields: Token.Value.bool(false))
    try validateApplication(of: op, to: (Token.Value.range(1...1), Token.Value.integer(1)), yields: Token.Value.bool(false))
  }
  
  // MARK: - Special Cases
  
  @Test("Self equality")
  func selfEquality() throws {
    // Every value should equal itself
    let values: [Token.Value] = [
      .nil,
      .bool(true),
      .bool(false),
      .string("hello"),
      .string(""),
      .integer(42),
      .integer(0),
      .integer(-5),
      .decimal(3.14),
      .decimal(0.0),
      .array([.integer(1), .integer(2)]),
      .dictionary(["key": .string("value")]),
      .range(1...5)
    ]
    
    for value in values {
      try validateApplication(of: op, to: (value, value), yields: Token.Value.bool(true), "Value should equal itself: \(value)")
    }
  }
  
  @Test("Empty special value")
  func emptySpecialValue() throws {
    // Note: The golden liquid tests mention that empty arrays/objects should equal
    // the special 'empty' value. However, LiquidKit doesn't seem to have a special
    // 'empty' value in Token.Value enum. This test documents the current behavior.
    
    // Empty arrays and dictionaries are not equal to nil
    try validateApplication(of: op, to: (Token.Value.array([]), Token.Value.nil), yields: Token.Value.bool(false))
    try validateApplication(of: op, to: (Token.Value.dictionary([:]), Token.Value.nil), yields: Token.Value.bool(false))
    
    // Empty string is not equal to nil
    try validateApplication(of: op, to: (Token.Value.string(""), Token.Value.nil), yields: Token.Value.bool(false))
  }
  
  // MARK: - Edge Cases
  
  @Test("Nested collections")
  func nestedCollections() throws {
    // Nested arrays
    let nestedArray1 = Token.Value.array([.integer(1), .array([.integer(2), .integer(3)])])
    let nestedArray2 = Token.Value.array([.integer(1), .array([.integer(2), .integer(3)])])
    let nestedArray3 = Token.Value.array([.integer(1), .array([.integer(2), .integer(4)])])
    
    try validateApplication(of: op, to: (nestedArray1, nestedArray2), yields: Token.Value.bool(true))
    try validateApplication(of: op, to: (nestedArray1, nestedArray3), yields: Token.Value.bool(false))
    
    // Nested dictionaries
    let nestedDict1 = Token.Value.dictionary(["a": .integer(1), "b": .dictionary(["c": .integer(2)])])
    let nestedDict2 = Token.Value.dictionary(["a": .integer(1), "b": .dictionary(["c": .integer(2)])])
    let nestedDict3 = Token.Value.dictionary(["a": .integer(1), "b": .dictionary(["c": .integer(3)])])
    
    try validateApplication(of: op, to: (nestedDict1, nestedDict2), yields: Token.Value.bool(true))
    try validateApplication(of: op, to: (nestedDict1, nestedDict3), yields: Token.Value.bool(false))
  }
  
  @Test("Decimal precision")
  func decimalPrecision() throws {
    // Test decimal comparison with different representations
    try validateApplication(of: op, to: (1.0, 1.00), yields: true)
    
    // Note: 0.1 + 0.2 != 0.3 due to floating-point representation
    // This is expected behavior and matches how liquidjs/python-liquid work
    try validateApplication(of: op, to: (0.1 + 0.2, 0.3), yields: false)
    
    // Very close but different values
    try validateApplication(of: op, to: (1.0, 1.0000001), yields: false)
  }
}

