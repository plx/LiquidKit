import Foundation
import Testing
@testable import LiquidKit

@Suite(.tags(.operator, .lessThanOrEqualOperator))
struct LessThanOrEqualOperatorTests {
  
  let lessThanOrEqualOperator = LessThanOrEqualOperator()
  
  // MARK: - Numeric Comparisons
  
  @Test("Integer less than comparisons")
  func integerLessThan() throws {
    try validateApplication(of: lessThanOrEqualOperator, to: (5, 10), yields: Token.Value.bool(true))
    try validateApplication(of: lessThanOrEqualOperator, to: (-10, -5), yields: Token.Value.bool(true))
    try validateApplication(of: lessThanOrEqualOperator, to: (0, 1), yields: Token.Value.bool(true))
  }
  
  @Test("Integer equal comparisons")
  func integerEqual() throws {
    try validateApplication(of: lessThanOrEqualOperator, to: (10, 10), yields: Token.Value.bool(true))
    try validateApplication(of: lessThanOrEqualOperator, to: (-5, -5), yields: Token.Value.bool(true))
    try validateApplication(of: lessThanOrEqualOperator, to: (0, 0), yields: Token.Value.bool(true))
  }
  
  @Test("Integer greater than comparisons")
  func integerGreaterThan() throws {
    try validateApplication(of: lessThanOrEqualOperator, to: (15, 10), yields: Token.Value.bool(false))
    try validateApplication(of: lessThanOrEqualOperator, to: (-5, -10), yields: Token.Value.bool(false))
    try validateApplication(of: lessThanOrEqualOperator, to: (1, 0), yields: Token.Value.bool(false))
  }
  
  @Test("Decimal less than comparisons")
  func decimalLessThan() throws {
    try validateApplication(of: lessThanOrEqualOperator, to: (3.14, 3.15), yields: Token.Value.bool(true))
    try validateApplication(of: lessThanOrEqualOperator, to: (-2.5, -1.5), yields: Token.Value.bool(true))
    try validateApplication(of: lessThanOrEqualOperator, to: (0.1, 0.2), yields: Token.Value.bool(true))
  }
  
  @Test("Decimal equal comparisons")
  func decimalEqual() throws {
    try validateApplication(of: lessThanOrEqualOperator, to: (3.14, 3.14), yields: Token.Value.bool(true))
    try validateApplication(of: lessThanOrEqualOperator, to: (-1.5, -1.5), yields: Token.Value.bool(true))
    try validateApplication(of: lessThanOrEqualOperator, to: (0.0, 0.0), yields: Token.Value.bool(true))
  }
  
  @Test("Decimal greater than comparisons")
  func decimalGreaterThan() throws {
    try validateApplication(of: lessThanOrEqualOperator, to: (3.15, 3.14), yields: Token.Value.bool(false))
    try validateApplication(of: lessThanOrEqualOperator, to: (-1.5, -2.5), yields: Token.Value.bool(false))
    try validateApplication(of: lessThanOrEqualOperator, to: (0.2, 0.1), yields: Token.Value.bool(false))
  }
  
  @Test("Mixed integer and decimal comparisons")
  func mixedNumericComparisons() throws {
    // Integer <= decimal
    try validateApplication(of: lessThanOrEqualOperator, to: (5, 5.5), yields: Token.Value.bool(true))
    try validateApplication(of: lessThanOrEqualOperator, to: (5, 5.0), yields: Token.Value.bool(true))
    try validateApplication(of: lessThanOrEqualOperator, to: (6, 5.5), yields: Token.Value.bool(false))
    
    // Decimal <= integer
    try validateApplication(of: lessThanOrEqualOperator, to: (4.5, 5), yields: Token.Value.bool(true))
    try validateApplication(of: lessThanOrEqualOperator, to: (5.0, 5), yields: Token.Value.bool(true))
    try validateApplication(of: lessThanOrEqualOperator, to: (5.5, 5), yields: Token.Value.bool(false))
  }
  
  // MARK: - String Comparisons
  
  @Test("String lexicographic less than comparisons")
  func stringLessThan() throws {
    try validateApplication(of: lessThanOrEqualOperator, to: ("abc", "acb"), yields: Token.Value.bool(true))
    try validateApplication(of: lessThanOrEqualOperator, to: ("apple", "banana"), yields: Token.Value.bool(true))
    try validateApplication(of: lessThanOrEqualOperator, to: ("a", "z"), yields: Token.Value.bool(true))
  }
  
