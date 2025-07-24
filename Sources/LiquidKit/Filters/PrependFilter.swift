import Foundation

/// Implements the `prepend` filter, which adds a prefix to the beginning of a string.
/// 
/// The `prepend` filter concatenates a specified string to the beginning of the input value.
/// This is the opposite of the `append` filter and is commonly used for building URLs,
/// file paths, or adding prefixes to string values. Both the input value and the parameter
/// are converted to strings before concatenation, making it flexible for use with various
/// data types.
/// 
/// The filter requires exactly one parameter - the string to prepend. Any value type can be
/// used as both input and parameter, as they will be converted to strings following these rules:
/// - `nil` → empty string (`""`)
/// - `bool` → `"true"` or `"false"`
/// - `integer` → string representation (e.g., `42` → `"42"`)
/// - `decimal` → string representation (e.g., `3.14` → `"3.14"`)
/// - `array` → JSON-like format (e.g., `["a", "b"]`)
/// - `dictionary` → JSON-like format (e.g., `{"key": "value"}`)
/// - `range` → range format (e.g., `1..5`)
/// 
/// When chaining multiple `prepend` filters, they are applied from left to right, meaning
/// the rightmost prepend value will appear at the beginning of the final string. This
/// behavior might be counterintuitive but follows the standard Liquid filter execution order.
/// 
/// ## Examples
/// 
/// Basic string concatenation:
/// ```liquid
/// {{ "world" | prepend: "Hello, " }}          → Hello, world
/// {{ "/index.html" | prepend: "https://example.com" }}  → https://example.com/index.html
/// ```
/// 
/// Type conversion:
/// ```liquid
/// {{ 42 | prepend: "Answer: " }}              → Answer: 42
/// {{ " items" | prepend: 5 }}                 → 5 items
/// {{ 3.14159 | prepend: "Pi: " }}             → Pi: 3.14159
/// {{ true | prepend: "Setting: " }}           → Setting: true
/// ```
/// 
/// Edge cases:
/// ```liquid
/// {{ nil | prepend: "text" }}                 → text
/// {{ "text" | prepend: nil }}                 → text
/// {{ "" | prepend: "text" }}                  → text
/// {{ nil | prepend: nil }}                    → (empty string)
/// ```
/// 
/// Chaining prepend filters:
/// ```liquid
/// {{ "a" | prepend: "b" | prepend: "c" }}     → cba
/// {{ "file.txt" | prepend: "/" | prepend: "/home/user" }}  → /home/user/file.txt
/// ```
/// 
/// > Important: This implementation follows the behavior of liquidjs and python-liquid,
/// > where all values are coerced to strings before concatenation. Nil values are treated
/// > as empty strings to allow safe concatenation with potentially missing values.
/// 
/// > Note: Currently, missing parameters return nil and extra parameters are ignored to
/// > maintain backward compatibility. In strict Liquid implementations, these would cause errors.
/// 
/// - SeeAlso: ``AppendFilter`` - Adds a suffix to the end of a string
/// - SeeAlso: [LiquidJS prepend](https://liquidjs.com/filters/prepend.html)
/// - SeeAlso: [Python Liquid prepend](https://liquid.readthedocs.io/en/latest/filter_reference/#prepend)
/// - SeeAlso: [Shopify Liquid prepend](https://shopify.github.io/liquid/filters/prepend/)
@usableFromInline
package struct PrependFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "prepend"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        // Check parameter count - prepend requires exactly one parameter
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
        
        // Perform the concatenation with the parameter first (prepend)
        return .string(parameterString + inputString)
    }
    
    /// Converts a Token.Value to its string representation for prepend operation
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
            // Sort keys for consistent output
            let sortedKeys = dict.keys.sorted()
            let pairs = sortedKeys.map { key in
                let value = dict[key]!
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