import Foundation

/// Implements the `find` filter, which searches for the first item in a collection matching specified criteria.
/// 
/// The `find` filter returns the first item in an array that matches the given criteria. When used with
/// arrays of objects, it can search for items where a specific property matches a given value or is
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
        // Convert input to array for uniform processing
        let arrayToSearch: [Token.Value]
        switch token {
        case .array(let array):
            // Arrays are processed as-is
            arrayToSearch = array
        case .dictionary:
            // Single dictionaries are treated as single-element arrays
            arrayToSearch = [token]
        case .nil:
            // Nil input returns nil immediately
            return .nil
        case .string, .integer, .decimal, .bool:
            // Single scalar values are treated as single-element arrays
            arrayToSearch = [token]
        case .range:
            // Ranges are treated as single-element arrays (not expanded)
            arrayToSearch = [token]
        }
        
        // Require at least one parameter (the property name or search string)
        guard let firstParameter = parameters.first else {
            // No parameters provided, return nil
            return .nil
        }
        
        // Extract the property name or search string
        let searchKey = firstParameter.stringValue
        
        if parameters.count >= 2 {
            // Two-parameter mode: find first item where property equals specific value
            // This mode is used for exact property matching in objects
            let valueToMatch = parameters[1]
            
            for item in arrayToSearch {
                if case .dictionary(let dict) = item {
                    // For dictionaries, check if the property exists and matches the value exactly
                    if let propertyValue = dict[searchKey], propertyValue == valueToMatch {
                        return item
                    }
                }
                // Non-dictionary items are not matched in two-parameter mode
                // This matches the behavior of liquidjs and python-liquid
            }
            
            return .nil
        } else {
            // One-parameter mode: find first item where property is truthy OR contains substring
            // This mode has different behavior based on the item type
            for item in arrayToSearch {
                if case .dictionary(let dict) = item {
                    // For dictionaries, check if property exists and is truthy
                    // Note: In Liquid, empty strings, zero, empty arrays are all truthy
                    if let propertyValue = dict[searchKey], propertyValue.isTruthy {
                        return item
                    }
                } else if case .string(let str) = item {
                    // For strings, check if it contains the search substring
                    // This enables finding strings that contain the search parameter
                    if str.contains(searchKey) {
                        return item
                    }
                }
                // Other non-dictionary, non-string items are not matched
                // This includes integers, decimals, booleans, and ranges
            }
            
            return .nil
        }
    }
}