
import Foundation

/// Implements the `<=` operator, which tests whether the left value is less than or equal to the right value.
/// 
/// The less than or equal operator performs comparison between values following these rules:
/// 
/// 1. **Equality check**: First checks if values are equal, returning `true` if they are.
/// 2. **Numeric comparisons**: When both operands are numeric (integer or decimal), the operator
///    performs standard mathematical comparison. Integers and decimals can be compared with each
///    other through automatic type conversion.
/// 3. **String comparisons**: When both operands are strings, the operator performs lexicographic
///    (alphabetical) comparison. This means `'abc' <= 'acb'` evaluates to `true` because 'abc'
///    comes before 'acb' alphabetically.
/// 4. **Boolean comparisons**: When both operands are booleans, `false` is considered less than
///    `true` (false = 0, true = 1).
/// 5. **Nil comparisons**: `nil` is treated as 0 for numeric comparisons and as an empty value
///    for other comparisons. This means `nil <= 0` is `true`.
/// 6. **Mixed type comparisons**: When operands are of different types, the comparison follows
///    a type ordering where nil < numbers < strings < arrays < dictionaries. Within each type,
///    the normal comparison rules apply.
/// 
/// This implementation matches the behavior of liquidjs and python-liquid, where string
/// comparisons are lexicographic rather than numeric, and type ordering is consistent.
/// 
/// ## Examples
/// 
/// Numeric comparisons:
/// ```liquid
/// {% if 5 <= 10 %}true{% endif %}
/// Output: true
/// 
/// {% if 10 <= 10 %}true{% endif %}
/// Output: true (equality)
/// 
/// {% if 15 <= 10 %}true{% endif %}
/// Output: false
/// 
/// {% if 3.14 <= 3.15 %}true{% endif %}
/// Output: true
/// 
/// {% if 10 <= 10.0 %}true{% endif %}
/// Output: true (integer 10 equals decimal 10.0)
/// ```
/// 
/// String comparisons (lexicographic):
/// ```liquid
/// {% if 'abc' <= 'acb' %}true{% endif %}
/// Output: true
/// 
/// {% if 'hello' <= 'hello' %}true{% endif %}
/// Output: true (equality)
/// 
/// {% if '10' <= '2' %}true{% endif %}
/// Output: true (because '1' < '2' lexicographically)
/// 
/// {% if 'apple' <= 'banana' %}true{% endif %}
/// Output: true
/// ```
/// 
/// Mixed type comparisons:
/// ```liquid
/// {% if 5 <= 'hello' %}true{% endif %}
/// Output: true (numbers are less than strings)
/// 
/// {% if nil <= 0 %}true{% endif %}
/// Output: true (nil is treated as 0)
/// 
/// {% if false <= true %}true{% endif %}
/// Output: true (false < true)
/// 
/// {% if 0 <= false %}true{% endif %}
/// Output: true (0 equals false)
/// ```
/// 
/// - Important: This implementation follows the Liquid specification with proper type-aware comparisons. \
///   String comparisons are lexicographic (alphabetical), numeric comparisons are mathematical, and \
///   mixed-type comparisons follow a consistent type ordering hierarchy.
/// 
/// - Note: When comparing different types, the operator follows the type hierarchy: \
///   nil < numbers < strings < arrays < dictionaries. Within each type category, the standard \
///   comparison rules apply (numeric for numbers, lexicographic for strings, etc.).
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
    // Less than or equal is true when: lhs < rhs OR lhs == rhs
    // We implement this using the same type-based comparison logic as LessThanOperator
    // but return true for equality cases
    
    // First check for exact equality (fast path)
    if lhs == rhs {
      return .bool(true)
    }
    
    // Handle numeric type coercion for equality (integer vs decimal, nil vs zero)
    switch (lhs, rhs) {
    case (.integer(let intValue), .decimal(let decimalValue)):
      // Convert integer to decimal for accurate comparison
      if Decimal(intValue) == decimalValue {
        return .bool(true)
      }
    case (.decimal(let decimalValue), .integer(let intValue)):
      // Convert integer to decimal for accurate comparison  
      if decimalValue == Decimal(intValue) {
        return .bool(true)
      }
    case (.nil, .integer(0)), (.integer(0), .nil):
      // nil is equal to 0 for comparison purposes
      return .bool(true)
    case (.nil, .decimal(let value)) where value == Decimal(0):
      // nil is equal to decimal 0.0
      return .bool(true)
    case (.decimal(let value), .nil) where value == Decimal(0):
      // decimal 0.0 is equal to nil
      return .bool(true)
    case (.integer(0), .bool(false)), (.bool(false), .integer(0)):
      // 0 equals false (both represent 0)
      return .bool(true)
    case (.integer(1), .bool(true)), (.bool(true), .integer(1)):
      // 1 equals true (both represent 1)
      return .bool(true)
    case (.decimal(let value), .bool(false)) where value == Decimal(0):
      // decimal 0.0 equals false
      return .bool(true)
    case (.bool(false), .decimal(let value)) where value == Decimal(0):
      // false equals decimal 0.0
      return .bool(true)
    case (.decimal(let value), .bool(true)) where value == Decimal(1):
      // decimal 1.0 equals true
      return .bool(true)
    case (.bool(true), .decimal(let value)) where value == Decimal(1):
      // true equals decimal 1.0
      return .bool(true)
    default:
      break
    }
    
    // Now perform less-than comparison using same logic as LessThanOperator
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
      // nil is not less than itself (already handled by equality check above)
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
