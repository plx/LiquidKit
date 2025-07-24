import Foundation
import Darwin

/// Implements the `divided_by` filter, which performs division operations on numeric values.
/// 
/// The `divided_by` filter divides the input value by a given divisor, with different behavior
/// depending on whether the divisor is an integer or a decimal. When dividing by an integer,
/// the result is truncated to an integer (floor division), unless the input value is a decimal,
/// in which case the result remains a decimal. When dividing by a decimal value, the result
/// always maintains decimal precision. This behavior matches the standard Liquid specification.
/// 
/// The filter handles string inputs by attempting to parse them as numbers. Non-numeric values
/// (empty strings, objects, arrays, booleans) are treated as zero. Division by zero throws an
/// error with a descriptive message. Invalid divisors (non-numeric strings, nil values, or
/// non-numeric types) also throw errors.
/// 
/// ## Examples
/// 
/// Integer division (truncated):
/// ```liquid
/// {{ 16 | divided_by: 4 }}
/// <!-- Output: 4 -->
/// 
/// {{ 5 | divided_by: 3 }}
/// <!-- Output: 1 (truncated, not rounded) -->
/// 
/// {{ 7 | divided_by: 2 }}
/// <!-- Output: 3 -->
/// ```
/// 
/// Decimal division (precise):
/// ```liquid
/// {{ 20 | divided_by: 7.0 }}
/// <!-- Output: 2.857142857142857 -->
/// 
/// {{ 10 | divided_by: 3.0 }}
/// <!-- Output: 3.333333333333333 -->
/// ```
/// 
/// Mixed numeric types:
/// ```liquid
/// {{ 9.0 | divided_by: 2 }}
/// <!-- Output: 4.5 (decimal input preserves decimal result) -->
/// 
/// {{ 10 | divided_by: 2.0 }}
/// <!-- Output: 5.0 (decimal divisor gives decimal result) -->
/// ```
/// 
/// String conversion:
/// ```liquid
/// {{ "10" | divided_by: "2" }}
/// <!-- Output: 5 (strings are converted to numbers) -->
/// 
/// {{ "foo" | divided_by: 2 }}
/// <!-- Output: 0 (non-numeric strings become 0) -->
/// 
/// {{ "" | divided_by: 2 }}
/// <!-- Output: 0 (empty string becomes 0) -->
/// ```
/// 
/// - Important: When the input is a decimal (float), the result is always a decimal, even
///   when dividing by an integer. Otherwise, division by an integer returns an integer result
///   (floor division), while division by a decimal returns a decimal result.
/// 
/// - Warning: Division by zero throws a FilterError with a descriptive message. Ensure your
///   templates handle potential zero divisors appropriately.
/// 
/// - Warning: Non-numeric divisors (including nil and non-numeric strings) throw a FilterError.
/// 
/// - Warning: Very large division results may lose precision due to floating-point limitations.
///   
/// - SeeAlso: ``TimesFilter``
/// - SeeAlso: ``MinusFilter``
/// - SeeAlso: ``PlusFilter``
/// - SeeAlso: ``ModuloFilter``
/// - SeeAlso: [Shopify Liquid divided_by](https://shopify.github.io/liquid/filters/divided_by/)
/// - SeeAlso: [LiquidJS divided_by](https://liquidjs.com/filters/divided_by.html)
/// - SeeAlso: [Python Liquid divided_by](https://liquid.readthedocs.io/en/latest/filters/divided_by/)
@usableFromInline
package struct DividedByFilter: Filter {
  @usableFromInline
  package static let filterIdentifier = "divided_by"
  
  @inlinable
  package init() {}
  
  @inlinable
  package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
    // Get the first parameter (divisor)
    guard let divisor = parameters.first else {
      return .nil
    }
    
    // Handle nil divisor
    if case .nil = divisor {
      throw FilterError.invalidArgument(
        "Attempted to call `divided_by` on `\(token) with nil as the divisor!"
      )
    }
    
    // Get numeric value of dividend, defaulting to 0 for non-numeric values
    let dividendDouble: Double
    if let numericValue = token.doubleValue {
      dividendDouble = numericValue
    } else {
      // Non-numeric values (empty string, objects, arrays, booleans) return 0
      switch token {
      case .nil:
        return .integer(0)
      case .string, .array, .dictionary, .bool:
        dividendDouble = 0.0
      default:
        return .nil
      }
    }
    
    // Handle division based on divisor type
    switch divisor {
    case .integer(let divisorInt):
      // Check for division by zero
      guard divisorInt != 0 else {
        throw FilterError.invalidArgument(
          "Attempted to call `divided_by` on `\(token) with 0 as the divisor!"
        )
      }
      
      // If dividend was originally a decimal, return decimal result even with integer divisor
      if case .decimal = token {
        return .decimal(Decimal(dividendDouble / Double(divisorInt)))
      } else {
        // Otherwise, perform integer division (floor division)
        return .integer(Int(Darwin.floor(dividendDouble / Double(divisorInt))))
      }
      
    case .decimal:
      // Get numeric value of decimal divisor
      guard let divisorDouble = divisor.doubleValue else {
        return .nil
      }
      
      // Check for division by zero
      guard divisorDouble != 0 else {
        throw FilterError.invalidArgument(
          "Attempted to call `divided_by` on `\(token) with 0 as the divisor!"
        )
      }
      
      // Decimal division always returns decimal
      return .decimal(Decimal(dividendDouble / divisorDouble))
      
    case .string(let str):
      // Try to parse string as number
      if let intValue = Int(str) {
        // Parsed as integer - same logic as integer case
        guard intValue != 0 else {
          throw FilterError.invalidArgument(
            "Attempted to call `divided_by` on `\(token) with 0 as the divisor!"
          )
        }
        
        // If dividend was originally a decimal, return decimal result
        if case .decimal = token {
          return .decimal(Decimal(dividendDouble / Double(intValue)))
        } else {
          // Otherwise, perform integer division
          return .integer(Int(Darwin.floor(dividendDouble / Double(intValue))))
        }
      } else if let doubleValue = Double(str) {
        // Parsed as decimal - same logic as decimal case
        guard doubleValue != 0 else {
          throw FilterError.invalidArgument(
            "Attempted to call `divided_by` on `\(token) with 0 as the divisor!"
          )
        }
        return .decimal(Decimal(dividendDouble / doubleValue))
      } else {
        // Non-numeric string as divisor is invalid
        throw FilterError.invalidArgument(
          "Attempted to call `divided_by` on `\(token) with non-numeric divisor: \(str)!"
        )
      }
      
    default:
      // Other types (array, dictionary, bool) as divisor are invalid
      throw FilterError.invalidArgument(
        "Attempted to call `divided_by` on `\(token) with invalid divisor type: \(divisor)!"
      )
    }
  }
}

