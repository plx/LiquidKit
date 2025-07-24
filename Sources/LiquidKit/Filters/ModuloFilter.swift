import Foundation

/// Implements the `modulo` filter, which returns the remainder after division of one number by another.
/// 
/// The `modulo` filter performs the modulo operation (remainder after division) on two
/// numeric values. Like other arithmetic filters in Liquid, it automatically converts
/// string representations of numbers and handles various edge cases gracefully. The
/// filter preserves integer types when both operands are integers and the result is
/// a whole number, otherwise returns a decimal.
/// 
/// Division by zero throws a FilterError with a descriptive message, matching the
/// behavior of the `divided_by` filter. This aligns with proper error handling practices
/// where invalid operations should be caught and reported. Non-numeric divisors (nil, arrays,
/// dictionaries, booleans) also throw errors.
/// 
/// ## Examples
/// 
/// Basic integer modulo:
/// ```liquid
/// {{ 10 | modulo: 3 }}
/// // Output: 1
/// ```
/// 
/// Even/odd checking:
/// ```liquid
/// {{ 7 | modulo: 2 }}
/// // Output: 1 (odd)
/// 
/// {{ 8 | modulo: 2 }}
/// // Output: 0 (even)
/// ```
/// 
/// Decimal modulo:
/// ```liquid
/// {{ 10.1 | modulo: 7.0 }}
/// // Output: 3.1
/// ```
/// 
/// String number conversion:
/// ```liquid
/// {{ "10" | modulo: "2.0" }}
/// // Output: 0.0
/// ```
/// 
/// Division by zero:
/// ```liquid
/// {{ 10 | modulo: 0 }}
/// // Error: Attempted to call `modulo` on `10` with 0 as the divisor!
/// ```
/// 
/// Non-numeric handling:
/// ```liquid
/// {{ "foo" | modulo: "2.0" }}
/// // Output: 0.0
/// ```
/// 
/// - Warning: Division by zero throws a FilterError. Ensure your templates handle
///   potential zero divisors appropriately.
/// 
/// - Warning: Non-numeric divisors (including nil and non-numeric strings) throw a FilterError.
/// 
/// - Important: The modulo operation uses Swift's `truncatingRemainder` method, which
///   follows IEEE 754 remainder semantics rather than Euclidean modulo for negative numbers.
/// 
/// - SeeAlso: ``DividedByFilter``, ``TimesFilter``, ``MinusFilter``
/// - SeeAlso: [LiquidJS Documentation](https://liquidjs.com/filters/modulo.html)
/// - SeeAlso: [Python Liquid Documentation](https://liquid.readthedocs.io/en/latest/filter_reference/#modulo)
/// - SeeAlso: [Shopify Liquid Documentation](https://shopify.github.io/liquid/filters/modulo/)
@usableFromInline
package struct ModuloFilter: Filter {
  @usableFromInline
  package static let filterIdentifier = "modulo"
  
  @inlinable
  package init() {}
  
  @inlinable
  package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
    // If no parameters provided, return the input unchanged
    guard !parameters.isEmpty else {
      return token
    }
    
    // Get the divisor parameter
    let divisor = parameters[0]
    
    // Nil divisor will be handled in the switch statement below
    
    // Get numeric value of dividend, handling special cases
    let dividendDouble: Double
    let dividendIsInteger: Bool
    
    switch token {
    case .integer(let value):
      dividendDouble = Double(value)
      dividendIsInteger = true
    case .decimal(let value):
      dividendDouble = (value as NSNumber).doubleValue
      dividendIsInteger = false
    case .string(let value):
      // String conversion - check if it's a valid number
      if let intValue = Int(value) {
        dividendDouble = Double(intValue)
        dividendIsInteger = true
      } else if let doubleValue = Double(value) {
        dividendDouble = doubleValue
        dividendIsInteger = false
      } else {
        // Invalid string becomes 0
        dividendDouble = 0
        dividendIsInteger = true
      }
    case .bool(let value):
      // Boolean becomes 1 (true) or 0 (false)
      dividendDouble = value ? 1.0 : 0.0
      dividendIsInteger = true
    case .nil, .array, .dictionary:
      // Non-numeric types become 0
      dividendDouble = 0
      dividendIsInteger = true
    case .range:
      // Range doesn't have a numeric value
      dividendDouble = 0
      dividendIsInteger = true
    }
    
    // Get numeric value of divisor, handling special cases
    let divisorDouble: Double
    let divisorIsInteger: Bool
    
    switch divisor {
    case .integer(let value):
      // Check for division by zero
      guard value != 0 else {
        throw FilterError.invalidArgument(
          "Attempted to call `modulo` on `\(token)` with 0 as the divisor!"
        )
      }
      divisorDouble = Double(value)
      divisorIsInteger = true
    case .decimal(let value):
      let doubleValue = (value as NSNumber).doubleValue
      // Check for division by zero
      guard doubleValue != 0 else {
        throw FilterError.invalidArgument(
          "Attempted to call `modulo` on `\(token)` with 0 as the divisor!"
        )
      }
      divisorDouble = doubleValue
      divisorIsInteger = false
    case .string(let value):
      // String conversion - check if it's a valid number
      if let intValue = Int(value) {
        guard intValue != 0 else {
          throw FilterError.invalidArgument(
            "Attempted to call `modulo` on `\(token)` with 0 as the divisor!"
          )
        }
        divisorDouble = Double(intValue)
        divisorIsInteger = true
      } else if let doubleValue = Double(value) {
        guard doubleValue != 0 else {
          throw FilterError.invalidArgument(
            "Attempted to call `modulo` on `\(token)` with 0 as the divisor!"
          )
        }
        divisorDouble = doubleValue
        divisorIsInteger = false
      } else {
        // Invalid string divisor - throw error
        throw FilterError.invalidArgument(
          "Attempted to call `modulo` on `\(token)` with '\(value)' (non-numeric string) as the divisor!"
        )
      }
    case .nil:
      // Nil divisor throws error
      throw FilterError.invalidArgument(
        "Attempted to call `modulo` on `\(token)` with nil as the divisor!"
      )
    case .bool, .array, .dictionary, .range:
      // Non-numeric divisor types throw error
      throw FilterError.invalidArgument(
        "Attempted to call `modulo` on `\(token)` with \(divisor) as the divisor!"
      )
    }
    
    // Perform the modulo operation
    let result = dividendDouble.truncatingRemainder(dividingBy: divisorDouble)
    
    // Determine return type based on operand types and result
    // If both operands were integers and result is a whole number, return an integer
    if dividendIsInteger && divisorIsInteger && result == Double(Int(result)) {
      return .integer(Int(result))
    }
    
    // Otherwise return decimal
    return .decimal(Decimal(result))
  }
}