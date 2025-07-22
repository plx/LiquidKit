import Foundation

/// Implements the `default` filter, which provides fallback values for nil, empty, or false values.
/// 
/// The `default` filter returns a default value when the input is considered "falsy" in Liquid terms.
/// This includes nil values, empty strings, and the boolean value false. For all other values,
/// including zero, empty arrays, and non-empty strings, the original input is returned unchanged.
/// This filter is crucial for providing fallback values in templates where data might be missing
/// or incomplete.
/// 
/// The filter's behavior with false values makes it particularly useful for boolean flags where
/// you want to provide a different value when something is explicitly false, not just missing.
/// This differs from simple nil-checking and provides more nuanced control over default values.
/// 
/// ## Examples
/// 
/// Basic usage with nil values:
/// ```liquid
/// {{ product_price | default: "Contact for price" }}
/// <!-- If product_price is nil, outputs: Contact for price -->
/// 
/// {{ user.name | default: "Guest" }}
/// <!-- If user.name is nil or empty, outputs: Guest -->
/// ```
/// 
/// Working with empty strings:
/// ```liquid
/// {{ "" | default: "No description available" }}
/// <!-- Output: No description available -->
/// 
/// {{ " " | default: "No description" }}
/// <!-- Output: " " (space is not empty) -->
/// ```
/// 
/// Boolean value handling:
/// ```liquid
/// {{ false | default: "Not available" }}
/// <!-- Output: Not available -->
/// 
/// {{ true | default: "Not available" }}
/// <!-- Output: true -->
/// ```
/// 
/// - Important: The filter only considers nil, empty string (""), and false as falsy.
///   Values like 0, empty arrays [], or strings with whitespace are not considered falsy.
/// 
/// - Important: Only the first parameter is used as the default value. Additional parameters
///   are ignored.
/// 
/// - SeeAlso: ``UnlessFilter``
/// - SeeAlso: [Shopify Liquid default](https://shopify.github.io/liquid/filters/default/)
/// - SeeAlso: [LiquidJS default](https://liquidjs.com/filters/default.html)
/// - SeeAlso: [Python Liquid default](https://liquid.readthedocs.io/en/latest/filters/default/)
@usableFromInline
package struct DefaultFilter: Filter {
  @usableFromInline
  package static let filterIdentifier = "default"
  
  @inlinable
  package init() {}
  
  @inlinable
  package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
    // If the value is nil, empty string, or false, return the default value
    switch token {
    case .nil:
      return parameters.isEmpty ? .nil : parameters[0]
    case .string(let str) where str.isEmpty:
      return parameters.isEmpty ? .nil : parameters[0]
    case .bool(false):
      return parameters.isEmpty ? .nil : parameters[0]
    default:
      return token
    }
  }
}