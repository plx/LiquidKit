import Foundation

/// Implements the `concat` filter, which concatenates arrays together.
/// 
/// The `concat` filter combines two or more arrays into a single array by appending the elements
/// of the parameter arrays to the input array. The original arrays are not modified; a new array
/// is created containing all elements in the order they appear. This filter is essential for
/// combining data from multiple sources or building complex arrays from simpler components.
/// 
/// When the input is not an array, it is converted to a single-element array containing that value.
/// When the input is nil, it is treated as an empty array. Nested arrays in the input are flattened
/// before concatenation. Range values are expanded to arrays of their constituent integers.
/// 
/// The filter requires at least one array parameter. Non-array parameters will cause an error.
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
/// Non-array input is converted to array:
/// ```liquid
/// {{ "hello" | concat: world_array }}
/// <!-- If world_array is ["world"], output is ["hello", "world"] -->
/// ```
/// 
/// - Important: The filter requires at least one parameter, and all parameters must be arrays.
///   Non-array parameters will cause a filter error.
/// 
/// - Important: Nested arrays in the input are flattened before concatenation.
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
        // Step 1: Validate that we have at least one parameter
        guard !parameters.isEmpty else {
            throw FilterError.improperParameters("concat filter requires at least one parameter")
        }
        
        // Step 2: Convert the input token to an array
        // - If it's nil, treat as empty array
        // - If it's an array, use it (will be flattened later)
        // - If it's a range, convert to array of integers
        // - Otherwise, wrap in a single-element array
        let inputArray: [Token.Value]
        switch token {
        case .nil:
            inputArray = []
        case .array(let array):
            inputArray = array
        case .range(let range):
            // Convert range to array of integers
            inputArray = range.map { .integer($0) }
        default:
            // Wrap non-array values in an array
            inputArray = [token]
        }
        
        // Step 3: Flatten the input array recursively
        // This handles nested arrays like [["a", "x"], ["b", ["y", ["z"]]]]
        var result = flattenArray(inputArray)
        
        // Step 4: Process each parameter
        for parameter in parameters {
            switch parameter {
            case .array(let otherArray):
                // Append the contents of the parameter array to our result
                result.append(contentsOf: otherArray)
            case .nil:
                // nil parameters are an error
                throw FilterError.invalidArgument("concat filter cannot concatenate with nil")
            default:
                // Non-array parameters are an error
                throw FilterError.invalidArgument("concat filter requires array parameters")
            }
        }
        
        return .array(result)
    }
    
    /// Recursively flattens an array, converting any nested arrays into a flat list
    /// For example: [["a", "x"], ["b", ["y", ["z"]]]] becomes ["a", "x", "b", "y", "z"]
    @usableFromInline
    internal func flattenArray(_ array: [Token.Value]) -> [Token.Value] {
        var flattened: [Token.Value] = []
        
        for element in array {
            if case .array(let nestedArray) = element {
                // Recursively flatten nested arrays
                flattened.append(contentsOf: flattenArray(nestedArray))
            } else {
                // Non-array elements are added directly
                flattened.append(element)
            }
        }
        
        return flattened
    }
}