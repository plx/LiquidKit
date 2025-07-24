import Foundation

/// Implements the `downcase` filter, which converts a string to lowercase.
/// 
/// The `downcase` filter is used to transform text to all lowercase letters. This is commonly used for
/// normalizing text for comparisons, creating consistent formatting, or preparing text for case-insensitive
/// operations. When applied to non-string values, the filter first converts them to their string representation
/// before applying the lowercase transformation, matching the behavior of liquidjs and python-liquid.
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
/// 
/// {{ false | downcase }}
/// // Output: "false"
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
/// - Important: This filter converts non-string inputs to their string representation before applying the\
///   lowercase transformation. Boolean values are converted to "true" or "false", numeric values to their\
///   string representation, and nil values to an empty string.
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
        // Convert the input token to a string representation
        let inputString: String
        
        // Special handling for boolean values to match liquidjs/python-liquid behavior
        switch token {
        case .bool(let value):
            // Boolean values should be converted to "true" or "false" strings
            inputString = value ? "true" : "false"
        case .nil:
            // nil values should convert to empty string, not return .nil
            inputString = ""
        default:
            // For all other types (string, integer, decimal, array, range, dictionary),
            // use the standard stringValue property which handles conversion appropriately
            inputString = token.stringValue
        }
        
        // Apply lowercase transformation to the string representation
        return .string(inputString.lowercased())
    }
}