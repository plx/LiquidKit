/// Implements the `and` operator, which performs logical AND operations between two values.
/// 
/// The `and` operator evaluates the truthiness of both operands and returns the result of a logical
/// AND operation. It is commonly used in conditional tags like `if`, `unless`, and `case` to combine
/// multiple conditions. The operator follows Liquid's truthiness rules: `false` and `nil` are
/// considered falsy, while all other values (including empty strings, zero, and empty arrays) are
/// considered truthy.
/// 
/// In this implementation, both operands are evaluated before the AND operation is applied. This is
/// consistent with how Liquid template engines typically work, where expressions are fully evaluated
/// before operators are applied. The result is always a boolean value (`true` or `false`),
/// never one of the original operands. This consistent behavior makes template logic more predictable
/// and easier to debug.
/// 
/// The operator is particularly useful for checking multiple conditions that must all be true. For
/// example, you might check if a product is both available and on sale, or if a user is both logged
/// in and has admin privileges. The `and` operator can be chained to test multiple conditions in a
/// single expression.
/// 
/// ## Examples
/// 
/// Basic logical AND operations:
/// ```liquid
/// {% if product.available and product.featured %}
///   This product is available and featured!
/// {% endif %}
/// 
/// {% if user.signed_in and user.admin %}
///   Welcome, administrator!
/// {% endif %}
/// ```
/// 
/// Truthiness evaluation:
/// ```liquid
/// {% if true and true %}yes{% else %}no{% endif %}
/// Output: yes
/// 
/// {% if true and false %}yes{% else %}no{% endif %}
/// Output: no
/// 
/// {% if "text" and 1 %}yes{% else %}no{% endif %}
/// Output: yes (both non-nil values are truthy)
/// 
/// {% if 0 and "" %}yes{% else %}no{% endif %}
/// Output: yes (zero and empty string are truthy in Liquid)
/// ```
/// 
/// Chaining multiple conditions:
/// ```liquid
/// {% if product.available and product.price < 100 and product.category == "shoes" %}
///   Affordable shoes in stock!
/// {% endif %}
/// ```
/// 
/// Falsy values:
/// ```liquid
/// {% if nil and true %}yes{% else %}no{% endif %}
/// Output: no (nil is falsy)
/// 
/// {% if false and "text" %}yes{% else %}no{% endif %}
/// Output: no (false is falsy)
/// 
/// {% if undefined_variable and true %}yes{% else %}no{% endif %}
/// Output: no (undefined variables are nil/falsy)
/// ```
/// 
/// - Important: In Liquid, only `false` and `nil` (including undefined variables) are falsy. \
///   Unlike JavaScript or Python, the values `0`, `""` (empty string), and `[]` (empty array) \
///   are all considered truthy. This can be surprising for developers coming from other languages.
/// 
/// - Note: The `and` operator always returns a boolean value (`true` or `false`), never one of \
///   the original operands. This differs from languages like JavaScript or Python where logical \
///   operators can return the actual operand values.
/// 
/// ## SeeAlso
/// - ``OrOperator``
/// - ``EqualsOperator``
/// - ``NotEqualsOperator``
/// - [Shopify Liquid Operators](https://shopify.github.io/liquid/basics/operators/)
/// - [LiquidJS Operators](https://liquidjs.com/tutorials/operators.html)
/// - [Python Liquid Operators](https://liquid.readthedocs.io/en/latest/guides/introduction-to-liquid/#conditional-tags-and-operators)
public struct AndOperator: Operator {
  
  public static let operatorIdentifier: String = "and"
  
  /// Applies the AND operator to two token values.
  /// 
  /// This implementation:
  /// 1. Evaluates the truthiness of the left operand using Liquid's truthiness rules
  /// 2. Evaluates the truthiness of the right operand using Liquid's truthiness rules
  /// 3. Returns a boolean Token.Value containing the result of the logical AND operation
  /// 
  /// Truthiness rules in Liquid:
  /// - `false` and `nil` are falsy
  /// - All other values are truthy (including 0, "", [], {})
  /// 
  /// - Parameters:
  ///   - lhs: The left-hand side operand
  ///   - rhs: The right-hand side operand
  /// - Returns: A boolean Token.Value (.bool(true) or .bool(false))
  public func apply(_ lhs: Token.Value, _ rhs: Token.Value) -> Token.Value {
    // Use Swift's && operator which provides short-circuit evaluation at the Swift level
    // Both operands have already been evaluated by the time they reach this method
    .bool(lhs.isTruthy && rhs.isTruthy)
  }
  
  @inlinable
  package init() { }
}