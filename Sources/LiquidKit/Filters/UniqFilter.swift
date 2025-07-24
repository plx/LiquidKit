import Foundation

/// Implements the `uniq` filter, which removes duplicate elements from an array.
/// 
/// The uniq filter processes an array and returns a new array containing only unique
/// elements, preserving the order of first occurrence. This implementation matches
/// the behavior of liquidjs and python-liquid by comparing actual values rather than
/// string representations. This is particularly useful when you need to deduplicate
/// lists of items in templates, such as tags, categories, or product attributes.
/// 
/// The filter compares elements by their actual value and type. For example, the
/// string "1" and integer 1 are considered different values. However, integer 1 and
/// decimal 1.0 are considered equal, matching JavaScript number behavior. The original
/// order is preserved, with the first occurrence of each unique value being retained.
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
/// With numeric arrays:
/// ```liquid
/// {% assign numbers = "1,2,1,3,2" | split: "," %}
/// {{ numbers | uniq | join: ", " }}
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
/// Type-aware comparison:
/// ```liquid
/// {% comment %} String "1" and integer 1 are different {% endcomment %}
/// {{ array | uniq | size }}
/// → Returns both string and integer if both are present
/// ```
/// 
/// - Important: Values are compared by their actual type and value. String "1" and
///   integer 1 are considered different, but integer 1 and decimal 1.0 are considered
///   equal.
/// 
/// - Important: If the input is not an array, the filter returns the input unchanged
///   rather than throwing an error.
/// 
/// - Note: This implementation does not currently support the property parameter that
///   python-liquid provides for filtering objects by a specific property.
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
        // If the input is not an array, return it unchanged
        guard case .array(let array) = token else {
            return token
        }
        
        // Array to store unique values in order of first appearance
        var uniqueValues: [Token.Value] = []
        
        // For each value in the array, check if we've seen it before
        for value in array {
            // Check if this value already exists in our unique values array
            var isDuplicate = false
            for uniqueValue in uniqueValues {
                if areValuesEqual(value, uniqueValue) {
                    isDuplicate = true
                    break
                }
            }
            
            // If it's not a duplicate, add it to our unique values
            if !isDuplicate {
                uniqueValues.append(value)
            }
        }
        
        return .array(uniqueValues)
    }
    
    /// Compares two Token.Value instances for equality in the context of the uniq filter.
    /// This matches the behavior of liquidjs and python-liquid, which compare actual values
    /// rather than string representations.
    @usableFromInline
    package func areValuesEqual(_ lhs: Token.Value, _ rhs: Token.Value) -> Bool {
        switch (lhs, rhs) {
        case (.nil, .nil):
            // nil values are equal to each other
            return true
        case (.bool(let l), .bool(let r)):
            // Boolean values are compared by their actual value
            return l == r
        case (.string(let l), .string(let r)):
            // Strings are compared directly
            return l == r
        case (.integer(let l), .integer(let r)):
            // Integers are compared directly
            return l == r
        case (.decimal(let l), .decimal(let r)):
            // Decimals are compared directly
            return l == r
        case (.array(let l), .array(let r)):
            // Arrays are equal if they have the same length and all elements are equal
            guard l.count == r.count else { return false }
            for i in 0..<l.count {
                if !areValuesEqual(l[i], r[i]) {
                    return false
                }
            }
            return true
        case (.dictionary(let l), .dictionary(let r)):
            // Dictionaries are equal if they have the same keys and values
            guard l.count == r.count else { return false }
            for (key, lValue) in l {
                guard let rValue = r[key], areValuesEqual(lValue, rValue) else {
                    return false
                }
            }
            return true
        case (.range(let l), .range(let r)):
            // Ranges are equal if their bounds are equal
            return l == r
        case (.integer(let i), .decimal(let d)), (.decimal(let d), .integer(let i)):
            // Special case: compare integer and decimal values
            // This matches liquidjs behavior where 1 and 1.0 are considered equal
            return Decimal(i) == d
        case (.string(_), .integer(_)), (.integer(_), .string(_)):
            // Special case: in Liquid, string "1" and integer 1 are considered different
            // This differs from the original implementation which used stringValue
            return false
        case (.string(_), .decimal(_)), (.decimal(_), .string(_)):
            // String and decimal are different types
            return false
        default:
            // Different types are not equal
            return false
        }
    }
}