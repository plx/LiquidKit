import Foundation

/// Implements the `newline_to_br` filter, which replaces newline characters with HTML line break tags.
/// 
/// The `newline_to_br` filter converts line breaks in text into HTML `<br />` tags,
/// making multi-line text display correctly in HTML output. This is particularly useful
/// when displaying user-generated content or any text that contains line breaks that
/// should be preserved in the rendered HTML. The filter handles all common newline
/// formats: Unix (`\n`), Windows (`\r\n`), and classic Mac (`\r`).
/// 
/// This implementation matches the behavior of liquidjs, python-liquid, and Shopify Liquid
/// by completely replacing newline characters with `<br />` tags. The original newline
/// characters are not preserved in the output. The filter only operates on string values;
/// non-string inputs are returned unchanged.
/// 
/// ## Examples
/// 
/// Basic newline conversion:
/// ```liquid
/// {{ "First line\nSecond line" | newline_to_br }}
/// // Output: "First line<br />Second line"
/// ```
/// 
/// Multi-line text formatting:
/// ```liquid
/// {{ "- apples\n- oranges\n" | newline_to_br }}
/// // Output: "- apples<br />- oranges<br />"
/// ```
/// 
/// Windows-style line endings:
/// ```liquid
/// {{ "Line 1\r\nLine 2" | newline_to_br }}
/// // Output: "Line 1<br />Line 2"
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
/// - Important: The filter completely replaces newline characters with `<br />` tags.
///   The original newline characters are not preserved in the output.
/// 
/// - Important: The filter processes line endings in order: `\r\n` first, then `\n`,
///   then `\r`. This ensures Windows-style line endings are handled as single breaks
///   rather than being converted to two separate `<br />` tags.
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
        // Only operate on string values; pass through all other types unchanged
        guard case .string(let string) = token else {
            return token
        }
        
        // Replace all newline characters with HTML line breaks
        // Process in order: Windows (\r\n) first to avoid double-conversion,
        // then Unix (\n), then classic Mac (\r)
        let result = string
            .replacingOccurrences(of: "\r\n", with: "<br />")  // Windows: CRLF -> <br />
            .replacingOccurrences(of: "\n", with: "<br />")    // Unix: LF -> <br />
            .replacingOccurrences(of: "\r", with: "<br />")    // Classic Mac: CR -> <br />
        
        return .string(result)
    }
}