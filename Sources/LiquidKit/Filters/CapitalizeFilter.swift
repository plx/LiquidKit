import Foundation

/// Implements the `capitalize` filter, which capitalizes the first character of a string.
/// 
/// The `capitalize` filter makes the first character of a string uppercase and converts
/// the rest of the string to lowercase. This behavior matches the standard Liquid
/// implementations in liquidjs and python-liquid. The filter operates on the entire
/// string as a single unit, not on individual words.
/// 
/// The filter converts any input value to a string before processing. Boolean values
/// are converted to "true" or "false" before capitalization. Empty strings and `nil` 
/// values return an empty string.
/// 
/// ## Examples
/// 
/// Basic capitalization:
/// ```liquid
/// {{ "hello" | capitalize }}
/// <!-- Output: Hello -->
/// 
/// {{ "hello world" | capitalize }}
/// <!-- Output: Hello world -->
/// ```
/// 
/// Uppercase strings are lowercased except for the first character:
/// ```liquid
/// {{ "HELLO" | capitalize }}
/// <!-- Output: Hello -->
/// 
/// {{ "HELLO WORLD" | capitalize }}
/// <!-- Output: Hello world -->
/// ```
/// 
/// Edge cases with punctuation and special characters:
/// ```liquid
/// {{ "123 hello" | capitalize }}
/// <!-- Output: 123 hello -->
/// 
/// {{ "...hello" | capitalize }}
/// <!-- Output: ...hello -->
/// 
/// {{ undefined_variable | capitalize }}
/// <!-- Output: (empty string) -->
/// 
/// {{ true | capitalize }}
/// <!-- Output: True -->
/// 
/// {{ false | capitalize }}
/// <!-- Output: False -->
/// ```
/// 
/// - Important: This filter capitalizes only the first character of the entire string \
///   and lowercases all remaining characters. It does not capitalize each word separately.
/// 
/// - Warning: The filter does not accept any parameters. Passing parameters will result \
///   in an error in strict Liquid implementations.
/// 
/// - SeeAlso: ``DowncaseFilter``, ``UpcaseFilter``
/// - SeeAlso: [Shopify Liquid capitalize](https://shopify.github.io/liquid/filters/capitalize/)
/// - SeeAlso: [LiquidJS capitalize](https://liquidjs.com/filters/capitalize.html)
/// - SeeAlso: [Python Liquid capitalize](https://liquid.readthedocs.io/en/latest/filter_reference/#capitalize)
@usableFromInline
package struct CapitalizeFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "capitalize"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        // Handle special cases for boolean values
        let inputString: String
        switch token {
        case .bool(let value):
            // Boolean values should be converted to "true" or "false" strings
            inputString = value ? "true" : "false"
        default:
            // For all other types, use the standard stringValue property
            inputString = token.stringValue
        }
        
        // Empty strings should return empty string, not nil
        guard inputString.count > 0 else {
            return .string("")
        }
        
        // Find the first character in the string
        guard let firstChar = inputString.first else {
            return .string(inputString)
        }
        
        // Get the uppercase version of the first character
        let uppercasedFirst = String(firstChar).uppercased()
        
        // If the string is only one character, return just the uppercased character
        if inputString.count == 1 {
            return .string(uppercasedFirst)
        }
        
        // Otherwise, combine the uppercase first character with the lowercase rest
        // Get everything after the first character
        let startIndex = inputString.index(after: inputString.startIndex)
        let remainingString = String(inputString[startIndex...])
        
        // Return the capitalized first character + the lowercase rest
        return .string(uppercasedFirst + remainingString.lowercased())
    }
}