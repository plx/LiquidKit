import Foundation
import HTMLEntities

/// Implements the `escape_once` filter, which escapes HTML special characters while preserving already-escaped entities.
/// 
/// The `escape_once` filter provides intelligent HTML escaping that prevents double-escaping of content.
/// It first unescapes any existing HTML entities, then re-escapes all content uniformly. This ensures
/// that mixed content containing both raw HTML and already-escaped entities is processed correctly,
/// with each special character escaped exactly once.
/// 
/// This filter is particularly useful when working with content that may have been partially escaped
/// by other processes, or when you need to ensure consistent escaping regardless of the input's
/// current escape state.
/// 
/// ## Examples
/// 
/// With already-escaped content:
/// ```liquid
/// {{ "&lt;p&gt;test&lt;/p&gt;" | escape_once }}
/// // Output: "&lt;p&gt;test&lt;/p&gt;"
/// ```
/// 
/// With mixed escaped and unescaped content:
/// ```liquid
/// {{ "&lt;p&gt;test&lt;/p&gt;<p>test</p>" | escape_once }}
/// // Output: "&lt;p&gt;test&lt;/p&gt;&lt;p&gt;test&lt;/p&gt;"
/// 
/// {{ "Rock &amp; Roll & Jazz" | escape_once }}
/// // Output: "Rock &amp; Roll &amp; Jazz"
/// ```
/// 
/// With raw HTML:
/// ```liquid
/// {{ "<script>alert('XSS')</script>" | escape_once }}
/// // Output: "&lt;script&gt;alert('XSS')&lt;/script&gt;"
/// ```
/// 
/// With non-string values:
/// ```liquid
/// {{ 5 | escape_once }}
/// // Output: "5"
/// 
/// {{ true | escape_once }}
/// // Output: "true"
/// ```
/// 
/// With undefined or nil values:
/// ```liquid
/// {{ undefined_variable | escape_once }}
/// // Output: ""
/// 
/// {{ nil | escape_once }}
/// // Output: ""
/// ```
/// 
/// - Important: The unescape-then-escape approach means that malformed or partial HTML entities in the input\
///   may be normalized or changed. For example, `&amp` (missing semicolon) might be treated differently\
///   than expected.
/// 
/// - Important: This filter is ideal for content that comes from multiple sources with different escaping\
///   policies, ensuring uniform output regardless of input state.
/// 
/// - Warning: The `escape_once` filter does not accept any parameters. Passing parameters will result in an error\
///   in strict Liquid implementations.
/// 
/// - SeeAlso: ``EscapeFilter``
/// - SeeAlso: ``StripHtmlFilter``
/// - SeeAlso: ``UrlEncodeFilter``
/// - SeeAlso: [Liquid documentation](https://shopify.github.io/liquid/filters/escape_once/)
/// - SeeAlso: [LiquidJS documentation](https://liquidjs.com/filters/escape_once.html)
/// - SeeAlso: [Python Liquid documentation](https://liquid.readthedocs.io/en/latest/filter_reference/#escape_once)
@usableFromInline
package struct EscapeOnceFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "escape_once"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        return .string(token.stringValue.htmlUnescape().htmlEscape(decimal: true, useNamedReferences: true))
    }
}