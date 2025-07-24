import Foundation
import Darwin

/// Implements the `floor` filter, which rounds a number down to the nearest integer.
/// 
/// The `floor` filter converts numeric values to their floor value (the largest integer less than
/// or equal to the number). It accepts integers, floats, and numeric strings as input. For positive
/// numbers, this rounds toward zero; for negative numbers, it rounds away from zero.
///
/// ## Examples
///
/// Positive float:
/// ```liquid
/// {{ 5.4 | floor }}
/// // Outputs: "5"
/// ```
///
/// Negative float:
/// ```liquid
/// {{ -5.4 | floor }}
/// // Outputs: "-6"
/// ```
///
/// String number:
/// ```liquid
/// {{ "5.1" | floor }}
/// // Outputs: "5"
/// ```
///
/// Integer (no change):
/// ```liquid
/// {{ 5 | floor }}
/// // Outputs: "5"
/// ```
///
/// Non-numeric value:
/// ```liquid
/// {{ "hello" | floor }}
/// // Outputs: "0"
/// ```
///
/// - Important: Non-numeric values (including objects, arrays, and non-numeric strings) are
///   converted to 0 rather than causing an error. This includes undefined variables.
///
/// - Warning: The filter does not accept any arguments. Providing arguments (e.g., `{{ -3.1 | floor: 1 }}`)
///   may cause an error in strict Liquid implementations, though this implementation currently
///   ignores extra arguments.
///
/// - SeeAlso: ``CeilFilter`` for rounding up
/// - SeeAlso: ``RoundFilter`` for rounding to nearest integer
/// - SeeAlso: [LiquidJS floor filter](https://liquidjs.com/filters/floor.html)
/// - SeeAlso: [Python Liquid floor filter](https://liquid.readthedocs.io/en/latest/filter_reference/#floor)
/// - SeeAlso: [Shopify Liquid floor filter](https://shopify.github.io/liquid/filters/floor/)
@usableFromInline
package struct FloorFilter: Filter {
  @usableFromInline
  package static let filterIdentifier = "floor"
  
  @inlinable
  package init() {}
  
  @inlinable
  package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
    // Handle different value types
    switch token {
    case .integer(let value):
      // Integers are already floored, just return as-is
      return .integer(value)
      
    case .decimal(let value):
      // For decimals, use Darwin.floor and convert to integer
      let doubleValue = (value as NSNumber).doubleValue
      let flooredValue = Darwin.floor(doubleValue)
      return .integer(Int(flooredValue))
      
    case .string(let string):
      // For strings, attempt to parse as a number
      // First trim whitespace
      let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
      
      // Check if it's empty after trimming
      if trimmed.isEmpty {
        // Empty strings should be treated as 0 (per python-liquid)
        return .integer(0)
      }
      
      // Try to parse as a number using Double
      // This handles scientific notation and decimal points
      if let doubleValue = Double(trimmed) {
        // Check for special values that shouldn't be valid
        if doubleValue.isInfinite || doubleValue.isNaN {
          // Infinity and NaN are not valid numbers for floor
          return .integer(0)
        }
        
        // Apply floor and return as integer
        let flooredValue = Darwin.floor(doubleValue)
        return .integer(Int(flooredValue))
      }
      
      // If string can't be parsed as a number, return 0
      return .integer(0)
      
    case .nil, .bool, .array, .dictionary, .range:
      // All non-numeric types return 0 (per python-liquid behavior)
      return .integer(0)
    }
  }
}