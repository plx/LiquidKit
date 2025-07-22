import Foundation

/// Implements the `concat` filter, which concatenates arrays together.
/// 
/// The `concat` filter combines two or more arrays into a single array by appending the elements
/// of the parameter arrays to the input array. The original arrays are not modified; a new array
/// is created containing all elements in the order they appear. This filter is essential for
/// combining data from multiple sources or building complex arrays from simpler components.
/// 
/// When the input is not an array, the filter returns it unchanged. When parameters are provided
/// that are not arrays, they are ignored. This makes the filter safe to use in chains where
/// data types might vary.
/// 
/// The filter can accept multiple array parameters, concatenating them all in the order provided.
/// Each array parameter is appended to the result of the previous concatenation.
/// 
/// ## Examples
/// 
/// Basic concatenation of two arrays:
/// ```liquid
/// {% assign fruits = "apples, oranges" | split: ", " %}
/// {% assign vegetables = "carrots, turnips" | split: ", " %}
/// {% assign produce = fruits | concat: vegetables %}
/// {{ produce | join: ", " }}
/// <!-- Output: apples, oranges, carrots, turnips -->
/// ```
/// 
/// Concatenating multiple arrays:
/// ```liquid
/// {% assign all = fruits | concat: vegetables | concat: grains %}
/// ```
/// 
/// Using with dynamic data:
/// ```liquid
/// {% assign all_products = electronics | concat: clothing | concat: books %}
/// {{ all_products | size }} total products
/// ```
/// 
/// - Important: Non-array parameters are silently ignored rather than causing errors.
///   This allows for flexible usage but may hide data type issues.
/// 
/// - Important: The concatenation creates a new array; the original arrays remain unchanged.
/// 
/// - SeeAlso: ``AppendFilter``
/// - SeeAlso: ``PrependFilter``
/// - SeeAlso: ``JoinFilter``
/// - SeeAlso: [Shopify Liquid concat](https://shopify.github.io/liquid/filters/concat/)
/// - SeeAlso: [LiquidJS concat](https://liquidjs.com/filters/concat.html)
@usableFromInline
package struct ConcatFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "concat"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard case .array(let array) = token else {
            return token
        }
        
        guard !parameters.isEmpty else {
            return token
        }
        
        var result = array
        
        for parameter in parameters {
            if case .array(let otherArray) = parameter {
                result.append(contentsOf: otherArray)
            }
        }
        
        return .array(result)
    }
}