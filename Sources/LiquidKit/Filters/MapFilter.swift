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
/// the result (which renders as empty in Liquid output). Non-dictionary elements in the
/// array are skipped entirely, resulting in a potentially shorter output array. If the
/// input is not an array, the filter returns the input unchanged rather than throwing
/// an error.
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
/// Non-array input:
/// ```liquid
/// {{ "hello" | map: 'title' }}
/// // Output: "hello" (unchanged)
/// ```
/// 
/// - Important: Elements that are not dictionaries are completely omitted from the result,
///   while dictionaries missing the requested property contribute `nil` (rendered as empty).
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
        guard case .array(let array) = token else {
            return token
        }
        
        guard let firstParameter = parameters.first else {
            return token
        }
        
        let key = firstParameter.stringValue
        
        let mappedValues = array.compactMap { item -> Token.Value? in
            if case .dictionary(let dict) = item {
                return dict[key] ?? .nil
            }
            return nil
        }
        
        return .array(mappedValues)
    }
}