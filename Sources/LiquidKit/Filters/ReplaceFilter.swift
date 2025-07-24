import Foundation

/// Implements the `replace` filter, which replaces all occurrences of a substring with another string.
/// 
/// The `replace` filter performs a global search-and-replace operation, replacing every 
/// occurrence of the search string with the replacement string. This is one of the most 
/// commonly used string manipulation filters in Liquid templates, useful for text 
/// transformation, URL manipulation, and data cleaning tasks.
/// 
/// The filter requires at least one parameter (the string to search for). The second 
/// parameter (replacement string) is optional and defaults to an empty string, effectively 
/// removing the search string. The search is case-sensitive and does not support regular 
/// expressions - it performs literal string matching only.
/// 
/// - Example: Basic replacement
/// ```liquid
/// {{ "Take my protein pills and put my helmet on" | replace: "my", "your" }}
/// <!-- Output: Take your protein pills and put your helmet on -->
/// 
/// {{ "Hello world" | replace: "world", "Liquid" }}
/// <!-- Output: Hello Liquid -->
/// ```
/// 
/// - Example: Multiple occurrences
/// ```liquid
/// {{ "red, red, red" | replace: "red", "blue" }}
/// <!-- Output: blue, blue, blue -->
/// 
/// {{ "1.1.1.1" | replace: ".", "-" }}
/// <!-- Output: 1-1-1-1 -->
/// ```
/// 
/// - Example: Removing substrings (missing second parameter)
/// ```liquid
/// {{ "Hello world" | replace: " " }}
/// <!-- Output: Helloworld -->
/// 
/// {{ "remove-dashes" | replace: "-" }}
/// <!-- Output: removedashes -->
/// ```
/// 
/// - Example: Empty search string behavior
/// ```liquid
/// {{ "test" | replace: "", "X" }}
/// <!-- Output: XtXeXsXtX (inserts X between each character) -->
/// ```
/// 
/// - Example: Type conversion
/// ```liquid
/// {{ 5 | replace: "5", "five" }}
/// <!-- Output: five (converts number to string) -->
/// 
/// {{ "hello5world" | replace: 5, "five" }}
/// <!-- Output: hellofiveworld (converts parameter to string) -->
/// ```
/// 
/// - Important: The filter replaces ALL occurrences of the search string, not just the first
///   one. Use `replace_first` if you only need to replace the first occurrence.
/// 
/// - Important: All non-string inputs and parameters are automatically converted to strings.
///   Nil values are treated as empty strings. This matches the behavior of liquidjs and 
///   python-liquid implementations.
/// 
/// - Important: When the search string is empty (including nil converted to empty), the 
///   replacement is inserted between every character in the input string.
/// 
/// - Warning: Be careful when replacing common substrings as they will be replaced everywhere
///   they appear, including within larger words. For example, replacing "cat" in "category"
///   would result in "egory".
/// 
/// - SeeAlso: ``ReplaceFirstFilter`` - Replaces only the first occurrence
/// - SeeAlso: ``RemoveFilter`` - Removes substrings (equivalent to replacing with empty string)
/// - SeeAlso: [LiquidJS replace](https://liquidjs.com/filters/replace.html)
/// - SeeAlso: [Python Liquid replace](https://liquid.readthedocs.io/en/latest/filter_reference/#replace)
/// - SeeAlso: [Shopify Liquid replace](https://shopify.github.io/liquid/filters/replace/)
@usableFromInline
package struct ReplaceFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "replace"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        // Validate parameter count - must have at least 1 parameter (search string)
        guard !parameters.isEmpty else {
            throw TemplateSyntaxError("replace filter requires at least one argument")
        }
        
        // Validate parameter count - must not have more than 2 parameters
        guard parameters.count <= 2 else {
            throw TemplateSyntaxError("replace filter takes at most 2 arguments")
        }
        
        // Convert input to string - all types should be coerced to strings
        let inputString: String
        switch token {
        case .string(let str):
            inputString = str
        case .nil:
            // Nil values become empty strings
            inputString = ""
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
        default:
            // For all other types, use their string representation
            inputString = token.stringValue
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
        
        // Extract and convert replacement parameter to string (defaults to empty if missing)
        let replacementString: String
        if parameters.count >= 2 {
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
        } else {
            // Missing second parameter defaults to empty string (removes the substring)
            replacementString = ""
        }
        
        // If search string is empty, insert replacement between every character
        if searchString.isEmpty {
            // Special behavior: empty search string matches between every character
            let characters = Array(inputString)
            let result = characters.map { String($0) }.joined(separator: replacementString)
            // Also prepend the replacement string at the beginning
            return .string(replacementString + result + (characters.isEmpty ? "" : replacementString))
        }
        
        // Perform the replacement
        return .string(inputString.replacingOccurrences(of: searchString, with: replacementString))
    }
}