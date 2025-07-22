import Foundation

/// Implements the `base64_url_safe_decode` filter, which decodes a URL-safe Base64 encoded string.
/// 
/// The `base64_url_safe_decode` filter decodes strings that have been encoded using URL-safe
/// Base64 encoding. URL-safe Base64 replaces the characters `+` and `/` with `-` and `_`
/// respectively, and typically omits padding characters (`=`). This filter handles the
/// conversion from URL-safe format to standard Base64 before decoding.
/// 
/// The filter only accepts string inputs. It automatically handles the conversion of URL-safe
/// characters back to standard Base64 characters and adds any necessary padding before
/// decoding. If the input cannot be decoded as valid Base64 or the decoded data is not
/// valid UTF-8 text, the filter returns `nil`.
/// 
/// ## Examples
/// 
/// Basic URL-safe Base64 decoding:
/// ```liquid
/// {{ "XyMvLg==" | base64_url_safe_decode }}
/// <!-- Output: _#/. -->
/// 
/// {{ "SGVsbG8sIFdvcmxkIQ" | base64_url_safe_decode }}
/// <!-- Output: Hello, World! -->
/// ```
/// 
/// Decoding with URL-safe characters:
/// ```liquid
/// {{ "YWJjZGVmZ2hpamtsbW5vcHFyc3R1dnd4eXogQUJDREVGR0hJSktMTU5PUFFSU1RVVldYWVogMTIzNDU2Nzg5MCAhQCMkJV4mKigpLT1fKy8_Ljo7W117fVx8" | base64_url_safe_decode }}
/// <!-- Output: abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLMNOPQRSTUVWXYZ 1234567890 !@#$%^&*()-=_+/?.:;[]{}\\| -->
/// ```
/// 
/// Non-string inputs and undefined values:
/// ```liquid
/// {{ 5 | base64_url_safe_decode }}
/// <!-- Error: invalid (non-string input) -->
/// 
/// {{ undefined_variable | base64_url_safe_decode }}
/// <!-- Output: (empty string) -->
/// ```
/// 
/// - Important: This filter automatically handles padding restoration. You don't need to \
///   add padding characters to the input string.
/// 
/// - Warning: Non-string inputs will cause an error in strict Liquid implementations. \
///   Invalid Base64 data or non-UTF8 decoded content will return `nil`.
/// 
/// - SeeAlso: ``Base64UrlSafeEncodeFilter``, ``Base64DecodeFilter``
/// - SeeAlso: [LiquidJS base64_url_safe_decode](https://liquidjs.com/filters/base64_url_safe_decode.html)
/// - SeeAlso: [Python Liquid base64_url_safe_decode](https://liquid.readthedocs.io/en/latest/filter_reference/#base64_url_safe_decode)
@usableFromInline
package struct Base64UrlSafeDecodeFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "base64_url_safe_decode"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard case .string(let inputString) = token else {
            return .nil
        }
        
        // Convert URL-safe base64 to standard base64
        var base64String = inputString
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        // Add padding if necessary
        let remainder = base64String.count % 4
        if remainder > 0 {
            base64String += String(repeating: "=", count: 4 - remainder)
        }
        
        guard let data = Data(base64Encoded: base64String),
              let decodedString = String(data: data, encoding: .utf8) else {
            return .nil
        }
        
        return .string(decodedString)
    }
}