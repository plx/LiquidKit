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
/// Base64 without padding (automatically padded):
/// ```liquid
/// {{ "c3VyZQ" | base64_decode }}                               → sure
/// {{ "c3VyZS4" | base64_decode }}                              → sure.
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
/// > represent valid UTF-8 text will fail to decode and return nil. Base64 strings without
/// > proper padding are automatically padded during decoding to handle various encoding sources.
/// 
/// > Note: The base64_decode filter ignores any parameters provided. In strict Liquid 
/// > implementations, providing parameters would result in an error. Non-string input
/// > values always return nil rather than throwing errors.
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
        // Only accept string input - non-string types return nil
        guard case .string(let inputString) = token else {
            return .nil
        }
        
        // Handle empty string case early
        if inputString.isEmpty {
            return .string("")
        }
        
        // Prepare the base64 string for decoding
        var base64String = inputString
        
        // Add padding if necessary
        // Base64 strings should have length that is multiple of 4
        // If not, we need to add '=' padding characters
        let remainder = base64String.count % 4
        if remainder > 0 {
            // Add the required padding
            base64String.append(String(repeating: "=", count: 4 - remainder))
        }
        
        // Create options for base64 decoding
        // .ignoreUnknownCharacters helps with some edge cases but we'll use default for strictness
        let options: Data.Base64DecodingOptions = []
        
        // Attempt to decode the base64 string
        guard let data = Data(base64Encoded: base64String, options: options) else {
            // Invalid base64 string - return nil
            return .nil
        }
        
        // Attempt to convert the decoded data to UTF-8 string
        guard let decodedString = String(data: data, encoding: .utf8) else {
            // Data is not valid UTF-8 - return nil
            return .nil
        }
        
        // Successfully decoded to UTF-8 string
        return .string(decodedString)
    }
}