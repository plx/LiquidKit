import Foundation

/// Implements the `where` filter, which selects elements from an array based on property values.
/// 
/// The where filter is a powerful array filtering tool that selects elements based on
/// property matching. It can filter by the presence of a truthy property value (one
/// parameter) or by exact property-value matching (two parameters). This filter is
/// particularly useful when working with arrays of objects, such as products, posts,
/// or any structured data where you need to select items based on their attributes.
/// 
/// The filter supports two modes of operation: truthy filtering (selects items where
/// the specified property has a truthy value) and equality filtering (selects items
/// where the property equals a specific value). For arrays of simple values (not objects),
/// the filter can select values that match the provided parameter. Non-array inputs are
/// treated as single-element arrays for consistent behavior.
/// 
/// ## Examples
/// 
/// Filtering by truthy property:
/// ```liquid
/// {% assign products = site.products | where: "available" %}
/// <!-- Selects all products where available is true or any truthy value -->
/// 
/// {{ products | where: "featured" | map: "title" | join: ", " }}
/// → "Product 1, Product 3"
/// ```
/// 
/// Filtering by property value:
/// ```liquid
/// {{ products | where: "type", "shoes" | map: "title" | join: ", " }}
/// → "Product 1, Product 3"
/// 
/// {{ posts | where: "author", "Jane" | size }}
/// → 5
/// ```
/// 
/// Filtering simple arrays:
/// ```liquid
/// {% assign colors = "red,blue,green,blue" | split: "," %}
/// {{ colors | where: "blue" | join: ", " }}
/// → "blue, blue"
/// ```
/// 
/// Chaining with other filters:
/// ```liquid
/// {{ products | where: "available" | where: "type", "shoes" | first | map: "title" }}
/// → "Product 1"
/// ```
/// 
/// Edge cases:
/// ```liquid
/// {{ empty_array | where: "property" }}
/// → []
/// 
/// {{ nil | where: "property" }}
/// → []
/// ```
/// 
/// - Important: When using single-parameter mode, the filter selects items where the\
///   property value is truthy (not nil, false, or empty string). This includes true,\
///   numbers, non-empty strings, arrays, and dictionaries.
/// 
/// - Important: Objects without the specified property are excluded from the result.\
///   The filter does not throw an error for missing properties.
/// 
/// - Important: For non-dictionary array elements, the filter compares the element\
///   directly with the first parameter rather than looking for a property.
/// 
/// - Warning: The current implementation has TODO comments indicating potential\
///   improvements needed for nil handling and range expansion.
/// 
/// - SeeAlso: ``MapFilter`` for extracting property values from filtered results
/// - SeeAlso: ``SelectFilter`` for more complex filtering logic
/// - SeeAlso: ``FindFilter`` for getting the first matching element
/// - SeeAlso: [LiquidJS where](https://liquidjs.com/filters/where.html)
/// - SeeAlso: [Python Liquid where](https://liquid.readthedocs.io/en/latest/filter_reference/#where)
/// - SeeAlso: [Shopify Liquid where](https://shopify.github.io/liquid/filters/where/)
@usableFromInline
package struct WhereFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "where"
    
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
            // Select items where property/value equals the specified value
            let valueToMatch = parameters[1]
            
            let filteredArray = arrayToFilter.filter { item in
                if case .dictionary(let dict) = item {
                    // For dictionaries, check the property value
                    guard let propertyValue = dict[key] else {
                        return false // Exclude items without the property
                    }
                    return propertyValue == valueToMatch
                } else {
                    // For non-dictionary items, compare directly if key matches value
                    return item == firstParameter
                }
            }
            
            return .array(filteredArray)
        } else {
            // Select items where property is truthy or value matches
            let filteredArray = arrayToFilter.filter { item in
                if case .dictionary(let dict) = item {
                    // For dictionaries, check if property is truthy
                    guard let propertyValue = dict[key] else {
                        return false // Exclude items without the property
                    }
                    return propertyValue.isTruthy
                } else {
                    // For non-dictionary items, select if they match the parameter
                    return item == firstParameter
                }
            }
            
            return .array(filteredArray)
        }
    }
}