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
/// The filter accepts strings that can be parsed as numbers and will attempt to convert them.
/// For non-numeric inputs that cannot be converted, the filter returns nil (which renders as
/// empty string in Liquid). The precision parameter can also be a string representation of a
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
/// ```
///
/// - Important: The filter uses banker's rounding (round half to even) for exact .5 values
///   in the underlying implementation, though this may vary by platform. Negative precision
///   values round to powers of 10: -1 rounds to tens, -2 to hundreds, etc. When the precision
///   parameter cannot be parsed as an integer, it defaults to 0.
///
/// - Warning: The current implementation returns nil for non-numeric inputs, while some
///   Liquid implementations may return 0. Passing too many arguments should raise an error
///   in strict Liquid implementations but may be ignored in this implementation.
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
    guard let value = token.doubleValue else {
      return .nil
    }
    
    // Get precision parameter (default is 0)
    let precision = parameters.first?.integerValue ?? 0
    
    if precision == 0 {
      // Round to nearest integer
      return .decimal(Decimal(Int(Darwin.round(value))))
    } else {
      // Round to specified decimal places
      let multiplier = pow(10.0, Double(precision))
      let rounded = Darwin.round(value * multiplier) / multiplier
      return .decimal(Decimal(rounded))
    }
  }
}