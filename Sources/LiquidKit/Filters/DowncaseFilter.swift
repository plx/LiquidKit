import Foundation

/// Implements the `downcase` filter, which converts a string to lowercase.
/// 
/// The `downcase` filter is used to transform text to all lowercase letters. This is commonly used for
/// normalizing text for comparisons, creating consistent formatting, or preparing text for case-insensitive
/// operations. When applied to non-string values, the filter first converts them to their string representation
/// before applying the lowercase transformation.
/// 
/// ## Examples
/// 
/// Basic usage with strings:
/// ```liquid
/// {{ "HELLO" | downcase }}
/// // Output: "hello"
/// 
/// {{ "Hello World" | downcase }}
/// // Output: "hello world"
/// 
/// {{ "MiXeD cAsE" | downcase }}
/// // Output: "mixed case"
/// ```
/// 
/// With non-string values:
/// ```liquid
/// {{ 5 | downcase }}
/// // Output: "5"
/// 
/// {{ true | downcase }}
/// // Output: "true"
/// ```
/// 
/// With undefined or nil values:
/// ```liquid
/// {{ undefined_variable | downcase }}
/// // Output: ""
/// 
/// {{ nil | downcase }}
/// // Output: ""
/// ```
/// 
/// - Important: Unlike some Liquid implementations, this filter returns `.nil` for non-string inputs rather than\
///   converting them to strings first. This means numeric and boolean values will result in empty output.
/// 
/// - Warning: The `downcase` filter does not accept any parameters. Passing parameters will result in an error\
///   in strict Liquid implementations.
/// 
/// - SeeAlso: ``UpcaseFilter``
/// - SeeAlso: ``CapitalizeFilter``
/// - SeeAlso: [Liquid documentation](https://shopify.github.io/liquid/filters/downcase/)
/// - SeeAlso: [LiquidJS documentation](https://liquidjs.com/filters/downcase.html)
/// - SeeAlso: [Python Liquid documentation](https://liquid.readthedocs.io/en/latest/filter_reference/#downcase)
@usableFromInline
package struct DowncaseFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "downcase"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard case .string(let inputString) = token else {
            return .nil
        }
        
        return .string(inputString.lowercased())
    }
}