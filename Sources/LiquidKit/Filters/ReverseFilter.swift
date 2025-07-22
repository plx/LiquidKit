import Foundation

/// Implements the `reverse` filter, which reverses the order of elements in an array or characters in a string.
/// 
/// The `reverse` filter inverts the order of items in a collection. When applied to an array,
/// it returns a new array with elements in reverse order. When applied to a string, it returns
/// a new string with characters in reverse order. This filter is particularly useful for
/// displaying lists in reverse chronological order or for string manipulation tasks.
///
/// The filter accepts no parameters. If any parameters are provided, they are ignored in this
/// implementation, though strict Liquid implementations may raise errors for unexpected arguments.
/// For non-array and non-string input values, the filter returns the original value unchanged.
///
/// ## Examples
///
/// Reversing an array:
/// ```liquid
/// {% assign fruits = "apple,banana,cherry" | split: "," %}
/// {{ fruits | reverse | join: ", " }}
/// <!-- Output: "cherry, banana, apple" -->
/// ```
///
/// Reversing a string:
/// ```liquid
/// {{ "hello" | reverse }}
/// <!-- Output: "olleh" -->
/// ```
///
/// Empty collections:
/// ```liquid
/// {{ "" | reverse }}
/// <!-- Output: "" -->
/// 
/// {% assign empty_array = "" | split: "," %}
/// {{ empty_array | reverse | join: "," }}
/// <!-- Output: "" -->
/// ```
///
/// Non-collection values pass through unchanged:
/// ```liquid
/// {{ 123 | reverse }}
/// <!-- Output: "123" -->
/// 
/// {{ true | reverse }}
/// <!-- Output: "true" -->
/// ```
///
/// - Important: When reversing strings, the filter operates on individual characters, not
///   grapheme clusters. This means complex Unicode characters (like emoji with modifiers)
///   may not reverse as expected. The implementation uses Swift's native string reversal,
///   which handles most common cases correctly.
///
/// - Warning: While this implementation ignores extra parameters, the strict Liquid
///   specification considers unexpected parameters an error. Code relying on this lenient
///   behavior may not be portable to other Liquid implementations.
///
/// - SeeAlso: ``SortFilter``, ``JoinFilter``
/// - SeeAlso: [LiquidJS Documentation](https://liquidjs.com/filters/reverse.html)
/// - SeeAlso: [Python Liquid Documentation](https://liquid.readthedocs.io/en/latest/filter_reference/#reverse)
/// - SeeAlso: [Shopify Liquid Documentation](https://shopify.github.io/liquid/filters/reverse/)
@usableFromInline
package struct ReverseFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "reverse"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        switch token {
        case .array(let array):
            return .array(array.reversed())
        case .string(let string):
            return .string(String(string.reversed()))
        default:
            return token
        }
    }
}