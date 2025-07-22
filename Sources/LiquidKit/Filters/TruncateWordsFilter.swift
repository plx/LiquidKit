import Foundation

/// Implements the `truncatewords` filter, which shortens a string to a specified number of words.
/// 
/// The `truncatewords` filter limits a string to a maximum number of words, appending an ellipsis or custom
/// suffix when truncation occurs. It accepts two optional parameters: the maximum word count (default 15) and
/// the ellipsis string (default "..."). Words are identified by splitting on whitespace characters, with
/// consecutive whitespace treated as a single separator.
/// 
/// The filter handles various forms of whitespace including spaces, tabs, and newlines as word separators.
/// Multiple consecutive whitespace characters are treated as a single separator, and leading/trailing whitespace
/// is effectively ignored. When the input contains fewer words than the specified limit, it is returned unchanged
/// without adding the ellipsis. For non-string values, the filter returns the value unchanged.
/// 
/// Special handling is applied for edge cases: a word count of 0 still returns the first word followed by the
/// ellipsis, and non-Latin text without spaces (like Chinese or Japanese) is treated as a single word.
/// 
/// ## Examples
/// 
/// Basic word truncation:
/// ```liquid
/// {{ "Ground control to Major Tom." | truncatewords: 3 }}
/// // Output: "Ground control to..."
/// 
/// {{ "Ground control to Major Tom." | truncatewords }}
/// // Output: "Ground control to Major Tom."
/// 
/// {{ "Ground control" | truncatewords: 3 }}
/// // Output: "Ground control"
/// ```
/// 
/// Custom ellipsis and whitespace handling:
/// ```liquid
/// {{ "Ground control to Major Tom." | truncatewords: 3, "--" }}
/// // Output: "Ground control to--"
/// 
/// {{ "Ground control to Major Tom." | truncatewords: 3, "" }}
/// // Output: "Ground control to"
/// 
/// {{ "    one    two three    four  " | truncatewords: 2 }}
/// // Output: "one two..."
/// 
/// {{ "one  two\tthree\nfour" | truncatewords: 3 }}
/// // Output: "one two three..."
/// ```
/// 
/// Edge cases:
/// ```liquid
/// {{ "one two three four" | truncatewords: 0 }}
/// // Output: "one..."
/// 
/// {{ 5 | truncatewords: 10 }}
/// // Output: "5"
/// 
/// {{ "测试测试测试测试" | truncatewords: 5 }}
/// // Output: "测试测试测试测试"
/// ```
/// 
/// - Important: The filter splits on any whitespace character (spaces, tabs, newlines), not just spaces. \
///   Multiple consecutive whitespace characters are treated as a single word separator.
/// 
/// - Important: A word count of 0 is treated specially - it returns the first word followed by the ellipsis, \
///   not an empty string. This maintains consistency with the reference implementation.
/// 
/// - Important: Text without whitespace (common in Chinese, Japanese, etc.) is treated as a single word \
///   and will not be truncated regardless of the word count parameter.
/// 
/// - Warning: Providing an undefined variable as the word count parameter will result in an error. \
///   However, an undefined ellipsis parameter is treated as an empty string.
/// 
/// - Warning: Providing more than two arguments will result in an error.
/// 
/// - SeeAlso: ``TruncateFilter`` - Truncates to a number of characters instead of words
/// - SeeAlso: ``SplitFilter`` - Splits a string into an array of words
/// - SeeAlso: [LiquidJS Documentation](https://liquidjs.com/filters/truncatewords.html)
/// - SeeAlso: [Python Liquid Documentation](https://liquid.readthedocs.io/en/latest/filters/truncatewords/)
/// - SeeAlso: [Shopify Liquid Documentation](https://shopify.github.io/liquid/filters/truncatewords/)
@usableFromInline
package struct TruncateWordsFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "truncatewords"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard case .string(let string) = token else {
            return token
        }
        
        // Default values
        var wordCount = 15
        var ellipsis = "..."
        
        // Parse parameters
        if parameters.count >= 1 {
            switch parameters[0] {
            case .integer(let w):
                wordCount = w
            case .string(let s):
                if let w = Int(s) {
                    wordCount = w
                }
            default:
                break
            }
        }
        
        if parameters.count >= 2, case .string(let e) = parameters[1] {
            ellipsis = e
        }
        
        // Split string into words
        let words = string.split(separator: " ", omittingEmptySubsequences: true)
        
        // If we have fewer words than requested, return as is
        if words.count <= wordCount {
            return .string(string)
        }
        
        // Take first n words and join with ellipsis
        let truncated = words.prefix(wordCount).joined(separator: " ") + ellipsis
        return .string(truncated)
    }
}