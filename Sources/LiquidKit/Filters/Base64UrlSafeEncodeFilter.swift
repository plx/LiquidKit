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
/// <!-- Output: XyMvLg -->
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
/// <!-- Output: NQ (encodes "5") -->
/// 
/// {{ undefined_variable | base64_url_safe_encode }}
/// <!-- Output: (empty string) -->
/// ```
/// 
/// - Important: The output is URL-safe and can be used directly in URLs without additional \
///   encoding. Padding characters are removed from the output.
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
        // The base64_url_safe_encode filter does not accept any parameters
        // Throw an error if any parameters are provided, matching strict Liquid behavior
        guard parameters.isEmpty else {
            throw TemplateSyntaxError("base64_url_safe_encode filter does not take any arguments")
        }
        
        // Handle nil values by returning empty string
        // This matches the behavior of other Liquid implementations
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
                // Each element is converted to its string representation
                stringToEncode = array.map { $0.stringValue }.joined()
            case .dictionary:
                // Dictionaries render as empty strings in Liquid
                stringToEncode = ""
            case .range(let range):
                // Ranges render as their string representation (e.g., "1..5")
                stringToEncode = "\(range.lowerBound)..\(range.upperBound)"
            case .nil:
                // This case is handled by the guard above, but needed for exhaustive switch
                return .string("")
            }
            
            // Convert the string to UTF-8 data for encoding
            guard let data = stringToEncode.data(using: .utf8) else {
                // If UTF-8 encoding fails (extremely rare), return empty string
                return .string("")
            }
            
            // Create URL-safe base64 string by:
            // 1. Starting with standard base64 encoding
            // 2. Replacing '+' with '-' (URL-safe character)
            // 3. Replacing '/' with '_' (URL-safe character)
            // 4. Removing all '=' padding characters
            let base64String = data.base64EncodedString()
                .replacingOccurrences(of: "+", with: "-")
                .replacingOccurrences(of: "/", with: "_")
                .trimmingCharacters(in: CharacterSet(charactersIn: "="))
            
            return .string(base64String)
        }
        
        // nil values return empty string
        return .string("")
    }
}