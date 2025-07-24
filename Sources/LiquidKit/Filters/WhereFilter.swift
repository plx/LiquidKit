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
/// where the property equals a specific value). The filter only processes dictionary
/// objects within arrays, filtering out any non-dictionary elements.
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
/// Filtering arrays with mixed element types:
/// ```liquid
/// {% comment %} Non-dictionary elements are filtered out {% endcomment %}
/// {{ mixed_array | where: "available" }}
/// → Only dictionary objects with truthy 'available' property
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
///   property value is truthy (not nil or false). This includes true, numbers,\
///   strings (including empty strings), arrays, and dictionaries.
/// 
/// - Important: Objects without the specified property are excluded from the result.\
///   The filter does not throw an error for missing properties.
/// 
/// - Important: The filter only works on arrays of dictionary objects. Non-dictionary\
///   elements in arrays are ignored and filtered out.
/// 
/// - Important: For non-array, non-dictionary inputs (strings, numbers, etc.), the\
///   filter returns an empty array since the where filter is designed for object filtering.
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
        // Extract the property name from the first parameter
        guard let firstParameter = parameters.first else {
            // If no property parameter provided, return the original input as an array
            // This matches the behavior when no filtering criteria is specified
            switch token {
            case .array(let array):
                return .array(array)
            case .dictionary:
                return .array([token])
            default:
                return .array([])
            }
        }
        
        // Get the property name to filter by
        let key = firstParameter.stringValue
        
        // Handle different input types to create array of items to filter
        let arrayToFilter: [Token.Value]
        switch token {
        case .array(let array):
            // Use the array directly
            arrayToFilter = array
        case .dictionary:
            // Treat single dictionary as an array with one element
            arrayToFilter = [token]
        case .nil:
            // Nil input returns empty array
            return .array([])
        default:
            // Non-array, non-dictionary inputs (string, integer, decimal, bool, range)
            // return empty array since where filter only works on objects
            return .array([])
        }
        
        if parameters.count >= 2 {
            // Two-parameter mode: filter by exact property-value match
            let valueToMatch = parameters[1]
            
            let filteredArray = arrayToFilter.filter { item in
                // Only process dictionary items (objects with properties)
                guard case .dictionary(let dict) = item else {
                    // Non-dictionary items are filtered out
                    return false
                }
                
                // Check if the item has the specified property
                guard let propertyValue = dict[key] else {
                    // Items without the property are excluded
                    return false
                }
                
                // Include item only if property value exactly matches the target value
                return propertyValue == valueToMatch
            }
            
            return .array(filteredArray)
        } else {
            // One-parameter mode: filter by truthy property value
            let filteredArray = arrayToFilter.filter { item in
                // Only process dictionary items (objects with properties)
                guard case .dictionary(let dict) = item else {
                    // Non-dictionary items are filtered out
                    return false
                }
                
                // Check if the item has the specified property
                guard let propertyValue = dict[key] else {
                    // Items without the property are excluded (missing property is falsy)
                    return false
                }
                
                // Include item only if property value is truthy
                return propertyValue.isTruthy
            }
            
            return .array(filteredArray)
        }
    }
}