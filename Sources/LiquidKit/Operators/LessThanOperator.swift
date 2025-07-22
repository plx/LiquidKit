
/// Implements the `<` operator, which tests whether the left value is less than the right value.
/// 
/// The less than operator performs numeric comparison by converting both operands to their numeric
/// representation before comparing. This operator is commonly used in conditional tags like `if`,
/// `unless`, and `case` to control template flow based on value comparisons. When used with numeric
/// values (integers and decimals), the operator performs standard mathematical comparison.
/// 
/// For string values, Liquid implementations traditionally perform lexicographic (alphabetical)
/// comparison. However, this implementation converts all values to numeric form using the
/// `numericComparisonValue` property, which returns the double value of numbers or 0.0 for
/// non-numeric types. This means string comparisons like `'abc' < 'acb'` will evaluate to
/// `false` (as both convert to 0.0) rather than performing alphabetical comparison.
/// 
/// The operator handles type coercion by attempting to extract numeric values from the operands.
/// Integer and decimal values are compared directly, while strings that contain valid numbers
/// are parsed and compared numerically. Non-numeric strings, nil values, booleans, arrays, and
/// dictionaries all convert to 0.0 for comparison purposes.
/// 
/// ## Examples
/// 
/// Basic numeric comparisons:
/// ```liquid
/// {% if 5 < 10 %}
///   Five is less than ten
/// {% endif %}
/// 
/// {% assign size = 650 %}
/// {% if size < 987 %}
///   Size is less than 987
/// {% endif %}
/// ```
/// 
/// Decimal comparisons:
/// ```liquid
/// {% if 3.14 < 3.15 %}
///   Pi is less than 3.15
/// {% endif %}
/// 
/// {% if product.price < 19.99 %}
///   Product costs less than $19.99
/// {% endif %}
/// ```
/// 
/// Edge cases with non-numeric values:
/// ```liquid
/// {% if "hello" < "world" %}true{% else %}false{% endif %}
/// Output: false (both strings convert to 0.0)
/// 
/// {% if nil < 5 %}true{% else %}false{% endif %}
/// Output: true (nil converts to 0.0, which is less than 5)
/// 
/// {% if true < 1 %}true{% else %}false{% endif %}
/// Output: true (true converts to 0.0, which is less than 1)
/// ```
/// 
/// Numeric string parsing:
/// ```liquid
/// {% if "42" < "100" %}true{% else %}false{% endif %}
/// Output: true (strings are parsed as numbers 42 and 100)
/// 
/// {% if "3.14" < 4 %}true{% else %}false{% endif %}
/// Output: true (string "3.14" is parsed as 3.14)
/// ```
/// 
/// - Important: Unlike some Liquid implementations that perform lexicographic string comparison, \
///   this implementation converts all values to numbers. Strings that cannot be parsed as numbers \
///   are treated as 0.0. This means `'abc' < 'def'` evaluates to `false` rather than `true`.
/// 
/// - Warning: Non-numeric values (strings that aren't valid numbers, booleans, nil, arrays, \
///   and dictionaries) all convert to 0.0 for comparison. This can lead to unexpected results \
///   when comparing mixed types. Always ensure your comparisons use compatible numeric values.
/// 
/// ## SeeAlso
/// - ``GreaterThanOperator``
/// - ``LessThanOrEqualOperator``
/// - ``GreaterThanOrEqualOperator``
/// - [Shopify Liquid Operators](https://shopify.github.io/liquid/basics/operators/)
/// - [LiquidJS Operators](https://liquidjs.com/tutorials/operators.html)
/// - [Python Liquid Operators](https://liquid.readthedocs.io/en/latest/guides/introduction-to-liquid/#conditional-tags-and-operators)
public struct LessThanOperator: Operator {
  
  public static let operatorIdentifier: String = "<"
  
  public func apply(_ lhs: Token.Value, _ rhs: Token.Value) -> Token.Value {
    .bool(lhs.numericComparisonValue < rhs.numericComparisonValue)
  }
  
  @inlinable
  package init() { }
}
