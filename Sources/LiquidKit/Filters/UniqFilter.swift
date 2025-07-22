import Foundation

/// Implements the `uniq` filter, which removes duplicate elements from an array.
/// 
/// The uniq filter processes an array and returns a new array containing only unique
/// elements, preserving the order of first occurrence. This filter uses string
/// representation for comparison, meaning that values are considered duplicates if
/// their string representations match. This is particularly useful when you need to
/// deduplicate lists of items in templates, such as tags, categories, or product
/// attributes.
/// 
/// The filter compares elements by converting them to strings, which means that
/// numeric values like 1 and "1" would be considered duplicates. The original order
/// is preserved, with the first occurrence of each unique value being retained.
/// Non-array inputs are returned unchanged.
/// 
/// ## Examples
/// 
/// Basic usage with strings:
/// ```liquid
/// {{ "ants, bugs, bees, bugs, ants" | split: ", " | uniq | join: ", " }}
/// → "ants, bugs, bees"
/// ```
/// 
/// With mixed data types:
/// ```liquid
/// {% assign items = "1,2,1,3,2" | split: "," %}
/// {{ items | uniq | join: ", " }}
/// → "1, 2, 3"
/// ```
/// 
/// Preserving order of first occurrence:
/// ```liquid
/// {% assign colors = "red,blue,green,blue,red,yellow" | split: "," %}
/// {{ colors | uniq | join: " " }}
/// → "red blue green yellow"
/// ```
/// 
/// - Important: The filter uses string comparison for determining uniqueness. This means\
///   that values with different types but same string representation are considered\
///   duplicates (e.g., the integer 1 and string "1").
/// 
/// - Important: If the input is not an array, the filter returns the input unchanged\
///   rather than throwing an error.
/// 
/// - SeeAlso: ``JoinFilter`` for combining array elements into a string
/// - SeeAlso: ``SplitFilter`` for creating arrays from strings
/// - SeeAlso: [LiquidJS uniq](https://liquidjs.com/filters/uniq.html)
/// - SeeAlso: [Python Liquid uniq](https://liquid.readthedocs.io/en/latest/filter_reference/#uniq)
/// - SeeAlso: [Shopify Liquid uniq](https://shopify.github.io/liquid/filters/uniq/)
@usableFromInline
package struct UniqFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "uniq"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard case .array(let array) = token else {
            return token
        }
        
        var uniqueValues: [Token.Value] = []
        var seenValues: Set<String> = []
        
        for value in array {
            let stringRepresentation = value.stringValue
            if !seenValues.contains(stringRepresentation) {
                seenValues.insert(stringRepresentation)
                uniqueValues.append(value)
            }
        }
        
        return .array(uniqueValues)
    }
}