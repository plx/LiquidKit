import Foundation

/// Implements the `remove` filter, which removes all occurrences of a substring from a string.
/// 
/// The `remove` filter performs a global search-and-replace operation, removing every
/// occurrence of the specified substring from the input string. This is equivalent to
/// using the `replace` filter with an empty replacement string. The filter is
/// case-sensitive and removes all matches, not just the first one.
/// 
/// The filter only operates on string inputs. Non-string values are returned unchanged,
/// and if the substring parameter is missing or not a string, the original input is
/// returned without modification.
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
/// - Important: The filter removes ALL occurrences of the substring, not just the first one.
///   Use `remove_first` if you only want to remove the first occurrence.
/// 
/// - Important: The removal is performed as a simple string replacement. It does not support
///   regular expressions or pattern matching. For more complex removals, consider using
///   multiple filters in combination.
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
        guard case .string(let string) = token else {
            return token
        }
        
        guard parameters.count >= 1,
              case .string(let substring) = parameters[0] else {
            return token
        }
        
        return .string(string.replacingOccurrences(of: substring, with: ""))
    }
}