  @Test("String equal comparisons")
  func stringEqual() throws {
    try validateApplication(of: lessThanOrEqualOperator, to: ("hello", "hello"), yields: Token.Value.bool(true))
    try validateApplication(of: lessThanOrEqualOperator, to: ("", ""), yields: Token.Value.bool(true))
    try validateApplication(of: lessThanOrEqualOperator, to: ("test", "test"), yields: Token.Value.bool(true))
  }
  
  @Test("String lexicographic greater than comparisons")
  func stringGreaterThan() throws {
    try validateApplication(of: lessThanOrEqualOperator, to: ("acb", "abc"), yields: Token.Value.bool(false))
    try validateApplication(of: lessThanOrEqualOperator, to: ("banana", "apple"), yields: Token.Value.bool(false))
    try validateApplication(of: lessThanOrEqualOperator, to: ("z", "a"), yields: Token.Value.bool(false))
  }
  
  @Test("Numeric strings compared lexicographically")
  func numericStringComparisons() throws {
    // Lexicographic comparison, not numeric
    try validateApplication(of: lessThanOrEqualOperator, to: ("10", "2"), yields: Token.Value.bool(true))
    try validateApplication(of: lessThanOrEqualOperator, to: ("100", "20"), yields: Token.Value.bool(true))
    try validateApplication(of: lessThanOrEqualOperator, to: ("9", "10"), yields: Token.Value.bool(false))
    
    // Equal numeric strings
    try validateApplication(of: lessThanOrEqualOperator, to: ("42", "42"), yields: Token.Value.bool(true))
    try validateApplication(of: lessThanOrEqualOperator, to: ("0", "0"), yields: Token.Value.bool(true))
  }
  
  // MARK: - Boolean Comparisons
  
  @Test("Boolean comparisons where false < true")
  func booleanComparisons() throws {
    // false <= false (equal)
    try validateApplication(of: lessThanOrEqualOperator, to: (false, false), yields: Token.Value.bool(true))
    
    // false <= true (less than)
    try validateApplication(of: lessThanOrEqualOperator, to: (false, true), yields: Token.Value.bool(true))
    
    // true <= false (greater than)
    try validateApplication(of: lessThanOrEqualOperator, to: (true, false), yields: Token.Value.bool(false))
    
    // true <= true (equal)
    try validateApplication(of: lessThanOrEqualOperator, to: (true, true), yields: Token.Value.bool(true))
  }
  
  // MARK: - Nil Comparisons
  
  @Test("Nil comparisons")
  func nilComparisons() throws {
    // Use the dedicated Token.Value validation function for nil comparisons
    // nil <= nil (equal)
    try validateApplication(of: lessThanOrEqualOperator, to: (Token.Value.nil, Token.Value.nil), yields: Token.Value.bool(true))
    
    // nil <= numbers (nil treated as 0)
    try validateApplication(of: lessThanOrEqualOperator, to: (Token.Value.nil, Token.Value.integer(0)), yields: Token.Value.bool(true))
    try validateApplication(of: lessThanOrEqualOperator, to: (Token.Value.nil, Token.Value.integer(1)), yields: Token.Value.bool(true))
    try validateApplication(of: lessThanOrEqualOperator, to: (Token.Value.nil, Token.Value.integer(-1)), yields: Token.Value.bool(false))
    
    // numbers <= nil
    try validateApplication(of: lessThanOrEqualOperator, to: (Token.Value.integer(0), Token.Value.nil), yields: Token.Value.bool(true))
    try validateApplication(of: lessThanOrEqualOperator, to: (Token.Value.integer(-1), Token.Value.nil), yields: Token.Value.bool(true))
    try validateApplication(of: lessThanOrEqualOperator, to: (Token.Value.integer(1), Token.Value.nil), yields: Token.Value.bool(false))
    
    // nil <= strings (nil is less than strings)
    try validateApplication(of: lessThanOrEqualOperator, to: (Token.Value.nil, Token.Value.string("hello")), yields: Token.Value.bool(true))
    try validateApplication(of: lessThanOrEqualOperator, to: (Token.Value.string("hello"), Token.Value.nil), yields: Token.Value.bool(false))
  }
  
  // MARK: - Type Ordering
  
