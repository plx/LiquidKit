import Foundation

/// Implements the `remove` filter, which removes all occurrences of a substring from a string.
/// 
/// The `remove` filter performs a global search-and-replace operation, removing every
/// occurrence of the specified substring from the input string. This is equivalent to
/// using the `replace` filter with an empty replacement string. The filter is
/// case-sensitive and removes all matches, not just the first one.
/// 
/// Following the behavior of python-liquid and liquidjs, this filter coerces both the input
/// and parameter values to strings before performing the removal operation. This means
/// integers, decimals, booleans, and other types are converted to their string representations
/// before processing.
/// 
/// - Example: Basic removal
/// ```liquid
/// {{ "I strained to see the train through the rain" | remove: "rain" }}
/// <!-- Output: I sted to see the t through the  -->
/// 
/// {{ "Hello, world!" | remove: "o" }}
/// <!-- Output: Hell, wrld! -->
/// ```
/// 
/// - Example: Removing whitespace and punctuation
/// ```liquid
/// {{ "1-800-555-1234" | remove: "-" }}
/// <!-- Output: 18005551234 -->
/// 
/// {{ "price: $19.99" | remove: "$" }}
/// <!-- Output: price: 19.99 -->
/// ```
/// 
/// - Example: Case sensitivity
/// ```liquid
/// {{ "Hello HELLO hello" | remove: "hello" }}
/// <!-- Output: Hello HELLO  -->
/// ```
/// 
/// - Example: Type coercion
/// ```liquid
/// {{ 12345 | remove: "3" }}
/// <!-- Output: 1245 -->
/// 
/// {{ true | remove: "r" }}
/// <!-- Output: tue -->
/// 
/// {{ "test123test" | remove: 123 }}
/// <!-- Output: testtest -->
/// ```
/// 
/// - Important: The filter removes ALL occurrences of the substring, not just the first one.
///   Use `remove_first` if you only want to remove the first occurrence.
/// 
/// - Important: The removal is performed as a simple string replacement. It does not support
///   regular expressions or pattern matching. For more complex removals, consider using
///   multiple filters in combination.
/// 
/// - Note: `nil` values are returned as `nil` (which renders as empty string), and arrays are
///   converted to strings by joining their elements.
/// 
/// - SeeAlso: ``RemoveFirstFilter`` - Removes only the first occurrence
/// - SeeAlso: ``ReplaceFilter`` - Replaces substrings with a different string
/// - SeeAlso: [LiquidJS remove](https://liquidjs.com/filters/remove.html)
/// - SeeAlso: [Python Liquid remove](https://liquid.readthedocs.io/en/latest/filter_reference/#remove)
/// - SeeAlso: [Shopify Liquid remove](https://shopify.github.io/liquid/filters/remove/)
@usableFromInline
package struct RemoveFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "remove"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        // Convert input to string - matching python-liquid behavior
        // For nil, return nil (which renders as empty string)
        if case .nil = token {
            return token
        }
        
        // Get string representation of the input value
        let inputString: String
        switch token {
        case .string(let str):
            // String values use their value directly
            inputString = str
        case .bool(let value):
            // Booleans convert to "true" or "false"
            inputString = value ? "true" : "false"
        case .integer(let value):
            // Integers convert to their string representation
            inputString = "\(value)"
        case .decimal(let value):
            // Decimals convert to their string representation
            inputString = "\(value)"
        case .array(let array):
            // Arrays join their elements' string values
            inputString = array.map { $0.stringValue }.joined()
        case .dictionary:
            // Dictionaries convert to their debug representation
            // This matches the behavior of other Liquid implementations
            inputString = token.stringValue
        case .range(let range):
            // Ranges convert to "lower..upper" format
            inputString = "\(range.lowerBound)..\(range.upperBound)"
        case .nil:
            // Already handled above, but needed for exhaustive switch
            return token
        }
        
        // Check if we have a parameter to remove
        guard parameters.count >= 1 else {
            // No parameter means return the string unchanged
            return .string(inputString)
        }
        
        // Convert parameter to string - matching python-liquid behavior
        let substringToRemove: String
        switch parameters[0] {
        case .string(let str):
            // String parameters use their value directly
            substringToRemove = str
        case .bool(let value):
            // Boolean parameters convert to "true" or "false"
            substringToRemove = value ? "true" : "false"
        case .integer(let value):
            // Integer parameters convert to their string representation
            substringToRemove = "\(value)"
        case .decimal(let value):
            // Decimal parameters convert to their string representation
            substringToRemove = "\(value)"
        case .nil:
            // nil parameter means return input unchanged
            return .string(inputString)
        default:
            // Other types (arrays, dictionaries, ranges) use their stringValue
            substringToRemove = parameters[0].stringValue
        }
        
        // Perform the removal - all occurrences are removed
        return .string(inputString.replacingOccurrences(of: substringToRemove, with: ""))
    }
}