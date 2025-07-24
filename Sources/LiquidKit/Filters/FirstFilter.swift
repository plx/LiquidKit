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
/// Non-collection types:
/// ```liquid
/// {{ 42 | first }}
/// // Outputs: "" (nil renders as empty string)
/// 
/// {{ true | first }}
/// // Outputs: "" (nil renders as empty string)
/// ```
///
/// - Important: When applied to non-collection types (numbers, booleans, dictionaries, ranges),
///   this filter returns nil, which matches the behavior of other Liquid implementations like
///   liquidjs and python-liquid.
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
        // The first filter extracts the initial element from collections
        switch token {
        case .array(let array):
            // For arrays, return the first element if it exists, otherwise nil
            return array.first ?? .nil
            
        case .string(let string):
            // For strings, return the first character as a single-character string
            if let firstCharacter = string.first {
                return .string(String(firstCharacter))
            } else {
                // Empty strings return nil
                return .nil
            }
            
        default:
            // Non-collection types (integers, decimals, booleans, nil, dictionaries, ranges)
            // return nil, which matches the behavior of liquidjs and python-liquid
            return .nil
        }
    }
}