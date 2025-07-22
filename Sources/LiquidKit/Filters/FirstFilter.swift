import Foundation

/// Implements the `first` filter, which returns the first element of an array or character of a string.
/// 
/// The `first` filter is commonly used to extract the initial element from collections. When applied to an
/// array, it returns the first element. When applied to a string, it returns the first character as a
/// single-character string. For empty collections or non-collection types, it returns nil.
///
/// ## Examples
///
/// Basic array usage:
/// ```liquid
/// {{ arr | first }}
/// // With arr = ["a", "b", "c"], outputs: "a"
/// ```
///
/// String usage:
/// ```liquid
/// {{ "hello" | first }}
/// // Outputs: "h"
/// ```
///
/// Mixed array types:
/// ```liquid
/// {{ arr | first }}
/// // With arr = ["a", 1, true], outputs: "a"
/// ```
///
/// Empty array:
/// ```liquid
/// {{ arr | first }}
/// // With arr = [], outputs: ""
/// ```
///
/// Range usage:
/// ```liquid
/// {{ (1..5) | first }}
/// // Outputs: "1"
/// ```
///
/// Hash/dictionary usage:
/// ```liquid
/// {% assign x = hash | first %}({{ x[0] }},{{ x[1] }})
/// // With hash = {"b": 1, "c": 2}, outputs: "(b,1)" or "(c,2)" depending on iteration order
/// ```
///
/// - Important: When applied to a hash/dictionary, `first` returns the first key-value pair as a
///   two-element array `[key, value]`. The order depends on the underlying hash implementation
///   and may not be predictable.
///
/// - Important: Unlike some Liquid implementations, this filter returns an empty string representation
///   when applied to non-collection types (like numbers) rather than the value itself.
///
/// - SeeAlso: ``LastFilter`` for getting the last element
/// - SeeAlso: [LiquidJS first filter](https://liquidjs.com/filters/first.html)
/// - SeeAlso: [Python Liquid first filter](https://liquid.readthedocs.io/en/latest/filter_reference/#first)
/// - SeeAlso: [Shopify Liquid first filter](https://shopify.github.io/liquid/filters/first/)
@usableFromInline
package struct FirstFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "first"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        switch token {
        case .array(let array):
            return array.first ?? .nil
        case .string(let string):
            if let firstCharacter = string.first {
                return .string(String(firstCharacter))
            } else {
                return .nil
            }
        default:
            return .nil
        }
    }
}