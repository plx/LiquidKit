import Testing
@testable import LiquidKit

@Suite(.tags(.operator, .greaterThanOperator))
struct GreaterThanOperatorTests {
  
  private let op = GreaterThanOperator()
  
  // MARK: - Numeric Comparisons
  
  @Test("Integer comparisons")
  func integerComparisons() throws {
    // Basic integer comparisons
    try validateApplication(of: op, to: (5, 3), yields: true)
    try validateApplication(of: op, to: (3, 5), yields: false)
    try validateApplication(of: op, to: (5, 5), yields: false) // not greater than, only equal
    
    // Negative integers
    try validateApplication(of: op, to: (-3, -5), yields: true)
    try validateApplication(of: op, to: (-5, -3), yields: false)
    try validateApplication(of: op, to: (5, -5), yields: true)
    try validateApplication(of: op, to: (-5, 5), yields: false)
    
    // Zero comparisons
    try validateApplication(of: op, to: (1, 0), yields: true)
    try validateApplication(of: op, to: (0, 1), yields: false)
    try validateApplication(of: op, to: (0, 0), yields: false)
    try validateApplication(of: op, to: (0, -1), yields: true)
    try validateApplication(of: op, to: (-1, 0), yields: false)
  }
  
  @Test("Decimal comparisons")
  func decimalComparisons() throws {
    // Basic decimal comparisons
    try validateApplication(of: op, to: (5.5, 3.2), yields: true)
    try validateApplication(of: op, to: (3.2, 5.5), yields: false)
    try validateApplication(of: op, to: (5.5, 5.5), yields: false)
    
    // Small differences
    try validateApplication(of: op, to: (1.0001, 1.0), yields: true)
    try validateApplication(of: op, to: (1.0, 1.0001), yields: false)
    
    // Zero comparisons
    try validateApplication(of: op, to: (0.1, 0.0), yields: true)
    try validateApplication(of: op, to: (0.0, 0.1), yields: false)
    try validateApplication(of: op, to: (0.0, -0.1), yields: true)
    try validateApplication(of: op, to: (-0.1, 0.0), yields: false)
  }
  
  @Test("Mixed integer and decimal comparisons")
  func mixedNumericComparisons() throws {
    // Integer vs decimal - should coerce properly
    try validateApplication(of: op, to: (5, 3.5), yields: true)
    try validateApplication(of: op, to: (3, 5.5), yields: false)
    try validateApplication(of: op, to: (5.0, 3), yields: true)
    try validateApplication(of: op, to: (3.0, 5), yields: false)
    
    // Equal values with different types
    try validateApplication(of: op, to: (5, 5.0), yields: false)
    try validateApplication(of: op, to: (5.0, 5), yields: false)
    
    // Edge cases
    try validateApplication(of: op, to: (1, 0.9999), yields: true)
    try validateApplication(of: op, to: (0.9999, 1), yields: false)
  }
  
  // MARK: - String Comparisons
  
  @Test("String lexicographic comparisons")
  func stringComparisons() throws {
    // Basic string comparisons
    try validateApplication(of: op, to: ("bbb", "aaa"), yields: true)
    try validateApplication(of: op, to: ("aaa", "bbb"), yields: false)
    try validateApplication(of: op, to: ("abc", "abc"), yields: false)
    
    // Different lengths
    try validateApplication(of: op, to: ("abc", "ab"), yields: true)
    try validateApplication(of: op, to: ("ab", "abc"), yields: false)
    
    // Empty strings
    try validateApplication(of: op, to: ("a", ""), yields: true)
    try validateApplication(of: op, to: ("", "a"), yields: false)
    try validateApplication(of: op, to: ("", ""), yields: false)
    
    // Case sensitivity
    try validateApplication(of: op, to: ("b", "B"), yields: true) // lowercase > uppercase in ASCII
    try validateApplication(of: op, to: ("B", "b"), yields: false)
    try validateApplication(of: op, to: ("ABC", "abc"), yields: false)
    try validateApplication(of: op, to: ("abc", "ABC"), yields: true)
    
    // Special characters
    try validateApplication(of: op, to: ("a!", "a"), yields: true)
    try validateApplication(of: op, to: ("a", "a!"), yields: false)
    
    // Numbers as strings
    try validateApplication(of: op, to: ("2", "10"), yields: true) // lexicographic: "2" > "10"
    try validateApplication(of: op, to: ("10", "2"), yields: false)
  }
  
  // MARK: - Type Mismatch Handling
  
  @Test("String vs number comparisons should fail or return false")
  func stringNumberComparisons() throws {
    // These should ideally throw errors or return false consistently
    // Current implementation converts to numeric, but standard Liquid throws errors
    
    // String number vs actual number
    try validateApplication(of: op, to: ("5", 3), yields: false)
    try validateApplication(of: op, to: (5, "3"), yields: false)
    try validateApplication(of: op, to: ("5.5", 3.2), yields: false)
    try validateApplication(of: op, to: (5.5, "3.2"), yields: false)
    
    // Non-numeric strings vs numbers
    try validateApplication(of: op, to: ("abc", 5), yields: false)
    try validateApplication(of: op, to: (5, "abc"), yields: false)
    try validateApplication(of: op, to: ("", 0), yields: false)
    try validateApplication(of: op, to: (0, ""), yields: false)
  }
  
