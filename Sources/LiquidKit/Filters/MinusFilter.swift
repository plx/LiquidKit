import Foundation

/// Implements the `minus` filter, which subtracts a number from another number.
/// 
/// The `minus` filter performs arithmetic subtraction, subtracting the filter parameter
/// from the input value. Both the input and parameter are converted to numeric values
/// before the operation. The filter intelligently preserves numeric types: if both
/// operands are integers and the result is a whole number, it returns an integer;
/// otherwise, it returns a decimal value.
/// 
/// String values that can be parsed as numbers are automatically converted. Non-numeric
/// strings and nil values are treated as 0. This lenient conversion behavior allows the
/// filter to work with various data types without throwing errors, making templates more
/// robust when dealing with user input or dynamic data.
/// 
/// ## Examples
/// 
/// Basic integer subtraction:
/// ```liquid
/// {{ 10 | minus: 2 }}
/// // Output: 8
/// ```
/// 
/// Decimal subtraction:
/// ```liquid
/// {{ 10.1 | minus: 2.2 }}
/// // Output: 7.9
/// ```
/// 
/// String to number conversion:
/// ```liquid
/// {{ "10.1" | minus: "2.2" }}
/// // Output: 7.9
/// ```
/// 
/// Non-numeric string handling:
/// ```liquid
/// {{ "foo" | minus: "2.0" }}
/// // Output: -2.0
/// ```
/// 
/// Nil value handling:
/// ```liquid
/// {{ nosuchthing | minus: 2 }}
/// // Output: -2
/// ```
/// 
/// Mixed integer and decimal:
/// ```liquid
/// {{ 10 | minus: 2.0 }}
/// // Output: 8.0
/// ```
/// 
/// - Important: The filter preserves integer types when possible. If both input and
///   parameter are integers and the result has no fractional part, an integer is returned.
/// 
/// - SeeAlso: ``PlusFilter``, ``TimesFilter``, ``DividedByFilter``, ``ModuloFilter``
/// - SeeAlso: [LiquidJS Documentation](https://liquidjs.com/filters/minus.html)
/// - SeeAlso: [Python Liquid Documentation](https://liquid.readthedocs.io/en/latest/filter_reference/#minus)
/// - SeeAlso: [Shopify Liquid Documentation](https://shopify.github.io/liquid/filters/minus/)
@usableFromInline
package struct MinusFilter: Filter {
  @usableFromInline
  package static let filterIdentifier = "minus"
  
  @inlinable
  package init() {}
  
  @inlinable
  package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
    guard !parameters.isEmpty else {
      return token
    }
    
    let left = token.doubleValue ?? 0
    let right = parameters[0].doubleValue ?? 0
    let result = left - right
    
    // If both operands were integers, return an integer
    if case .integer = token,
       case .integer = parameters[0],
       result == Double(Int(result)) {
      return .integer(Int(result))
    }
    
    return .decimal(Decimal(result))
  }
}