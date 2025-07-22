
/// Implements the `>` operator, which tests whether the left value is greater than the right value.
///
/// The greater than operator performs numeric comparisons between values. When used with numeric types
/// (integers and decimals), it performs a standard mathematical comparison. String values cannot be
/// directly compared with numeric values - attempting to do so results in an invalid operation. However,
/// strings can be compared with other strings using lexicographic ordering.
///
/// The operator uses the `numericComparisonValue` property of Token values, which converts values to
/// Double for comparison. Non-numeric values (nil, bool, array, dictionary) are treated as 0.0 when
/// compared, which can lead to unexpected results. String values that can be parsed as numbers are
/// converted to their numeric representation for comparison.
///
/// ## Examples
///
/// Basic numeric comparisons:
/// ```liquid
/// {% if 650 > 100 %}
///   This is true
/// {% endif %}
///
/// {% if 5.5 > 3.2 %}
///   This is true
/// {% endif %}
///
/// {% if 10 > 10 %}
///   This is false (not greater than, only equal)
/// {% endif %}
/// ```
///
/// String comparisons use lexicographic ordering:
/// ```liquid
/// {% if 'bbb' > 'aaa' %}
///   This is true (lexicographic comparison)
/// {% endif %}
///
/// {% if 'abc' > 'acb' %}
///   This is false (lexicographic comparison)
/// {% endif %}
/// ```
///
/// - Important: Comparing strings with numbers is invalid in strict Liquid implementations.
///              While this implementation may convert numeric strings to numbers for comparison,
///              this behavior should not be relied upon for cross-platform compatibility.
///
/// - Warning: Non-numeric values (nil, bool, arrays, dictionaries) are coerced to 0.0 for \
///            comparison purposes. This means `nil > -1` evaluates to true, which may be \
///            surprising. Always ensure operands are of appropriate types.
///
/// ## SeeAlso
/// - ``LessThanOperator``
/// - ``GreaterThanOrEqualOperator``
/// - [LiquidJS Operators](https://liquidjs.com/tutorials/operators.html)
/// - [Shopify Liquid Operators](https://shopify.github.io/liquid/basics/operators/)
public struct GreaterThanOperator: Operator {
  
  public static let operatorIdentifier: String = ">"
  
  public func apply(_ lhs: Token.Value, _ rhs: Token.Value) -> Token.Value {
    .bool(lhs.numericComparisonValue > rhs.numericComparisonValue)
  }
  
  @inlinable
  package init() { }
}
