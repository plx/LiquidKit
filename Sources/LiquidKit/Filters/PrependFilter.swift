import Foundation

/// Implements the `prepend` filter, which adds a prefix to the beginning of a string.
/// 
/// The `prepend` filter concatenates a specified string to the beginning of the input value.
/// This is the opposite of the `append` filter and is commonly used for building URLs,
/// file paths, or adding prefixes to string values. The filter only operates on string
/// inputs - non-string values are returned unchanged.
/// 
/// When chaining multiple `prepend` filters, they are applied from left to right, meaning
/// the rightmost prepend value will appear at the beginning of the final string. This
/// behavior might be counterintuitive but follows the standard Liquid filter execution order.
/// 
/// - Example: Basic usage
/// ```liquid
/// {{ "world" | prepend: "Hello, " }}
/// <!-- Output: Hello, world -->
/// 
/// {{ "/index.html" | prepend: "https://example.com" }}
/// <!-- Output: https://example.com/index.html -->
/// ```
/// 
/// - Example: Chaining prepend filters
/// ```liquid
/// {{ "a" | prepend: "b" | prepend: "c" }}
/// <!-- Output: cba -->
/// 
/// {{ "file.txt" | prepend: "/" | prepend: "/home/user" }}
/// <!-- Output: /home/user/file.txt -->
/// ```
/// 
/// - Example: Using with variables
/// ```liquid
/// {% assign domain = "example.com" %}
/// {{ "/page.html" | prepend: domain }}
/// <!-- Output: example.com/page.html -->
/// ```
/// 
/// - Important: Non-string inputs are returned unchanged without error. If you need to
///   prepend to a non-string value, first convert it using the `string` filter or ensure
///   the input is already a string.
/// 
/// - Important: The filter requires exactly one parameter. If no parameter is provided or
///   the parameter is not a string, the original input is returned unchanged.
/// 
/// - SeeAlso: ``AppendFilter`` - Adds a suffix to the end of a string
/// - SeeAlso: [LiquidJS prepend](https://liquidjs.com/filters/prepend.html)
/// - SeeAlso: [Python Liquid prepend](https://liquid.readthedocs.io/en/latest/filter_reference/#prepend)
/// - SeeAlso: [Shopify Liquid prepend](https://shopify.github.io/liquid/filters/prepend/)
@usableFromInline
package struct PrependFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "prepend"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard case .string(let string) = token else {
            return token
        }
        
        guard parameters.count >= 1,
              case .string(let prefix) = parameters[0] else {
            return token
        }
        
        return .string(prefix + string)
    }
}