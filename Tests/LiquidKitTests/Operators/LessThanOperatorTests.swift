import Testing
@testable import LiquidKit

@Suite(.tags(.operator, .lessThanOperator))
struct LessThanOperatorTests {
  
  private let op = LessThanOperator()
  
  // MARK: - Numeric Comparisons
  
  @Test("Integer less than comparisons")
  func integerComparisons() throws {
    // Basic integer comparisons
    try validateApplication(of: op, to: (5, 10), yields: true, "5 < 10")
    try validateApplication(of: op, to: (10, 5), yields: false, "10 < 5")
    try validateApplication(of: op, to: (5, 5), yields: false, "5 < 5")
    
    // Negative integers
    try validateApplication(of: op, to: (-5, 0), yields: true, "-5 < 0")
    try validateApplication(of: op, to: (0, -5), yields: false, "0 < -5")
    try validateApplication(of: op, to: (-10, -5), yields: true, "-10 < -5")
    try validateApplication(of: op, to: (-5, -10), yields: false, "-5 < -10")
    
    // Edge cases
    try validateApplication(of: op, to: (0, 0), yields: false, "0 < 0")
  }
  
  @Test("Decimal less than comparisons")
  func decimalComparisons() throws {
    // Basic decimal comparisons
    try validateApplication(of: op, to: (3.14, 3.15), yields: true, "3.14 < 3.15")
    try validateApplication(of: op, to: (3.15, 3.14), yields: false, "3.15 < 3.14")
    try validateApplication(of: op, to: (3.14, 3.14), yields: false, "3.14 < 3.14")
    
    // Negative decimals
    try validateApplication(of: op, to: (-3.14, -3.13), yields: true, "-3.14 < -3.13")
    try validateApplication(of: op, to: (-3.13, -3.14), yields: false, "-3.13 < -3.14")
    
    // Very small differences
    try validateApplication(of: op, to: (1.0, 1.000001), yields: true, "1.0 < 1.000001")
    try validateApplication(of: op, to: (1.000001, 1.0), yields: false, "1.000001 < 1.0")
  }
  
  @Test("Mixed integer and decimal comparisons")
  func mixedNumericComparisons() throws {
    // Integer vs decimal
    try validateApplication(of: op, to: (5, 5.1), yields: true, "5 < 5.1")
    try validateApplication(of: op, to: (5.1, 5), yields: false, "5.1 < 5")
    try validateApplication(of: op, to: (5, 5.0), yields: false, "5 < 5.0")
    
    // Negative mixed
    try validateApplication(of: op, to: (-5, -4.9), yields: true, "-5 < -4.9")
    try validateApplication(of: op, to: (-4.9, -5), yields: false, "-4.9 < -5")
  }
  
  // MARK: - String Comparisons
  
  @Test("String lexicographic comparisons")
  func stringComparisons() throws {
    // Basic string comparisons (should be lexicographic, not numeric)
    try validateApplication(of: op, to: ("abc", "acb"), yields: true, "'abc' < 'acb'")
    try validateApplication(of: op, to: ("acb", "abc"), yields: false, "'acb' < 'abc'")
    try validateApplication(of: op, to: ("bbb", "aaa"), yields: false, "'bbb' < 'aaa'")
    try validateApplication(of: op, to: ("aaa", "bbb"), yields: true, "'aaa' < 'bbb'")
    
    // Same strings
    try validateApplication(of: op, to: ("hello", "hello"), yields: false, "'hello' < 'hello'")
    
    // Empty strings
    try validateApplication(of: op, to: ("", "a"), yields: true, "'' < 'a'")
    try validateApplication(of: op, to: ("a", ""), yields: false, "'a' < ''")
    try validateApplication(of: op, to: ("", ""), yields: false, "'' < ''")
    
    // Case sensitivity
    try validateApplication(of: op, to: ("A", "a"), yields: true, "'A' < 'a' (ASCII order)")
    try validateApplication(of: op, to: ("a", "A"), yields: false, "'a' < 'A'")
    
    // Longer strings
    try validateApplication(of: op, to: ("apple", "application"), yields: true, "'apple' < 'application'")
    try validateApplication(of: op, to: ("application", "apple"), yields: false, "'application' < 'apple'")
  }
  
  @Test("Numeric string comparisons")
  func numericStringComparisons() throws {
    // Strings that look like numbers should still be compared as strings
    try validateApplication(of: op, to: ("10", "2"), yields: true, "'10' < '2' (lexicographic)")
    try validateApplication(of: op, to: ("2", "10"), yields: false, "'2' < '10'")
    
    // Decimal strings
    try validateApplication(of: op, to: ("3.14", "3.2"), yields: true, "'3.14' < '3.2' (lexicographic)")
    try validateApplication(of: op, to: ("3.2", "3.14"), yields: false, "'3.2' < '3.14'")
    
    // Mixed numeric and non-numeric
    try validateApplication(of: op, to: ("10abc", "2abc"), yields: true, "'10abc' < '2abc'")
    try validateApplication(of: op, to: ("abc10", "abc2"), yields: true, "'abc10' < 'abc2'")
  }
  
  // MARK: - Type Mismatch Comparisons
  
  @Test("String vs numeric comparisons")
  func stringVsNumericComparisons() throws {
    // String vs integer - strings should be greater than numbers in some implementations
    // But we need to check what the expected behavior is
    try validateApplication(of: op, to: ("hello", 100), yields: false, "'hello' < 100")
    try validateApplication(of: op, to: (100, "hello"), yields: true, "100 < 'hello'")
    
    // Numeric string vs number
    try validateApplication(of: op, to: ("42", 100), yields: false, "'42' < 100")
    try validateApplication(of: op, to: (42, "100"), yields: true, "42 < '100'")
  }
  
