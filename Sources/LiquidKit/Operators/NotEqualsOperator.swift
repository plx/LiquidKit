
/// Implements the `!=` operator, which tests whether two values are not equal.
/// 
/// The not-equals operator performs inequality comparison between two values and is the exact logical
/// inverse of the `==` operator. It returns `true` when values are different and `false` when they
/// are the same. The operator is commonly used in conditional tags like `if`, `unless`, and `case` 
/// to control template flow based on whether values do not match.
/// 
/// The not-equals operator is mostly strict about types. String `"1"` is not equal to integer `1` 
/// (so `!=` returns true), and integer `0` is not equal to boolean `false` (so `!=` returns true). 
/// However, like the equality operator, numeric values are compared by their mathematical value, 
/// so integer `1` is equal to decimal `1.0` (and thus `1 != 1.0` returns false). This behavior 
/// matches liquidjs and python-liquid implementations.
/// 
/// Arrays and dictionaries are compared by their contents. Two arrays with different elements or
/// different order are considered not equal, as are two dictionaries with different key-value pairs.
/// The special values `nil` and `null` are considered equal to each other and to undefined variables,
/// so comparing them with `!=` returns false.
/// 
/// ## Examples
/// 
/// Basic inequality comparisons:
/// ```liquid
/// {% if product.title != "Boring Shoes" %}
///   These shoes are interesting!
/// {% endif %}
/// 
/// {% if status != "completed" %}
///   Task is still pending
/// {% endif %}
/// ```
/// 
/// Type comparisons with numeric coercion:
/// ```liquid
/// {% if 1 != "1" %}true{% else %}false{% endif %}
/// Output: true (string vs number - no coercion)
/// 
/// {% if 0 != false %}true{% else %}false{% endif %}
/// Output: true (number vs boolean - no coercion)
/// 
/// {% if 1.0 != 1 %}true{% else %}false{% endif %}
/// Output: false (numeric coercion: 1.0 equals 1)
/// 
/// {% if 42 != 42.0 %}true{% else %}false{% endif %}
/// Output: false (numeric coercion: integers and decimals with same value)
/// ```
/// 
/// Array and collection comparisons:
/// ```liquid
/// {% assign x = "a,b,c" | split: "," %}
/// {% assign y = "x,y,z" | split: "," %}
/// {% if x != y %}Arrays are different{% endif %}
/// Output: Arrays are different
/// 
/// {% if empty_array != empty %}false{% endif %}
/// Output: false (empty collections equal the 'empty' value)
/// ```
/// 
/// Nil and undefined comparisons:
/// ```liquid
/// {% if undefined_variable != nil %}true{% else %}false{% endif %}
/// Output: false (undefined equals nil)
/// 
/// {% if some_value != nil %}
///   Value is defined and not nil
/// {% endif %}
/// ```
/// 
/// - Important: The not-equals operator is the exact logical inverse of the equals operator. \
///   If `a == b` returns true, then `a != b` returns false, and vice versa. This relationship \
///   holds for all value types including arrays, dictionaries, special values like nil, and \
///   crucially, for numeric comparisons where integer and decimal values are coerced. For example, \
///   since `1 == 1.0` returns true (numeric coercion), `1 != 1.0` returns false.
/// 
/// - Warning: When comparing floating-point decimals, be aware that values that appear different \
///   due to precision issues may still compare as equal. For example, the result of calculations \
///   like `0.1 + 0.2` might not be exactly `0.3` due to floating-point representation, but may \
///   still compare as equal depending on the precision used.
/// 
/// ## SeeAlso
/// - ``EqualsOperator``
/// - ``GreaterThanOperator``
/// - ``LessThanOperator``
/// - [Shopify Liquid Operators](https://shopify.github.io/liquid/basics/operators/)
/// - [LiquidJS Operators](https://liquidjs.com/tutorials/operators.html)
/// - [Python Liquid Operators](https://liquid.readthedocs.io/en/latest/guides/introduction-to-liquid/#conditional-tags-and-operators)
public struct NotEqualsOperator: Operator {
  
  public static let operatorIdentifier: String = "!="
  
  // Use EqualsOperator to ensure we're the exact logical inverse.
  // This is crucial for numeric coercion behavior: since EqualsOperator
  // considers 1 == 1.0 to be true, NotEqualsOperator must consider
  // 1 != 1.0 to be false. By delegating to EqualsOperator and inverting
  // the result, we guarantee consistent behavior.
  private let equalsOperator = EqualsOperator()
  
  public func apply(_ lhs: Token.Value, _ rhs: Token.Value) -> Token.Value {
    // Get the result from EqualsOperator
    let equalsResult = equalsOperator.apply(lhs, rhs)
    
    // Return the inverse of the equals result
    switch equalsResult {
    case .bool(let isEqual):
      return .bool(!isEqual)
    default:
      // This should never happen since EqualsOperator always returns a bool,
      // but we handle it for completeness by returning true (not equal)
      return .bool(true)
    }
  }
  
  @inlinable
  package init() { }
}
