import Foundation

/// Implements the `<` operator, which tests whether the left value is less than the right value.
/// 
/// The less than operator performs comparison between values following these rules:
/// 
/// 1. **Numeric comparisons**: When both operands are numeric (integer or decimal), the operator
///    performs standard mathematical comparison. Integers and decimals can be compared with each
///    other through automatic type conversion.
/// 
/// 2. **String comparisons**: When both operands are strings, the operator performs lexicographic
///    (alphabetical) comparison. This means `'abc' < 'acb'` evaluates to `true` because 'abc'
///    comes before 'acb' alphabetically.
/// 
/// 3. **Boolean comparisons**: When both operands are booleans, `false` is considered less than
///    `true` (false = 0, true = 1).
/// 
/// 4. **Nil comparisons**: `nil` is treated as 0 for numeric comparisons and as an empty value
///    for other comparisons.
/// 
/// 5. **Mixed type comparisons**: When operands are of different types, the comparison follows
///    a type ordering where nil < numbers < strings < arrays < dictionaries. Within each type,
///    the normal comparison rules apply.
/// 
/// This implementation matches the behavior of liquidjs and python-liquid, where string
/// comparisons are lexicographic rather than numeric.
/// 
/// ## Examples
/// 
/// Numeric comparisons:
/// ```liquid
/// {% if 5 < 10 %}true{% endif %}
/// Output: true
/// 
/// {% if 3.14 < 3.15 %}true{% endif %}
/// Output: true
/// 
/// {% if 10 < 5.5 %}true{% endif %}
/// Output: false
/// ```
/// 
/// String comparisons (lexicographic):
/// ```liquid
/// {% if 'abc' < 'acb' %}true{% endif %}
/// Output: true
/// 
/// {% if '10' < '2' %}true{% endif %}
/// Output: true (because '1' < '2' lexicographically)
/// 
/// {% if 'hello' < 'world' %}true{% endif %}
/// Output: true
/// ```
/// 
/// Mixed type comparisons:
/// ```liquid
/// {% if 5 < 'hello' %}true{% endif %}
/// Output: true (numbers are less than strings)
/// 
/// {% if nil < 5 %}true{% endif %}
/// Output: true (nil is treated as 0)
/// ```
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
    // Type-based comparison following liquidjs/python-liquid behavior
    switch (lhs, rhs) {
    // NUMERIC COMPARISONS
    // When both values are numeric (integer or decimal), perform numeric comparison
    case let (.integer(left), .integer(right)):
      // Direct integer comparison
      return .bool(left < right)
      
    case let (.decimal(left), .decimal(right)):
      // Direct decimal comparison
      return .bool(left < right)
      
    case let (.integer(left), .decimal(right)):
      // Convert integer to decimal for accurate comparison
      return .bool(Decimal(left) < right)
      
    case let (.decimal(left), .integer(right)):
      // Convert integer to decimal for accurate comparison
      return .bool(left < Decimal(right))
      
    // STRING COMPARISONS
    // When both values are strings, perform lexicographic comparison
    case let (.string(left), .string(right)):
      // Lexicographic string comparison (alphabetical order)
      return .bool(left < right)
      
    // BOOLEAN COMPARISONS
    // When both values are booleans, false < true
    case let (.bool(left), .bool(right)):
      // false = 0, true = 1, so false < true
      return .bool(!left && right)
      
    // NIL COMPARISONS
    // nil is treated specially in comparisons
    case (.nil, .nil):
      // nil is not less than itself
      return .bool(false)
      
    case (.nil, .integer(let value)):
      // nil is treated as 0 for numeric comparisons
      return .bool(0 < value)
      
    case (.integer(let value), .nil):
      // nil is treated as 0 for numeric comparisons
      return .bool(value < 0)
      
    case (.nil, .decimal(let value)):
      // nil is treated as 0 for numeric comparisons
      return .bool(Decimal(0) < value)
      
    case (.decimal(let value), .nil):
      // nil is treated as 0 for numeric comparisons
      return .bool(value < Decimal(0))
      
    case (.nil, .string(_)):
      // nil is less than any non-empty string
      return .bool(true)
      
    case (.string(_), .nil):
      // strings are greater than nil
      return .bool(false)
      
    case (.nil, _):
      // nil is less than other types (arrays, dicts, etc)
      return .bool(true)
      
    case (_, .nil):
      // other types are greater than nil
      return .bool(false)
      
    // MIXED TYPE COMPARISONS
    // When types don't match, use type ordering:
    // nil < numbers < strings < arrays < dictionaries
    
    // Numbers vs strings
    case (.integer(_), .string(_)), (.decimal(_), .string(_)):
      // Numbers are less than strings
      return .bool(true)
      
    case (.string(_), .integer(_)), (.string(_), .decimal(_)):
      // Strings are greater than numbers
      return .bool(false)
      
    // Numbers vs booleans
    case let (.integer(left), .bool(right)):
      // Boolean converts to 0 or 1
      return .bool(left < (right ? 1 : 0))
      
    case let (.bool(left), .integer(right)):
      // Boolean converts to 0 or 1
      return .bool((left ? 1 : 0) < right)
      
    case let (.decimal(left), .bool(right)):
      // Boolean converts to 0 or 1
      return .bool(left < Decimal(right ? 1 : 0))
      
    case let (.bool(left), .decimal(right)):
      // Boolean converts to 0 or 1
      return .bool(Decimal(left ? 1 : 0) < right)
      
    // Strings vs booleans
    case (.string(_), .bool(_)):
      // Strings are greater than booleans
      return .bool(false)
      
    case (.bool(_), .string(_)):
      // Booleans are less than strings
      return .bool(true)
      
    // Arrays and dictionaries
    case (.array(_), .array(_)), (.dictionary(_), .dictionary(_)):
      // Arrays and dictionaries of same type are not comparable
      // They convert to 0.0 in numeric context
      return .bool(false)
      
    case (.integer(_), .array(_)), (.decimal(_), .array(_)), 
         (.string(_), .array(_)), (.bool(_), .array(_)):
      // Other types are less than arrays
      return .bool(true)
      
    case (.array(_), .integer(_)), (.array(_), .decimal(_)), 
         (.array(_), .string(_)), (.array(_), .bool(_)):
      // Arrays are greater than other types
      return .bool(false)
      
    case (.integer(_), .dictionary(_)), (.decimal(_), .dictionary(_)), 
         (.string(_), .dictionary(_)), (.bool(_), .dictionary(_)), 
         (.array(_), .dictionary(_)):
      // Other types are less than dictionaries
      return .bool(true)
      
    case (.dictionary(_), .integer(_)), (.dictionary(_), .decimal(_)), 
         (.dictionary(_), .string(_)), (.dictionary(_), .bool(_)), 
         (.dictionary(_), .array(_)):
      // Dictionaries are greater than other types
      return .bool(false)
      
    // Range comparisons
    case (.range(_), .range(_)):
      // Ranges are not comparable
      return .bool(false)
      
    case (_, .range(_)):
      // Other types vs range
      return .bool(true)
      
    case (.range(_), _):
      // Range vs other types
      return .bool(false)
    }
  }
  
  @inlinable
  package init() { }
}