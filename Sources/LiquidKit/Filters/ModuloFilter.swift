import Foundation

/// Implements the `modulo` filter, which returns the remainder after division of one number by another.
/// 
/// The `modulo` filter performs the modulo operation (remainder after division) on two
/// numeric values. Like other arithmetic filters in Liquid, it automatically converts
/// string representations of numbers and handles various edge cases gracefully. The
/// filter preserves integer types when both operands are integers and the result is
/// a whole number, otherwise returns a decimal.
/// 
/// Division by zero is handled safely and returns 0 rather than throwing an error or
/// returning infinity. This behavior matches the reference Liquid implementation's
/// approach to error handling, prioritizing template robustness over mathematical
/// strictness. Non-numeric values and nil are treated as 0 for the calculation.
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
/// // Output: 0
/// ```
/// 
/// Non-numeric handling:
/// ```liquid
/// {{ "foo" | modulo: "2.0" }}
/// // Output: 0.0
/// ```
/// 
/// - Warning: Division by zero returns 0 rather than throwing an error. This is
///   intentional behavior for template robustness but may mask logical errors.
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
    guard !parameters.isEmpty else {
      return token
    }
    
    let left = token.doubleValue ?? 0
    let right = parameters[0].doubleValue ?? 0
    
    guard right != 0 else {
      return .integer(0)
    }
    
    let result = left.truncatingRemainder(dividingBy: right)
    
    // If both operands were integers and result is a whole number, return an integer
    if case .integer = token,
       case .integer = parameters[0],
       result == Double(Int(result)) {
      return .integer(Int(result))
    }
    
    return .decimal(Decimal(result))
  }
}