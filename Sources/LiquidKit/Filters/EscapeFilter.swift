import Foundation
import HTMLEntities

/// Implements the `escape` filter, which converts HTML special characters to their entity equivalents.
/// 
/// The `escape` filter is essential for preventing XSS attacks and ensuring that user-generated content
/// is safely displayed in HTML contexts. It replaces characters that have special meaning in HTML
/// (such as `<`, `>`, `&`, `"`, and `'`) with their corresponding HTML entities. This filter always
/// escapes content, even if it has already been partially escaped.
/// 
/// The filter uses both named and decimal entity references where appropriate, providing maximum
/// compatibility across different HTML parsers and browsers.
/// 
/// ## Examples
/// 
/// Basic HTML escaping:
/// ```liquid
/// {{ "<p>Hello & welcome</p>" | escape }}
/// // Output: "&lt;p&gt;Hello &amp; welcome&lt;/p&gt;"
/// 
/// {{ 'Say "Hello"' | escape }}
/// // Output: "Say &quot;Hello&quot;"
/// 
/// {{ "Rock & Roll" | escape }}
/// // Output: "Rock &amp; Roll"
/// ```
/// 
/// With already escaped content (will escape again):
/// ```liquid
/// {{ "&lt;p&gt;Already escaped&lt;/p&gt;" | escape }}
/// // Output: "&amp;lt;p&amp;gt;Already escaped&amp;lt;/p&amp;gt;"
/// ```
/// 
/// With non-string values:
/// ```liquid
/// {{ 5 | escape }}
/// // Output: "5"
/// 
/// {{ true | escape }}
/// // Output: "true"
/// ```
/// 
/// With undefined or nil values:
/// ```liquid
/// {{ undefined_variable | escape }}
/// // Output: ""
/// 
/// {{ nil | escape }}
/// // Output: ""
/// ```
/// 
/// - Important: This filter will escape already-escaped content, potentially double-escaping it. If you need\
///   to escape content only once, use the `escape_once` filter instead.
/// 
/// - Important: The filter converts any input to its string representation before escaping, so numbers,\
///   booleans, and other non-string values are safely handled.
/// 
/// - Warning: The `escape` filter does not accept any parameters. Passing parameters will result in an error\
///   in strict Liquid implementations.
/// 
/// - SeeAlso: ``EscapeOnceFilter``
/// - SeeAlso: ``UrlEncodeFilter``
/// - SeeAlso: ``StripHtmlFilter``
/// - SeeAlso: [Liquid documentation](https://shopify.github.io/liquid/filters/escape/)
/// - SeeAlso: [LiquidJS documentation](https://liquidjs.com/filters/escape.html)
/// - SeeAlso: [Python Liquid documentation](https://liquid.readthedocs.io/en/latest/filter_reference/#escape)
@usableFromInline
package struct EscapeFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "escape"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        return .string(token.stringValue.htmlEscape(decimal: true, useNamedReferences: true))
    }
}