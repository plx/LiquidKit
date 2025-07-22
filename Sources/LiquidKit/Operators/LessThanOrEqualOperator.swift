
/// Implements the `<=` operator, which tests whether the left value is less than or equal to the right value.
/// 
/// The less than or equal operator performs numeric comparisons between values, returning true when the
/// left operand is less than or equal to the right operand. This operator is commonly used in conditional
/// statements like `if`, `unless`, and loop conditions to create inclusive upper bounds or test for
/// maximum thresholds. When used with numeric types (integers and decimals), it performs standard
/// mathematical comparison with automatic type coercion between integer and decimal values.
/// 
/// The operator converts both operands to their numeric representation using the `numericComparisonValue`
/// property before comparison. This conversion process handles various types: integers and decimals
/// maintain their numeric values, strings that contain valid numbers are parsed to their numeric form,
/// and all other types (non-numeric strings, nil, booleans, arrays, and dictionaries) are converted
/// to 0.0. This numeric conversion approach differs from some Liquid implementations that perform
/// lexicographic string comparison.
/// 
/// A notable behavior is that string comparisons in this implementation are numeric rather than
/// lexicographic. For example, `'abc' <= 'acb'` would evaluate based on both strings converting
/// to 0.0 (making them equal, thus returning true), rather than performing alphabetical comparison
/// where 'abc' would be less than 'acb'. This can lead to unexpected results when comparing
/// non-numeric strings.
/// 
/// ## Examples
/// 
/// Basic numeric comparisons:
/// ```liquid
/// {% if 5 <= 10 %}
///   This will print (5 is less than 10)
/// {% endif %}
/// 
/// {% if 10 <= 10 %}
///   This will print (10 equals 10)
/// {% endif %}
/// 
/// {% if 15 <= 10 %}
///   This will not print (15 is greater than 10)
/// {% endif %}
/// ```
/// 
/// Mixed integer and decimal comparisons:
/// ```liquid
/// {% if 9.99 <= 10 %}
///   This will print (9.99 is less than 10)
/// {% endif %}
/// 
/// {% if 10 <= 10.0 %}
///   This will print (integer 10 equals decimal 10.0)
/// {% endif %}
/// 
/// {% if 10.1 <= 10 %}
///   This will not print (10.1 is greater than 10)
/// {% endif %}
/// ```
/// 
/// String to number conversions:
/// ```liquid
/// {% if "5" <= "10" %}
///   This will print (strings parsed as 5.0 <= 10.0)
/// {% endif %}
/// 
/// {% if "100" <= "20" %}
///   This will not print (parsed as 100.0 <= 20.0)
/// {% endif %}
/// 
/// {% if "3.14" <= 4 %}
///   This will print (string "3.14" parsed as 3.14)
/// {% endif %}
/// ```
/// 
/// Edge cases with non-numeric values:
/// ```liquid
/// {% if "hello" <= "world" %}
///   This will print (both convert to 0.0, and 0.0 <= 0.0 is true)
/// {% endif %}
/// 
/// {% if nil <= 0 %}
///   This will print (nil converts to 0.0, and 0.0 <= 0 is true)
/// {% endif %}
/// 
/// {% if false <= true %}
///   This will print (both booleans convert to 0.0, so 0.0 <= 0.0 is true)
/// {% endif %}
/// 
/// {% if "text" <= 5 %}
///   This will print (non-numeric string converts to 0.0, and 0.0 <= 5 is true)
/// {% endif %}
/// ```
/// 
/// - Important: This implementation performs numeric comparison only. While the Liquid specification \
///   and other implementations support lexicographic string comparison (where 'abc' <= 'acb' would be \
///   true based on alphabetical ordering), this implementation converts all values to numbers. \
///   Non-numeric strings become 0.0, which means string comparisons may coincidentally match expected \
///   results in some cases (like 'abc' <= 'acb' returning true because 0.0 <= 0.0) but for the wrong \
///   reasons.
/// 
/// - Warning: When comparing values that might not be numeric, be aware that all non-numeric values \
///   (including non-numeric strings, nil, booleans, arrays, and dictionaries) convert to 0.0. This \
///   means comparisons like `'any string' <= 'another string'` will always return true (as 0.0 <= 0.0), \
///   which may not match your intended logic. Consider using the `==` operator for string equality \
///   checks or ensure your values are numeric before comparison.
/// 
/// - SeeAlso: ``LessThanOperator``
/// - SeeAlso: ``GreaterThanOperator``
/// - SeeAlso: ``GreaterThanOrEqualOperator``
/// - SeeAlso: [Liquid Operators - Shopify](https://shopify.github.io/liquid/basics/operators/)
/// - SeeAlso: [Comparison Operators - LiquidJS](https://liquidjs.com/tutorials/operators.html#comparisons)
/// - SeeAlso: [Operators - Python Liquid](https://liquid.readthedocs.io/en/latest/guides/liquid-operators.html)
public struct LessThanOrEqualOperator: Operator {
  
  public static let operatorIdentifier: String = "<="
  
  public func apply(_ lhs: Token.Value, _ rhs: Token.Value) -> Token.Value {
    .bool(lhs.numericComparisonValue <= rhs.numericComparisonValue)
  }
  
  @inlinable
  package init() { }
}
