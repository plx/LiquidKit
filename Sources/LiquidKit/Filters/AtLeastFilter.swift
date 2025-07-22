import Foundation

/// Implements the `at_least` filter, which returns the maximum of two values, ensuring a minimum threshold.
/// 
/// The at_least filter compares the input value with a specified minimum threshold and returns
/// the larger of the two values. This filter is particularly useful for enforcing minimum values
/// in calculations, ensuring that a value never falls below a certain threshold. Common use cases
/// include setting minimum prices, ensuring positive values, or establishing floor values for
/// mathematical operations.
/// 
/// Both the input value and the parameter must be numeric or convertible to numeric values.
/// String representations of numbers are automatically converted. If either value cannot be
/// converted to a number, special handling applies based on which value is non-numeric.
/// 
/// ## Examples
/// 
/// Basic numeric comparisons:
/// ```liquid
/// {{ 5 | at_least: 8 }}         → 8
/// {{ 8 | at_least: 5 }}         → 8
/// {{ 5 | at_least: 5 }}         → 5
/// {{ -8 | at_least: 5 }}        → 5
/// {{ 5.4 | at_least: 8.9 }}     → 8.9
/// ```
/// 
/// String conversion:
/// ```liquid
/// {{ "9" | at_least: 8 }}       → 9
/// {{ 5 | at_least: "8" }}       → 8
/// ```
/// 
/// Edge cases with non-numeric values:
/// ```liquid
/// {{ "abc" | at_least: 2 }}     → 2
/// {{ "abc" | at_least: -2 }}    → 0
/// {{ -1 | at_least: "abc" }}    → 0
/// {{ nil | at_least: 5 }}       → 5
/// {{ 5 | at_least: nil }}       → 5
/// ```
/// 
/// > Important: When the input value is non-numeric but the parameter is numeric, the filter
/// > returns the parameter value (enforcing the minimum). When the parameter is non-numeric,
/// > the filter returns 0. This behavior differs from some other Liquid implementations
/// > that might throw errors or return the original value.
/// 
/// > Warning: The at_least filter requires exactly one numeric parameter. Missing parameters
/// > or multiple parameters will cause an error in strict Liquid implementations.
/// 
/// - SeeAlso: ``AtMostFilter``, ``ClampFilter``
/// - SeeAlso: [LiquidJS at_least](https://liquidjs.com/filters/at_least.html)
/// - SeeAlso: [Python Liquid at_least](https://liquid.readthedocs.io/en/latest/filter_reference/#at_least)
/// - SeeAlso: [Shopify Liquid at_least](https://shopify.github.io/liquid/filters/at_least/)
@usableFromInline
package struct AtLeastFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "at_least"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard
            let inputDecimal = token.decimalValue,
            let parameterDecimal = parameters.first?.decimalValue
        else {
            return .nil
        }
        
        return .decimal(max(inputDecimal, parameterDecimal))
    }
}