  @Test("Mixed type comparisons follow type ordering")
  func mixedTypeComparisons() throws {
    // Numbers <= strings
    try validateApplication(of: lessThanOrEqualOperator, to: (100, "hello"), yields: Token.Value.bool(true))
    try validateApplication(of: lessThanOrEqualOperator, to: (3.14, "world"), yields: Token.Value.bool(true))
    try validateApplication(of: lessThanOrEqualOperator, to: ("hello", 100), yields: Token.Value.bool(false))
    
    // Booleans <= strings
    try validateApplication(of: lessThanOrEqualOperator, to: (true, "test"), yields: Token.Value.bool(true))
    try validateApplication(of: lessThanOrEqualOperator, to: (false, "test"), yields: Token.Value.bool(true))
    try validateApplication(of: lessThanOrEqualOperator, to: ("test", true), yields: Token.Value.bool(false))
    
    // Numbers <= booleans (bool converts to 0 or 1)
    try validateApplication(of: lessThanOrEqualOperator, to: (0, false), yields: Token.Value.bool(true))
    try validateApplication(of: lessThanOrEqualOperator, to: (0, true), yields: Token.Value.bool(true))
    try validateApplication(of: lessThanOrEqualOperator, to: (1, true), yields: Token.Value.bool(true))
    try validateApplication(of: lessThanOrEqualOperator, to: (2, true), yields: Token.Value.bool(false))
  }
  
  // MARK: - Array and Dictionary Comparisons
  
  @Test("Array comparisons")
  func arrayComparisons() throws {
    let array1 = Token.Value.array([Token.Value.string("a"), Token.Value.string("b"), Token.Value.string("c")])
    let array2 = Token.Value.array([Token.Value.string("a"), Token.Value.string("b"), Token.Value.string("c")])
    
    // Arrays with same content are equal (so <= is true)
    try validateApplication(of: lessThanOrEqualOperator, to: (array1, array2), yields: Token.Value.bool(true))
    
    // Other types <= arrays
    try validateApplication(of: lessThanOrEqualOperator, to: (Token.Value.integer(100), array1), yields: Token.Value.bool(true))
    try validateApplication(of: lessThanOrEqualOperator, to: (Token.Value.string("test"), array1), yields: Token.Value.bool(true))
    try validateApplication(of: lessThanOrEqualOperator, to: (array1, Token.Value.integer(100)), yields: Token.Value.bool(false))
  }
  
  @Test("Dictionary comparisons")
  func dictionaryComparisons() throws {
    let dict1 = Token.Value.dictionary(["key": Token.Value.string("value")])
    let dict2 = Token.Value.dictionary(["key": Token.Value.string("value")])
    
    // Dictionaries with same content are equal (so <= is true)
    try validateApplication(of: lessThanOrEqualOperator, to: (dict1, dict2), yields: Token.Value.bool(true))
    
    // Other types <= dictionaries
    try validateApplication(of: lessThanOrEqualOperator, to: (Token.Value.integer(100), dict1), yields: Token.Value.bool(true))
    try validateApplication(of: lessThanOrEqualOperator, to: (Token.Value.string("test"), dict1), yields: Token.Value.bool(true))
    try validateApplication(of: lessThanOrEqualOperator, to: (dict1, Token.Value.integer(100)), yields: Token.Value.bool(false))
    
    // Arrays <= dictionaries
    let array = Token.Value.array([Token.Value.string("a"), Token.Value.string("b")])
    try validateApplication(of: lessThanOrEqualOperator, to: (array, dict1), yields: Token.Value.bool(true))
    try validateApplication(of: lessThanOrEqualOperator, to: (dict1, array), yields: Token.Value.bool(false))
  }
  
  // MARK: - Edge Cases
  
  @Test("Range comparisons")
  func rangeComparisons() throws {
    let range1 = Token.Value.range(1...3)
    let range2 = Token.Value.range(1...3)
    
    // Ranges with same bounds are equal (so <= is true)
    try validateApplication(of: lessThanOrEqualOperator, to: (range1, range2), yields: Token.Value.bool(true))
    
    // Other types <= range
    try validateApplication(of: lessThanOrEqualOperator, to: (Token.Value.string("test"), range1), yields: Token.Value.bool(true))
    try validateApplication(of: lessThanOrEqualOperator, to: (Token.Value.integer(100), range1), yields: Token.Value.bool(true))
    try validateApplication(of: lessThanOrEqualOperator, to: (range1, Token.Value.string("test")), yields: Token.Value.bool(false))
  }
}