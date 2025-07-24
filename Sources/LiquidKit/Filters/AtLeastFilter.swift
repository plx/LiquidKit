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
/// converted to a number, it is treated as 0, following the behavior of python-liquid.
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
/// > Important: When either value cannot be converted to a number, it is treated as 0.
/// > This matches the behavior of python-liquid and ensures consistent results.
/// 
/// > Warning: The at_least filter requires exactly one numeric parameter. Missing parameters
/// > will be treated as 0, and extra parameters will be ignored.
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
        // Get the decimal value of the input, defaulting to 0 if not numeric
        // This matches python-liquid behavior where non-numeric values are treated as 0
        let inputDecimal = token.decimalValue ?? 0
        
        // Get the decimal value of the parameter, defaulting to 0 if not provided or not numeric
        // This matches python-liquid behavior where non-numeric values are treated as 0
        let parameterDecimal = parameters.first?.decimalValue ?? 0
        
        // Return the maximum of the two values
        // This ensures the result is at least the specified minimum
        let result = max(inputDecimal, parameterDecimal)
        
        // Determine if we should return an integer or decimal
        // We return an integer if:
        // 1. Both input and parameter were originally integers, OR
        // 2. The result can be exactly represented as an integer AND at least one of the values was missing/nil/non-numeric
        
        // Check if both original values were integers
        let inputIsInteger = if case .integer = token { true } else { false }
        let paramIsInteger = if let param = parameters.first, case .integer = param { true } else { false }
        
        // Check if the values are numeric strings that convert to integers
        let inputIsIntegerString: Bool = {
            if case .string(let str) = token,
               let decimal = Decimal(string: str) {
                let doubleVal = NSDecimalNumber(decimal: decimal).doubleValue
                return doubleVal.truncatingRemainder(dividingBy: 1) == 0
            }
            return false
        }()
        
        let paramIsIntegerString: Bool = {
            if let param = parameters.first,
               case .string(let str) = param,
               let decimal = Decimal(string: str) {
                let doubleVal = NSDecimalNumber(decimal: decimal).doubleValue
                return doubleVal.truncatingRemainder(dividingBy: 1) == 0
            }
            return false
        }()
        
        // Check if the result can be exactly represented as an integer
        let doubleResult = NSDecimalNumber(decimal: result).doubleValue
        if doubleResult.truncatingRemainder(dividingBy: 1) == 0,
           doubleResult >= Double(Int.min),
           doubleResult <= Double(Int.max) {
            let intResult = Int(doubleResult)
            // If both were integers (actual or string representations), return integer
            if (inputIsInteger || inputIsIntegerString) && (paramIsInteger || paramIsIntegerString) {
                return .integer(intResult)
            }
            
            // If one was nil/missing/non-numeric and the other was integer, return integer
            // This handles cases like nil|at_least:5 → 5 (not 5.0)
            let inputWasNonNumeric = token.decimalValue == nil
            let paramWasNonNumeric = parameters.isEmpty || parameters.first?.decimalValue == nil
            
            if (inputWasNonNumeric && paramIsInteger) || (paramWasNonNumeric && inputIsInteger) {
                return .integer(intResult)
            }
            
            // Special case: if both were non-numeric (result is 0), return integer 0
            if inputWasNonNumeric && paramWasNonNumeric && intResult == 0 {
                return .integer(0)
            }
        }
        
        // For all other cases (mixed types, decimals, etc.), return as decimal
        return .decimal(result)
    }
}