  // MARK: - nil Handling
  
  @Test("nil comparisons")
  func nilComparisons() throws {
    // nil compared to nil - type mismatch returns false
    try validateApplication(of: op, to: (Token.Value.nil, Token.Value.nil), yields: Token.Value.bool(false))
    
    // nil compared to numbers - type mismatch returns false
    try validateApplication(of: op, to: (Token.Value.nil, Token.Value.integer(-1)), yields: Token.Value.bool(false))
    try validateApplication(of: op, to: (Token.Value.nil, Token.Value.integer(0)), yields: Token.Value.bool(false))
    try validateApplication(of: op, to: (Token.Value.nil, Token.Value.integer(1)), yields: Token.Value.bool(false))
    try validateApplication(of: op, to: (Token.Value.integer(1), Token.Value.nil), yields: Token.Value.bool(false))
    try validateApplication(of: op, to: (Token.Value.integer(0), Token.Value.nil), yields: Token.Value.bool(false))
    try validateApplication(of: op, to: (Token.Value.integer(-1), Token.Value.nil), yields: Token.Value.bool(false))
    
    // nil compared to other types - type mismatch returns false
    try validateApplication(of: op, to: (Token.Value.nil, Token.Value.string("abc")), yields: Token.Value.bool(false))
    try validateApplication(of: op, to: (Token.Value.nil, Token.Value.bool(true)), yields: Token.Value.bool(false))
    try validateApplication(of: op, to: (Token.Value.nil, Token.Value.array([])), yields: Token.Value.bool(false))
  }
  
  // MARK: - Boolean Handling
  
  @Test("Boolean comparisons")
  func booleanComparisons() throws {
    // Booleans compared to each other - type mismatch returns false
    try validateApplication(of: op, to: (true, false), yields: false)
    try validateApplication(of: op, to: (false, true), yields: false)
    try validateApplication(of: op, to: (true, true), yields: false)
    try validateApplication(of: op, to: (false, false), yields: false)
    
    // Booleans compared to numbers - type mismatch returns false
    try validateApplication(of: op, to: (true, 0), yields: false)
    try validateApplication(of: op, to: (false, -1), yields: false)
    try validateApplication(of: op, to: (true, 2), yields: false)
  }
  
  // MARK: - Collection Handling
  
  @Test("Array comparisons")
  func arrayComparisons() throws {
    // Arrays should not be comparable - type mismatch returns false
    let array1 = Token.Value.array([.integer(1), .integer(2)])
    let array2 = Token.Value.array([.integer(3), .integer(4)])
    let emptyArray = Token.Value.array([])
    
    try validateApplication(of: op, to: (array1, array2), yields: Token.Value.bool(false))
    try validateApplication(of: op, to: (array1, emptyArray), yields: Token.Value.bool(false))
    try validateApplication(of: op, to: (emptyArray, Token.Value.integer(-1)), yields: Token.Value.bool(false))
  }
  
  @Test("Dictionary comparisons")
  func dictionaryComparisons() throws {
    // Dictionaries should not be comparable - type mismatch returns false
    let dict1 = Token.Value.dictionary(["a": .integer(1)])
    let dict2 = Token.Value.dictionary(["b": .integer(2)])
    let emptyDict = Token.Value.dictionary([:])
    
    try validateApplication(of: op, to: (dict1, dict2), yields: Token.Value.bool(false))
    try validateApplication(of: op, to: (dict1, emptyDict), yields: Token.Value.bool(false))
    try validateApplication(of: op, to: (emptyDict, Token.Value.integer(-1)), yields: Token.Value.bool(false))
  }
  
  @Test("Range comparisons")
  func rangeComparisons() throws {
    // Ranges should not be comparable - type mismatch returns false
    let range1 = Token.Value.range(1...3)
    let range2 = Token.Value.range(4...6)
    
    try validateApplication(of: op, to: (range1, range2), yields: Token.Value.bool(false))
    try validateApplication(of: op, to: (range1, Token.Value.integer(-1)), yields: Token.Value.bool(false))
  }
  
  // MARK: - Edge Cases
  
  @Test("Special numeric values")
  func specialNumericValues() throws {
    // Very large numbers
    try validateApplication(of: op, to: (999999999999.0, 1000000.0), yields: true)
    try validateApplication(of: op, to: (1000000.0, 999999999999.0), yields: false)
    
    // Very small differences
    try validateApplication(of: op, to: (1.0000001, 1.0), yields: true)
    try validateApplication(of: op, to: (1.0, 1.0000001), yields: false)
    
    // Negative zero (should be equal to positive zero)
    try validateApplication(of: op, to: (0.0, -0.0), yields: false)
    try validateApplication(of: op, to: (-0.0, 0.0), yields: false)
  }
  
  @Test("Example from documentation")
  func documentationExamples() throws {
    // Examples from the operator documentation
    try validateApplication(of: op, to: (650, 100), yields: true)
    try validateApplication(of: op, to: (5.5, 3.2), yields: true)
    try validateApplication(of: op, to: (10, 10), yields: false)
    
    // String examples
    try validateApplication(of: op, to: ("bbb", "aaa"), yields: true)
    try validateApplication(of: op, to: ("abc", "acb"), yields: false)
  }
}