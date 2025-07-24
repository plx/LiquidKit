import Foundation

/// Implements the `join` filter, which combines array elements into a single string with a separator.
/// 
/// The `join` filter concatenates all elements of an array into a string, inserting a specified
/// separator between each element. If no separator is provided, it defaults to a single space.
/// Non-array values pass through unchanged. This filter is essential for formatting array data
/// for display.
///
/// ## Examples
///
/// Basic array joining:
/// ```liquid
/// {{ arr | join: '#' }}
/// // With arr = ["a", "b", "c"], outputs: "a#b#c"
/// ```
///
/// Default separator (space):
/// ```liquid
/// {{ arr | join }}
/// // With arr = ["a", "b"], outputs: "a b"
/// ```
///
/// Mixed type array:
/// ```liquid
/// {{ arr | join: ', ' }}
/// // With arr = ["a", 1, true], outputs: "a, 1, true"
/// ```
///
/// Range joining:
/// ```liquid
/// {{ (1..5) | join: '-' }}
/// // Outputs: "1-2-3-4-5"
/// ```
///
/// Non-array input (passes through):
/// ```liquid
/// {{ "hello" | join: '#' }}
/// // Outputs: "hello"
/// 
/// {{ 123 | join: '#' }}
/// // Outputs: "123"
/// ```
///
/// Empty or nil separator:
/// ```liquid
/// {{ arr | join: nil }}
/// // With arr = ["H", "i"], outputs: "Hi"
/// ```
///
/// - Important: All array elements are converted to strings using their string representation
///   before joining. Objects and hashes will use their default string conversion.
///
/// - Important: When the input is not an array (including strings, numbers, or undefined values),
///   the filter returns the input unchanged rather than raising an error.
///
/// - Warning: Providing more than one argument to the filter (e.g., `{{ arr | join: '#', 42 }}`)
///   may cause an error in strict Liquid implementations, though this implementation uses only
///   the first argument.
///
/// - SeeAlso: ``SplitFilter`` for the inverse operation
/// - SeeAlso: ``ConcatFilter`` for combining arrays
/// - SeeAlso: [LiquidJS join filter](https://liquidjs.com/filters/join.html)
/// - SeeAlso: [Python Liquid join filter](https://liquid.readthedocs.io/en/latest/filter_reference/#join)
/// - SeeAlso: [Shopify Liquid join filter](https://shopify.github.io/liquid/filters/join/)
@usableFromInline
package struct JoinFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "join"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        // Handle different input types
        let arrayToJoin: [Token.Value]
        switch token {
        case .array(let array):
            // Already an array, use it directly
            arrayToJoin = array
        case .range(let range):
            // Convert range to array of integers
            arrayToJoin = range.map { .integer($0) }
        default:
            // Non-array values pass through unchanged
            return token
        }
        
        // Determine separator from first parameter, default to space
        let separator: String
        if let firstParameter = parameters.first {
            separator = firstParameter.stringValue
        } else {
            separator = " "
        }
        
        // Convert each element to string representation
        let stringArray = arrayToJoin.map { element in
            switch element {
            case .bool(let value):
                // Explicitly handle booleans to show "true"/"false"
                return value ? "true" : "false"
            case .dictionary:
                // Dictionaries render as "{}" in join output
                return "{}"
            default:
                // Use default stringValue conversion for other types
                return element.stringValue
            }
        }
        
        // Join the strings with the separator
        return .string(stringArray.joined(separator: separator))
    }
}