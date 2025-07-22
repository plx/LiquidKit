import Foundation

/// Implements the `base64_encode` filter, which encodes a string to Base64 format.
/// 
/// The `base64_encode` filter converts a string value into its Base64-encoded representation,
/// which is useful for encoding binary data or text in a format that can be safely transmitted
/// in text-based protocols. The filter uses standard Base64 encoding with padding characters.
/// 
/// The filter accepts any value type as input. String values are encoded directly, while
/// non-string values (numbers, booleans) are first converted to their string representation
/// before encoding. If the input is `nil` or undefined, the filter returns an empty string.
/// 
/// ## Examples
/// 
/// Basic string encoding:
/// ```liquid
/// {{ "_#/." | base64_encode }}
/// <!-- Output: XyMvLg== -->
/// 
/// {{ "Hello, World!" | base64_encode }}
/// <!-- Output: SGVsbG8sIFdvcmxkIQ== -->
/// ```
/// 
/// Non-string values are converted to strings first:
/// ```liquid
/// {{ 5 | base64_encode }}
/// <!-- Output: NQ== (encodes "5") -->
/// 
/// {{ true | base64_encode }}
/// <!-- Output: dHJ1ZQ== (encodes "true") -->
/// ```
/// 
/// Undefined values return empty string:
/// ```liquid
/// {{ undefined_variable | base64_encode }}
/// <!-- Output: (empty string) -->
/// ```
/// 
/// - Important: The filter does not accept any parameters. Passing parameters will result \
///   in an error in strict Liquid implementations.
/// 
/// - Warning: The current implementation returns `nil` for non-string inputs instead of \
///   converting them to strings first, which differs from the standard Liquid behavior \
///   shown in the golden-liquid test suite.
/// 
/// - SeeAlso: ``Base64DecodeFilter``, ``Base64UrlSafeEncodeFilter``
/// - SeeAlso: [LiquidJS base64_encode](https://liquidjs.com/filters/base64_encode.html)
/// - SeeAlso: [Python Liquid base64_encode](https://liquid.readthedocs.io/en/latest/filter_reference/#base64_encode)
@usableFromInline
package struct Base64EncodeFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "base64_encode"
    
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
        
        return .string(data.base64EncodedString())
    }
}