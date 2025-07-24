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
/// - Note: When the word count parameter is undefined or non-numeric, the default value of 15 is used. \
///   When the ellipsis parameter is undefined (nil), it is treated as an empty string.
/// 
/// - Note: Extra parameters beyond the first two are ignored.
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
        // Return non-string values unchanged
        guard case .string(let string) = token else {
            return token
        }
        
        // Default values - matches liquidjs and python-liquid behavior
        var wordCount = 15
        var ellipsis = "..."
        
        // Parse first parameter (word count)
        if parameters.count >= 1 {
            switch parameters[0] {
            case .integer(let w):
                // Use integer value directly
                wordCount = w
            case .decimal(let d):
                // Convert decimal to integer (truncate)
                wordCount = NSDecimalNumber(decimal: d).intValue
            case .string(let s):
                // Try to parse string as integer
                if let w = Int(s) {
                    wordCount = w
                }
                // If string is not numeric, keep default value of 15
            default:
                // For any other type (nil, bool, array, dict), keep default value of 15
                break
            }
        }
        
        // Parse second parameter (ellipsis string)
        if parameters.count >= 2 {
            switch parameters[1] {
            case .string(let e):
                // Use provided string as ellipsis
                ellipsis = e
            case .nil:
                // Treat nil/undefined as empty string (matches liquidjs/python-liquid)
                ellipsis = ""
            case .integer(let i):
                // Convert integer to string representation
                ellipsis = String(i)
            case .decimal(let d):
                // Convert decimal to string representation  
                ellipsis = String(describing: d)
            case .bool(let b):
                // Convert boolean to string representation
                ellipsis = String(b)
            default:
                // For arrays/dictionaries, use default ellipsis
                break
            }
        }
        
        // Split string into words using any whitespace as separator
        // This handles spaces, tabs, newlines, and multiple consecutive whitespace
        let words = string.split(whereSeparator: \.isWhitespace)
        
        // Special case: word count of 0 or negative returns first word + ellipsis
        // This matches the reference implementation behavior
        if wordCount <= 0 {
            if words.isEmpty {
                return .string(string)
            }
            return .string(String(words[0]) + ellipsis)
        }
        
        // If we have fewer or equal words than requested, return original string unchanged
        if words.count <= wordCount {
            return .string(string)
        }
        
        // Take first n words, join with single spaces, and append ellipsis
        let truncated = words.prefix(wordCount).joined(separator: " ") + ellipsis
        return .string(truncated)
    }
}