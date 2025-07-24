import Foundation

/// Implements the `replace_first` filter, which replaces only the first occurrence of a substring.
/// 
/// The `replace_first` filter searches for a substring within the input string and replaces only
/// the first occurrence with a replacement string. This filter is useful when you want to modify
/// only the initial instance of a pattern while leaving any subsequent occurrences unchanged.
/// Unlike the `replace` filter which replaces all occurrences, `replace_first` provides precise
/// control over string modifications.
///
/// The filter accepts one or two parameters: the search string and optionally the replacement 
/// string. If the second parameter is missing, it defaults to an empty string, effectively 
/// removing the first occurrence of the search string. The filter performs case-sensitive 
/// literal string matching, not regular expression matching.
///
/// ## Examples
///
/// Basic usage replacing the first occurrence:
/// ```liquid
/// {{ "Take my protein pills and put my helmet on" | replace_first: "my", "your" }}
/// <!-- Output: "Take your protein pills and put my helmet on" -->
/// ```
///
/// When the search string doesn't exist:
/// ```liquid
/// {{ "Hello world" | replace_first: "foo", "bar" }}
/// <!-- Output: "Hello world" -->
/// ```
///
/// With only one parameter (removes first occurrence):
/// ```liquid
/// {{ "hello" | replace_first: "ll" }}
/// <!-- Output: "heo" -->
/// ```
///
/// Non-string input values are converted to strings:
/// ```liquid
/// {{ 5 | replace_first: "rain", "foo" }}
/// <!-- Output: "5" -->
/// {{ 12345 | replace_first: "2", "X" }}
/// <!-- Output: "1X345" -->
/// ```
///
/// - Important: This implementation follows the behavior of liquidjs and python-liquid:
///   - Nil/undefined input values are converted to empty strings
///   - Nil/undefined parameters are treated as empty strings
///   - Non-string values (integers, booleans, arrays, etc.) are automatically converted to 
///     their string representations
///   - An empty search string will insert the replacement at the beginning of the input
///
/// - SeeAlso: ``ReplaceFilter``, ``ReplaceLastFilter``
/// - SeeAlso: [LiquidJS Documentation](https://liquidjs.com/filters/replace_first.html)
/// - SeeAlso: [Python Liquid Documentation](https://liquid.readthedocs.io/en/latest/filter_reference/#replace_first)
/// - SeeAlso: [Shopify Liquid Documentation](https://shopify.github.io/liquid/filters/replace_first/)
@usableFromInline
package struct ReplaceFirstFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "replace_first"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        // Convert input to string - matching liquidjs/python-liquid behavior
        // Non-string inputs are coerced to their string representation
        let string: String
        switch token {
        case .string(let str):
            string = str
        case .nil:
            // Nil values become empty strings
            string = ""
        case .dictionary:
            // Dictionary becomes string representation "{}"
            string = "{}"
        case .array(let values):
            // Array becomes string representation like "[1, 2, 3]"
            let elements = values.map { value -> String in
                switch value {
                case .string(let s): return s
                case .integer(let i): return String(i)
                case .decimal(let d): return String(describing: d)
                case .bool(let b): return b ? "true" : "false"
                case .nil: return ""
                case .array, .dictionary, .range: return value.stringValue
                }
            }
            string = "[" + elements.joined(separator: ", ") + "]"
        case .bool(let b):
            // Boolean becomes "true" or "false"
            string = b ? "true" : "false"
        case .integer(let i):
            string = String(i)
        case .decimal(let d):
            string = String(describing: d)
        case .range(let r):
            string = "\(r.lowerBound)..\(r.upperBound)"
        }
        
        // Return original value if no parameters provided
        guard parameters.count >= 1 else {
            return token
        }
        
        // Get search parameter - convert to string with proper handling for all types
        let search: String
        switch parameters[0] {
        case .nil:
            search = ""
        case .bool(let b):
            search = b ? "true" : "false"
        case .integer(let i):
            search = String(i)
        case .decimal(let d):
            search = String(describing: d)
        case .string(let s):
            search = s
        case .array, .dictionary, .range:
            search = parameters[0].stringValue
        }
        
        // Get replacement parameter - default to empty string if missing or nil
        // This matches python-liquid behavior where missing second parameter removes the match
        let replacement: String
        if parameters.count >= 2 {
            switch parameters[1] {
            case .nil:
                replacement = ""
            case .bool(let b):
                replacement = b ? "true" : "false"
            case .integer(let i):
                replacement = String(i)
            case .decimal(let d):
                replacement = String(describing: d)
            case .string(let s):
                replacement = s
            case .array, .dictionary, .range:
                replacement = parameters[1].stringValue
            }
        } else {
            replacement = ""
        }
        
        // Handle empty search string - insert replacement at the beginning
        // This matches the behavior where empty string matches the start position
        if search.isEmpty {
            return .string(replacement + string)
        }
        
        // Find first occurrence and replace only that
        if let range = string.range(of: search) {
            var result = string
            result.replaceSubrange(range, with: replacement)
            return .string(result)
        }
        
        // No match found - return original string
        return .string(string)
    }
}