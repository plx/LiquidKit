import Foundation

/// Implements the `strip_newlines` filter, which removes all newline characters from a string.
/// 
/// The `strip_newlines` filter removes all types of newline characters from a string, including Unix line feeds (`\n`),
/// Windows carriage return/line feed pairs (`\r\n`), and old Mac carriage returns (`\r`). This filter is useful for
/// normalizing text that needs to be displayed on a single line or when preparing text for contexts where newlines
/// would cause formatting issues.
/// 
/// The filter only removes newline characters - other whitespace characters like spaces and tabs are preserved.
/// When applied to non-string values, the filter returns the value unchanged. Empty strings and nil values
/// pass through without modification.
/// 
/// ## Examples
/// 
/// Basic newline removal:
/// ```liquid
/// {{ "Line one
/// Line two" | strip_newlines }}
/// // Output: "Line oneLine two"
/// 
/// {{ "a\nb\nc" | strip_newlines }}
/// // Output: "abc"
/// ```
/// 
/// Different newline types:
/// ```liquid
/// {{ "Windows\r\nUnix\nMac\r" | strip_newlines }}
/// // Output: "WindowsUnixMac"
/// 
/// {{ "hello there\nyou" | strip_newlines }}
/// // Output: "hello thereyou"
/// ```
/// 
/// Non-string values:
/// ```liquid
/// {{ 5 | strip_newlines }}
/// // Output: "5"
/// 
/// {{ nil | strip_newlines }}
/// // Output: ""
/// ```
/// 
/// - Important: Only newline characters are removed. Spaces, tabs, and other whitespace \
///   characters are preserved. If you need to normalize all whitespace, consider using \
///   multiple filters in combination.
/// 
/// - Important: The filter removes newlines but does not add spaces in their place. \
///   This can result in words being concatenated if they were only separated by newlines.
/// 
/// - Warning: The filter expects no arguments. Passing any arguments will result in an error.
/// 
/// - SeeAlso: ``StripFilter`` - Removes all occurrences of a substring
/// - SeeAlso: ``StripHtmlFilter`` - Removes HTML tags from a string
/// - SeeAlso: ``NewlineToBrFilter`` - Converts newlines to HTML `<br>` tags
/// - SeeAlso: [LiquidJS Documentation](https://liquidjs.com/filters/strip_newlines.html)
/// - SeeAlso: [Python Liquid Documentation](https://liquid.readthedocs.io/en/latest/filters/strip_newlines/)
/// - SeeAlso: [Shopify Liquid Documentation](https://shopify.github.io/liquid/filters/strip_newlines/)
@usableFromInline
package struct StripNewlinesFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "strip_newlines"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard case .string(let string) = token else {
            return token
        }
        
        // Remove all newline characters (both \n and \r\n)
        let result = string
            .replacingOccurrences(of: "\r\n", with: "")
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\r", with: "")
        
        return .string(result)
    }
}