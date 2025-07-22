import Foundation

/// Implements the `find_index` filter, which returns the zero-based index of the first matching item in a collection.
/// 
/// The `find_index` filter works similarly to the `find` filter but returns the index position instead of
/// the item itself. It searches arrays for items matching specified criteria and returns the zero-based
/// index of the first match. When used with arrays of objects, it can search by property values. When
/// used with strings or string arrays, it performs substring matching. Non-array inputs are treated as
/// single-element arrays, with matching items returning index 0.
/// 
/// Like the `find` filter, it accepts one or two parameters: the first specifies the property name or
/// substring to search for, and the optional second parameter specifies an exact value to match. When
/// only one parameter is provided, it returns the index of the first item where the property is truthy
/// (for objects) or contains the substring (for strings).
/// 
/// ## Examples
/// 
/// Finding index by property value:
/// ```liquid
/// {% assign products = '[{"name": "Shirt", "price": 20}, {"name": "Pants", "price": 30}]' | parse_json %}
/// {{ products | find_index: "name", "Pants" }}
/// // Output: 1
/// ```
/// 
/// Finding index by truthy property:
/// ```liquid
/// {% assign users = '[{"name": "Alice"}, {"name": "Bob", "admin": true}]' | parse_json %}
/// {{ users | find_index: "admin" }}
/// // Output: 1
/// ```
/// 
/// String array substring matching:
/// ```liquid
/// {% assign words = "apple,banana,cherry" | split: "," %}
/// {{ words | find_index: "err" }}
/// // Output: 2
/// 
/// {{ words | find_index: "z" }}
/// // Output: ""  // No match found
/// ```
/// 
/// With single string values:
/// ```liquid
/// {{ "zoo" | find_index: "z" }}
/// // Output: 0  // String contains "z"
/// 
/// {{ "hello" | find_index: "x" }}
/// // Output: ""  // String doesn't contain "x"
/// ```
/// 
/// With objects treated as single-element arrays:
/// ```liquid
/// {% assign user = '{"name": "Alice", "active": true}' | parse_json %}
/// {{ user | find_index: "active" }}
/// // Output: 0  // Object has truthy "active" property
/// ```
/// 
/// Edge cases:
/// ```liquid
/// {{ nil | find_index: "test" }}
/// // Output: ""
/// 
/// {% assign empty = "" | split: "," %}
/// {{ empty | find_index: "test" }}
/// // Output: ""
/// ```
/// 
/// - Important: The filter returns an empty string (rendered as "") when no match is found, not -1 or nil.\
///   This follows Liquid's convention of using empty strings for "no result" scenarios.
/// 
/// - Important: For non-array inputs (except nil), the input is treated as a single-element array. If it matches,\
///   the index 0 is returned; otherwise, an empty string is returned.
/// 
/// - Important: When searching string arrays, the filter uses substring matching, not exact matching. For exact\
///   matching, use the second parameter to specify the exact value.
/// 
/// - Warning: The current implementation's string matching behavior for non-dictionary items may not fully align\
///   with the reference implementation when using two parameters.
/// 
/// - SeeAlso: ``FindFilter``
/// - SeeAlso: ``IndexFilter``
/// - SeeAlso: [LiquidJS documentation](https://liquidjs.com/filters/find_index.html)
/// - SeeAlso: [Python Liquid documentation](https://liquid.readthedocs.io/en/latest/filter_reference/#find_index)
@usableFromInline
package struct FindIndexFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "find_index"
    
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
            // TODO: Should this return nil or throw an error?
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
            // Find index of first item where property/value equals the specified value
            let valueToMatch = parameters[1]
            
            for (index, item) in arrayToSearch.enumerated() {
                if case .dictionary(let dict) = item {
                    // For dictionaries, check the property value
                    guard let propertyValue = dict[key] else {
                        continue // Skip items without the property
                    }
                    if propertyValue == valueToMatch {
                        return .integer(index)
                    }
                } else {
                    // For non-dictionary items (strings), check if the search string is contained
                    if case .string(let str) = item, str.contains(key) {
                        return .integer(index)
                    }
                }
            }
            
            return .nil
        } else {
            // Find index of first item where property is truthy or value matches
            for (index, item) in arrayToSearch.enumerated() {
                if case .dictionary(let dict) = item {
                    // For dictionaries, check if property is truthy
                    guard let propertyValue = dict[key] else {
                        continue // Skip items without the property
                    }
                    if propertyValue.isTruthy {
                        return .integer(index)
                    }
                } else {
                    // For non-dictionary items (strings), check if the search string is contained
                    if case .string(let str) = item, str.contains(key) {
                        return .integer(index)
                    }
                }
            }
            
            return .nil
        }
    }
}