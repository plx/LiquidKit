import Foundation

/// Implements the `escape` filter, which converts HTML special characters to their entity equivalents.
/// 
/// The `escape` filter is essential for preventing XSS attacks and ensuring that user-generated content
/// is safely displayed in HTML contexts. It replaces characters that have special meaning in HTML
/// (such as `<`, `>`, `&`, `"`, and `'`) with their corresponding HTML entities. This filter always
/// escapes content, even if it has already been partially escaped.
/// 
/// This implementation matches the behavior of liquidjs and python-liquid, escaping only the five
/// core HTML special characters and using `&#39;` for single quotes for maximum browser compatibility.
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
/// {{ "It's amazing" | escape }}
/// // Output: "It&#39;s amazing"
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
/// - Important: The filter converts any input to its string representation before escaping. Numbers\
///   and arrays are converted to strings, booleans become "true" or "false", and dictionaries\
///   return empty strings (matching LiquidKit's Token type behavior).
/// 
/// - Note: The `escape` filter ignores any parameters passed to it, following the standard Liquid\
///   implementation where this filter takes no parameters.
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
        // Get the string representation of the token value
        // Handle special cases where stringValue returns empty string
        let stringValue: String
        switch token {
        case .bool(let value):
            // Convert booleans to "true" or "false" strings to match liquidjs/python-liquid
            stringValue = value ? "true" : "false"
        case .dictionary:
            // For dictionaries, we'll use the default stringValue which returns empty string
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
        
        // Use a mutable string to build the escaped result
        var escaped = ""
        
        // Reserve capacity to avoid multiple reallocations
        escaped.reserveCapacity(stringValue.count)
        
        // Process each character in the string
        for character in stringValue {
            switch character {
            case "<":
                // Less-than sign - prevents opening of HTML tags
                escaped.append("&lt;")
            case ">":
                // Greater-than sign - prevents closing of HTML tags
                escaped.append("&gt;")
            case "&":
                // Ampersand - prevents entity injection
                escaped.append("&amp;")
            case "\"":
                // Double quote - prevents breaking out of HTML attributes
                escaped.append("&quot;")
            case "'":
                // Single quote/apostrophe - use &#39; for HTML compatibility  
                // Note: &apos; is XML-only and not supported in older browsers like IE8
                escaped.append("&#39;")
            default:
                // All other characters (including Unicode) pass through unchanged
                // This matches the behavior of liquidjs and python-liquid
                escaped.append(character)
            }
        }
        
        return .string(escaped)
    }
}