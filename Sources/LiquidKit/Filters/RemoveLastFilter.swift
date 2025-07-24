import Foundation

/// Implements the `remove_last` filter, which removes only the last occurrence of a substring from a string.
/// 
/// The `remove_last` filter searches for the last occurrence of a specified substring
/// in the input string and removes only that occurrence, leaving any earlier matches
/// intact. This is useful when you need precise control over string modification,
/// particularly when dealing with repeated patterns where you only want to affect the
/// final instance.
/// 
/// Following the behavior of liquidjs and python-liquid, this filter coerces both the input
/// and parameter values to strings before performing the removal operation. This means
/// integers, decimals, booleans, and other types are converted to their string representations
/// before processing.
/// 
/// - Example: Basic usage
/// ```liquid
/// {{ "I strained to see the train through the rain" | remove_last: "rain" }}
/// <!-- Output: I strained to see the train through the  -->
/// 
/// {{ "one, two, one, three, one" | remove_last: "one" }}
/// <!-- Output: one, two, one, three,  -->
/// ```
/// 
/// - Example: When substring appears only once
/// ```liquid
/// {{ "Hello world" | remove_last: "world" }}
/// <!-- Output: Hello  -->
/// 
/// {{ "http://example.com/path/" | remove_last: "/" }}
/// <!-- Output: http://example.com/path -->
/// ```
/// 
/// - Example: No match found
/// ```liquid
/// {{ "Hello, world!" | remove_last: "xyz" }}
/// <!-- Output: Hello, world! -->
/// ```
/// 
/// - Example: Type coercion
/// ```liquid
/// {{ 123123 | remove_last: "123" }}
/// <!-- Output: 123 -->
/// 
/// {{ "test123test" | remove_last: 123 }}
/// <!-- Output: testtest -->
/// ```
/// 
/// - Important: Only the LAST occurrence is removed. To remove all occurrences, use the
///   `remove` filter instead. To remove only the first occurrence, use the `remove_first` filter.
/// 
/// - Important: If the substring is not found in the input string, the original string is
///   returned unchanged. This makes the filter safe to use even when you're not certain
///   the substring exists.
/// 
/// - Note: `nil` values are returned as `nil` (which renders as empty string), and arrays are
///   converted to strings by joining their elements.
/// 
/// - SeeAlso: ``RemoveFilter`` - Removes all occurrences of a substring
/// - SeeAlso: ``RemoveFirstFilter`` - Removes only the first occurrence
/// - SeeAlso: ``ReplaceFilter`` - Replaces substrings with a different string
/// - SeeAlso: [LiquidJS remove_last](https://liquidjs.com/filters/remove_last.html)
/// - SeeAlso: [Python Liquid remove_last](https://liquid.readthedocs.io/en/latest/filter_reference/#remove_last)
/// - SeeAlso: [Shopify Liquid remove_last](https://shopify.github.io/liquid/filters/remove_last/)
@usableFromInline
package struct RemoveLastFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "remove_last"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        // Convert input to string - matching python-liquid and liquidjs behavior
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
        
        // Convert parameter to string - matching python-liquid and liquidjs behavior
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
        
        // If substring to remove is empty, return original string
        // This matches the behavior of liquidjs and python-liquid
        if substringToRemove.isEmpty {
            return .string(inputString)
        }
        
        // Find the last occurrence of the substring
        // We'll search from the end of the string backwards
        if let lastRange = inputString.range(of: substringToRemove, options: .backwards) {
            // Create a new string with the last occurrence removed
            var result = inputString
            result.replaceSubrange(lastRange, with: "")
            return .string(result)
        }
        
        // No occurrence found, return original string
        return .string(inputString)
    }
}