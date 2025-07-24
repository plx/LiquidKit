import Foundation

/// Implements the `size` filter, which returns the number of items in a collection or characters in a string.
/// 
/// The `size` filter counts elements in different types of values. For arrays, it returns the
/// number of elements. For dictionaries (hashes), it returns the number of key-value pairs.
/// For strings, it returns the number of characters. This filter is essential for conditional
/// logic based on collection sizes and for displaying counts in templates.
///
/// The filter accepts no parameters. Any value that is not a collection or string returns 0.
/// This includes nil/undefined values, numbers, booleans, and other scalar types. The filter
/// provides a safe way to check sizes without worrying about the input type.
///
/// ## Examples
///
/// Array size:
/// ```liquid
/// {% assign fruits = "apple,banana,cherry" | split: "," %}
/// {{ fruits | size }}
/// <!-- Output: "3" -->
/// 
/// {% assign empty = "" | split: "," %}
/// {{ empty | size }}
/// <!-- Output: "0" -->
/// ```
///
/// String length:
/// ```liquid
/// {{ "hello" | size }}
/// <!-- Output: "5" -->
/// 
/// {{ "" | size }}
/// <!-- Output: "0" -->
/// ```
///
/// Dictionary size:
/// ```liquid
/// {% assign user = "name:John,age:30" | split: "," | map: "split:" %}
/// {{ user | size }}
/// <!-- Output: "2" -->
/// ```
///
/// Non-collection values:
/// ```liquid
/// {{ 123 | size }}
/// <!-- Output: "0" -->
/// 
/// {{ true | size }}
/// <!-- Output: "0" -->
/// 
/// {{ nil | size }}
/// <!-- Output: "0" -->
/// ```
///
/// - Important: For strings, the size is the character count, not the byte count. This means
///   multi-byte Unicode characters (like emoji) are counted as single characters. The count
///   is based on Swift's String.count property, which counts extended grapheme clusters.
///
/// - Warning: Strict Liquid implementations should raise an error when parameters are provided
///   to this filter. This implementation may ignore extra parameters, which could lead to
///   portability issues. Always use the filter without parameters for maximum compatibility.
///
/// - SeeAlso: ``FirstFilter``, ``LastFilter``, ``WhereFilter``
/// - SeeAlso: [LiquidJS Documentation](https://liquidjs.com/filters/size.html)
/// - SeeAlso: [Python Liquid Documentation](https://liquid.readthedocs.io/en/latest/filter_reference/#size)
/// - SeeAlso: [Shopify Liquid Documentation](https://shopify.github.io/liquid/filters/size/)
@usableFromInline
package struct SizeFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "size"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        // The size filter ignores all parameters - it only operates on the input value
        // This matches the behavior of liquidjs and python-liquid
        
        switch token {
        case .array(let array):
            // For arrays, return the number of elements
            // This counts all elements regardless of their type (including nil values)
            return .integer(array.count)
            
        case .dictionary(let dictionary):
            // For dictionaries/hashes, return the number of key-value pairs
            // This matches how liquidjs and python-liquid handle objects/hashes
            return .integer(dictionary.count)
            
        case .string(let string):
            // For strings, return the number of characters (not bytes)
            // Swift's String.count returns the number of extended grapheme clusters,
            // which correctly handles Unicode characters like emoji as single characters
            // This matches the character counting behavior of liquidjs and python-liquid
            return .integer(string.count)
            
        default:
            // For all non-collection types (nil, integers, decimals, booleans, ranges),
            // return 0 as the size. This behavior matches other Liquid implementations
            // where only strings, arrays, and hashes have a meaningful size
            return .integer(0)
        }
    }
}