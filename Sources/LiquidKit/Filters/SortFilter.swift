import Foundation

/// Implements the `sort` filter, which sorts items in an array in case-sensitive order.
///
/// The `sort` filter arranges array elements in ascending order using case-sensitive
/// comparison. For strings, this means capital letters come before lowercase letters
/// (e.g., "A" before "a"). The filter handles various data types including strings,
/// numbers, booleans, and nil values, each with specific sorting rules.
///
/// When sorting arrays containing mixed types, the filter applies a type hierarchy:
/// nil values come first, followed by booleans (false before true), then numbers
/// (integers and decimals sorted numerically), and finally strings (lexicographically).
/// For completely incompatible types, values are converted to strings and compared.
///
/// ## Examples
///
/// Basic string sorting (case-sensitive):
/// ```liquid
/// {% assign letters = "b,a,B,A" | split: "," %}
/// {{ letters | sort | join: "#" }}
/// // Output: "A#B#a#b"
/// ```
///
/// Number sorting:
/// ```liquid
/// {% assign numbers = "30,1,1000,3" | split: "," %}
/// {{ numbers | sort | join: "#" }}
/// // Output: "1#3#30#1000"
/// ```
///
/// Sorting by property:
/// ```liquid
/// {% assign products_by_price = collection.products | sort: "price" %}
/// {% for product in products_by_price %}
///   <h4>{{ product.title }}</h4>
/// {% endfor %}
/// ```
///
/// Mixed type sorting:
/// ```liquid
/// {% assign mixed = [nil, true, false, 5, "hello"] %}
/// {{ mixed | sort }}
/// // nil comes first, then false, true, 5, "hello"
/// ```
///
/// - Important: Unlike `sort_natural`, this filter is case-sensitive, meaning uppercase
///   letters sort before their lowercase equivalents. Use `sort_natural` for
///   case-insensitive sorting.
///
/// - Note: When sorting arrays of dictionaries by a property, objects missing the
///   specified property are treated as having a nil value and will appear first
///   in the sorted array.
///
/// - SeeAlso: ``SortNaturalFilter``, ``ReverseFilter``, ``UniqFilter``
/// - SeeAlso: [Shopify Liquid sort](https://shopify.github.io/liquid/filters/sort/)
/// - SeeAlso: [LiquidJS sort](https://liquidjs.com/filters/sort.html)
/// - SeeAlso: [Python Liquid sort](https://liquid.readthedocs.io/en/latest/filter_reference/#sort)
@usableFromInline
package struct SortFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "sort"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        // If the input is not an array, return it unchanged
        guard case .array(let array) = token else {
            return token
        }
        
        // Check if a property name was provided for sorting
        let propertyName: String? = parameters.first.flatMap { param in
            // Only accept string parameters as property names
            if case .string(let prop) = param {
                return prop
            }
            return nil
        }
        
        let sortedArray = array.sorted { (lhs, rhs) -> Bool in
            let leftValue: Token.Value
            let rightValue: Token.Value
            
            // If a property name was provided, extract the property values
            if let propertyName = propertyName {
                // For property-based sorting, extract the values from dictionaries
                if case .dictionary(let leftDict) = lhs {
                    leftValue = leftDict[propertyName] ?? .nil
                } else {
                    leftValue = .nil
                }
                
                if case .dictionary(let rightDict) = rhs {
                    rightValue = rightDict[propertyName] ?? .nil
                } else {
                    rightValue = .nil
                }
            } else {
                // For direct sorting, use the values as-is
                leftValue = lhs
                rightValue = rhs
            }
            
            // Compare the values using the same logic
            switch (leftValue, rightValue) {
            // nil values always come first
            case (.nil, _):
                return true
            case (_, .nil):
                return false
            // Booleans: false comes before true
            case (.bool(let l), .bool(let r)):
                return !l && r
            // Integer comparisons
            case (.integer(let l), .integer(let r)):
                return l < r
            // Decimal comparisons
            case (.decimal(let l), .decimal(let r)):
                return l < r
            // Mixed numeric comparisons (integer vs decimal)
            case (.integer(let l), .decimal(let r)):
                return Decimal(l) < r
            case (.decimal(let l), .integer(let r)):
                return l < Decimal(r)
            // String comparisons (case-sensitive)
            case (.string(let l), .string(let r)):
                return l < r
            // For all other cases (mixed types), convert to string and compare
            default:
                return leftValue.stringValue < rightValue.stringValue
            }
        }
        
        return .array(sortedArray)
    }
}