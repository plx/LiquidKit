import Foundation

/// Implements the `default` filter, which provides fallback values for nil, empty, or false values.
/// 
/// The `default` filter returns a default value when the input is considered "empty" according to 
/// Liquid specifications. This includes nil values, empty strings, empty arrays, and the boolean 
/// value false. For all other values, including zero, non-empty arrays, and non-empty strings,
/// the original input is returned unchanged. This filter is crucial for providing fallback values
/// in templates where data might be missing or incomplete.
/// 
/// The filter's behavior matches the Shopify Liquid specification, where "empty" values trigger
/// the default replacement. This provides consistent behavior across different Liquid implementations.
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
/// Empty arrays:
/// ```liquid
/// {{ empty_array | default: "No items" }}
/// <!-- If empty_array is [], outputs: No items -->
/// ```
/// 
/// - Important: The filter considers nil, empty string (""), empty arrays ([]), and false as values
///   that trigger the default. Values like 0, strings with whitespace, and empty dictionaries are
///   not considered empty and pass through unchanged.
/// 
/// - Important: Only the first parameter is used as the default value. Additional parameters
///   are ignored.
/// 
/// - Note: The `allow_false` parameter mentioned in some Liquid implementations is not currently
///   supported. In this implementation, `false` always triggers the default replacement.
/// 
/// - SeeAlso: ``UnlessFilter``
/// - SeeAlso: [Shopify Liquid default](https://shopify.github.io/liquid/filters/default/)
/// - SeeAlso: [LiquidJS default](https://liquidjs.com/filters/default.html)
@usableFromInline
package struct DefaultFilter: Filter {
  @usableFromInline
  package static let filterIdentifier = "default"
  
  @inlinable
  package init() {}
  
  @inlinable
  package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
    // Get the default value from the first parameter, or nil if no parameters
    let defaultValue = parameters.isEmpty ? Token.Value.nil : parameters[0]
    
    // Check if the input value should be replaced with the default
    switch token {
    case .nil:
      // nil values always use the default
      return defaultValue
      
    case .string(let str) where str.isEmpty:
      // Empty strings use the default
      return defaultValue
      
    case .bool(false):
      // false uses the default (unless allow_false parameter is used, which we don't support yet)
      return defaultValue
      
    case .array(let arr) where arr.isEmpty:
      // Empty arrays use the default according to Shopify Liquid spec
      return defaultValue
      
    default:
      // All other values pass through unchanged:
      // - Non-empty strings (including whitespace-only strings)
      // - true
      // - Any number (including 0)
      // - Non-empty arrays
      // - Dictionaries (even empty ones)
      // - Ranges
      return token
    }
  }
}