import Foundation

/// Implements the `truncate` filter, which shortens a string to a specified number of characters.
/// 
/// The `truncate` filter limits a string to a maximum number of characters, appending an ellipsis or custom
/// suffix when truncation occurs. It accepts two optional parameters: the maximum length (default 50) and
/// the ellipsis string (default "..."). The length includes the ellipsis, so the actual text is shortened
/// to accommodate both the content and the suffix within the specified limit.
/// 
/// When the input string is shorter than or equal to the specified length, it is returned unchanged without
/// adding the ellipsis. For non-string values, the filter returns the value unchanged. The filter intelligently
/// handles edge cases where the ellipsis is longer than the allowed length by ensuring non-negative character counts.
/// 
/// ## Examples
/// 
/// Basic truncation:
/// ```liquid
/// {{ "Ground control to Major Tom." | truncate: 20 }}
/// // Output: "Ground control to..."
/// 
/// {{ "Ground control to Major Tom. Ground control to Major Tom." | truncate }}
/// // Output: "Ground control to Major Tom. Ground control to ..."
/// 
/// {{ "Short text" | truncate: 20 }}
/// // Output: "Short text"
/// ```
/// 
/// Custom ellipsis:
/// ```liquid
/// {{ "Ground control to Major Tom." | truncate: 25, ", and so on" }}
/// // Output: "Ground control, and so on"
/// 
/// {{ "Ground control to Major Tom." | truncate: 20, "" }}
/// // Output: "Ground control to Ma"
/// ```
/// 
/// Edge cases:
/// ```liquid
/// {{ 5 | truncate: 10 }}
/// // Output: "5"
/// 
/// {{ nil | truncate: 5 }}
/// // Output: ""
/// ```
/// 
/// - Important: The length parameter includes the ellipsis string. For example, with a length \
///   of 20 and the default "..." ellipsis, only 17 characters of the original text are preserved.
/// 
/// - Important: When the ellipsis string is longer than the specified length, the filter will \
///   truncate to zero characters and append only the ellipsis, ensuring the result doesn't exceed \
///   the specified length.
/// 
/// - Note: When an undefined variable is used as the length parameter, the filter uses the default \
///   length of 50. When an undefined variable is used as the ellipsis parameter, it is treated as \
///   an empty string. This behavior matches liquidjs and python-liquid implementations.
/// 
/// - SeeAlso: ``TruncateWordsFilter`` - Truncates to a number of words instead of characters
/// - SeeAlso: ``SliceFilter`` - Extracts a substring from a string
/// - SeeAlso: [LiquidJS Documentation](https://liquidjs.com/filters/truncate.html)
/// - SeeAlso: [Python Liquid Documentation](https://liquid.readthedocs.io/en/latest/filters/truncate/)
/// - SeeAlso: [Shopify Liquid Documentation](https://shopify.github.io/liquid/filters/truncate/)
@usableFromInline
package struct TruncateFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "truncate"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        // Only process string values - non-strings are returned unchanged
        guard case .string(let string) = token else {
            return token
        }
        
        // Initialize with default values per Liquid specification
        var length = 50  // Default maximum length if not specified
        var ellipsis = "..."  // Default ellipsis string
        
        // Parse the first parameter (length)
        if parameters.count >= 1 {
            switch parameters[0] {
            case .integer(let l):
                // Direct integer value for length
                length = l
            case .string(let s):
                // Try to parse string as integer
                if let l = Int(s) {
                    length = l
                }
                // If parsing fails, keep default length
            default:
                // Other types (nil, decimal, etc.) use default length
                break
            }
        }
        
        // Parse the second parameter (ellipsis)
        if parameters.count >= 2 {
            switch parameters[1] {
            case .string(let e):
                // Use provided string as ellipsis
                ellipsis = e
            case .nil:
                // Special case: undefined variables (nil) are treated as empty strings
                // This matches liquidjs and python-liquid behavior
                ellipsis = ""
            default:
                // Other types (integer, decimal, etc.) keep default ellipsis
                break
            }
        }
        
        // If the string is already shorter than or equal to the target length,
        // return it unchanged without adding ellipsis
        if string.count <= length {
            return .string(string)
        }
        
        // Calculate how many characters to keep from the original string
        // The ellipsis counts toward the total length limit
        let ellipsisLength = ellipsis.count
        let keepLength = max(0, length - ellipsisLength)
        
        // Truncate the string and append the ellipsis
        let truncated = String(string.prefix(keepLength)) + ellipsis
        return .string(truncated)
    }
}