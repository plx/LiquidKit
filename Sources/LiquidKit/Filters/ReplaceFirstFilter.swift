import Foundation

/// Implements the `replace_first` filter, which replaces only the first occurrence of a substring.
/// 
/// The `replace_first` filter searches for a substring within the input string and replaces only
/// the first occurrence with a replacement string. This filter is useful when you want to modify
/// only the initial instance of a pattern while leaving any subsequent occurrences unchanged.
/// Unlike the `replace` filter which replaces all occurrences, `replace_first` provides precise
/// control over string modifications.
///
/// The filter requires two parameters: the search string and the replacement string. If either
/// parameter is missing, the filter behaves differently - with only one parameter, it treats
/// the missing second parameter as an empty string, effectively removing the first occurrence.
/// The filter performs case-sensitive literal string matching, not regular expression matching.
///
/// ## Examples
///
/// Basic usage replacing the first occurrence:
/// ```liquid
/// {{ "Take my protein pills and put my helmet on" | replace_first: "my", "your" }}
/// <!-- Output: "Take your protein pills and put my helmet on" -->
/// ```
///
/// When the search string doesn't exist:
/// ```liquid
/// {{ "Hello world" | replace_first: "foo", "bar" }}
/// <!-- Output: "Hello world" -->
/// ```
///
/// With only one parameter (removes first occurrence):
/// ```liquid
/// {{ "hello" | replace_first: "ll" }}
/// <!-- Output: "heo" -->
/// ```
///
/// Non-string input values are returned unchanged:
/// ```liquid
/// {{ 5 | replace_first: "rain", "foo" }}
/// <!-- Output: "5" -->
/// ```
///
/// - Important: When the input value is nil or undefined, the filter returns an empty string.
///   When parameters are nil/undefined, they are treated as empty strings. For example,
///   replacing with an undefined variable effectively removes the first occurrence of the
///   search string.
///
/// - Warning: The current implementation accepts non-string arguments and attempts to convert
///   them to strings, which may not match the strict Liquid specification. Some Liquid
///   implementations throw errors for invalid argument types.
///
/// - SeeAlso: ``ReplaceFilter``, ``ReplaceLastFilter``
/// - SeeAlso: [LiquidJS Documentation](https://liquidjs.com/filters/replace_first.html)
/// - SeeAlso: [Python Liquid Documentation](https://liquid.readthedocs.io/en/latest/filter_reference/#replace_first)
/// - SeeAlso: [Shopify Liquid Documentation](https://shopify.github.io/liquid/filters/replace_first/)
@usableFromInline
package struct ReplaceFirstFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "replace_first"
    
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
        
        // Find first occurrence and replace only that
        if let range = string.range(of: search) {
            var result = string
            result.replaceSubrange(range, with: replacement)
            return .string(result)
        }
        
        return token
    }
}