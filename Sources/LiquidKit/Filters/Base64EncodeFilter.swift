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
        // The base64_encode filter does not accept any parameters
        // Throw an error if any parameters are provided, matching strict Liquid behavior
        guard parameters.isEmpty else {
            throw TemplateSyntaxError("base64_encode filter does not take any arguments")
        }
        
        // Handle nil values by returning empty string
        // This matches the behavior expected by golden-liquid tests
        guard case .nil = token else {
            // For all non-nil values, convert to string representation first
            let stringToEncode: String
            
            switch token {
            case .string(let str):
                // String values are used directly
                stringToEncode = str
            case .integer(let int):
                // Convert integers to their string representation
                stringToEncode = String(int)
            case .decimal(let dec):
                // Convert decimals to their string representation
                stringToEncode = String(describing: dec)
            case .bool(let bool):
                // Convert booleans to "true" or "false"
                stringToEncode = bool ? "true" : "false"
            case .array(let array):
                // Arrays are concatenated without separators in Liquid
                stringToEncode = array.map { $0.stringValue }.joined()
            case .dictionary:
                // Dictionaries render as empty strings in Liquid
                stringToEncode = ""
            case .range(let range):
                // Ranges should render as their string representation
                stringToEncode = "\(range.lowerBound)..\(range.upperBound)"
            case .nil:
                // This case is handled by the guard above, but needed for exhaustive switch
                return .string("")
            }
            
            // Convert the string to UTF-8 data and encode to Base64
            guard let data = stringToEncode.data(using: .utf8) else {
                // If UTF-8 encoding fails (extremely rare), return empty string
                return .string("")
            }
            
            // Return the Base64 encoded string
            return .string(data.base64EncodedString())
        }
        
        // nil values return empty string
        return .string("")
    }
}