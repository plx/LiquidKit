import Foundation

/// Implements the `split` filter, which divides a string into an array using a separator.
///
/// The `split` filter breaks a string into an array of substrings based on a delimiter.
/// This is commonly used to convert comma-separated values or other delimited strings
/// into arrays that can be iterated over or further processed.
///
/// When the separator is an empty string or omitted, the filter splits the input into
/// individual characters. When the separator is not found in the input string, the filter
/// returns an array containing the original string as its only element. The filter preserves
/// empty strings that result from consecutive separators.
///
/// ## Separator Behavior
/// 
/// - **No separator**: If the separator parameter is omitted, the input is split into
///   individual characters (matching python-liquid behavior)
/// - **Empty separator**: Explicitly passing an empty string also splits into characters
/// - **nil separator**: Treated as an empty separator (splits into characters)
/// - **Non-string separator**: Automatically converted to its string representation
///
/// ## Type Conversion
///
/// Non-string inputs are automatically converted to their string representation before
/// splitting:
/// - **Numbers**: Converted to their decimal representation
/// - **Booleans**: Converted to "true" or "false"
/// - **nil**: Returns nil without splitting
/// - **Arrays**: Rendered as "[]"
/// - **Dictionaries**: Rendered as "{}"
/// - **Ranges**: Rendered as "start..end" format
///
/// ## Examples
///
/// Basic string splitting:
/// ```liquid
/// {% assign beatles = "John, Paul, George, Ringo" | split: ", " %}
/// {% for member in beatles %}
///   {{ member }}
/// {% endfor %}
/// // Output: John Paul George Ringo
/// ```
///
/// Split by different delimiters:
/// ```liquid
/// {{ "Hello there" | split: " " | join: "#" }}
/// // Output: "Hello#there"
///
/// {{ "Hi, how are you today?" | split: " " | join: "#" }}
/// // Output: "Hi,#how#are#you#today?"
/// ```
///
/// Split into individual characters:
/// ```liquid
/// {{ "Hello" | split: "" | join: "#" }}
/// // Output: "H#e#l#l#o"
///
/// {{ "Hello" | split | join: "#" }}
/// // Output: "H#e#l#l#o" (no separator = split into characters)
/// ```
///
/// Edge cases:
/// ```liquid
/// {{ "hello##there" | split: "#" | join: "-" }}
/// // Output: "hello--there" (preserves empty strings)
///
/// {{ "no-delimiter" | split: "," | first }}
/// // Output: "no-delimiter" (returns whole string in array)
///
/// {{ 12345 | split: "" | join: "-" }}
/// // Output: "1-2-3-4-5" (converts number to string first)
/// ```
///
/// - SeeAlso: ``JoinFilter``, ``FirstFilter``, ``LastFilter``
/// - SeeAlso: [Shopify Liquid split](https://shopify.github.io/liquid/filters/split/)
/// - SeeAlso: [LiquidJS split](https://liquidjs.com/filters/split.html)
/// - SeeAlso: [Python Liquid split](https://liquid.readthedocs.io/en/latest/filter_reference/#split)
@usableFromInline
package struct SplitFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "split"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        // Step 1: Convert the input token to a string
        // Non-string values need to be converted to their string representation first
        // This matches the behavior of liquidjs and python-liquid
        let string: String
        switch token {
        case .string(let s):
            // String values pass through unchanged
            string = s
        case .integer(let i):
            // Convert integers to their decimal representation
            string = String(i)
        case .decimal(let d):
            // Convert decimals using String(describing:) to preserve precision
            string = String(describing: d)
        case .bool(let b):
            // Convert booleans to "true" or "false"
            string = b ? "true" : "false"
        case .nil:
            // Special case: nil values should return nil, not be split
            return .nil
        case .dictionary:
            // Dictionaries render as "{}" in Liquid
            string = "{}"
        case .array:
            // Arrays render as "[]" in Liquid
            string = "[]"
        case .range(let r):
            // Ranges render as "start..end" format
            string = "\(r.lowerBound)..\(r.upperBound)"
        }
        
        // Step 2: Determine the separator
        // If no parameter is provided, split into individual characters (python-liquid behavior)
        let separator: String
        if parameters.isEmpty {
            // No separator provided - split into characters
            separator = ""
        } else {
            // Convert the separator parameter to string using the same logic
            let sepValue = parameters[0]
            switch sepValue {
            case .string(let s):
                separator = s
            case .integer(let i):
                separator = String(i)
            case .decimal(let d):
                separator = String(describing: d)
            case .bool(let b):
                separator = b ? "true" : "false"
            case .nil:
                // nil separator is treated as empty string (split into characters)
                separator = ""
            case .dictionary:
                separator = "{}"
            case .array:
                separator = "[]"
            case .range(let r):
                separator = "\(r.lowerBound)..\(r.upperBound)"
            }
        }
        
        // Step 3: Perform the split operation
        if separator.isEmpty {
            // Empty separator means split into individual characters
            // This handles both explicit empty string and missing separator cases
            let characters = string.map { Token.Value.string(String($0)) }
            return .array(characters)
        } else {
            // Split by the provided separator
            // components(separatedBy:) preserves empty strings between consecutive separators
            let parts = string.components(separatedBy: separator).map { Token.Value.string($0) }
            return .array(parts)
        }
    }
}