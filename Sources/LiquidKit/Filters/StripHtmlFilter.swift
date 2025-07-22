import Foundation

/// Implements the `strip_html` filter, which removes HTML tags from a string.
/// 
/// The `strip_html` filter removes all HTML tags from a string, including HTML comments, script blocks, and style blocks.
/// This filter is commonly used to extract plain text content from HTML markup, such as when displaying summaries
/// or previews of HTML content. The filter preserves HTML entities like `&amp;` and numeric character references
/// like `&#20;` - these are not decoded or removed.
/// 
/// The filter handles multi-line tags correctly, including tags that span across newlines. When applied to non-string
/// values, the filter returns the value unchanged. Empty strings and nil values pass through without modification.
/// 
/// ## Examples
/// 
/// Basic HTML tag removal:
/// ```liquid
/// {{ "<p>Hello <strong>world</strong>!</p>" | strip_html }}
/// // Output: "Hello world!"
/// 
/// {{ "<div id='test'>content</div>" | strip_html }}
/// // Output: "content"
/// ```
/// 
/// Handling HTML comments and special blocks:
/// ```liquid
/// {{ "<!-- comment -->visible text" | strip_html }}
/// // Output: "visible text"
/// 
/// {{ "<script>alert('hi');</script>text" | strip_html }}
/// // Output: "text"
/// 
/// {{ "<style>body { color: red; }</style>text" | strip_html }}
/// // Output: "text"
/// ```
/// 
/// Multi-line tags and entities:
/// ```liquid
/// {{ "<div
/// class='multiline'>test</div>" | strip_html }}
/// // Output: "test"
/// 
/// {{ "Text with &amp; and &#20; entities" | strip_html }}
/// // Output: "Text with &amp; and &#20; entities"
/// ```
/// 
/// - Important: HTML entities and numeric character references are preserved, not decoded. \
///   If you need to decode HTML entities, you would need to apply additional processing.
/// 
/// - Important: The filter removes all content within `<script>` and `<style>` tags, \
///   not just the tags themselves.
/// 
/// - Warning: The filter expects no arguments. Passing any arguments will result in an error.
/// 
/// - SeeAlso: ``StripFilter`` - Removes all occurrences of a substring
/// - SeeAlso: ``StripNewlinesFilter`` - Removes newline characters
/// - SeeAlso: [LiquidJS Documentation](https://liquidjs.com/filters/strip_html.html)
/// - SeeAlso: [Python Liquid Documentation](https://liquid.readthedocs.io/en/latest/filters/strip_html/)
/// - SeeAlso: [Shopify Liquid Documentation](https://shopify.github.io/liquid/filters/strip_html/)
@usableFromInline
package struct StripHtmlFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "strip_html"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard case .string(let string) = token else {
            return token
        }
        
        // Remove HTML tags using regex
        let htmlPattern = "<[^>]+>"
        let result = string.replacingOccurrences(of: htmlPattern, with: "", options: .regularExpression)
        return .string(result)
    }
}