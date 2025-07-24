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
/// converted to a number, the filter uses 0 as the default value, following the behavior of
/// liquidjs and python-liquid implementations.
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
/// {{ "abc" | at_most: 5 }}      → 0
/// {{ 5 | at_most: "abc" }}      → 0
/// {{ nil | at_most: 5 }}        → 0
/// {{ 5 | at_most: nil }}        → 0
/// {{ -1 | at_most: "xyz" }}     → 0
/// ```
/// 
/// > Important: When the parameter cannot be converted to a number (excluding nil and boolean values),
/// > the filter returns 0 regardless of the input value. When the input cannot be converted to a number,
/// > it is treated as 0. This behavior matches the implementation in liquidjs and python-liquid.
/// 
/// > Warning: The at_most filter requires exactly one numeric parameter. Missing parameters
/// > are treated as 0.
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
    
    /// Helper function to convert Token.Value to decimal with proper handling of all types
    @inlinable
    package func toDecimal(_ value: Token.Value) -> Decimal {
        switch value {
        case .bool(let b):
            // Booleans convert to 1 (true) or 0 (false)
            return b ? 1 : 0
        default:
            // Use the built-in decimalValue conversion for other types
            return value.decimalValue ?? 0
        }
    }
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        // Special case: if the parameter is non-numeric (excluding nil/bool), return 0
        // This matches the behavior of liquidjs and python-liquid where a non-numeric
        // parameter causes the filter to return 0 regardless of the input value
        if let param = parameters.first {
            switch param {
            case .string(let str) where Decimal(string: str) == nil:
                // Non-numeric string parameter (e.g., "abc", "xyz")
                return .integer(0)
            case .array, .dictionary:
                // Collection types cannot be converted to numbers
                return .integer(0)
            default:
                // For .integer, .decimal, .bool, .nil, .range, and numeric strings,
                // continue with normal processing
                break
            }
        }
        
        // Get the input value as a decimal, with special handling for booleans
        let inputDecimal = toDecimal(token)
        
        // Get the parameter value (if present) as a decimal
        let parameterDecimal = parameters.first.map(toDecimal) ?? 0
        
        // Calculate the minimum of the two values
        let result = min(inputDecimal, parameterDecimal)
        
        // Determine if we should return an integer or decimal
        // We return an integer if:
        // 1. The result has no fractional part AND
        // 2. The output type should be integer based on the input types
        
        // First check if result is a whole number
        if result == Decimal(Int(truncating: result as NSNumber)) {
            // Special handling: if input had decimal places but result is integer,
            // we should return integer (e.g., "8.5" | at_most: 5 → 5, not 5.0)
            let shouldReturnInteger: Bool
            
            // If the result equals the parameter value, check parameter type
            if result == parameterDecimal {
                shouldReturnInteger = {
                    guard let param = parameters.first else {
                        return true  // missing parameter defaults to 0 which is integer
                    }
                    switch param {
                    case .integer:
                        return true
                    case .nil, .bool:
                        return true
                    case .string(let str):
                        // Check if string represents an integer or can be parsed as one
                        if let _ = Int(str) {
                            return true
                        } else if let decimal = Decimal(string: str) {
                            return decimal == Decimal(Int(truncating: decimal as NSNumber))
                        }
                        // Non-numeric strings default to 0 which is integer
                        return true
                    case .decimal(let d):
                        return d == Decimal(Int(truncating: d as NSNumber))
                    case .array, .dictionary, .range:
                        return true
                    }
                }()
            } else {
                // Result equals input value, check input type
                shouldReturnInteger = {
                    switch token {
                    case .integer:
                        return true
                    case .nil, .bool:
                        return true
                    case .string(let str):
                        if let _ = Int(str) {
                            return true
                        } else if let decimal = Decimal(string: str) {
                            return decimal == Decimal(Int(truncating: decimal as NSNumber))
                        }
                        return true
                    case .decimal(let d):
                        return d == Decimal(Int(truncating: d as NSNumber))
                    case .array, .dictionary, .range:
                        return true
                    }
                }()
            }
            
            if shouldReturnInteger {
                return .integer(Int(truncating: result as NSNumber))
            }
        }
        
        // Otherwise return as decimal
        return .decimal(result)
    }
}