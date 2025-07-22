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
/// - Warning: The current implementation has some limitations marked with TODOs:
///   - Nil input returns an empty array but might need different handling
///   - Range inputs are not expanded to arrays
///   - Missing property parameter doesn't throw an error as it should
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
        // Handle different input types
        let arrayToFilter: [Token.Value]
        switch token {
        case .array(let array):
            arrayToFilter = array
        case .dictionary:
            // For dictionaries, treat as an array with the dictionary as a single element
            arrayToFilter = [token]
        case .nil:
            // TODO: Should this return nil or empty array?
            return .array([])
        case .string, .integer, .decimal, .bool:
            // Treat single values as single-element arrays
            arrayToFilter = [token]
        case .range:
            // TODO: Should ranges be expanded to arrays?
            arrayToFilter = [token]
        }
        
        guard let firstParameter = parameters.first else {
            // TODO: Should throw an error for missing property parameter
            return .array(arrayToFilter)
        }
        
        let key = firstParameter.stringValue
        
        if parameters.count >= 2 {
            // Reject items where property/value equals the specified value
            let valueToReject = parameters[1]
            
            let filteredArray = arrayToFilter.filter { item in
                if case .dictionary(let dict) = item {
                    // For dictionaries, check the property value
                    guard let propertyValue = dict[key] else {
                        return true // Keep items without the property
                    }
                    return propertyValue != valueToReject
                } else {
                    // For non-dictionary items, compare directly if key matches value
                    return item != firstParameter
                }
            }
            
            return .array(filteredArray)
        } else {
            // Reject items where property is truthy or value matches
            let filteredArray = arrayToFilter.filter { item in
                if case .dictionary(let dict) = item {
                    // For dictionaries, check if property is truthy
                    guard let propertyValue = dict[key] else {
                        return true // Keep items without the property
                    }
                    return !propertyValue.isTruthy
                } else {
                    // For non-dictionary items, reject if they match the parameter
                    return item != firstParameter
                }
            }
            
            return .array(filteredArray)
        }
    }
}