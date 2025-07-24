
import Foundation

/// Implements the `==` operator, which tests whether two values are equal.
/// 
/// The equality operator performs strict equality comparison between two values. It is commonly used
/// in conditional tags like `if`, `unless`, and `case` to control template flow based on whether
/// values match. The operator uses Swift's standard equality semantics, which means values must be
/// of the same type and have the same content to be considered equal.
/// 
/// The equality operator is mostly strict about types. String `"1"` is not equal to integer `1`, 
/// and integer `0` is not equal to boolean `false`. However, numeric values are compared by their
/// mathematical value, so integer `1` equals decimal `1.0`. This behavior matches liquidjs and 
/// python-liquid implementations.
/// 
/// Arrays and dictionaries are compared by their contents, not by reference. Two arrays with the
/// same elements in the same order are considered equal, as are two dictionaries with the same
/// key-value pairs. Range values are equal if they have the same bounds. The special values `nil`
/// and `null` are considered equal to each other and to undefined variables.
/// 
/// ## Examples
/// 
/// Basic equality comparisons:
/// ```liquid
/// {% if product.title == "Awesome Shoes" %}
///   These shoes are awesome!
/// {% endif %}
/// 
/// {% if count == 5 %}
///   There are exactly 5 items
/// {% endif %}
/// ```
/// 
/// Type-strict comparisons:
/// ```liquid
/// {% if 1 == "1" %}true{% else %}false{% endif %}
/// Output: false
/// 
/// {% if 0 == false %}true{% else %}false{% endif %}
/// Output: false
/// 
/// {% if 1.0 == 1 %}true{% else %}false{% endif %}
/// Output: true (numeric types are compared by value)
/// ```
/// 
/// Array and range comparisons:
/// ```liquid
/// {% assign x = "a,b,c" | split: "," %}
/// {% assign y = "a,b,c" | split: "," %}
/// {% if x == y %}Arrays are equal{% endif %}
/// Output: Arrays are equal
/// 
/// {% assign range1 = (1..3) %}
/// {% if range1 == (1..3) %}Ranges match{% endif %}
/// Output: Ranges match
/// ```
/// 
/// Special value comparisons:
/// ```liquid
/// {% if undefined_variable == nil %}true{% endif %}
/// Output: true
/// ```
/// 
/// - Important: The equality operator is strict about types except for numeric comparisons. \
///   String `"1"` is not equal to integer `1`, and integer `0` is not equal to boolean `false`. \
///   However, integer `1` equals decimal `1.0` as they represent the same mathematical value.
/// 
/// - Warning: When comparing floating-point numbers, be aware of potential precision issues. \
///   While `1.0 == 1` evaluates to true (as both represent the same numeric value), comparisons \
///   involving decimal calculations may not work as expected due to floating-point representation.
/// 
/// ## SeeAlso
/// - ``NotEqualsOperator``
/// - ``ContainsOperator``
/// - [Shopify Liquid Operators](https://shopify.github.io/liquid/basics/operators/)
/// - [LiquidJS Operators](https://liquidjs.com/tutorials/operators.html)
/// - [Python Liquid Operators](https://liquid.readthedocs.io/en/latest/guides/introduction-to-liquid/#conditional-tags-and-operators)
public struct EqualsOperator: Operator {
  
  public static let operatorIdentifier: String = "=="
  
  public func apply(_ lhs: Token.Value, _ rhs: Token.Value) -> Token.Value {
    // Check if both values are the same case first for efficiency
    if lhs == rhs {
      return .bool(true)
    }
    
    // Handle numeric type coercion: integer and decimal with same numeric value are equal
    switch (lhs, rhs) {
    case (.integer(let intValue), .decimal(let decimalValue)):
      // Convert integer to decimal and compare
      return .bool(Decimal(intValue) == decimalValue)
      
    case (.decimal(let decimalValue), .integer(let intValue)):
      // Convert integer to decimal and compare
      return .bool(decimalValue == Decimal(intValue))
      
    default:
      // For all other cases, values are not equal if they didn't match above
      return .bool(false)
    }
  }
  
  @inlinable
  package init() { }
}
