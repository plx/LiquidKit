import Foundation

/// Implements the `plus` filter, which adds two numbers together.
/// 
/// The `plus` filter performs arithmetic addition, adding the filter parameter to the
/// input value. It features automatic type conversion for string representations of
/// numbers and graceful handling of non-numeric values. Like other arithmetic filters
/// in Liquid, it preserves integer types when both operands are integers and the result
/// is a whole number, ensuring type consistency in calculations.
/// 
/// The filter's lenient conversion behavior treats non-numeric strings and nil values
/// as 0, allowing templates to handle missing or invalid data without errors. This makes
/// it particularly useful for calculations involving user input or optional values where
/// robustness is more important than strict type checking.
/// 
/// ## Examples
/// 
/// Basic integer addition:
/// ```liquid
/// {{ 10 | plus: 2 }}
/// // Output: 12
/// ```
/// 
/// Decimal addition:
/// ```liquid
/// {{ 10.1 | plus: 2.2 }}
/// // Output: 12.3
/// ```
/// 
/// String number conversion:
/// ```liquid
/// {{ "10.1" | plus: "2.2" }}
/// // Output: 12.3
/// ```
/// 
/// Negative number addition:
/// ```liquid
/// {{ 10 | plus: -2 }}
/// // Output: 8
/// ```
/// 
/// Non-numeric string handling:
/// ```liquid
/// {{ "foo" | plus: "2.0" }}
/// // Output: 2.0
/// ```
/// 
/// Nil value handling:
/// ```liquid
/// {{ nosuchthing | plus: 2 }}
/// // Output: 2
/// 
/// {{ 10 | plus: nosuchthing }}
/// // Output: 10
/// ```
/// 
/// Mixed types preserving decimal:
/// ```liquid
/// {{ 10 | plus: 2.0 }}
/// // Output: 12.0
/// ```
/// 
/// - Important: The filter preserves integer types when possible. If both operands are
///   integers, the result is an integer. If either operand is a decimal, the result is decimal.
/// 
/// - Important: Invalid numeric strings are treated as 0 rather than causing errors,
///   which can mask data issues but ensures template rendering continues.
/// 
/// - SeeAlso: ``MinusFilter``, ``TimesFilter``, ``DividedByFilter``
/// - SeeAlso: [LiquidJS Documentation](https://liquidjs.com/filters/plus.html)
/// - SeeAlso: [Python Liquid Documentation](https://liquid.readthedocs.io/en/latest/filter_reference/#plus)
/// - SeeAlso: [Shopify Liquid Documentation](https://shopify.github.io/liquid/filters/plus/)
@usableFromInline
package struct PlusFilter: Filter {
  @usableFromInline
  package static let filterIdentifier = "plus"
  
  @inlinable
  package init() {}
  
  @inlinable
  package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
    guard !parameters.isEmpty else {
      return token
    }
    
    let left = token.doubleValue ?? 0
    let right = parameters[0].doubleValue ?? 0
    let result = left + right
    
    // If both operands were integers, return an integer
    if case .integer = token,
       case .integer = parameters[0],
       result == Double(Int(result)) {
      return .integer(Int(result))
    }
    
    return .decimal(Decimal(result))
  }
}