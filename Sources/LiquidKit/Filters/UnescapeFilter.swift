import Foundation
import HTMLEntities

/// Implements the `unescape` filter, which converts HTML entities back to their original characters.
/// 
/// The `unescape` filter reverses the HTML entity encoding process, converting entity references
/// (like `&lt;`, `&gt;`, `&amp;`, `&quot;`, and `&#39;`) back to their corresponding characters
/// (`<`, `>`, `&`, `"`, and `'`). This filter supports both named entities (e.g., `&amp;`) and
/// numeric character references (e.g., `&#60;` or `&#x3C;`).
/// 
/// This implementation provides an unescape filter similar to those found in some Liquid variants
/// like Treepl's implementation. While this filter is not part of the official Shopify Liquid
/// standard filter set, it's a useful addition for handling HTML-encoded content.
/// 
/// ## Examples
/// 
/// Basic HTML entity unescaping:
/// ```liquid
/// {{ "&lt;p&gt;Hello &amp; welcome&lt;/p&gt;" | unescape }}
/// // Output: "<p>Hello & welcome</p>"
/// 
/// {{ "Say &quot;Hello&quot;" | unescape }}
/// // Output: 'Say "Hello"'
/// 
/// {{ "It&#39;s amazing" | unescape }}
/// // Output: "It's amazing"
/// ```
/// 
/// With numeric character references:
/// ```liquid
/// {{ "&#60;tag&#62;" | unescape }}
/// // Output: "<tag>"
/// 
/// {{ "&#x3C;hex&#x3E;" | unescape }}
/// // Output: "<hex>"
/// ```
/// 
/// With common named entities:
/// ```liquid
/// {{ "Copyright &copy; 2024" | unescape }}
/// // Output: "Copyright © 2024"
/// 
/// {{ "Text&mdash;more text" | unescape }}
/// // Output: "Text—more text"
/// ```
/// 
/// With non-string values:
/// ```liquid
/// {{ 42 | unescape }}
/// // Output: "42"
/// 
/// {{ true | unescape }}
/// // Output: "true"
/// ```
/// 
/// - Important: This filter processes entities only once and is not recursive. Double-escaped
///   content like `&amp;lt;` will become `&lt;`, not `<`.
/// 
/// - Important: The filter uses the HTMLEntities library to handle entity decoding, which supports
///   the full range of HTML5 named entities and numeric character references. The library can
///   decode entities even without trailing semicolons (e.g., `&amp` becomes `&`) and converts
///   invalid numeric references to the Unicode replacement character (�).
/// 
/// - Note: The `unescape` filter ignores any parameters passed to it, following the pattern of
///   other string transformation filters.
/// 
/// - SeeAlso: ``EscapeFilter``
/// - SeeAlso: ``EscapeOnceFilter``
/// - SeeAlso: ``UrlDecodeFilter``
@usableFromInline
package struct UnescapeFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "unescape"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        // Get the string representation of the token value
        // Handle special cases where stringValue returns empty string
        let stringValue: String
        switch token {
        case .bool(let value):
            // Convert booleans to "true" or "false" strings to match other filter behaviors
            stringValue = value ? "true" : "false"
        case .dictionary:
            // For dictionaries, use the default stringValue which returns empty string
            // This matches the behavior of other Liquid implementations for complex types
            stringValue = token.stringValue
        default:
            // For all other types, use the built-in stringValue conversion
            stringValue = token.stringValue
        }
        
        // Return early for empty strings to avoid unnecessary processing
        guard !stringValue.isEmpty else {
            return .string("")
        }
        
        // Use the HTMLEntities library to decode all HTML entities in the string
        // This handles both named entities (like &amp;) and numeric references (like &#60; or &#x3C;)
        // The decode method processes the entire string and replaces all valid HTML entities
        // with their corresponding characters
        let unescaped = stringValue.htmlUnescape()
        
        return .string(unescaped)
    }
}