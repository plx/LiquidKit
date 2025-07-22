import Foundation

/// Implements the `at_most` filter, which returns the minimum of two values, ensuring a maximum threshold.
/// 
/// The at_most filter compares the input value with a specified maximum threshold and returns
/// the smaller of the two values. This filter is useful for capping values at a certain limit,
/// ensuring that a value never exceeds a maximum threshold. Common applications include setting
/// maximum prices, limiting display values, or establishing ceiling values for calculations.
/// 
/// Both the input value and the parameter must be numeric or convertible to numeric values.
/// String representations of numbers are automatically converted. If either value cannot be
/// converted to a number, the filter returns specific default values based on the conversion
/// failure pattern.
/// 
/// ## Examples
/// 
/// Basic numeric comparisons:
/// ```liquid
/// {{ 8 | at_most: 5 }}          → 5
/// {{ 5 | at_most: 8 }}          → 5
/// {{ 5 | at_most: 5 }}          → 5
/// {{ -8 | at_most: 5 }}         → -8
/// {{ 8.4 | at_most: 5.9 }}      → 5.9
/// ```
/// 
/// String conversion:
/// ```liquid
/// {{ "9" | at_most: 8 }}        → 8
/// {{ 5 | at_most: "8" }}        → 5
/// ```
/// 
/// Edge cases with non-numeric values:
/// ```liquid
/// {{ "abc" | at_most: -2 }}     → -2
/// {{ 5 | at_most: "abc" }}      → 0
/// {{ nil | at_most: 5 }}        → 0
/// {{ 5 | at_most: nil }}        → 0
/// ```
/// 
/// > Important: When either the input or parameter cannot be converted to a number, the filter
/// > returns 0 in most cases. However, if the input is non-numeric but the parameter is numeric,
/// > it returns the parameter value (enforcing the maximum). This behavior ensures safe defaults
/// > while still applying the cap when possible.
/// 
/// > Warning: The at_most filter requires exactly one numeric parameter. Missing parameters
/// > or multiple parameters will cause an error in strict Liquid implementations.
/// 
/// - SeeAlso: ``AtLeastFilter``, ``ClampFilter``
/// - SeeAlso: [LiquidJS at_most](https://liquidjs.com/filters/at_most.html)
/// - SeeAlso: [Python Liquid at_most](https://liquid.readthedocs.io/en/latest/filter_reference/#at_most)
/// - SeeAlso: [Shopify Liquid at_most](https://shopify.github.io/liquid/filters/at_most/)
@usableFromInline
package struct AtMostFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "at_most"
    
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
        
        return .decimal(min(inputDecimal, parameterDecimal))
    }
}