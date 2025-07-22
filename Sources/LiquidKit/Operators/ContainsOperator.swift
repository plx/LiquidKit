
/// Implements the `contains` operator, which tests whether a collection contains a specific value or a string contains a substring.
/// 
/// The `contains` operator is one of Liquid's comparison operators that checks for the presence of a value within another value.
/// It has two primary modes of operation: substring matching for strings and element matching for arrays. When used with strings,
/// it performs a case-sensitive substring search. When used with arrays, it checks for exact element matches using string comparison.
/// The operator is commonly used in conditional statements to filter content based on the presence of specific values.
/// 
/// ## String Contains
/// 
/// When both operands are strings, `contains` checks if the right-hand string is a substring of the left-hand string:
/// 
/// ```liquid
/// {% if product.title contains "Pack" %}
///   This product's title contains the word Pack.
/// {% endif %}
/// 
/// {% if "hello world" contains "llo" %}
///   Found substring!
/// {% endif %}
/// ```
/// 
/// ## Array Contains
/// 
/// When the left operand is an array and the right is a string, `contains` checks if the array contains that exact string element:
/// 
/// ```liquid
/// {% if product.tags contains "garden" %}
///   This product has been tagged with "garden".
/// {% endif %}
/// 
/// {% assign fruits = "apple,banana,orange" | split: "," %}
/// {% if fruits contains "banana" %}
///   We have bananas!
/// {% endif %}
/// ```
/// 
/// ## Edge Cases and Special Behavior
/// 
/// The operator handles several edge cases with specific behaviors:
/// 
/// ```liquid
/// // Numbers are converted to strings for comparison
/// {% if "hel9lo" contains 9 %}  // TRUE - 9 is stringified to "9"
/// 
/// // Nil, undefined, and non-string values in arrays return false
/// {% if array contains nil %}  // FALSE
/// {% if array contains undefined_var %}  // FALSE
/// 
/// // Non-string/non-array left operands return false
/// {% if 123 contains "2" %}  // FALSE
/// {% if nil contains "anything" %}  // FALSE
/// ```
/// 
/// - Important: The `contains` operator can only search for strings. When checking arrays, it performs \
///   exact string matches, not partial matches. For example, an array containing "Black and White" \
///   will not match a search for "Black".
/// 
/// - Important: Unlike some Liquid implementations, this version does not support checking for objects \
///   in arrays of objects or using contains with hash/dictionary types. Only string and array types \
///   are supported as the left operand.
/// 
/// - Warning: The operator always returns false for unsupported type combinations rather than throwing \
///   an error. This includes cases like checking if a number contains a string or if nil contains \
///   anything.
/// 
/// - SeeAlso: ``EqualsOperator``
/// - SeeAlso: [Shopify Liquid - Operators](https://shopify.github.io/liquid/basics/operators/)
/// - SeeAlso: [LiquidJS - Operators](https://liquidjs.com/tutorials/operators.html)
/// - SeeAlso: [Python Liquid - Syntax](https://liquid.readthedocs.io/en/latest/syntax/)
public struct ContainsOperator: Operator {
  
  public static let operatorIdentifier: String = "contains"
  
  public func apply(_ lhs: Token.Value, _ rhs: Token.Value) -> Token.Value {
    switch (lhs, rhs) {
    case (.array(let array), .string(let string)):
      .bool(array.contains(.string(string)))
    case (.string(let haystack), .string(let needle)):
      .bool(haystack.contains(needle))
    default:
      .bool(false)
    }
  }
  
  @inlinable
  package init() { }
}
