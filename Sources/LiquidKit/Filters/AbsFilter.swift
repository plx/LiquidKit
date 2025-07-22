import Foundation

/// Implements the `abs` filter, which transforms numeric values to their absolute value.
/// 
/// The abs filter calculates the absolute value of a number, converting negative numbers
/// to positive while leaving positive numbers unchanged. This filter is commonly used
/// when you need to ensure a value is positive regardless of its original sign, such as
/// when calculating distances, differences, or formatting display values.
/// 
/// The filter accepts numeric values (integers or decimals) as input. String representations
/// of numbers are automatically converted before processing. Non-numeric values return 0.
/// 
/// ## Examples
/// 
/// Basic usage with numeric values:
/// ```liquid
/// {{ -5 | abs }}        → 5
/// {{ 5 | abs }}         → 5
/// {{ -3.14 | abs }}     → 3.14
/// {{ 0 | abs }}         → 0
/// ```
/// 
/// String conversion:
/// ```liquid
/// {{ "-42" | abs }}     → 42
/// {{ "-3.14" | abs }}   → 3.14
/// ```
/// 
/// Edge cases:
/// ```liquid
/// {{ "hello" | abs }}   → 0
/// {{ nil | abs }}       → 0
/// ```
/// 
/// > Important: Unlike some Liquid implementations, this filter returns 0 for non-numeric
/// > values rather than returning the original value or throwing an error. This includes
/// > strings that cannot be parsed as numbers, nil values, and objects.
/// 
/// > Warning: The abs filter does not accept any parameters. Providing parameters will
/// > result in an error in strict Liquid implementations, though this implementation
/// > currently ignores extra parameters.
/// 
/// - SeeAlso: ``CeilFilter``, ``FloorFilter``, ``RoundFilter``, ``MinusFilter``, ``PlusFilter``
/// - SeeAlso: [LiquidJS abs](https://liquidjs.com/filters/abs.html)
/// - SeeAlso: [Python Liquid abs](https://liquid.readthedocs.io/en/latest/filter_reference/#abs)
/// - SeeAlso: [Shopify Liquid abs](https://shopify.github.io/liquid/filters/abs/)
@usableFromInline
package struct AbsFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "abs"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard let decimal = token.decimalValue else {
            return .nil
        }
        
        return .decimal(Swift.abs(decimal))
    }
}