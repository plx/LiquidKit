import Foundation

/// Implements the `times` filter, which multiplies a number by another number.
/// 
/// The `times` filter performs multiplication on numeric values. It accepts one required argument - the number
/// to multiply by. Both the input value and the argument can be integers, decimals, or numeric strings.
/// The filter preserves integer types when both operands are integers and the result has no fractional part,
/// otherwise it returns a decimal.
/// 
/// When either operand is nil or undefined, it is treated as 0. Non-numeric values that cannot be converted
/// to numbers are also treated as 0. This behavior ensures the filter always produces a numeric result rather
/// than causing errors with invalid input.
/// 
/// String values are automatically trimmed of whitespace before parsing. Strings that contain integer values
/// (e.g., "5") are treated as integers for type preservation purposes, while strings containing decimal
/// values (e.g., "5.0") are treated as decimals.
/// 
/// ## Examples
/// 
/// Basic multiplication:
/// ```liquid
/// {{ 5 | times: 2 }}
/// // Output: "10"
/// 
/// {{ 5.0 | times: 2.1 }}
/// // Output: "10.5"
/// 
/// {{ 5 | times: 2.1 }}
/// // Output: "10.5"
/// ```
/// 
/// String conversion and negative numbers:
/// ```liquid
/// {{ "5" | times: "2" }}
/// // Output: "10"  (integer preserved)
/// 
/// {{ "5.0" | times: "2.1" }}
/// // Output: "10.5"
/// 
/// {{ " 5 " | times: " 2 " }}
/// // Output: "10"  (whitespace trimmed)
/// 
/// {{ -5 | times: 2 }}
/// // Output: "-10"
/// ```
/// 
/// Nil and undefined handling:
/// ```liquid
/// {{ nil | times: 2 }}
/// // Output: "0"
/// 
/// {{ 5 | times: undefined_var }}
/// // Output: "0"
/// ```
/// 
/// - Important: When both operands are integers (including nil and integer strings) and the \
///   mathematical result is a whole number, the filter returns an integer. Otherwise, it returns \
///   a decimal. This preserves type information when appropriate.
/// 
/// - Warning: The filter requires exactly one argument. Using it without arguments \
///   (e.g., `{{ 5 | times }}`) will return the input unchanged. Extra arguments beyond the first \
///   are ignored (e.g., `{{ 5 | times: 2, 3 }}` will multiply by 2 only).
/// 
/// - SeeAlso: ``DividedByFilter`` - Divides a number by another number
/// - SeeAlso: ``PlusFilter`` - Adds two numbers
/// - SeeAlso: ``MinusFilter`` - Subtracts one number from another
/// - SeeAlso: ``ModuloFilter`` - Returns the remainder of division
/// - SeeAlso: [LiquidJS Documentation](https://liquidjs.com/filters/times.html)
/// - SeeAlso: [Python Liquid Documentation](https://liquid.readthedocs.io/en/latest/filters/times/)
/// - SeeAlso: [Shopify Liquid Documentation](https://shopify.github.io/liquid/filters/times/)
@usableFromInline
package struct TimesFilter: Filter {
  @usableFromInline
  package static let filterIdentifier = "times"
  
  @inlinable
  package init() {}
  
  @inlinable
  package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
    // If no parameters provided, return the input unchanged
    guard !parameters.isEmpty else {
      return token
    }
    
    // Helper function to get numeric value and track if it's integer-like
    func getNumericValue(from value: Token.Value) -> (value: Double, isIntegerLike: Bool) {
      switch value {
      case .integer(let i):
        return (Double(i), true)
      case .nil:
        return (0, true)  // nil is treated as integer 0
      case .decimal(let d):
        return ((d as NSNumber).doubleValue, false)
      case .string(let s):
        // Try to parse the string, handling whitespace
        let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // First try as integer
        if let intValue = Int(trimmed) {
          return (Double(intValue), true)
        }
        // Then try as double
        if let doubleValue = Double(trimmed), doubleValue.isFinite {
          return (doubleValue, false)
        }
        // Non-numeric string defaults to 0
        return (0, true)  // Treat non-numeric as integer 0
      default:
        // Other types (bool, array, etc.) default to 0
        return (0, true)  // Treat as integer 0
      }
    }
    
    // Get values and type information
    let (leftValue, leftIsInteger) = getNumericValue(from: token)
    let (rightValue, rightIsInteger) = getNumericValue(from: parameters[0])
    let result = leftValue * rightValue
    
    // Return integer if both operands are integer-like and result is whole
    if leftIsInteger && rightIsInteger && result == Double(Int(result)) {
      return .integer(Int(result))
    }
    
    // Otherwise return decimal
    return .decimal(Decimal(result))
  }
}
