import Testing
@testable import LiquidKit

@Suite(.tags(.operator, .greaterThanOrEqualOperator))
struct GreaterThanOrEqualOperatorTests {
  
  private let op = GreaterThanOrEqualOperator()
  
  // MARK: - Numeric Comparisons
  
  @Test("Integer comparisons")
  func integerComparisons() throws {
    // Basic integer comparisons
    try validateApplication(of: op, to: (5, 3), yields: true)
    try validateApplication(of: op, to: (3, 5), yields: false)
    try validateApplication(of: op, to: (5, 5), yields: true) // equal case
    
    // Negative integers
    try validateApplication(of: op, to: (-3, -5), yields: true)
    try validateApplication(of: op, to: (-5, -3), yields: false)
    try validateApplication(of: op, to: (5, -5), yields: true)
    try validateApplication(of: op, to: (-5, 5), yields: false)
    
    // Zero comparisons
    try validateApplication(of: op, to: (1, 0), yields: true)
    try validateApplication(of: op, to: (0, 1), yields: false)
    try validateApplication(of: op, to: (0, 0), yields: true) // equal case
    try validateApplication(of: op, to: (0, -1), yields: true)
    try validateApplication(of: op, to: (-1, 0), yields: false)
  }
  
  @Test("Decimal comparisons")
  func decimalComparisons() throws {
    // Basic decimal comparisons
    try validateApplication(of: op, to: (5.5, 3.2), yields: true)
    try validateApplication(of: op, to: (3.2, 5.5), yields: false)
    try validateApplication(of: op, to: (5.5, 5.5), yields: true) // equal case
    
    // Small differences
    try validateApplication(of: op, to: (1.0001, 1.0), yields: true)
    try validateApplication(of: op, to: (1.0, 1.0001), yields: false)
    try validateApplication(of: op, to: (1.0, 1.0), yields: true) // equal case
    
    // Zero comparisons
    try validateApplication(of: op, to: (0.1, 0.0), yields: true)
    try validateApplication(of: op, to: (0.0, 0.1), yields: false)
    try validateApplication(of: op, to: (0.0, 0.0), yields: true) // equal case
    try validateApplication(of: op, to: (0.0, -0.1), yields: true)
    try validateApplication(of: op, to: (-0.1, 0.0), yields: false)
  }
  
  @Test("Mixed integer and decimal comparisons")
  func mixedNumericComparisons() throws {
    // Integer vs decimal - greater than
    try validateApplication(of: op, to: (10, 5.5), yields: true)
    try validateApplication(of: op, to: (10.5, 5), yields: true)
    
    // Integer vs decimal - less than
    try validateApplication(of: op, to: (5, 10.5), yields: false)
    try validateApplication(of: op, to: (5.5, 10), yields: false)
    
    // Integer vs decimal - equal
    try validateApplication(of: op, to: (5, 5.0), yields: true)
    try validateApplication(of: op, to: (5.0, 5), yields: true)
    try validateApplication(of: op, to: (0, 0.0), yields: true)
    try validateApplication(of: op, to: (-10.0, -10), yields: true)
    
    // Edge cases
    try validateApplication(of: op, to: (10, 9.999), yields: true)
    try validateApplication(of: op, to: (9.999, 10), yields: false)
  }
  
  // MARK: - String Comparisons
  
  @Test("String comparisons")
  func stringComparisons() throws {
    // Basic string comparisons - greater than
    try validateApplication(of: op, to: ("bbb", "aaa"), yields: true)
    try validateApplication(of: op, to: ("zebra", "apple"), yields: true)
    try validateApplication(of: op, to: ("b", "a"), yields: true)
    
    // Basic string comparisons - less than
    try validateApplication(of: op, to: ("aaa", "bbb"), yields: false)
    try validateApplication(of: op, to: ("apple", "zebra"), yields: false)
    try validateApplication(of: op, to: ("a", "b"), yields: false)
    
    // String equality
    try validateApplication(of: op, to: ("hello", "hello"), yields: true)
    try validateApplication(of: op, to: ("world", "world"), yields: true)
    try validateApplication(of: op, to: ("", ""), yields: true)
    
    // Case sensitivity
    try validateApplication(of: op, to: ("Hello", "hello"), yields: false) // uppercase comes before lowercase
    try validateApplication(of: op, to: ("hello", "Hello"), yields: true)
    try validateApplication(of: op, to: ("ABC", "abc"), yields: false)
    try validateApplication(of: op, to: ("abc", "ABC"), yields: true)
    
    // Empty strings
    try validateApplication(of: op, to: ("", "a"), yields: false)
    try validateApplication(of: op, to: ("a", ""), yields: true)
  }
  
  // MARK: - Type Mismatch Comparisons
  
  @Test("String vs number comparisons return false")
  func stringVsNumber() throws {
    // Strings vs numbers always return false
    try validateApplication(of: op, to: ("hello", 5), yields: false)
    try validateApplication(of: op, to: (10, "world"), yields: false)
    try validateApplication(of: op, to: ("10", 5), yields: false)
    try validateApplication(of: op, to: (5, "10"), yields: false)
    try validateApplication(of: op, to: ("5.5", 5.5), yields: false)
  }
  
  @Test("Boolean comparisons return false")
  func booleanComparisons() throws {
    // Booleans cannot be compared
    try validateApplication(of: op, to: (true, false), yields: false)
    try validateApplication(of: op, to: (false, true), yields: false)
    try validateApplication(of: op, to: (true, true), yields: false)
    try validateApplication(of: op, to: (false, false), yields: false)
  }
  
  @Test("Boolean vs other types return false")
  func booleanVsOtherTypes() throws {
    try validateApplication(of: op, to: (true, 1), yields: false)
    try validateApplication(of: op, to: (false, 0), yields: false)
    try validateApplication(of: op, to: (true, "true"), yields: false)
    try validateApplication(of: op, to: (1, true), yields: false)
    try validateApplication(of: op, to: ("true", false), yields: false)
  }
  
  // MARK: - Edge Cases
  
  @Test("Large number comparisons")
  func largeNumbers() throws {
    let largeInt1 = 999_999_999
    let largeInt2 = 999_999_998
    try validateApplication(of: op, to: (largeInt1, largeInt2), yields: true)
    try validateApplication(of: op, to: (largeInt2, largeInt1), yields: false)
    try validateApplication(of: op, to: (largeInt1, largeInt1), yields: true)
    
    let largeDecimal1 = 999_999_999.99
    let largeDecimal2 = 999_999_999.98
    try validateApplication(of: op, to: (largeDecimal1, largeDecimal2), yields: true)
    try validateApplication(of: op, to: (largeDecimal2, largeDecimal1), yields: false)
    try validateApplication(of: op, to: (largeDecimal1, largeDecimal1), yields: true)
  }
  
  @Test("Very small decimal differences")
  func smallDecimalDifferences() throws {
    let epsilon = 0.000001
    try validateApplication(of: op, to: (1.0 + epsilon, 1.0), yields: true)
    try validateApplication(of: op, to: (1.0, 1.0 + epsilon), yields: false)
    try validateApplication(of: op, to: (1.0, 1.0), yields: true)
  }
}