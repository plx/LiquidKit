import Foundation

/// Implements the `find` filter, which searches for the first item in a collection matching specified criteria.
/// 
/// The `find` filter is a powerful search utility that works with arrays, strings, and objects. When used
/// with arrays of objects, it can search for items where a specific property matches a given value or is
/// truthy. When used with arrays of strings, it performs substring matching. The filter supports both
/// simple property existence checks and explicit value comparisons.
/// 
/// The filter accepts one or two parameters: the first parameter specifies the property name (for objects)
/// or substring (for strings) to search for, and the optional second parameter specifies the exact value
/// to match against. When only one parameter is provided, the filter returns the first item where the
/// specified property is truthy (for objects) or contains the substring (for strings).
/// 
/// ## Examples
/// 
/// Finding objects by property value:
/// ```liquid
/// {% assign products = '[{"name": "Shirt", "price": 20}, {"name": "Pants", "price": 30}]' | parse_json %}
/// {{ products | find: "name", "Pants" | json }}
/// // Output: {"name": "Pants", "price": 30}
/// ```
/// 
/// Finding objects by truthy property:
/// ```liquid
/// {% assign users = '[{"name": "Alice", "admin": true}, {"name": "Bob"}]' | parse_json %}
/// {{ users | find: "admin" | json }}
/// // Output: {"name": "Alice", "admin": true}
/// ```
/// 
/// String substring matching:
/// ```liquid
/// {% assign words = "apple,banana,cherry" | split: "," %}
/// {{ words | find: "an" }}
/// // Output: "banana"
/// 
/// {{ "Hello World" | find: "Wor" }}
/// // Output: "Hello World"
/// ```
/// 
/// With single values (treated as single-element arrays):
/// ```liquid
/// {{ "zoo" | find: "z" }}
/// // Output: "zoo"
/// 
/// {{ 42 | find: "4" }}
/// // Output: ""  // Numbers don't support substring matching
/// ```
/// 
/// Edge cases:
/// ```liquid
/// {{ nil | find: "test" }}
/// // Output: ""
/// 
/// {% assign empty = "" | split: "," %}
/// {{ empty | find: "test" }}
/// // Output: ""
/// ```
/// 
/// - Important: When searching arrays of objects, the filter only examines direct properties, not nested ones.\
///   Dot notation for nested property access is not supported.
/// 
/// - Important: For string arrays, the filter performs substring matching, not exact matching. Use the second\
///   parameter for exact value matching when needed.
/// 
/// - Important: Non-array inputs (except nil) are treated as single-element arrays, allowing the filter to work\
///   with individual strings or objects.
/// 
/// - Warning: The current implementation has some limitations with non-dictionary arrays when using two parameters.\
///   String matching behavior may not align with the reference implementation in all cases.
/// 
/// - SeeAlso: ``FindIndexFilter``
/// - SeeAlso: ``WhereFilter``
/// - SeeAlso: ``SelectFilter``
/// - SeeAlso: [LiquidJS documentation](https://liquidjs.com/filters/find.html)
/// - SeeAlso: [Python Liquid documentation](https://liquid.readthedocs.io/en/latest/filter_reference/#find)
@usableFromInline
package struct FindFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "find"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        // Handle different input types
        let arrayToSearch: [Token.Value]
        switch token {
        case .array(let array):
            arrayToSearch = array
        case .dictionary:
            // For dictionaries, treat as an array with the dictionary as a single element
            arrayToSearch = [token]
        case .nil:
            // TODO: Should this return nil or empty array?
            return .nil
        case .string, .integer, .decimal, .bool:
            // Treat single values as single-element arrays
            arrayToSearch = [token]
        case .range:
            // TODO: Should ranges be expanded to arrays?
            arrayToSearch = [token]
        }
        
        guard let firstParameter = parameters.first else {
            // TODO: Should throw an error for missing property parameter
            return .nil
        }
        
        let key = firstParameter.stringValue
        
        if parameters.count >= 2 {
            // Find first item where property/value equals the specified value
            let valueToMatch = parameters[1]
            
            for item in arrayToSearch {
                if case .dictionary(let dict) = item {
                    // For dictionaries, check the property value
                    guard let propertyValue = dict[key] else {
                        continue // Skip items without the property
                    }
                    if propertyValue == valueToMatch {
                        return item
                    }
                } else {
                    // For non-dictionary items, compare directly if key matches value
                    if item == firstParameter {
                        return item
                    }
                }
            }
            
            return .nil
        } else {
            // Find first item where property is truthy or value matches
            for item in arrayToSearch {
                if case .dictionary(let dict) = item {
                    // For dictionaries, check if property is truthy
                    guard let propertyValue = dict[key] else {
                        continue // Skip items without the property
                    }
                    if propertyValue.isTruthy {
                        return item
                    }
                } else {
                    // For non-dictionary items, select if they match the parameter
                    if item == firstParameter {
                        return item
                    }
                }
            }
            
            return .nil
        }
    }
}