import Foundation

/// Implements the `replace_last` filter, which replaces only the last occurrence of a substring.
/// 
/// The `replace_last` filter searches for a substring within the input string and replaces only
/// the last occurrence with a replacement string. This filter is useful when you want to modify
/// only the final instance of a pattern while leaving any preceding occurrences unchanged.
/// It provides precise control for scenarios where you need to target the end of repeated patterns.
///
/// The filter requires exactly two parameters: the search string and the replacement string. 
/// Both parameters are mandatory, matching the behavior of liquidjs and python-liquid. The filter 
/// performs case-sensitive literal string matching, not regular expression matching.
///
/// ## Examples
///
/// Basic usage replacing the last occurrence:
/// ```liquid
/// {{ "Take my protein pills and put my helmet on" | replace_last: "my", "your" }}
/// <!-- Output: "Take my protein pills and put your helmet on" -->
/// ```
///
/// With multiple occurrences:
/// ```liquid
/// {{ "red red red" | replace_last: "red", "blue" }}
/// <!-- Output: "red red blue" -->
/// ```
///
/// When the search string doesn't exist:
/// ```liquid
/// {{ "Hello world" | replace_last: "foo", "bar" }}
/// <!-- Output: "Hello world" -->
/// ```
///
/// Type conversion examples:
/// ```liquid
/// {{ 12321 | replace_last: "2", "5" }}
/// <!-- Output: "12351" -->
/// 
/// {{ "hello5" | replace_last: 5, "!" }}
/// <!-- Output: "hello!" -->
/// ```
///
/// - Important: All non-string inputs and parameters are automatically converted to strings.
///   Nil values are treated as empty strings. This matches the behavior of liquidjs and 
///   python-liquid implementations.
///
/// - Important: When the search string is empty (including nil converted to empty), the 
///   replacement is appended to the end of the input string.
///
/// - Warning: The filter requires exactly 2 parameters. Providing fewer or more parameters
///   will result in a TemplateSyntaxError.
///
/// - SeeAlso: ``ReplaceFilter`` - Replaces all occurrences
/// - SeeAlso: ``ReplaceFirstFilter`` - Replaces only the first occurrence
/// - SeeAlso: [LiquidJS replace_last](https://liquidjs.com/filters/replace_last.html)
/// - SeeAlso: [Shopify Liquid replace_last](https://shopify.github.io/liquid/filters/replace_last/)
@usableFromInline
package struct ReplaceLastFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "replace_last"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        // Validate parameter count - must have exactly 2 parameters
        guard parameters.count == 2 else {
            if parameters.isEmpty {
                throw TemplateSyntaxError("replace_last filter requires exactly 2 arguments")
            } else if parameters.count == 1 {
                throw TemplateSyntaxError("replace_last filter requires exactly 2 arguments")
            } else {
                throw TemplateSyntaxError("replace_last filter takes exactly 2 arguments")
            }
        }
        
        // Convert input to string - all types should be coerced to strings
        let inputString: String
        switch token {
        case .string(let str):
            inputString = str
        case .nil:
            // Nil values become empty strings
            inputString = ""
        case .bool(let b):
            // Boolean values become "true" or "false"
            inputString = b ? "true" : "false"
        case .integer(let i):
            // Integer values are converted to string
            inputString = String(i)
        case .decimal(let d):
            // Decimal values need special handling to match Liquid behavior
            // Use String(describing:) to get the most accurate representation
            inputString = String(describing: d)
        case .dictionary:
            // Dictionary becomes string representation "{}"
            inputString = "{}"
        case .array(let values):
            // Array becomes string representation like "[1, 2, 3]"
            let elements = values.map { value -> String in
                switch value {
                case .string(let s): return s
                case .integer(let i): return String(i)
                case .decimal(let d): return String(describing: d)
                case .bool(let b): return b ? "true" : "false"
                case .nil: return ""
                case .dictionary: return "{}"
                case .array: return "[]"
                case .range(let r): return "\(r.lowerBound)..\(r.upperBound)"
                }
            }
            inputString = "[" + elements.joined(separator: ", ") + "]"
        case .range(let r):
            // Range becomes "start..end"
            inputString = "\(r.lowerBound)..\(r.upperBound)"
        }
        
        // Extract and convert search parameter to string
        let searchString: String
        switch parameters[0] {
        case .string(let str):
            searchString = str
        case .nil:
            // Nil search parameter becomes empty string
            searchString = ""
        case .integer(let i):
            searchString = String(i)
        default:
            // All other types use their string value
            searchString = parameters[0].stringValue
        }
        
        // Extract and convert replacement parameter to string
        let replacementString: String
        switch parameters[1] {
        case .string(let str):
            replacementString = str
        case .nil:
            // Nil replacement parameter becomes empty string
            replacementString = ""
        case .integer(let i):
            replacementString = String(i)
        default:
            // All other types use their string value
            replacementString = parameters[1].stringValue
        }
        
        // If search string is empty, insert replacement at the end only
        if searchString.isEmpty {
            // Special behavior for empty search string:
            // For replace_last with empty search, we append the replacement at the end
            return .string(inputString + replacementString)
        }
        
        // Find the last occurrence of the search string
        var lastRange: Range<String.Index>? = nil
        var searchStartIndex = inputString.startIndex
        
        // Iterate through all occurrences to find the last one
        while searchStartIndex < inputString.endIndex {
            if let range = inputString.range(of: searchString, 
                                           options: [],
                                           range: searchStartIndex..<inputString.endIndex) {
                lastRange = range
                // Move past this occurrence to continue searching
                searchStartIndex = range.upperBound
            } else {
                // No more occurrences found
                break
            }
        }
        
        // If we found at least one occurrence, replace the last one
        if let range = lastRange {
            var result = inputString
            result.replaceSubrange(range, with: replacementString)
            return .string(result)
        }
        
        // No occurrence found, return original string
        return .string(inputString)
    }
}