  @Test("Boolean comparisons")
  func booleanComparisons() throws {
    // Boolean to boolean
    try validateApplication(of: op, to: (false, true), yields: true, "false < true")
    try validateApplication(of: op, to: (true, false), yields: false, "true < false")
    try validateApplication(of: op, to: (true, true), yields: false, "true < true")
    try validateApplication(of: op, to: (false, false), yields: false, "false < false")
    
    // Boolean vs numeric
    try validateApplication(of: op, to: (false, 1), yields: true, "false < 1")
    try validateApplication(of: op, to: (true, 2), yields: true, "true < 2")
    try validateApplication(of: op, to: (true, 0), yields: false, "true < 0")
  }
  
  // MARK: - Nil Comparisons
  
  @Test("Nil comparisons")
  func nilComparisons() throws {
    // Use Token.Value directly for all nil tests
    let nilValue = Token.Value.nil
    let zero = Token.Value.integer(0)
    let five = Token.Value.integer(5)
    let hello = Token.Value.string("hello")
    
    // Nil vs nil
    try validateApplication(of: op, to: (nilValue, nilValue), yields: Token.Value.bool(false), "nil < nil")
    
    // Nil vs numeric
    try validateApplication(of: op, to: (nilValue, zero), yields: Token.Value.bool(false), "nil < 0")
    try validateApplication(of: op, to: (zero, nilValue), yields: Token.Value.bool(false), "0 < nil")
    try validateApplication(of: op, to: (nilValue, five), yields: Token.Value.bool(true), "nil < 5")
    try validateApplication(of: op, to: (five, nilValue), yields: Token.Value.bool(false), "5 < nil")
    
    // Nil vs string
    try validateApplication(of: op, to: (nilValue, hello), yields: Token.Value.bool(true), "nil < 'hello'")
    try validateApplication(of: op, to: (hello, nilValue), yields: Token.Value.bool(false), "'hello' < nil")
  }
  
  // MARK: - Array and Dictionary Comparisons
  
  @Test("Array comparisons")
  func arrayComparisons() throws {
    let array1 = Token.Value.array([.integer(1), .integer(2)])
    let array2 = Token.Value.array([.integer(1), .integer(3)])
    let emptyArray = Token.Value.array([])
    let five = Token.Value.integer(5)
    
    // Arrays should not be comparable (convert to 0.0 in current implementation)
    try validateApplication(of: op, to: (array1, array2), yields: Token.Value.bool(false), "[1, 2] < [1, 3]")
    try validateApplication(of: op, to: (emptyArray, array1), yields: Token.Value.bool(false), "[] < [1, 2]")
    
    // In mixed-type scenarios, arrays come *after* numbers (regardless of contents)
    try validateApplication(of: op, to: (array1, five), yields: Token.Value.bool(false), "[1, 2] < 5")
  }
  
  @Test("Dictionary comparisons")
  func dictionaryComparisons() throws {
    let dict1 = Token.Value.dictionary(["a": .integer(1)])
    let dict2 = Token.Value.dictionary(["b": .integer(2)])
    let emptyDict = Token.Value.dictionary([:])
    let five = Token.Value.integer(5)
    
    // Dictionaries should not be comparable (convert to 0.0 in current implementation)
    try validateApplication(of: op, to: (dict1, dict2), yields: Token.Value.bool(false), "{a: 1} < {b: 2}")
    try validateApplication(of: op, to: (emptyDict, dict1), yields: Token.Value.bool(false), "{} < {a: 1}")
    
    // In mixed-type scenarios, dictionaries come *after* numbers (regardless of contents)
    try validateApplication(of: op, to: (dict1, five), yields: Token.Value.bool(false), "{a: 1} < 5")
  }
  
  // MARK: - Edge Cases
  
//  @Test("Special numeric values")
//  func specialNumericValues() throws {
//    // Infinity comparisons
//    try validateApplication(of: op, to: (Double.infinity, Double.infinity), yields: false, "inf < inf")
//    try validateApplication(of: op, to: (1000.0, Double.infinity), yields: true, "1000 < inf")
//    try validateApplication(of: op, to: (Double.infinity, 1000.0), yields: false, "inf < 1000")
//    try validateApplication(of: op, to: (-Double.infinity, Double.infinity), yields: true, "-inf < inf")
//    
//    // NaN comparisons (NaN is not less than anything, including itself)
//    try validateApplication(of: op, to: (Double.nan, Double.nan), yields: false, "NaN < NaN")
//    try validateApplication(of: op, to: (Double.nan, 0.0), yields: false, "NaN < 0")
//    try validateApplication(of: op, to: (0.0, Double.nan), yields: false, "0 < NaN")
//  }
  
  @Test("Whitespace in strings")
  func whitespaceStrings() throws {
    // Strings with whitespace
    try validateApplication(of: op, to: (" ", "a"), yields: true, "' ' < 'a' (space is ASCII 32)")
    try validateApplication(of: op, to: ("a", " "), yields: false, "'a' < ' '")
    try validateApplication(of: op, to: ("hello", "hello "), yields: true, "'hello' < 'hello '")
    try validateApplication(of: op, to: ("hello ", "hello"), yields: false, "'hello ' < 'hello'")
  }
}
