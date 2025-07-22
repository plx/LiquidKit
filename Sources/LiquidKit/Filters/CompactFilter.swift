import Foundation

/// Implements the `compact` filter, which removes nil/null values from arrays.
/// 
/// The `compact` filter is used to remove all nil (null) values from an array, creating a new array
/// containing only the non-nil elements in their original order. This is particularly useful when
/// working with arrays that may contain sparse data or when you need to clean up data before processing.
/// 
/// When applied to non-array values, the filter returns the original value unchanged. This makes it
/// safe to use in filter chains without worrying about type checking.
/// 
/// ## Examples
/// 
/// Basic usage with an array containing nil values:
/// ```liquid
/// {% assign categories = site.categories | compact %}
/// {{ categories | join: ", " }}
/// ```
/// 
/// Working with sparse arrays:
/// ```liquid
/// {% assign items = array_with_nils | compact %}
/// {{ items | size }} items remaining
/// ```
/// 
/// Chaining with other filters:
/// ```liquid
/// {{ products | map: "category" | compact | uniq | join: ", " }}
/// ```
/// 
/// - Important: The filter only removes nil values, not empty strings, false values, or empty arrays.
///   If you need to remove "falsy" values, consider using additional filters or conditional logic.
/// 
/// - SeeAlso: ``MapFilter``
/// - SeeAlso: ``RejectFilter``
/// - SeeAlso: [Shopify Liquid compact](https://shopify.github.io/liquid/filters/compact/)
/// - SeeAlso: [LiquidJS compact](https://liquidjs.com/filters/compact.html)
@usableFromInline
package struct CompactFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "compact"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard case .array(let array) = token else {
            return token
        }
        
        let compacted = array.filter { $0 != .nil }
        return .array(compacted)
    }
}