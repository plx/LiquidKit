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
/// - Important: This implementation does not support sorting arrays of objects by a
///   property name, which is a feature available in some Liquid implementations.
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
        guard case .array(let array) = token else {
            return token
        }
        
        let sortedArray = array.sorted { (lhs, rhs) -> Bool in
            switch (lhs, rhs) {
            case (.nil, _):
                return true
            case (_, .nil):
                return false
            case (.bool(let l), .bool(let r)):
                return !l && r
            case (.integer(let l), .integer(let r)):
                return l < r
            case (.decimal(let l), .decimal(let r)):
                return l < r
            case (.integer(let l), .decimal(let r)):
                return Decimal(l) < r
            case (.decimal(let l), .integer(let r)):
                return l < Decimal(r)
            case (.string(let l), .string(let r)):
                return l < r
            default:
                // For mixed types, convert to string and compare
                return lhs.stringValue < rhs.stringValue
            }
        }
        
        return .array(sortedArray)
    }
}