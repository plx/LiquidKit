
import Foundation

/// Implements the `>=` operator, which tests whether the left value is greater than or equal to the right value.
///
/// The greater than or equal operator performs type-aware comparisons. Numeric types (integers and decimals) 
/// can be compared with each other using standard mathematical comparison rules, including equality. Strings 
/// are compared using lexicographic ordering when both operands are strings, also including equality. 
/// Comparing values of incompatible types (such as strings with numbers, or nil with any other type) returns 
/// false, matching the behavior of standard Liquid implementations like liquidjs and python-liquid.
///
/// This operator extends the behavior of the greater than operator (`>`) by also returning true when the
/// operands are equal. It is commonly used in conditional statements and loops to control flow based on
/// inclusive range checks and boundary conditions.
/// 
/// ## Examples
///
/// Basic numeric comparisons:
/// ```liquid
/// {% if 650 >= 100 %}
///   This is true
/// {% endif %}
///
/// {% if 5.5 >= 3.2 %}
///   This is true
/// {% endif %}
///
/// {% if 10 >= 10 %}
///   This is true (includes equality)
/// {% endif %}
///
/// {% if 5 >= 10 %}
///   This is false
/// {% endif %}
/// ```
///
/// Mixed integer and decimal comparisons:
/// ```liquid
/// {% if 10.5 >= 10 %}
///   This is true
/// {% endif %}
///
/// {% if 10 >= 10.0 %}
///   This is true (integers and decimals can be compared)
/// {% endif %}
/// ```
///
/// String comparisons use lexicographic ordering:
/// ```liquid
/// {% if 'bbb' >= 'aaa' %}
///   This is true (lexicographic comparison)
/// {% endif %}
///
/// {% if 'hello' >= 'hello' %}
///   This is true (equality case)
/// {% endif %}
///
/// {% if 'abc' >= 'acb' %}
///   This is false (lexicographic comparison)
/// {% endif %}
/// ```
///
/// Type compatibility:
/// ```liquid
/// {% if 'hello' >= 5 %}
///   This is false (type mismatch)
/// {% endif %}
///
/// {% if true >= false %}
///   This is false (booleans cannot be compared)
/// {% endif %}
/// ```
/// 
/// - Important: This operator requires compatible types for comparison. Comparing strings with
///              numbers, or any non-numeric type with numbers, returns false rather than attempting
///              type coercion. This matches the behavior of liquidjs and python-liquid.
///
/// - Note: Integer and decimal values can be compared with each other through automatic numeric
///         conversion, but all other type combinations are considered incompatible.
/// 
/// - SeeAlso: ``GreaterThanOperator``
/// - SeeAlso: ``LessThanOperator``
/// - SeeAlso: ``LessThanOrEqualOperator``
/// - SeeAlso: [Liquid Operators - Shopify](https://shopify.github.io/liquid/basics/operators/)
/// - SeeAlso: [Comparison Operators - LiquidJS](https://liquidjs.com/tutorials/operators.html#comparisons)
/// - SeeAlso: [Operators - Python Liquid](https://liquid.readthedocs.io/en/latest/guides/liquid-operators.html)
public struct GreaterThanOrEqualOperator: Operator {
  
  public static let operatorIdentifier: String = ">="
  
  public func apply(_ lhs: Token.Value, _ rhs: Token.Value) -> Token.Value {
    // Match types exactly for comparison - follows the same pattern as GreaterThanOperator
    switch (lhs, rhs) {
    // Numeric comparisons: integer and decimal can be compared
    case let (.integer(left), .integer(right)):
      // Direct integer comparison - includes equality
      return .bool(left >= right)
      
    case let (.decimal(left), .decimal(right)):
      // Direct decimal comparison - includes equality
      return .bool(left >= right)
      
    case let (.integer(left), .decimal(right)):
      // Convert integer to decimal for comparison - includes equality
      let leftDecimal = Decimal(left)
      return .bool(leftDecimal >= right)
      
    case let (.decimal(left), .integer(right)):
      // Convert integer to decimal for comparison - includes equality
      let rightDecimal = Decimal(right)
      return .bool(left >= rightDecimal)
      
    // String comparisons: lexicographic ordering with equality
    case let (.string(left), .string(right)):
      // Lexicographic string comparison - includes equality
      return .bool(left >= right)
      
    // All other type combinations return false
    // This matches the behavior of liquidjs/python-liquid where
    // comparing incompatible types either throws an error or returns false
    default:
      return .bool(false)
    }
  }
  
  @inlinable
  package init() { }
}
