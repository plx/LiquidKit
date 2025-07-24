import Foundation

/// Implements the `strip` filter, which removes whitespace from both ends of a string.
///
/// The `strip` filter removes all leading and trailing whitespace characters from a string,
/// including spaces, tabs, newlines, and carriage returns. Non-string values are first
/// converted to their string representation before stripping. The filter does not affect
/// whitespace within the string - only whitespace at the beginning and end is removed.
/// This is useful for cleaning up user input or formatting text that may have unwanted
/// padding.
///
/// The filter uses Foundation's `trimmingCharacters(in:)` method with the
/// `.whitespacesAndNewlines` character set, which includes space (U+0020), tab (U+0009),
/// newline (U+000A), form feed (U+000C), carriage return (U+000D), and other Unicode
/// whitespace characters.
///
/// ## Examples
///
/// Basic whitespace removal:
/// ```liquid
/// {{ "  Hello World  " | strip }}
/// // Output: "Hello World"
/// ```
///
/// Multiple types of whitespace:
/// ```liquid
/// {{ " \t\r\n  hello  \t\r\n " | strip }}
/// // Output: "hello"
/// ```
///
/// Preserving internal whitespace:
/// ```liquid
/// {{ "  So much room for activities  " | strip }}!
/// // Output: "So much room for activities!"
/// ```
///
/// Edge cases:
/// ```liquid
/// {{ "" | strip }}                    // Output: "" (empty string)
/// {{ "no-whitespace" | strip }}       // Output: "no-whitespace" (unchanged)
/// {{ "   " | strip }}                 // Output: "" (all whitespace)
/// {{ 123 | strip }}                   // Output: "123" (converts to string first)
/// {{ true | strip }}                  // Output: "true" (boolean conversion)
/// {{ false | strip }}                 // Output: "false" (boolean conversion)
/// ```
///
/// - Important: The filter only removes whitespace from the beginning and end of the
///   string. Internal whitespace between words is preserved.
///
/// - Warning: The filter does not accept any parameters. Passing parameters will result
///   in an error according to the Liquid specification.
///
/// - SeeAlso: ``LstripFilter``, ``RstripFilter``, ``StripNewlinesFilter``
/// - SeeAlso: [Shopify Liquid strip](https://shopify.github.io/liquid/filters/strip/)
/// - SeeAlso: [LiquidJS strip](https://liquidjs.com/filters/strip.html)
/// - SeeAlso: [Python Liquid strip](https://liquid.readthedocs.io/en/latest/filter_reference/#strip)
@usableFromInline
package struct StripFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "strip"
    
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
            stringValue = token.stringValue
        }
        
        // Remove leading and trailing whitespace characters
        // Uses Foundation's .whitespacesAndNewlines character set which includes:
        // - Space (U+0020)
        // - Tab (U+0009)
        // - Newline (U+000A)
        // - Form feed (U+000C)
        // - Carriage return (U+000D)
        // - Various Unicode whitespace characters like non-breaking space (U+00A0)
        let strippedString = stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Return the stripped string as a Token.Value.string
        return .string(strippedString)
    }
}