import Foundation

/// Implements the `url_encode` filter, which encodes a string for safe use in URLs.
/// 
/// The url_encode filter converts strings into a format safe for inclusion in URLs by
/// percent-encoding special characters and replacing spaces with plus signs (+). This
/// filter follows the application/x-www-form-urlencoded encoding rules, making it
/// suitable for encoding form data, query parameters, and other URL components. The
/// encoding preserves alphanumeric characters and the characters "-", "_", ".", and "~"
/// while encoding everything else.
/// 
/// The filter specifically replaces spaces with plus signs rather than %20, following
/// form-encoding conventions. This makes it ideal for encoding data that will be sent
/// as form parameters or used in query strings. Non-string inputs are returned unchanged.
/// 
/// ## Examples
/// 
/// Basic URL encoding:
/// ```liquid
/// {{ "john@liquid.com" | url_encode }}
/// → "john%40liquid.com"
/// 
/// {{ "Tetsuro Takara" | url_encode }}
/// → "Tetsuro+Takara"
/// ```
/// 
/// Special characters:
/// ```liquid
/// {{ "Hello World!" | url_encode }}
/// → "Hello+World%21"
/// 
/// {{ "param=value&other=test" | url_encode }}
/// → "param%3Dvalue%26other%3Dtest"
/// ```
/// 
/// International characters:
/// ```liquid
/// {{ "café résumé" | url_encode }}
/// → "caf%C3%A9+r%C3%A9sum%C3%A9"
/// ```
/// 
/// Safe characters remain unchanged:
/// ```liquid
/// {{ "safe-string_123.txt~" | url_encode }}
/// → "safe-string_123.txt~"
/// ```
/// 
/// Edge cases:
/// ```liquid
/// {{ "" | url_encode }}
/// → ""
/// 
/// {{ " " | url_encode }}
/// → "+"
/// ```
/// 
/// - Important: This filter uses form-encoding rules where spaces become plus signs (+).\
///   If you need spaces encoded as %20 (for example, in path components), you may need\
///   to use a different encoding approach.
/// 
/// - Important: The filter preserves the characters "-", "_", ".", and "~" as they are\
///   considered safe in URLs. All other non-alphanumeric characters are percent-encoded.
/// 
/// - Warning: If encoding fails (which is rare), the filter returns the original string\
///   unchanged rather than throwing an error.
/// 
/// - SeeAlso: ``UrlDecodeFilter`` for decoding URL-encoded strings
/// - SeeAlso: ``EscapeOnceFilter`` for HTML entity encoding
/// - SeeAlso: [LiquidJS url_encode](https://liquidjs.com/filters/url_encode.html)
/// - SeeAlso: [Python Liquid url_encode](https://liquid.readthedocs.io/en/latest/filter_reference/#url_encode)
/// - SeeAlso: [Shopify Liquid url_encode](https://shopify.github.io/liquid/filters/url_encode/)
@usableFromInline
package struct UrlEncodeFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "url_encode"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard case .string(let string) = token else {
            return token
        }
        
        // URL encode the string
        // Use form encoding which replaces spaces with +
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: "-._~")
        
        if let encoded = string.addingPercentEncoding(withAllowedCharacters: allowed) {
            // Replace percent-encoded spaces with +
            let formEncoded = encoded.replacingOccurrences(of: "%20", with: "+")
            return .string(formEncoded)
        }
        
        // If encoding fails, return original
        return token
    }
}