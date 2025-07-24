import Foundation

/// Implements the `map` filter, which extracts a property from each element in an array.
/// 
/// The `map` filter is designed to extract a specific property from an array of objects,
/// creating a new array containing just those property values. When given an array of
/// dictionaries or objects, it returns an array of the values for the specified property
/// key from each element. This is particularly useful for extracting specific fields from
/// structured data, such as getting all titles from a list of blog posts or all prices
/// from a list of products.
/// 
/// For array elements that don't contain the specified property, `nil` is included in
/// the result (which renders as empty in Liquid output). If the array contains any
/// non-dictionary elements, the filter throws an error. When the input is a single
/// dictionary (not an array), the filter extracts the specified property value directly.
/// For other non-array inputs, the filter throws an error.
/// 
/// ## Examples
/// 
/// Basic property extraction:
/// ```liquid
/// {{ products | map: 'title' | join: ', ' }}
/// // Input: [{"title": "Shirt"}, {"title": "Pants"}]
/// // Output: "Shirt, Pants"
/// ```
/// 
/// Handling missing properties:
/// ```liquid
/// {{ items | map: 'price' | join: '#' }}
/// // Input: [{"price": 10}, {"price": 20}, {"name": "Special"}]
/// // Output: "10#20#"
/// ```
/// 
/// Dictionary input:
/// ```liquid
/// {{ product | map: 'title' }}
/// // Input: {"title": "Shirt", "price": 20}
/// // Output: "Shirt"
/// ```
/// 
/// - Important: Non-dictionary elements in arrays will cause an error to be thrown.
///   This matches the behavior of liquidjs and python-liquid implementations.
/// 
/// - SeeAlso: ``WhereFilter``, ``SelectFilter``
/// - SeeAlso: [LiquidJS Documentation](https://liquidjs.com/filters/map.html)
/// - SeeAlso: [Shopify Liquid Documentation](https://shopify.github.io/liquid/filters/map/)
@usableFromInline
package struct MapFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "map"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        // Validate that we have at least one parameter (the property name)
        guard let firstParameter = parameters.first else {
            throw TemplateSyntaxError("map filter requires a property name argument")
        }
        
        // Handle nil parameter - return empty array
        guard firstParameter != .nil else {
            return .array([])
        }
        
        // Get the property key as a string
        let key = firstParameter.stringValue
        
        // Handle different input types
        switch token {
        case .array(let array):
            // Process array input
            var mappedValues: [Token.Value] = []
            
            for item in array {
                switch item {
                case .dictionary(let dict):
                    // For dictionaries, extract the property value or use nil if missing
                    if let value = extractValue(from: dict, key: key) {
                        mappedValues.append(value)
                    } else {
                        mappedValues.append(.nil)
                    }
                default:
                    // Non-dictionary elements in arrays should throw an error
                    throw TemplateSyntaxError("map filter can only be applied to arrays of objects")
                }
            }
            
            return .array(mappedValues)
            
        case .dictionary(let dict):
            // For a single dictionary input, extract the property value
            if let value = extractValue(from: dict, key: key) {
                return value
            } else {
                return .nil
            }
            
        default:
            // All other input types should throw an error
            throw TemplateSyntaxError("map filter can only be applied to arrays or objects")
        }
    }
    
    /// Extracts a value from a dictionary, supporting dot notation for nested properties
    /// - Parameters:
    ///   - dict: The dictionary to extract from
    ///   - key: The key path (may contain dots for nested access)
    /// - Returns: The extracted value, or nil if not found
    @inlinable
    func extractValue(from dict: [String: Token.Value], key: String) -> Token.Value? {
        // Split the key by dots to handle nested property access
        let keyComponents = key.split(separator: ".").map(String.init)
        
        // Start with the full dictionary
        var currentValue: Token.Value = .dictionary(dict)
        
        // Navigate through each component of the key path
        for component in keyComponents {
            switch currentValue {
            case .dictionary(let currentDict):
                // If we have a dictionary, try to get the value for this component
                if let nextValue = currentDict[component] {
                    currentValue = nextValue
                } else {
                    // Key not found at this level
                    return nil
                }
            default:
                // If we're not at a dictionary, we can't continue navigating
                return nil
            }
        }
        
        return currentValue
    }
}