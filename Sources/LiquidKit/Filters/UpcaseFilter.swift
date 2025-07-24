import Foundation

/// Implements the `upcase` filter, which converts a string to uppercase.
/// 
/// The `upcase` filter is used to transform text to all uppercase letters. This is commonly used for
/// formatting headers, creating emphasis, or standardizing text display. When applied to non-string values,
/// the filter first converts them to their string representation before applying the uppercase transformation,
/// matching the behavior of liquidjs and python-liquid. The filter uses the locale-aware uppercasing
/// provided by Swift's String implementation, which correctly handles international characters and special
/// casing rules.
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
/// With non-string values:
/// ```liquid
/// {{ 5 | upcase }}
/// → "5"
/// 
/// {{ true | upcase }}
/// → "TRUE"
/// 
/// {{ false | upcase }}
/// → "FALSE"
/// ```
/// 
/// With undefined or nil values:
/// ```liquid
/// {{ undefined_variable | upcase }}
/// → ""
/// 
/// {{ nil | upcase }}
/// → ""
/// ```
/// 
/// - Important: This filter converts non-string inputs to their string representation before applying the\
///   uppercase transformation. Boolean values are converted to "TRUE" or "FALSE", numeric values to their\
///   string representation, and nil values to an empty string.
/// 
/// - Warning: The `upcase` filter does not accept any parameters. Passing parameters will result in an error\
///   in strict Liquid implementations.
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
        // Convert the input token to a string representation
        let inputString: String
        
        // Special handling for boolean values to match liquidjs/python-liquid behavior
        switch token {
        case .bool(let value):
            // Boolean values should be converted to "true" or "false" strings
            // When uppercased, these become "TRUE" or "FALSE"
            inputString = value ? "true" : "false"
        case .nil:
            // nil values should convert to empty string, not return .nil
            // This matches the behavior of python-liquid where nil/None becomes ""
            inputString = ""
        default:
            // For all other types (string, integer, decimal, array, range, dictionary),
            // use the standard stringValue property which handles conversion appropriately
            // - Strings return themselves
            // - Integers/decimals convert to their string representation
            // - Arrays concatenate their elements' string values
            // - Ranges return format like "1..5"
            // - Dictionaries return empty string
            inputString = token.stringValue
        }
        
        // Apply uppercase transformation to the string representation
        return .string(inputString.uppercased())
    }
}