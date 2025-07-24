import Foundation

/// Implements the `last` filter, which returns the last element of an array.
/// 
/// The `last` filter extracts the final element from arrays. When applied to an array, it
/// returns the last element. For empty arrays or non-array types (including strings), it 
/// returns nil. This behavior matches python-liquid and other Liquid implementations.
///
/// ## Examples
///
/// Basic array usage:
/// ```liquid
/// {{ arr | last }}
/// // With arr = ["a", "b", "c"], outputs: "c"
/// ```
///
/// String usage (returns nil):
/// ```liquid
/// {{ "hello" | last }}
/// // Outputs: "" (nil renders as empty string)
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
///
/// Non-array types return nil:
/// ```liquid
/// {{ 42 | last }}
/// // Outputs: "" (nil renders as empty string)
/// 
/// {{ hash | last }}
/// // With hash = {"a": 1, "b": 2}, outputs: "" (nil renders as empty string)
/// ```
///
/// - Important: This filter only operates on arrays. All non-array types (including strings,
///   numbers, booleans, dictionaries, and ranges) return nil, which matches the behavior
///   of python-liquid and ensures consistency across implementations.
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
        // The last filter only operates on arrays, returning the final element
        // All other types (including strings) return nil to match python-liquid behavior
        switch token {
        case .array(let array):
            // For arrays, return the last element if it exists
            // Empty arrays return nil
            return array.last ?? .nil
            
        case .string(_):
            // Strings are not treated as character arrays in python-liquid
            // They return nil when passed to the last filter
            return .nil
            
        case .integer(_), .decimal(_), .bool(_), .nil, .dictionary(_), .range(_):
            // All non-array types return nil
            // This includes numbers, booleans, dictionaries, and ranges
            return .nil
        }
    }
}