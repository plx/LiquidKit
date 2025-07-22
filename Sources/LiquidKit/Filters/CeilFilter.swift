import Foundation
import Darwin

/// Implements the `ceil` filter, which rounds a number up to the nearest integer.
/// 
/// The `ceil` filter rounds a numeric value up to the nearest integer, returning the smallest
/// integer that is greater than or equal to the input value. This is the mathematical ceiling
/// function. The filter accepts numbers in various formats including integers, floats, and
/// numeric strings. Non-numeric values are treated as zero.
/// 
/// For positive numbers, `ceil` rounds away from zero (e.g., 5.1 becomes 6). For negative
/// numbers, it rounds toward zero (e.g., -5.1 becomes -5). Integer inputs are returned
/// unchanged since they are already at their ceiling value.
/// 
/// ## Examples
/// 
/// Rounding positive numbers:
/// ```liquid
/// {{ 5.4 | ceil }}
/// <!-- Output: 6 -->
/// 
/// {{ 5 | ceil }}
/// <!-- Output: 5 -->
/// 
/// {{ "5.1" | ceil }}
/// <!-- Output: 6 -->
/// ```
/// 
/// Rounding negative numbers:
/// ```liquid
/// {{ -5.4 | ceil }}
/// <!-- Output: -5 -->
/// 
/// {{ -5 | ceil }}
/// <!-- Output: -5 -->
/// 
/// {{ "-5.1" | ceil }}
/// <!-- Output: -5 -->
/// ```
/// 
/// Edge cases:
/// ```liquid
/// {{ 0 | ceil }}
/// <!-- Output: 0 -->
/// 
/// {{ "hello" | ceil }}
/// <!-- Output: 0 -->
/// 
/// {{ undefined_variable | ceil }}
/// <!-- Output: 0 -->
/// ```
/// 
/// - Important: Non-numeric values (including objects, arrays, and non-numeric strings) \
///   are treated as zero rather than causing an error. This follows the Liquid convention \
///   of graceful error handling.
/// 
/// - Warning: The filter does not accept any parameters. Passing parameters will result \
///   in an error in strict Liquid implementations.
/// 
/// - SeeAlso: ``FloorFilter``, ``RoundFilter``
/// - SeeAlso: [Shopify Liquid ceil](https://shopify.github.io/liquid/filters/ceil/)
/// - SeeAlso: [LiquidJS ceil](https://liquidjs.com/filters/ceil.html)
/// - SeeAlso: [Python Liquid ceil](https://liquid.readthedocs.io/en/latest/filter_reference/#ceil)
@usableFromInline
package struct CeilFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "ceil"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard let inputDouble = token.doubleValue else {
            return .nil
        }
        
        return .decimal(Decimal(Int(Darwin.ceil(inputDouble))))
    }
}