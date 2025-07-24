import Foundation

/// Implements the `remove_first` filter, which removes only the first occurrence of a substring from a string.
/// 
/// The `remove_first` filter searches for the first occurrence of a specified substring
/// in the input string and removes only that occurrence, leaving any subsequent matches
/// intact. This is useful when you need precise control over string modification,
/// particularly when dealing with repeated patterns where you only want to affect the
/// first instance.
/// 
/// Following python-liquid behavior, `remove_first` will coerce non-string inputs to strings
/// before processing. Numbers become their string representation, booleans become "true" or 
/// "false", and nil becomes an empty string. Complex types like arrays and dictionaries are
/// not coerced and are returned unchanged. The search is case-sensitive and starts from the
/// beginning of the string.
/// 
/// - Example: Basic usage
/// ```liquid
/// {{ "I strained to see the train through the rain" | remove_first: "rain" }}
/// <!-- Output: I sted to see the train through the rain -->
/// 
/// {{ "aaabbbccc" | remove_first: "b" }}
/// <!-- Output: aaabbccc -->
/// ```
/// 
/// - Example: When substring appears multiple times
/// ```liquid
/// {{ "one, two, one, three, one" | remove_first: "one" }}
/// <!-- Output: , two, one, three, one -->
/// 
/// {{ "http://http://example.com" | remove_first: "http://" }}
/// <!-- Output: http://example.com -->
/// ```
/// 
/// - Example: No match found
/// ```liquid
/// {{ "Hello, world!" | remove_first: "xyz" }}
/// <!-- Output: Hello, world! -->
/// ```
/// 
/// - Example: Non-string input coercion
/// ```liquid
/// {{ 123 | remove_first: "2" }}
/// <!-- Output: 13 -->
/// 
/// {{ true | remove_first: "ru" }}
/// <!-- Output: te -->
/// ```
/// 
/// - Important: Only the FIRST occurrence is removed. To remove all occurrences, use the
///   `remove` filter instead. The search always starts from the beginning of the string
///   and stops after finding and removing the first match.
/// 
/// - Important: If the substring is not found in the input string, the original string is
///   returned unchanged. This makes the filter safe to use even when you're not certain
///   the substring exists.
/// 
/// - SeeAlso: ``RemoveFilter`` - Removes all occurrences of a substring
/// - SeeAlso: ``ReplaceFirstFilter`` - Replaces only the first occurrence with a different string
/// - SeeAlso: [LiquidJS remove_first](https://liquidjs.com/filters/remove_first.html)
/// - SeeAlso: [Python Liquid remove_first](https://liquid.readthedocs.io/en/latest/filter_reference/#remove_first)
/// - SeeAlso: [Shopify Liquid remove_first](https://shopify.github.io/liquid/filters/remove_first/)
@usableFromInline
package struct RemoveFirstFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "remove_first"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        // Coerce input to string - matches python-liquid behavior
        // If input is not a string, convert it to a string representation
        let string: String
        switch token {
        case .string(let s):
            string = s
        case .nil:
            // nil converts to empty string in Liquid
            string = ""
        case .bool(let b):
            // Booleans convert to "true" or "false"
            string = b ? "true" : "false"
        case .integer(let i):
            // Integers convert to their string representation
            string = String(i)
        case .decimal(let d):
            // Decimals convert to their string representation
            string = String(describing: d)
        case .array, .dictionary, .range:
            // Complex types are not coerced - return original value
            return token
        }
        
        // Ensure we have at least one parameter
        guard parameters.count >= 1 else {
            return .string(string)
        }
        
        // Coerce the substring parameter to string as well
        let substring: String
        switch parameters[0] {
        case .string(let s):
            substring = s
        case .nil:
            // nil parameter means no substring to remove
            return .string(string)
        case .bool(let b):
            substring = b ? "true" : "false"
        case .integer(let i):
            substring = String(i)
        case .decimal(let d):
            substring = String(describing: d)
        case .array, .dictionary, .range:
            // Complex types cannot be used as substrings
            return .string(string)
        }
        
        // Find the first occurrence of substring and remove it
        if let range = string.range(of: substring) {
            var result = string
            result.replaceSubrange(range, with: "")
            return .string(result)
        }
        
        // If substring not found, return original string
        return .string(string)
    }
}