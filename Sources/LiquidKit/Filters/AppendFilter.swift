import Foundation

/// Implements the `append` filter, which concatenates a string to the end of another string.
/// 
/// The append filter is used for string concatenation, adding the specified text to the end
/// of the input value. This is one of the fundamental string manipulation filters in Liquid,
/// commonly used for building URLs, file paths, CSS classes, or any scenario where you need
/// to combine strings. Both the input value and the parameter are converted to strings before
/// concatenation, making it flexible for use with various data types.
/// 
/// The filter requires exactly one parameter - the string to append. Any value type can be used
/// as both input and parameter, as they will be converted to strings following these rules:
/// - `nil` → empty string (`""`)
/// - `bool` → `"true"` or `"false"`
/// - `integer` → string representation (e.g., `42` → `"42"`)
/// - `decimal` → string representation (e.g., `3.14` → `"3.14"`)
/// - `array` → JSON-like format (e.g., `["a", "b"]`)
/// - `dictionary` → JSON-like format (e.g., `{"key": "value"}`)
/// - `range` → range format (e.g., `1..5`)
/// 
/// ## Examples
/// 
/// Basic string concatenation:
/// ```liquid
/// {{ "Hello" | append: " World" }}      → Hello World
/// {{ "file" | append: ".txt" }}         → file.txt
/// {{ "/path/to" | append: "/file" }}    → /path/to/file
/// ```
/// 
/// Type conversion:
/// ```liquid
/// {{ "Version " | append: 2 }}          → Version 2
/// {{ 5 | append: " items" }}            → 5 items
/// {{ true | append: " value" }}         → true value
/// {{ false | append: " flag" }}         → false flag
/// ```
/// 
/// Edge cases:
/// ```liquid
/// {{ nil | append: "text" }}            → text
/// {{ "text" | append: nil }}            → text
/// {{ "" | append: "text" }}             → text
/// {{ nil | append: nil }}               → (empty string)
/// ```
/// 
/// > Important: This implementation follows the behavior of liquidjs and python-liquid,
/// > where all values are coerced to strings before concatenation. Nil values are treated
/// > as empty strings to allow safe concatenation with potentially missing values.
/// 
/// > Note: Currently, missing parameters return nil and extra parameters are ignored to
/// > maintain backward compatibility. In strict Liquid implementations, these would cause errors.
/// 
/// - SeeAlso: ``PrependFilter``, ``RemoveFilter``, ``RemoveFirstFilter``, ``ReplaceFilter``
/// - SeeAlso: [LiquidJS append](https://liquidjs.com/filters/append.html)
/// - SeeAlso: [Python Liquid append](https://liquid.readthedocs.io/en/latest/filter_reference/#append)
/// - SeeAlso: [Shopify Liquid append](https://shopify.github.io/liquid/filters/append/)
@usableFromInline
package struct AppendFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "append"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        // Check parameter count - append requires exactly one parameter
        // In strict Liquid implementations, missing or extra parameters would throw an error
        // For now, we return nil for missing parameters (maintaining backward compatibility)
        guard let parameter = parameters.first else {
            return .nil
        }
        
        // Convert both input and parameter to strings for concatenation
        // This matches the behavior of liquidjs and python-liquid where all values
        // are coerced to strings before concatenation
        let inputString = convertToString(token)
        let parameterString = convertToString(parameter)
        
        // Perform the concatenation
        return .string(inputString + parameterString)
    }
    
    /// Converts a Token.Value to its string representation for append operation
    /// This ensures consistent string conversion that matches other Liquid implementations
    @usableFromInline
    package func convertToString(_ value: Token.Value) -> String {
        switch value {
        case .nil:
            // Nil values are treated as empty strings
            return ""
        case .bool(let bool):
            // Booleans are converted to "true" or "false"
            return bool ? "true" : "false"
        case .integer(let int):
            // Integers are converted directly
            return "\(int)"
        case .decimal(let decimal):
            // Decimals use standard string conversion
            // Note: This may produce different precision than expected in some cases
            return "\(decimal)"
        case .string(let string):
            // Strings are used as-is
            return string
        case .array(let array):
            // Arrays are converted to JSON-like representation
            let elements = array.map { element in
                switch element {
                case .string(let s):
                    return "\"\(s)\""
                default:
                    return convertToString(element)
                }
            }
            return "[" + elements.joined(separator: ", ") + "]"
        case .dictionary(let dict):
            // Dictionaries are converted to JSON-like representation
            let pairs = dict.map { key, value in
                let valueStr: String
                switch value {
                case .string(_):
                    valueStr = "\"\(convertToString(value))\""
                default:
                    valueStr = convertToString(value)
                }
                return "\"\(key)\": \(valueStr)"
            }
            return "{" + pairs.joined(separator: ", ") + "}"
        case .range(let range):
            // Ranges use the standard format
            return "\(range.lowerBound)..\(range.upperBound)"
        }
    }
}