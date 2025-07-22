/// Implements the `or` operator, which performs logical OR operations between two values.
/// 
/// The `or` operator evaluates the truthiness of both operands and returns the result of a logical
/// OR operation. It is commonly used in conditional tags like `if`, `unless`, and `case` to test
/// whether at least one of multiple conditions is true. The operator follows Liquid's truthiness
/// rules: `false` and `nil` are considered falsy, while all other values (including empty strings,
/// zero, and empty arrays) are considered truthy.
/// 
/// Unlike programming languages that use short-circuit evaluation, Liquid evaluates both operands
/// before applying the OR operation. The result is always a boolean value (`true` or `false`),
/// never one of the original operands. This consistent behavior makes template logic more predictable
/// and easier to debug.
/// 
/// The operator is particularly useful for providing fallback conditions or checking if any one of
/// several conditions is met. For example, you might display content if a user is either logged in
/// or viewing a public page, or show a message if a product is either on sale or newly arrived.
/// 
/// ## Examples
/// 
/// Basic logical OR operations:
/// ```liquid
/// {% if user.premium or user.trial %}
///   Access to premium features granted!
/// {% endif %}
/// 
/// {% if product.on_sale or product.clearance %}
///   Special pricing available!
/// {% endif %}
/// ```
/// 
/// Truthiness evaluation:
/// ```liquid
/// {% if true or false %}yes{% else %}no{% endif %}
/// Output: yes
/// 
/// {% if false or false %}yes{% else %}no{% endif %}
/// Output: no
/// 
/// {% if nil or "text" %}yes{% else %}no{% endif %}
/// Output: yes (second operand is truthy)
/// 
/// {% if 0 or "" %}yes{% else %}no{% endif %}
/// Output: yes (both zero and empty string are truthy in Liquid)
/// ```
/// 
/// Fallback patterns:
/// ```liquid
/// {% if page.title or product.name %}
///   <h1>{{ page.title | default: product.name }}</h1>
/// {% endif %}
/// 
/// {% if user.nickname or user.name or "Guest" %}
///   Welcome!
/// {% endif %}
/// ```
/// 
/// Combining with other operators:
/// ```liquid
/// {% if product.featured and (product.on_sale or product.new) %}
///   This featured product has a special status!
/// {% endif %}
/// 
/// {% if quantity == 0 or quantity > 100 %}
///   Quantity is out of normal range
/// {% endif %}
/// ```
/// 
/// - Important: In Liquid, only `false` and `nil` (including undefined variables) are falsy. \
///   Unlike JavaScript or Python, the values `0`, `""` (empty string), and `[]` (empty array) \
///   are all considered truthy. This can be surprising for developers coming from other languages.
/// 
/// - Note: The `or` operator always returns a boolean value (`true` or `false`), never one of \
///   the original operands. This differs from languages like JavaScript or Python where logical \
///   operators can return the actual operand values. For default/fallback values, use the \
///   `default` filter instead.
/// 
/// ## SeeAlso
/// - ``AndOperator``
/// - ``EqualsOperator``
/// - ``NotEqualsOperator``
/// - [Shopify Liquid Operators](https://shopify.github.io/liquid/basics/operators/)
/// - [LiquidJS Operators](https://liquidjs.com/tutorials/operators.html)
/// - [Python Liquid Operators](https://liquid.readthedocs.io/en/latest/guides/introduction-to-liquid/#conditional-tags-and-operators)
public struct OrOperator: Operator {
  
  public static let operatorIdentifier: String = "or"
  
  public func apply(_ lhs: Token.Value, _ rhs: Token.Value) -> Token.Value {
    .bool(lhs.isTruthy || rhs.isTruthy)
  }
  
  @inlinable
  package init() { }
}