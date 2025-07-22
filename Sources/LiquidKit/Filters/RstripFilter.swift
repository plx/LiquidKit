import Foundation

/// Implements the `rstrip` filter, which removes all trailing whitespace from the right side of a string.
/// 
/// The `rstrip` filter strips whitespace characters from the end (right side) of a string,
/// leaving the beginning of the string intact. This includes spaces, tabs, newlines, and
/// carriage returns. The filter is useful for cleaning up user input or formatting text
/// where trailing whitespace needs to be removed while preserving any intentional leading
/// whitespace or indentation.
///
/// The filter accepts no parameters. Any parameters provided should cause an error in strict
/// Liquid implementations. For non-string input values, the filter returns the original value
/// unchanged, rendering it as a string representation in the output.
///
/// ## Examples
///
/// Basic trailing whitespace removal:
/// ```liquid
/// {{ "hello   " | rstrip }}
/// <!-- Output: "hello" -->
/// 
/// {{ "hello\t\n" | rstrip }}
/// <!-- Output: "hello" -->
/// ```
///
/// Preserving leading whitespace:
/// ```liquid
/// {{ "  hello  " | rstrip }}
/// <!-- Output: "  hello" -->
/// 
/// {{ "\t\r\n  hello  \t\r\n" | rstrip }}
/// <!-- Output: "\t\r\n  hello" -->
/// ```
///
/// Edge cases:
/// ```liquid
/// {{ "" | rstrip }}
/// <!-- Output: "" -->
/// 
/// {{ "   " | rstrip }}
/// <!-- Output: "" -->
/// 
/// {{ 5 | rstrip }}
/// <!-- Output: "5" -->
/// ```
///
/// - Important: The filter removes all types of Unicode whitespace from the right side,
///   including spaces, tabs (`\t`), newlines (`\n`), and carriage returns (`\r`). The
///   implementation uses a regular expression to identify and remove these characters,
///   which may include other Unicode whitespace characters beyond ASCII whitespace.
///
/// - Warning: This implementation accepts extra parameters without error, while strict
///   Liquid implementations should raise an error for unexpected arguments. The filter
///   returns non-string values unchanged rather than converting them to strings first,
///   which may differ from other implementations.
///
/// - SeeAlso: ``LstripFilter``, ``StripFilter``, ``StripNewlinesFilter``
/// - SeeAlso: [LiquidJS Documentation](https://liquidjs.com/filters/rstrip.html)
/// - SeeAlso: [Python Liquid Documentation](https://liquid.readthedocs.io/en/latest/filter_reference/#rstrip)
/// - SeeAlso: [Shopify Liquid Documentation](https://shopify.github.io/liquid/filters/rstrip/)
@usableFromInline
package struct RstripFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "rstrip"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard case .string(let string) = token else {
            return token
        }
        
        // Remove trailing whitespace
        let result = string.replacingOccurrences(of: "\\s+$", with: "", options: .regularExpression)
        return .string(result)
    }
}