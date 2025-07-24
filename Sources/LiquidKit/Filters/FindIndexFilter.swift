import Foundation

/// Implements the `find_index` filter, which returns the zero-based index of the first matching item in a collection.
/// 
/// The `find_index` filter searches arrays for items matching specified criteria and returns the zero-based
/// index of the first match. When used with arrays of objects, it searches by property values. When
/// used with strings or string arrays, it performs substring matching. Non-array inputs are treated as
/// single-element arrays, with matching items returning index 0.
/// 
/// This filter accepts one or two parameters:
/// - With arrays of objects: Two parameters are required - the property name and the value to match
/// - With arrays of strings: One parameter for substring matching
/// 
/// ## Examples
/// 
/// Finding index by property value (requires two parameters):
/// ```liquid
/// {% assign products = '[{"name": "Shirt", "price": 20}, {"name": "Pants", "price": 30}]' | parse_json %}
/// {{ products | find_index: "name", "Pants" }}
/// // Output: 1
/// ```
/// 
/// String array substring matching (one parameter):
/// ```liquid
/// {% assign words = "apple,banana,cherry" | split: "," %}
/// {{ words | find_index: "err" }}
/// // Output: 2
/// 
/// {{ words | find_index: "z" }}
/// // Output: nil  // No match found
/// ```
/// 
/// With single string values:
/// ```liquid
/// {{ "zoo" | find_index: "z" }}
/// // Output: 0  // String contains "z"
/// 
/// {{ "hello" | find_index: "x" }}
/// // Output: nil  // String doesn't contain "x"
/// ```
/// 
/// Edge cases:
/// ```liquid
/// {{ nil | find_index: "test" }}
/// // Output: nil
/// 
/// {% assign empty = "" | split: "," %}
/// {{ empty | find_index: "test" }}
/// // Output: nil
/// ```
/// 
/// - Important: The filter returns nil when no match is found, matching liquidjs and python-liquid behavior.
/// 
/// - Important: For non-array inputs (except nil), the input is treated as a single-element array. If it matches,
///   the index 0 is returned; otherwise, nil is returned.
/// 
/// - Important: When searching arrays of objects, both property name and value parameters are required.
///   This matches the behavior of liquidjs and python-liquid implementations.
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
        // Convert input to array for uniform processing
        let arrayToSearch: [Token.Value]
        switch token {
        case .array(let array):
            // Input is already an array
            arrayToSearch = array
        case .nil:
            // Nil input returns nil (no match possible)
            return .nil
        case .dictionary, .string, .integer, .decimal, .bool, .range:
            // Treat single values as single-element arrays
            arrayToSearch = [token]
        }
        
        // Require at least one parameter (the search criteria)
        guard let firstParameter = parameters.first else {
            // Missing required parameter - return nil (no match)
            return .nil
        }
        
        // Get the search key/substring from the first parameter
        let searchKey = firstParameter.stringValue
        
        if parameters.count >= 2 {
            // Two parameters: search for object property matching exact value
            let valueToMatch = parameters[1]
            
            // Iterate through array elements to find match
            for (index, item) in arrayToSearch.enumerated() {
                if case .dictionary(let dict) = item {
                    // For dictionary items, check if property equals the specified value
                    if let propertyValue = dict[searchKey], propertyValue == valueToMatch {
                        return .integer(index)
                    }
                }
                // Note: For non-dictionary items with two parameters, no match is possible
                // This aligns with liquidjs/python-liquid behavior
            }
            
            // No match found
            return .nil
        } else {
            // Single parameter: search for substring in string values
            for (index, item) in arrayToSearch.enumerated() {
                if case .string(let str) = item {
                    // Check if string contains the search substring
                    if str.contains(searchKey) {
                        return .integer(index)
                    }
                }
                // Note: Single parameter only works with string values
                // Dictionary items require two parameters for property matching
            }
            
            // No match found
            return .nil
        }
    }
}