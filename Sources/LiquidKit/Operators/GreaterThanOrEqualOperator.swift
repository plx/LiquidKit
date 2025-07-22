
/// Implements the `>=` operator, which tests whether the left value is greater than or equal to the right value.
/// 
/// The greater than or equal operator performs numeric comparisons between values. When used with numeric
/// types (integers and decimals), it performs a standard mathematical comparison returning true when the
/// left operand is greater than or equal to the right operand. The operator uses numeric coercion to
/// convert values to `Double` for comparison, which allows comparing integers with decimals seamlessly.
/// 
/// Non-numeric values are handled through the `numericComparisonValue` property, which converts values
/// to `Double` for comparison. Strings that can be parsed as numbers are converted to their numeric
/// representation, while strings that cannot be parsed and other non-numeric types (nil, bool, array,
/// dictionary) are treated as 0.0. This behavior can lead to unexpected results when comparing
/// non-numeric values, as they will often evaluate to equal (both being 0.0).
/// 
/// The operator is commonly used in conditional statements and loops to control flow based on numeric
/// thresholds or boundaries. Unlike the strict greater than operator, this operator includes equality
/// in its comparison, making it useful for inclusive range checks.
/// 
/// ## Examples
/// 
/// Basic numeric comparisons:
/// ```liquid
/// {% if 10 >= 5 %}
///   This will print
/// {% endif %}
/// 
/// {% if 5 >= 5 %}
///   This will also print (equality case)
/// {% endif %}
/// 
/// {% if 3 >= 7 %}
///   This will not print
/// {% endif %}
/// ```
/// 
/// Mixed integer and decimal comparisons:
/// ```liquid
/// {% if 10.5 >= 10 %}
///   This will print
/// {% endif %}
/// 
/// {% if 10 >= 10.0 %}
///   This will print (integers and decimals compare correctly)
/// {% endif %}
/// ```
/// 
/// String to number conversions:
/// ```liquid
/// {% if "15" >= 10 %}
///   This will print (string "15" converts to 15.0)
/// {% endif %}
/// 
/// {% if "5.5" >= 5 %}
///   This will print (string "5.5" converts to 5.5)
/// {% endif %}
/// ```
/// 
/// Edge cases with non-numeric values:
/// ```liquid
/// {% if "hello" >= 0 %}
///   This will print (non-numeric string converts to 0.0, and 0.0 >= 0 is true)
/// {% endif %}
/// 
/// {% if nil >= 0 %}
///   This will print (nil converts to 0.0)
/// {% endif %}
/// 
/// {% if true >= false %}
///   This will print (booleans convert to 0.0, so 0.0 >= 0.0 is true)
/// {% endif %}
/// ```
/// 
/// - Important: Unlike some programming languages, Liquid does not support string comparisons with
///   relational operators. Attempting to compare non-numeric strings will result in both operands
///   being treated as 0.0, which may produce unexpected results. Use the `==` operator for string
///   equality checks instead.
/// 
/// - Warning: Be cautious when using this operator with variables that might contain non-numeric
///   values. The automatic conversion to 0.0 for non-numeric values can lead to logic errors.
///   Always validate or filter your data when the type might be ambiguous.
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
    .bool(lhs.numericComparisonValue >= rhs.numericComparisonValue)
  }
  
  @inlinable
  package init() { }
}
