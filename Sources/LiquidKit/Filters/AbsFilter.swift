import Foundation

/// Implements the `abs` filter, which transforms numeric values to their absolute value.
/// 
/// The abs filter calculates the absolute value of a number, converting negative numbers
/// to positive while leaving positive numbers unchanged. This filter is commonly used
/// when you need to ensure a value is positive regardless of its original sign, such as
/// when calculating distances, differences, or formatting display values.
/// 
/// The filter accepts numeric values (integers or decimals) as input. String representations
/// of numbers are automatically converted before processing. Non-numeric values return 0,
/// following the behavior of python-liquid and other standard implementations.
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
/// {{ true | abs }}      → 0
/// {{ [1,2,3] | abs }}   → 0
/// ```
/// 
/// Special numeric strings:
/// ```liquid
/// {{ "1e5" | abs }}     → 100000
/// {{ " 42 " | abs }}    → 42
/// {{ "12.34.56" | abs }} → 0 (invalid format)
/// {{ "Infinity" | abs }} → 0 (not a valid number)
/// ```
/// 
/// > Important: This filter returns 0 for non-numeric values, consistent with python-liquid
/// > and the standard Liquid specification. This includes strings that cannot be parsed as
/// > numbers, nil values, booleans, arrays, dictionaries, and ranges.
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
        // First, try to get the numeric value
        switch token {
        case .integer(let value):
            // For integers, preserve the integer type and return absolute value
            return .integer(Swift.abs(value))
            
        case .decimal(let value):
            // For decimals, preserve the decimal type and return absolute value
            return .decimal(Swift.abs(value))
            
        case .string(let string):
            // For strings, attempt to parse as a number
            // First trim whitespace
            let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Check if it's empty after trimming
            if trimmed.isEmpty {
                // Empty strings should be treated as 0 (per python-liquid)
                return .integer(0)
            }
            
            // Try to parse as integer first to preserve type if possible
            if let intValue = Int(trimmed) {
                return .integer(Swift.abs(intValue))
            }
            
            // If not an integer, try decimal
            // But we need to be more careful about what constitutes a valid number
            if let decimalValue = Decimal(string: trimmed) {
                // Additional validation: check if the string is a valid number format
                // Reject strings with multiple dots or other invalid patterns
                let components = trimmed.components(separatedBy: ".")
                if components.count > 2 {
                    // Multiple decimal points - not a valid number
                    return .integer(0)
                }
                
                // Special handling for infinity/nan strings that Decimal might parse as 0
                let lowerTrimmed = trimmed.lowercased()
                if lowerTrimmed == "infinity" || lowerTrimmed == "-infinity" || lowerTrimmed == "nan" {
                    // These should not be treated as valid numbers
                    return .integer(0)
                }
                
                // Check for scientific notation - if it parses as decimal and contains 'e'
                // we should check if the result is actually an integer
                if lowerTrimmed.contains("e") {
                    // Scientific notation - check if result is an integer
                    let absValue = Swift.abs(decimalValue)
                    if absValue == Decimal(Int(truncating: absValue as NSNumber)) {
                        return .integer(Int(truncating: absValue as NSNumber))
                    }
                }
                
                return .decimal(Swift.abs(decimalValue))
            }
            
            // If string cannot be parsed as a number, return 0 (per python-liquid spec)
            return .integer(0)
            
        default:
            // For all other types (nil, bool, array, dictionary, range), return 0
            // This matches python-liquid behavior: "Given a value that can't be cast to a 
            // number, 0 will be returned"
            return .integer(0)
        }
    }
}