import Foundation

/// Implements the `url_decode` filter, which decodes a URL-encoded string.
/// 
/// The url_decode filter reverses URL encoding, converting percent-encoded characters
/// back to their original form and replacing plus signs (+) with spaces. This filter
/// is essential when processing URL parameters, form data, or any percent-encoded
/// strings that need to be displayed in human-readable format. It handles both standard
/// percent encoding and the application/x-www-form-urlencoded format where spaces are
/// represented as plus signs.
/// 
/// The filter first replaces all plus signs with spaces (following form-encoding
/// conventions), then performs percent decoding. If the decoding fails due to invalid
/// encoding sequences, the original string is returned unchanged. Non-string inputs
/// are also returned unchanged.
/// 
/// ## Examples
/// 
/// Basic URL decoding:
/// ```liquid
/// {{ "%27Stop%21%27+said+Fred" | url_decode }}
/// → "'Stop!' said Fred"
/// ```
/// 
/// Decoding special characters:
/// ```liquid
/// {{ "Hello%20World%21" | url_decode }}
/// → "Hello World!"
/// 
/// {{ "user%40example.com" | url_decode }}
/// → "user@example.com"
/// ```
/// 
/// Form-encoded data with plus signs:
/// ```liquid
/// {{ "first+name=John&last+name=Doe" | url_decode }}
/// → "first name=John&last name=Doe"
/// ```
/// 
/// International characters:
/// ```liquid
/// {{ "caf%C3%A9+r%C3%A9sum%C3%A9" | url_decode }}
/// → "café résumé"
/// ```
/// 
/// Invalid encoding returns original:
/// ```liquid
/// {{ "invalid%ZZ" | url_decode }}
/// → "invalid%ZZ"
/// ```
/// 
/// - Important: Plus signs (+) are always converted to spaces, following the\
///   application/x-www-form-urlencoded convention. If you need to preserve literal\
///   plus signs, they should be encoded as %2B in the input.
/// 
/// - Important: Invalid percent-encoding sequences cause the filter to return the\
///   original string unchanged rather than throwing an error or partially decoding.
/// 
/// - Warning: The filter does not validate that the decoded result is valid UTF-8.\
///   Malformed sequences might produce unexpected results.
/// 
/// - SeeAlso: ``UrlEncodeFilter`` for encoding strings for URL use
/// - SeeAlso: ``EscapeFilter`` for HTML entity encoding
/// - SeeAlso: [LiquidJS url_decode](https://liquidjs.com/filters/url_decode.html)
/// - SeeAlso: [Python Liquid url_decode](https://liquid.readthedocs.io/en/latest/filter_reference/#url_decode)
/// - SeeAlso: [Shopify Liquid url_decode](https://shopify.github.io/liquid/filters/url_decode/)
@usableFromInline
package struct UrlDecodeFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "url_decode"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard case .string(let string) = token else {
            return token
        }
        
        // URL decode the string
        // Replace + with space first (form-encoded data)
        let plusDecoded = string.replacingOccurrences(of: "+", with: " ")
        
        // Then percent decode
        if let decoded = plusDecoded.removingPercentEncoding {
            return .string(decoded)
        }
        
        // If decoding fails, return original
        return token
    }
}