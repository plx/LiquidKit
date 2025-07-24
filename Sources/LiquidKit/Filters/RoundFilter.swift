import Foundation
import Darwin

/// Implements the `round` filter, which rounds a number to the nearest integer or to a specified number of decimal places.
/// 
/// The `round` filter performs mathematical rounding on numeric values. When used without parameters,
/// it rounds to the nearest integer using standard rounding rules (0.5 rounds up). When provided
/// with a precision parameter, it rounds to that many decimal places. The filter can handle both
/// positive and negative precision values, where negative precision rounds to powers of ten
/// (e.g., -1 rounds to the nearest 10).
///
/// The filter accepts strings that can be parsed as numbers and will attempt to convert them,
/// automatically trimming whitespace from string inputs. For non-numeric inputs that cannot
/// be converted, the filter returns 0, matching the behavior of python-liquid and other
/// Liquid implementations. The precision parameter can also be a string representation of a
/// number, which will be parsed and used for rounding.
///
/// ## Examples
///
/// Basic rounding to nearest integer:
/// ```liquid
/// {{ 5.6 | round }}
/// <!-- Output: "6" -->
/// 
/// {{ 5.1 | round }}
/// <!-- Output: "5" -->
/// 
/// {{ 5.5 | round }}
/// <!-- Output: "6" -->
/// ```
///
/// Rounding with decimal precision:
/// ```liquid
/// {{ 5.666666 | round: 2 }}
/// <!-- Output: "5.67" -->
/// 
/// {{ 5.666 | round: 1 }}
/// <!-- Output: "5.7" -->
/// 
/// {{ 1.234567 | round: 4 }}
/// <!-- Output: "1.2346" -->
/// ```
///
/// String inputs and edge cases:
/// ```liquid
/// {{ "5.6" | round }}
/// <!-- Output: "6" -->
/// 
/// {{ "5.666" | round: "1" }}
/// <!-- Output: "5.7" -->
/// 
/// {{ 5.666 | round: -2 }}
/// <!-- Output: "0" -->
/// 
/// {{ "hello" | round }}
/// <!-- Output: "0" -->
/// ```
///
/// - Important: The filter uses standard rounding rules where 0.5 rounds up. Negative precision
///   values round to powers of 10: -1 rounds to tens, -2 to hundreds, etc. When the precision
///   parameter cannot be parsed as an integer, it defaults to 0. Special numeric values like
///   NaN and Infinity are treated as invalid and return 0.
///
/// - Note: Extra parameters beyond the first precision parameter are ignored. This implementation
///   matches the behavior of python-liquid by returning 0 for non-numeric inputs.
///
/// - SeeAlso: ``CeilFilter``, ``FloorFilter``, ``AbsFilter``
/// - SeeAlso: [LiquidJS Documentation](https://liquidjs.com/filters/round.html)
/// - SeeAlso: [Python Liquid Documentation](https://liquid.readthedocs.io/en/latest/filter_reference/#round)
/// - SeeAlso: [Shopify Liquid Documentation](https://shopify.github.io/liquid/filters/round/)
@usableFromInline
package struct RoundFilter: Filter {
  @usableFromInline
  package static let filterIdentifier = "round"
  
  @inlinable
  package init() {}
  
  @inlinable
  package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
    // Get the numeric value from the token
    let value: Double
    
    // Handle string inputs specially to trim whitespace
    if case .string(let str) = token {
      let trimmed = str.trimmingCharacters(in: .whitespacesAndNewlines)
      
      // Empty strings should return 0
      if trimmed.isEmpty {
        return .integer(0)
      }
      
      // Try to parse the trimmed string as a number
      if let parsedValue = Double(trimmed) {
        value = parsedValue
      } else {
        // Non-numeric strings return 0 (matching python-liquid behavior)
        return .integer(0)
      }
    } else {
      // For non-string types, use the standard doubleValue conversion
      guard let doubleValue = token.doubleValue else {
        return .integer(0)
      }
      value = doubleValue
    }
    
    // Check for NaN or infinite values
    // These should return 0 to match python-liquid behavior
    if value.isNaN || value.isInfinite {
      return .integer(0)
    }
    
    // Get precision parameter (default is 0)
    // If the precision parameter can't be converted to an integer, default to 0
    let precision = parameters.first?.integerValue ?? 0
    
    if precision == 0 {
      // Round to nearest integer using standard rounding (0.5 rounds up)
      let rounded = Darwin.round(value)
      
      // Check if the result is within Int range to avoid crashes
      if rounded >= Double(Int.min) && rounded <= Double(Int.max) {
        return .integer(Int(rounded))
      } else {
        // For values outside Int range, return as decimal
        return .decimal(Decimal(rounded))
      }
    } else if precision < 0 {
      // Negative precision rounds to powers of 10
      // -1 rounds to tens, -2 to hundreds, etc.
      let divisor = pow(10.0, Double(-precision))
      let rounded = Darwin.round(value / divisor) * divisor
      
      // Check if the result is within Int range
      if rounded >= Double(Int.min) && rounded <= Double(Int.max) && rounded == Double(Int(rounded)) {
        return .integer(Int(rounded))
      } else {
        // For values outside Int range or with fractional parts, return as decimal
        return .decimal(Decimal(rounded))
      }
    } else {
      // Positive precision rounds to specified decimal places
      let multiplier = pow(10.0, Double(precision))
      let rounded = Darwin.round(value * multiplier) / multiplier
      
      // If the result is a whole number and within Int range, return as integer
      if rounded == Double(Int(rounded)) && rounded >= Double(Int.min) && rounded <= Double(Int.max) {
        // Check if we actually need decimal precision
        // If precision > 0 but the result is a whole number, still return as decimal
        // to preserve the requested precision (e.g., 5.5 rounded to 1 decimal = 5.5)
        if value != Double(Int(value)) || parameters.count > 0 {
          return .decimal(Decimal(rounded))
        } else {
          return .integer(Int(rounded))
        }
      } else {
        return .decimal(Decimal(rounded))
      }
    }
  }
}