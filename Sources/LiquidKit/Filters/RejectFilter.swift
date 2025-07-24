import Foundation

/// Implements the `reject` filter, which removes items from an array based on a property test.
/// 
/// The `reject` filter creates a new array containing only the elements that fail a specified
/// test. It's the opposite of the `where` filter. When used with one parameter, it removes
/// items where the specified property is truthy. When used with two parameters, it removes
/// items where the property equals the specified value.
/// 
/// The filter is primarily designed for arrays of objects (dictionaries), where it tests
/// properties within each object. However, it also handles arrays of simple values by
/// comparing them directly against the filter parameter. Non-array inputs are treated as
/// single-element arrays, except for nil which returns an empty array.
/// 
/// - Example: Reject items with truthy property
/// ```liquid
/// {% assign products = site.products %}
/// {{ products | reject: "available" }}
/// <!-- Removes all products where available is true -->
/// 
/// {{ products | reject: "featured" | map: "title" | join: ", " }}
/// <!-- Lists titles of non-featured products -->
/// ```
/// 
/// - Example: Reject items by property value
/// ```liquid
/// {{ products | reject: "type", "shoes" }}
/// <!-- Removes all products where type equals "shoes" -->
/// 
/// {{ products | reject: "status", "sold_out" | map: "name" }}
/// <!-- Lists names of products that are not sold out -->
/// ```
/// 
/// - Example: Reject from simple arrays
/// ```liquid
/// {% assign colors = "red,blue,red,green" | split: "," %}
/// {{ colors | reject: "red" | join: ", " }}
/// <!-- Output: blue, green -->
/// ```
/// 
/// - Important: When filtering dictionaries without the specified property, those items are
///   kept in the result (not rejected). This behavior ensures that missing properties are
///   treated as falsy rather than causing items to be filtered out.
/// 
/// - Note: In LiquidKit, only `nil` and `false` are considered falsy. All other values,
///   including `0`, empty strings, and empty arrays, are considered truthy. This differs
///   from some other Liquid implementations where `0` might be considered falsy.
/// 
/// - SeeAlso: ``WhereFilter`` - The opposite filter that keeps matching items
/// - SeeAlso: ``SelectFilter`` - Alias for the where filter
/// - SeeAlso: [LiquidJS reject](https://liquidjs.com/filters/reject.html)
/// - SeeAlso: [Python Liquid reject](https://liquid.readthedocs.io/en/latest/filter_reference/#reject)
/// - SeeAlso: [Shopify Liquid reject](https://shopify.github.io/liquid/filters/reject/)
@usableFromInline
package struct RejectFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "reject"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        // Step 1: Handle different input types to create an array to filter
        let arrayToFilter: [Token.Value]
        switch token {
        case .array(let array):
            // Use the array directly
            arrayToFilter = array
        case .dictionary:
            // For dictionaries, treat as an array with the dictionary as a single element
            arrayToFilter = [token]
        case .nil:
            // Nil input returns empty array (matching python-liquid and liquidjs behavior)
            return .array([])
        case .string, .integer, .decimal, .bool:
            // Treat single values as single-element arrays
            arrayToFilter = [token]
        case .range:
            // Ranges are treated as single-element arrays
            // (not expanded, matching other filter implementations)
            arrayToFilter = [token]
        }
        
        // Step 2: Check if we have a property parameter
        guard let firstParameter = parameters.first else {
            // No parameters provided - return the original array
            // (this matches the behavior of other implementations)
            return .array(arrayToFilter)
        }
        
        // Get the property name to filter by
        let key = firstParameter.stringValue
        
        // Step 3: Apply filtering based on parameter count
        if parameters.count >= 2 {
            // Two-parameter mode: reject items where property equals the specified value
            let valueToReject = parameters[1]
            
            let filteredArray = arrayToFilter.filter { item in
                if case .dictionary(let dict) = item {
                    // For dictionaries, check the property value
                    guard let propertyValue = dict[key] else {
                        // Items without the property are kept (not rejected)
                        return true
                    }
                    // Keep the item only if its property value does NOT equal valueToReject
                    return propertyValue != valueToReject
                } else {
                    // For non-dictionary items (simple values in array),
                    // reject if the item equals the first parameter
                    return item != firstParameter
                }
            }
            
            return .array(filteredArray)
        } else {
            // One-parameter mode: reject items where property is truthy
            let filteredArray = arrayToFilter.filter { item in
                if case .dictionary(let dict) = item {
                    // For dictionaries, check if property is truthy
                    guard let propertyValue = dict[key] else {
                        // Items without the property are kept (missing property is falsy)
                        return true
                    }
                    // Keep the item only if its property value is NOT truthy
                    // This is the opposite of the where filter
                    return !propertyValue.isTruthy
                } else {
                    // For non-dictionary items (simple values in array),
                    // reject if they match the parameter value
                    return item != firstParameter
                }
            }
            
            return .array(filteredArray)
        }
    }
}