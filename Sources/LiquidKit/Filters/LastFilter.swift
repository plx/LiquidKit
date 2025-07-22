import Foundation

/// Implements the `last` filter, which returns the last element of an array or character of a string.
/// 
/// The `last` filter extracts the final element from collections. When applied to an array, it
/// returns the last element. When applied to a string, it returns the last character as a
/// single-character string. For empty collections or non-collection types, it returns nil.
///
/// ## Examples
///
/// Basic array usage:
/// ```liquid
/// {{ arr | last }}
/// // With arr = ["a", "b", "c"], outputs: "c"
/// ```
///
/// String usage:
/// ```liquid
/// {{ "hello" | last }}
/// // Outputs: "o"
/// ```
///
/// Mixed array types:
/// ```liquid
/// {{ arr | last }}
/// // With arr = ["a", 1, true], outputs: "true"
/// ```
///
/// Empty array:
/// ```liquid
/// {{ arr | last }}
/// // With arr = [], outputs: ""
/// ```
///
/// Range usage:
/// ```liquid
/// {{ (1..5) | last }}
/// // Outputs: "5"
/// ```
///
/// Hash/dictionary usage:
/// ```liquid
/// {{ hash | last }}
/// // With hash = {"a": 1, "b": 2}, may output: "2" or the last value based on iteration order
/// ```
///
/// - Important: When applied to a hash/dictionary, `last` behavior may vary between implementations.
///   Some return the last key-value pair as an array, others return just the value. The order
///   depends on the underlying hash implementation.
///
/// - Important: Unlike some Liquid implementations, this filter returns an empty string representation
///   when applied to non-collection types (like numbers) rather than the value itself.
///
/// - SeeAlso: ``FirstFilter`` for getting the first element
/// - SeeAlso: [LiquidJS last filter](https://liquidjs.com/filters/last.html)
/// - SeeAlso: [Python Liquid last filter](https://liquid.readthedocs.io/en/latest/filter_reference/#last)
/// - SeeAlso: [Shopify Liquid last filter](https://shopify.github.io/liquid/filters/last/)
@usableFromInline
package struct LastFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "last"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        switch token {
        case .array(let array):
            return array.last ?? .nil
        case .string(let string):
            if let lastCharacter = string.last {
                return .string(String(lastCharacter))
            } else {
                return .nil
            }
        default:
            return .nil
        }
    }
}