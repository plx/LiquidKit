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
/// This implementation matches the behavior of liquidjs and python-liquid by using a comprehensive regex pattern
/// that removes script tags and their content, style tags and their content, HTML comments, and all other HTML tags.
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
/// - Important: HTML comments (`<!-- comment -->`) are completely removed, including multiline comments.
/// 
/// - Important: The filter removes all content within `<script>` and `<style>` tags, \
///   not just the tags themselves. This includes multiline JavaScript and CSS content.
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
        // Return non-string values unchanged
        guard case .string(let string) = token else {
            return token
        }
        
        // Use comprehensive HTML stripping approach matching liquidjs and python-liquid behavior
        // Apply multiple regex patterns in sequence for better handling of edge cases
        var result = string
        
        do {
            // 1. Remove script tags and their content (including multiline)
            let scriptRegex = try NSRegularExpression(
                pattern: "<script.*?</script>", 
                options: [.caseInsensitive, .dotMatchesLineSeparators]
            )
            var range = NSRange(location: 0, length: result.utf16.count)
            result = scriptRegex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: "")
            
            // 2. Remove style tags and their content (including multiline)
            let styleRegex = try NSRegularExpression(
                pattern: "<style.*?</style>", 
                options: [.caseInsensitive, .dotMatchesLineSeparators]
            )
            range = NSRange(location: 0, length: result.utf16.count)
            result = styleRegex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: "")
            
            // 3. Remove HTML comments (including multiline)
            let commentRegex = try NSRegularExpression(
                pattern: "<!--.*?-->", 
                options: [.dotMatchesLineSeparators]
            )
            range = NSRange(location: 0, length: result.utf16.count)
            result = commentRegex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: "")
            
            // 4. Remove all remaining HTML tags (including malformed ones)
            // This pattern is more robust for handling quotes and special characters
            let tagRegex = try NSRegularExpression(
                pattern: "<[^>]*>", 
                options: []
            )
            range = NSRange(location: 0, length: result.utf16.count)
            result = tagRegex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: "")
            
            return .string(result)
        } catch {
            // If regex fails, fall back to the simple pattern (shouldn't happen with static patterns)
            let simpleResult = string.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            return .string(simpleResult)
        }
    }
}