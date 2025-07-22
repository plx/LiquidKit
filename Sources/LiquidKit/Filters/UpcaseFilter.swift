import Foundation

/// Implements the `upcase` filter, which converts a string to uppercase.
/// 
/// The upcase filter transforms all alphabetic characters in a string to their uppercase
/// equivalents. This is one of the most basic text transformation filters, commonly used
/// for formatting headers, emphasis, or standardizing text display. The filter uses the
/// locale-aware uppercasing provided by Swift's String implementation, which correctly
/// handles international characters and special casing rules.
/// 
/// Non-string inputs are returned unchanged, making the filter safe to use in filter
/// chains where the value type might be uncertain. This behavior allows for graceful
/// handling of mixed-type data without causing template errors.
/// 
/// ## Examples
/// 
/// Basic usage with strings:
/// ```liquid
/// {{ "Parker Moore" | upcase }}
/// → "PARKER MOORE"
/// 
/// {{ "hello world" | upcase }}
/// → "HELLO WORLD"
/// ```
/// 
/// Already uppercase strings remain unchanged:
/// ```liquid
/// {{ "APPLE" | upcase }}
/// → "APPLE"
/// ```
/// 
/// International character support:
/// ```liquid
/// {{ "café résumé" | upcase }}
/// → "CAFÉ RÉSUMÉ"
/// 
/// {{ "über größe" | upcase }}
/// → "ÜBER GRÖSSE"
/// ```
/// 
/// Non-string values pass through:
/// ```liquid
/// {{ 123 | upcase }}
/// → 123
/// 
/// {{ true | upcase }}
/// → true
/// ```
/// 
/// - Important: The filter preserves non-alphabetic characters such as numbers,\
///   punctuation, and whitespace exactly as they appear in the input.
/// 
/// - Important: For non-string inputs, the filter returns the value unchanged rather\
///   than converting it to a string first. Use the `string` filter before `upcase`\
///   if you need to uppercase the string representation of non-string values.
/// 
/// - SeeAlso: ``DowncaseFilter`` for converting to lowercase
/// - SeeAlso: ``CapitalizeFilter`` for capitalizing only the first letter
/// - SeeAlso: [LiquidJS upcase](https://liquidjs.com/filters/upcase.html)
/// - SeeAlso: [Python Liquid upcase](https://liquid.readthedocs.io/en/latest/filter_reference/#upcase)
/// - SeeAlso: [Shopify Liquid upcase](https://shopify.github.io/liquid/filters/upcase/)
@usableFromInline
package struct UpcaseFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "upcase"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard case .string(let string) = token else {
            return token
        }
        
        return .string(string.uppercased())
    }
}