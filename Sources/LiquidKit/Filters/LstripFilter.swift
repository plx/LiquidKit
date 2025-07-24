import Foundation

/// Implements the `lstrip` filter, which removes whitespace characters from the beginning of a string.
/// 
/// The `lstrip` filter strips all leading whitespace characters from a string, including spaces,
/// tabs (`\t`), newlines (`\n`), and carriage returns (`\r`). The filter only affects the
/// beginning of the string, leaving trailing whitespace and internal whitespace untouched. This
/// is useful for cleaning up user input or formatting text alignment.
///
/// ## Examples
///
/// Basic usage:
/// ```liquid
/// {{ "  hello" | lstrip }}
/// // Outputs: "hello"
/// ```
///
/// Multiple whitespace types:
/// ```liquid
/// {{ " \t\r\n  hello  \t\r\n " | lstrip }}
/// // Outputs: "hello  \t\r\n "
/// ```
///
/// No leading whitespace:
/// ```liquid
/// {{ "hello world" | lstrip }}
/// // Outputs: "hello world"
/// ```
///
/// Only trailing whitespace:
/// ```liquid
/// {{ "hello \t\r\n  " | lstrip }}
/// // Outputs: "hello \t\r\n  "
/// ```
///
/// Non-string input:
/// ```liquid
/// {{ 5 | lstrip }}
/// // Outputs: "5"
/// ```
///
/// Empty or all-whitespace string:
/// ```liquid
/// {{ "   " | lstrip }}
/// // Outputs: ""
/// ```
///
/// - Important: The filter removes all Unicode whitespace characters as defined by
///   `CharacterSet.whitespacesAndNewlines`, which includes more than just ASCII spaces.
///
/// - Important: Non-string values are converted to their string representation first. If the
///   input is nil or undefined, an empty string is returned.
///
/// - Warning: The filter does not accept any arguments. Providing arguments (e.g., `{{ "hello" | lstrip: 5 }}`)
///   will cause an error in strict Liquid implementations.
///
/// - SeeAlso: ``RstripFilter`` for removing trailing whitespace
/// - SeeAlso: ``StripFilter`` for removing both leading and trailing whitespace
/// - SeeAlso: ``StripNewlinesFilter`` for removing only newline characters
/// - SeeAlso: [LiquidJS lstrip filter](https://liquidjs.com/filters/lstrip.html)
/// - SeeAlso: [Python Liquid lstrip filter](https://liquid.readthedocs.io/en/latest/filter_reference/#lstrip)
/// - SeeAlso: [Shopify Liquid lstrip filter](https://shopify.github.io/liquid/filters/lstrip/)
@usableFromInline
package struct LstripFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "lstrip"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        // Convert the input token to a string representation
        // This matches liquidjs and python-liquid behavior where non-string values
        // are converted to strings before stripping
        let stringValue: String
        switch token {
        case .bool(let value):
            // Boolean values should be converted to "true" or "false" strings
            // to match liquidjs and python-liquid behavior
            stringValue = value ? "true" : "false"
        default:
            // For all other types, use the standard stringValue property
            // This handles nil, integer, decimal, string, array, etc.
            stringValue = token.stringValue
        }
        
        // Use Foundation's CharacterSet to identify whitespace and newlines
        let charset = CharacterSet.whitespacesAndNewlines
        
        // Find the first index where the character is NOT whitespace
        let firstNonWhitespaceIndex = stringValue.firstIndex { char in
            // For each character, check if all its unicode scalars are non-whitespace
            // This handles multi-scalar characters properly
            return char.unicodeScalars.allSatisfy { scalar in
                !charset.contains(scalar)
            }
        }
        
        // If we found a non-whitespace character, return the substring from that point
        if let index = firstNonWhitespaceIndex {
            return .string(String(stringValue[index...]))
        } else {
            // If the string is all whitespace or empty, return an empty string
            // This matches the behavior of liquidjs and python-liquid
            return .string("")
        }
    }
}