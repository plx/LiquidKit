import Foundation

/// Implements the `replace` filter, which replaces all occurrences of a substring with another string.
/// 
/// The `replace` filter performs a global search-and-replace operation on string inputs,
/// replacing every occurrence of the search string with the replacement string. This is
/// one of the most commonly used string manipulation filters in Liquid templates, useful
/// for text transformation, URL manipulation, and data cleaning tasks.
/// 
/// The filter requires two parameters: the string to search for and the string to replace
/// it with. Both the search and replacement can be empty strings, allowing for insertion
/// or removal operations. The search is case-sensitive and does not support regular
/// expressions - it performs literal string matching only.
/// 
/// - Example: Basic replacement
/// ```liquid
/// {{ "Take my protein pills and put my helmet on" | replace: "my", "your" }}
/// <!-- Output: Take your protein pills and put your helmet on -->
/// 
/// {{ "Hello world" | replace: "world", "Liquid" }}
/// <!-- Output: Hello Liquid -->
/// ```
/// 
/// - Example: Multiple occurrences
/// ```liquid
/// {{ "red, red, red" | replace: "red", "blue" }}
/// <!-- Output: blue, blue, blue -->
/// 
/// {{ "1.1.1.1" | replace: ".", "-" }}
/// <!-- Output: 1-1-1-1 -->
/// ```
/// 
/// - Example: Empty string replacement
/// ```liquid
/// {{ "Hello world" | replace: " ", "" }}
/// <!-- Output: Helloworld -->
/// 
/// {{ "test" | replace: "", "X" }}
/// <!-- Output: test (empty search string matches nothing) -->
/// ```
/// 
/// - Important: The filter replaces ALL occurrences of the search string, not just the first
///   one. Use `replace_first` if you only need to replace the first occurrence.
/// 
/// - Important: The filter only operates on string inputs. Non-string values are returned
///   unchanged. Both parameters must be present and must be strings, otherwise the original
///   input is returned without modification.
/// 
/// - Warning: Be careful when replacing common substrings as they will be replaced everywhere
///   they appear, including within larger words. For example, replacing "cat" in "category"
///   would result in "egory".
/// 
/// - SeeAlso: ``ReplaceFirstFilter`` - Replaces only the first occurrence
/// - SeeAlso: ``RemoveFilter`` - Removes substrings (equivalent to replacing with empty string)
/// - SeeAlso: [LiquidJS replace](https://liquidjs.com/filters/replace.html)
/// - SeeAlso: [Python Liquid replace](https://liquid.readthedocs.io/en/latest/filter_reference/#replace)
/// - SeeAlso: [Shopify Liquid replace](https://shopify.github.io/liquid/filters/replace/)
@usableFromInline
package struct ReplaceFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "replace"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard case .string(let string) = token else {
            return token
        }
        
        guard parameters.count >= 2,
              case .string(let search) = parameters[0],
              case .string(let replacement) = parameters[1] else {
            return token
        }
        
        return .string(string.replacingOccurrences(of: search, with: replacement))
    }
}