import Foundation

/// Implements the `remove_first` filter, which removes only the first occurrence of a substring from a string.
/// 
/// The `remove_first` filter searches for the first occurrence of a specified substring
/// in the input string and removes only that occurrence, leaving any subsequent matches
/// intact. This is useful when you need precise control over string modification,
/// particularly when dealing with repeated patterns where you only want to affect the
/// first instance.
/// 
/// Like other string filters, `remove_first` only operates on string inputs. If the input
/// is not a string, or if the substring parameter is missing or not a string, the original
/// value is returned unchanged. The search is case-sensitive and starts from the beginning
/// of the string.
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
        guard case .string(let string) = token else {
            return token
        }
        
        guard parameters.count >= 1,
              case .string(let substring) = parameters[0] else {
            return token
        }
        
        // Find first occurrence and replace only that
        if let range = string.range(of: substring) {
            var result = string
            result.replaceSubrange(range, with: "")
            return .string(result)
        }
        
        return token
    }
}