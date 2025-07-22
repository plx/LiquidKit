import Foundation

/// Implements the `base64_decode` filter, which decodes a Base64-encoded string into its original UTF-8 text.
/// 
/// The base64_decode filter takes a Base64-encoded string and decodes it back to its original
/// text representation. This filter is the counterpart to base64_encode and is commonly used
/// when working with encoded data from APIs, configuration files, or secure transmission protocols.
/// The filter expects valid Base64 input and produces UTF-8 decoded text output.
/// 
/// The filter only accepts string input values. The input must be a valid Base64-encoded string
/// that, when decoded, produces valid UTF-8 text. If the input is not a string, cannot be decoded
/// as Base64, or does not produce valid UTF-8 text, the filter returns nil (rendered as empty string).
/// 
/// ## Examples
/// 
/// Basic Base64 decoding:
/// ```liquid
/// {{ "SGVsbG8gV29ybGQ=" | base64_decode }}                    → Hello World
/// {{ "XyMvLg==" | base64_decode }}                             → _#/.
/// {{ "YWJjZGVmZ2hpamtsbW5vcHFyc3R1dnd4eXogQUJDREVGR0hJSktMTU5PUFFSU1RVVldYWVogMTIzNDU2Nzg5MCAhQCMkJV4mKigpLT1fKy8/Ljo7W117fVx8" | base64_decode }}
/// → abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLMNOPQRSTUVWXYZ 1234567890 !@#$%^&*()-=_+/?.:;[]{}\\|
/// ```
/// 
/// Edge cases:
/// ```liquid
/// {{ "" | base64_decode }}              → (empty string)
/// {{ "invalid base64!" | base64_decode }} → (empty string)
/// {{ nil | base64_decode }}             → (empty string)
/// ```
/// 
/// > Important: This filter specifically decodes to UTF-8 text. Binary data that doesn't
/// > represent valid UTF-8 text will fail to decode and return nil. For binary data handling,
/// > a different approach would be needed.
/// 
/// > Warning: The base64_decode filter does not accept any parameters. Providing parameters
/// > will result in an error in strict Liquid implementations. Additionally, non-string input
/// > values are considered invalid and will cause errors in strict implementations.
/// 
/// - SeeAlso: ``Base64EncodeFilter``, ``Base64UrlSafeDecodeFilter``, ``Base64UrlSafeEncodeFilter``
/// - SeeAlso: [LiquidJS base64_decode](https://liquidjs.com/filters/base64_decode.html)
/// - SeeAlso: [Python Liquid base64_decode](https://liquid.readthedocs.io/en/latest/filter_reference/#base64_decode)
@usableFromInline
package struct Base64DecodeFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "base64_decode"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard case .string(let inputString) = token else {
            return .nil
        }
        
        guard let data = Data(base64Encoded: inputString),
              let decodedString = String(data: data, encoding: .utf8) else {
            return .nil
        }
        
        return .string(decodedString)
    }
}