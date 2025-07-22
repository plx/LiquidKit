import Foundation

/// Implements the `newline_to_br` filter, which replaces newline characters with HTML line break tags.
/// 
/// The `newline_to_br` filter converts line breaks in text into HTML `<br />` tags,
/// making multi-line text display correctly in HTML output. This is particularly useful
/// when displaying user-generated content or any text that contains line breaks that
/// should be preserved in the rendered HTML. The filter handles all common newline
/// formats: Unix (`\n`), Windows (`\r\n`), and classic Mac (`\r`).
/// 
/// Unlike some other implementations, this filter preserves the original newline
/// characters after inserting the `<br />` tags. This approach maintains the source
/// formatting, which can be beneficial for viewing HTML source or when the output might
/// be processed further. The filter only operates on string values; non-string inputs
/// are returned unchanged.
/// 
/// ## Examples
/// 
/// Basic newline conversion:
/// ```liquid
/// {{ "First line\nSecond line" | newline_to_br }}
/// // Output: "First line<br />\nSecond line"
/// ```
/// 
/// Multi-line text formatting:
/// ```liquid
/// {{ "- apples\n- oranges\n" | newline_to_br }}
/// // Output: "- apples<br />\n- oranges<br />\n"
/// ```
/// 
/// Windows-style line endings:
/// ```liquid
/// {{ "Line 1\r\nLine 2" | newline_to_br }}
/// // Output: "Line 1<br />\nLine 2"
/// ```
/// 
/// Non-string input:
/// ```liquid
/// {{ 5 | newline_to_br }}
/// // Output: 5
/// ```
/// 
/// Empty or nil values:
/// ```liquid
/// {{ nosuchthing | newline_to_br }}
/// // Output: "" (empty string)
/// ```
/// 
/// - Important: The filter preserves the original newline characters after inserting
///   `<br />` tags. This differs from some implementations that replace newlines entirely.
/// 
/// - Important: The filter processes line endings in order: `\r\n` first, then `\n`,
///   then `\r`. This ensures Windows-style line endings are handled as single breaks.
/// 
/// - SeeAlso: ``StripNewlinesFilter``, ``StripFilter``, ``EscapeFilter``
/// - SeeAlso: [LiquidJS Documentation](https://liquidjs.com/filters/newline_to_br.html)
/// - SeeAlso: [Python Liquid Documentation](https://liquid.readthedocs.io/en/latest/filter_reference/#newline_to_br)
/// - SeeAlso: [Shopify Liquid Documentation](https://shopify.github.io/liquid/filters/newline_to_br/)
@usableFromInline
package struct NewlineToBrFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "newline_to_br"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard case .string(let string) = token else {
            return token
        }
        
        // Replace all newline characters with <br />
        let result = string
            .replacingOccurrences(of: "\r\n", with: "<br />")
            .replacingOccurrences(of: "\n", with: "<br />")
            .replacingOccurrences(of: "\r", with: "<br />")
        
        return .string(result)
    }
}