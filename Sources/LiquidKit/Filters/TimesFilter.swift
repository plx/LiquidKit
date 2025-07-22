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
/// {{ "5.0" | times: "2.1" }}
/// // Output: "10.5"
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
/// - Important: The filter requires exactly one argument. Omitting the argument or \
///   providing multiple arguments will result in an error.
/// 
/// - Important: When both operands are integers and the mathematical result is a whole number, \
///   the filter returns an integer. Otherwise, it returns a decimal. This preserves type \
///   information when appropriate.
/// 
/// - Warning: The filter requires exactly one argument. Using it without arguments \
///   (e.g., `{{ 5 | times }}`) or with multiple arguments (e.g., `{{ 5 | times: 1, 2 }}`) \
///   will result in an error.
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
    guard !parameters.isEmpty else {
      return token
    }
    
    let left = token.doubleValue ?? 0
    let right = parameters[0].doubleValue ?? 0
    let result = left * right
    
    // If both operands were integers, return an integer
    if case .integer = token,
       case .integer = parameters[0],
       result == Double(Int(result)) {
      return .integer(Int(result))
    }
    
    return .decimal(Decimal(result))
  }
}