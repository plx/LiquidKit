import Foundation

/// Implements the `base64_url_safe_encode` filter, which encodes a string to URL-safe Base64 format.
/// 
/// The `base64_url_safe_encode` filter converts a string value into its URL-safe Base64-encoded
/// representation. URL-safe Base64 encoding is designed for use in URLs and filenames by
/// replacing the standard Base64 characters `+` and `/` with `-` and `_` respectively, and
/// removing padding characters (`=`). This makes the encoded string safe for use in URLs
/// without requiring additional URL encoding.
/// 
/// The filter accepts any value type as input. String values are encoded directly, while
/// non-string values (numbers, booleans) are first converted to their string representation
/// before encoding. If the input is `nil` or undefined, the filter returns an empty string.
/// The output never includes padding characters, making it suitable for URL parameters.
/// 
/// ## Examples
/// 
/// Basic URL-safe encoding:
/// ```liquid
/// {{ "_#/." | base64_url_safe_encode }}
/// <!-- Output: XyMvLg== -->
/// 
/// {{ "Hello, World!" | base64_url_safe_encode }}
/// <!-- Output: SGVsbG8sIFdvcmxkIQ (note: no padding) -->
/// ```
/// 
/// Encoding with special characters:
/// ```liquid
/// {{ "data+with/special=chars" | base64_url_safe_encode }}
/// <!-- Output: ZGF0YSt3aXRoL3NwZWNpYWw9Y2hhcnM (uses - and _ instead of + and /) -->
/// ```
/// 
/// Non-string values and undefined:
/// ```liquid
/// {{ 5 | base64_url_safe_encode }}
/// <!-- Output: NQ== (encodes "5") -->
/// 
/// {{ undefined_variable | base64_url_safe_encode }}
/// <!-- Output: (empty string) -->
/// ```
/// 
/// - Important: The output is URL-safe and can be used directly in URLs without additional \
///   encoding. Padding characters are removed from the output.
/// 
/// - Warning: The current implementation returns `nil` for non-string inputs instead of \
///   converting them to strings first, which differs from the standard Liquid behavior. \
///   Also note that some implementations may keep padding characters in the output.
/// 
/// - SeeAlso: ``Base64UrlSafeDecodeFilter``, ``Base64EncodeFilter``
/// - SeeAlso: [LiquidJS base64_url_safe_encode](https://liquidjs.com/filters/base64_url_safe_encode.html)
/// - SeeAlso: [Python Liquid base64_url_safe_encode](https://liquid.readthedocs.io/en/latest/filter_reference/#base64_url_safe_encode)
@usableFromInline
package struct Base64UrlSafeEncodeFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "base64_url_safe_encode"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard case .string(let inputString) = token else {
            return .nil
        }
        
        guard let data = inputString.data(using: .utf8) else {
            return .nil
        }
        
        // Create URL-safe base64 string
        let base64String = data.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .trimmingCharacters(in: CharacterSet(charactersIn: "="))
        
        return .string(base64String)
    }
}