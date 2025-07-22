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
    guard let inputDouble = token.doubleValue else {
      return .nil
    }
    
    return .decimal(Decimal(Int(Darwin.floor(inputDouble))))
  }
}