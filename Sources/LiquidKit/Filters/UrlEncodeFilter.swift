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
/// - Important: This implementation matches the behavior of Ruby's CGI.escape method,\
///   which is used by the original Shopify Liquid implementation. It is fully compatible\
///   with LiquidJS and other standard Liquid implementations.
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
        // Only process string values - return non-strings unchanged
        guard case .string(let string) = token else {
            return token
        }
        
        // Implement form-encoding (application/x-www-form-urlencoded) which is what
        // Ruby's CGI.escape does and what the original Liquid implementation uses.
        //
        // The encoding rules are:
        // 1. Alphanumeric characters (a-z, A-Z, 0-9) remain unchanged
        // 2. The characters "-", "_", ".", and "~" remain unchanged (unreserved characters)
        // 3. Space characters are encoded as "+" (not %20)
        // 4. All other characters are percent-encoded using UTF-8
        
        // Create a character set containing only the safe characters
        // This matches Ruby CGI.escape behavior
        var allowedCharacters = CharacterSet.alphanumerics
        allowedCharacters.insert(charactersIn: "-._~")
        
        // Perform the percent encoding
        // This will encode spaces as %20 and all other unsafe characters appropriately
        guard let percentEncoded = string.addingPercentEncoding(withAllowedCharacters: allowedCharacters) else {
            // If encoding fails (which is extremely rare), return the original string
            // This matches the Ruby implementation behavior
            return token
        }
        
        // Convert %20 (percent-encoded spaces) to + for form encoding
        // This is the key difference between regular URL encoding and form encoding
        let formEncoded = percentEncoded.replacingOccurrences(of: "%20", with: "+")
        
        return .string(formEncoded)
    }
}