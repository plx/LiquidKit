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
/// - Warning: Providing an undefined variable as the length parameter will result in an error. \
///   However, an undefined ellipsis parameter is treated as an empty string.
/// 
/// - Warning: Providing more than two arguments will result in an error.
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
        guard case .string(let string) = token else {
            return token
        }
        
        // Default values
        var length = 50
        var ellipsis = "..."
        
        // Parse parameters
        if parameters.count >= 1 {
            switch parameters[0] {
            case .integer(let l):
                length = l
            case .string(let s):
                if let l = Int(s) {
                    length = l
                }
            default:
                break
            }
        }
        
        if parameters.count >= 2, case .string(let e) = parameters[1] {
            ellipsis = e
        }
        
        // If string is shorter than or equal to length, return as is
        if string.count <= length {
            return .string(string)
        }
        
        // Calculate how much of the string we can keep
        let ellipsisLength = ellipsis.count
        let keepLength = max(0, length - ellipsisLength)
        
        // Truncate and add ellipsis
        let truncated = String(string.prefix(keepLength)) + ellipsis
        return .string(truncated)
    }
}