import Foundation
import HTMLEntities

/// Implements the `escape_once` filter, which escapes HTML special characters while preserving already-escaped entities.
/// 
/// The `escape_once` filter provides intelligent HTML escaping that prevents double-escaping of content.
/// It escapes unescaped HTML special characters while leaving already-escaped HTML entities unchanged.
/// This ensures that mixed content containing both raw HTML and already-escaped entities is processed 
/// correctly, with each special character escaped exactly once.
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
/// // Output: "&lt;script&gt;alert(&#39;XSS&#39;)&lt;/script&gt;"
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
/// - Important: This filter preserves already-escaped HTML entities, preventing double-escaping.
///   For example, `&amp;` remains `&amp;` and is not converted to `&amp;amp;`.
/// 
/// - Important: This filter is ideal for content that comes from multiple sources with different escaping
///   policies, ensuring uniform output regardless of input state.
/// 
/// - Warning: The `escape_once` filter does not accept any parameters. Passing parameters will result in an error
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
        
        // Build the escaped result by processing the string character by character
        var result = ""
        result.reserveCapacity(stringValue.count)
        
        // Use a string iterator to process the input
        var index = stringValue.startIndex
        
        while index < stringValue.endIndex {
            let character = stringValue[index]
            
            // Check if this is the start of an HTML entity
            if character == "&" {
                // Look for the end of a potential entity (semicolon)
                var entityEndIndex = stringValue.index(after: index)
                var foundSemicolon = false
                
                // Scan forward to find a semicolon, but limit the search
                // HTML entities are typically short (e.g., &amp; is 5 chars, &#128512; is 9 chars)
                // Set a reasonable limit to avoid scanning too far
                let maxEntityLength = 10
                var scannedLength = 1
                
                while entityEndIndex < stringValue.endIndex && scannedLength < maxEntityLength {
                    if stringValue[entityEndIndex] == ";" {
                        foundSemicolon = true
                        break
                    }
                    entityEndIndex = stringValue.index(after: entityEndIndex)
                    scannedLength += 1
                }
                
                // If we found a semicolon, check if this is a valid HTML entity
                if foundSemicolon {
                    // Include the semicolon in the entity
                    let entityEndIndexInclusive = stringValue.index(after: entityEndIndex)
                    let potentialEntity = String(stringValue[index..<entityEndIndexInclusive])
                    
                    // Check if this is a valid HTML entity by attempting to unescape it
                    let unescaped = potentialEntity.htmlUnescape()
                    
                    // If the unescaped version is different, it was a valid entity
                    // Keep the original entity unchanged
                    if unescaped != potentialEntity {
                        result.append(potentialEntity)
                        index = entityEndIndexInclusive
                        continue
                    }
                }
                
                // Not a valid entity, escape the ampersand
                result.append("&amp;")
                index = stringValue.index(after: index)
            } else {
                // Process other special characters that need escaping
                switch character {
                case "<":
                    // Less-than sign - prevents opening of HTML tags
                    result.append("&lt;")
                case ">":
                    // Greater-than sign - prevents closing of HTML tags  
                    result.append("&gt;")
                case "\"":
                    // Double quote - prevents breaking out of HTML attributes
                    result.append("&quot;")
                case "'":
                    // Single quote/apostrophe - use &#39; for HTML compatibility
                    // This matches liquidjs and python-liquid behavior
                    result.append("&#39;")
                default:
                    // All other characters (including Unicode) pass through unchanged
                    result.append(character)
                }
                index = stringValue.index(after: index)
            }
        }
        
        return .string(result)
    }
}