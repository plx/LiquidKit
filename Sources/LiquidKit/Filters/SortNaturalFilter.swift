import Foundation

/// Implements the `sort_natural` filter, which sorts items in an array in case-insensitive order.
///
/// The `sort_natural` filter arranges array elements in ascending order using case-insensitive
/// comparison. Unlike the regular `sort` filter, this treats uppercase and lowercase letters
/// as equivalent during sorting (e.g., "a" and "A" are considered equal). The filter uses
/// localized comparison rules, which means it respects locale-specific sorting conventions.
///
/// Like the `sort` filter, `sort_natural` handles various data types with a consistent
/// hierarchy: nil values sort first, followed by booleans (false before true), then numbers
/// (sorted numerically with integers and decimals interchangeable), and finally strings
/// (sorted alphabetically without regard to case). Mixed types that don't fit these categories
/// are converted to strings and compared using case-insensitive rules.
///
/// ## Examples
///
/// Basic string sorting (case-insensitive):
/// ```liquid
/// {% assign letters = "zebra,octopus,giraffe,Sally Snake" | split: "," %}
/// {{ letters | sort_natural | join: ", " }}
/// // Output: "giraffe, octopus, Sally Snake, zebra"
/// ```
///
/// Case-insensitive comparison:
/// ```liquid
/// {% assign mixed_case = "b,A,B,a,C" | split: "," %}
/// {{ mixed_case | sort_natural | join: "#" }}
/// // Output: "a#A#b#B#C" or "A#a#b#B#C" (order within equal elements is not guaranteed)
/// ```
///
/// Number sorting (same as regular sort):
/// ```liquid
/// {% assign numbers = [30, 1, 1000, 3] %}
/// {{ numbers | sort_natural | join: "#" }}
/// // Output: "1#3#30#1000"
/// ```
///
/// Sorting objects by property:
/// ```liquid
/// {% assign products = collection.products %}
/// {% assign sorted_products = products | sort_natural: "company" %}
/// // Sorts products by their company name, case-insensitively
/// ```
///
/// - Important: The "natural" in `sort_natural` refers to case-insensitive sorting, not
///   to natural number sorting (where "2" would come before "10"). For true natural
///   number sorting, additional processing would be required.
///
/// - Note: When sorting objects by a property, objects missing that property will sort
///   first (as if the property value were nil).
///
/// - SeeAlso: ``SortFilter``, ``ReverseFilter``, ``UniqFilter``
/// - SeeAlso: [Shopify Liquid sort_natural](https://shopify.github.io/liquid/filters/sort_natural/)
/// - SeeAlso: [LiquidJS sort_natural](https://liquidjs.com/filters/sort_natural.html)
/// - SeeAlso: [Python Liquid sort_natural](https://liquid.readthedocs.io/en/latest/filter_reference/#sort_natural)
@usableFromInline
package struct SortNaturalFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "sort_natural"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        // Only process arrays
        guard case .array(let array) = token else {
            return token
        }
        
        // Check if we have a property parameter for sorting objects
        let propertyName: String? = parameters.first.flatMap { param in
            guard case .string(let prop) = param else { return nil }
            return prop
        }
        
        let sortedArray = array.sorted { (lhs, rhs) -> Bool in
            // If a property name is provided, extract values from dictionaries
            let leftValue: Token.Value
            let rightValue: Token.Value
            
            if let property = propertyName {
                // Try to extract the property value from dictionaries
                if case .dictionary(let leftDict) = lhs {
                    leftValue = leftDict[property] ?? .nil
                } else {
                    // Non-dictionary items are treated as having nil for the property
                    leftValue = .nil
                }
                
                if case .dictionary(let rightDict) = rhs {
                    rightValue = rightDict[property] ?? .nil
                } else {
                    // Non-dictionary items are treated as having nil for the property
                    rightValue = .nil
                }
            } else {
                // No property specified, compare the values directly
                leftValue = lhs
                rightValue = rhs
            }
            
            // Compare the values using the same logic as before
            switch (leftValue, rightValue) {
            case (.nil, _):
                // nil values always sort first
                return true
            case (_, .nil):
                // non-nil values come after nil
                return false
            case (.bool(let l), .bool(let r)):
                // false before true
                return !l && r
            case (.integer(let l), .integer(let r)):
                // numeric comparison
                return l < r
            case (.decimal(let l), .decimal(let r)):
                // numeric comparison
                return l < r
            case (.integer(let l), .decimal(let r)):
                // convert integer to decimal for comparison
                return Decimal(l) < r
            case (.decimal(let l), .integer(let r)):
                // convert integer to decimal for comparison
                return l < Decimal(r)
            case (.string(let l), .string(let r)):
                // Natural sort: case-insensitive string comparison
                return l.localizedCaseInsensitiveCompare(r) == .orderedAscending
            default:
                // For mixed types, convert to string and compare case-insensitively
                let lString = leftValue.stringValue
                let rString = rightValue.stringValue
                return lString.localizedCaseInsensitiveCompare(rString) == .orderedAscending
            }
        }
        
        return .array(sortedArray)
    }
}