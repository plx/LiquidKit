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
/// Non-string inputs throw errors, undefined values return empty string:
/// ```liquid
/// {{ 5 | base64_url_safe_decode }}
/// <!-- Error: base64_url_safe_decode filter requires a string input -->
/// 
/// {{ undefined_variable | base64_url_safe_decode }}
/// <!-- Output: (empty string) -->
/// 
/// {{ "SGVsbG8" | base64_url_safe_decode: "extra" }}
/// <!-- Error: base64_url_safe_decode filter does not accept any parameters -->
/// ```
/// 
/// - Important: This filter automatically handles padding restoration. You don't need to \
///   add padding characters to the input string.
/// 
/// - Warning: This filter matches liquidjs and python-liquid behavior by throwing errors for: \
///   1. Non-string inputs (integers, booleans, arrays, dictionaries) \
///   2. Extra parameters (this filter accepts no parameters) \
///   Invalid Base64 data or non-UTF8 decoded content will return `nil` (rendered as empty string).
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
        // Check for unexpected parameters - this filter doesn't accept any
        guard parameters.isEmpty else {
            // Throw an error if any parameters are provided, matching liquidjs/python-liquid behavior
            throw FilterError.improperParameters("base64_url_safe_decode filter does not accept any parameters")
        }
        
        // Handle nil/undefined input by returning empty string
        // This matches the golden liquid test: "undefined left value" returns ""
        guard case .string(let inputString) = token else {
            // If input is nil, return empty string (matching golden liquid behavior)
            if case .nil = token {
                return .string("")
            }
            // For non-string inputs (integers, booleans, etc.), throw an error
            // This matches the golden liquid test: "not a string" is marked as invalid
            throw FilterError.invalidArgument("base64_url_safe_decode filter requires a string input, got \(type(of: token))")
        }
        
        // Handle empty string input - return as-is
        if inputString.isEmpty {
            return .string("")
        }
        
        // Convert URL-safe base64 to standard base64
        // URL-safe base64 uses:
        // - dash (-) instead of plus (+)
        // - underscore (_) instead of slash (/)
        // - often omits padding (=) characters
        var base64String = inputString
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        // Add padding if necessary
        // Base64 strings must have a length that is a multiple of 4
        // If not, we need to add '=' padding characters
        let remainder = base64String.count % 4
        if remainder > 0 {
            base64String += String(repeating: "=", count: 4 - remainder)
        }
        
        // Attempt to decode the base64 string
        guard let data = Data(base64Encoded: base64String),
              let decodedString = String(data: data, encoding: .utf8) else {
            // If decoding fails or result is not valid UTF-8, return nil
            // This will be rendered as empty string in Liquid templates
            return .nil
        }
        
        return .string(decodedString)
    }
}