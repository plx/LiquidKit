import Foundation

/// Implements the `reverse` filter, which reverses the order of elements in an array.
/// 
/// The `reverse` filter inverts the order of items in an array, returning a new array with
/// elements in reverse order. When applied to strings or other non-array values, they are
/// returned unchanged. This behavior matches the standard Liquid implementations in LiquidJS,
/// Shopify Liquid, and Python Liquid.
///
/// The filter accepts no parameters. If any parameters are provided, they are ignored in this
/// implementation, though strict Liquid implementations may raise errors for unexpected arguments.
/// For non-array input values (including strings), the filter returns the original value unchanged.
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
/// Strings are not reversed directly:
/// ```liquid
/// {{ "hello" | reverse }}
/// <!-- Output: "hello" -->
/// ```
///
/// To reverse a string, split it into an array first:
/// ```liquid
/// {{ "hello" | split: "" | reverse | join: "" }}
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
/// Non-array values pass through unchanged:
/// ```liquid
/// {{ 123 | reverse }}
/// <!-- Output: "123" -->
/// 
/// {{ true | reverse }}
/// <!-- Output: "true" -->
/// 
/// {{ "test string" | reverse }}
/// <!-- Output: "test string" -->
/// ```
///
/// - Important: This filter only reverses arrays. Strings and other non-array values are
///   returned unchanged. To reverse a string, you must first split it into an array of
///   characters using the `split` filter, then reverse the array, and finally join it
///   back together using the `join` filter.
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
            // Reverse the array elements and return a new array
            return .array(array.reversed())
        case .string(_):
            // Strings pass through unchanged to match LiquidJS/Shopify behavior
            // To reverse a string, users should: string | split: "" | reverse | join: ""
            return token
        default:
            // All other types pass through unchanged
            return token
        }
    }
}