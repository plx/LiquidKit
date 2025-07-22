import Foundation

/// Implements the `capitalize` filter, which capitalizes the first word of a string.
/// 
/// The `capitalize` filter makes the first letter of the first word in a string uppercase
/// while leaving the rest of the string unchanged. This filter uses locale-aware word
/// boundary detection to find the first word and applies localized capitalization rules.
/// Unlike some string manipulation functions that capitalize every word, this filter only
/// affects the first word found in the input.
/// 
/// The filter converts any input value to a string before processing. If the input contains
/// no words (e.g., only punctuation or whitespace), the original string is returned unchanged.
/// Empty strings or `nil` values return `nil`.
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
/// Already capitalized strings remain unchanged:
/// ```liquid
/// {{ "Hello" | capitalize }}
/// <!-- Output: Hello -->
/// 
/// {{ "HELLO WORLD" | capitalize }}
/// <!-- Output: HELLO WORLD -->
/// ```
/// 
/// Edge cases with punctuation and special characters:
/// ```liquid
/// {{ "123 hello" | capitalize }}
/// <!-- Output: 123 Hello -->
/// 
/// {{ "...hello" | capitalize }}
/// <!-- Output: ...Hello -->
/// 
/// {{ undefined_variable | capitalize }}
/// <!-- Output: (empty string) -->
/// ```
/// 
/// - Important: Only the first word is capitalized, not every word in the string. The \
///   filter uses locale-aware word boundary detection, so behavior may vary slightly \
///   depending on the system locale.
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
        let inputString = token.stringValue
        
        guard inputString.count > 0 else {
            return .nil
        }
        
        var firstWord: String?
        var firstWordRange: Range<String.Index>?
        
        inputString.enumerateSubstrings(in: inputString.startIndex..., options: .byWords) {
            (word, range, _, stop) in
            
            firstWord = word
            firstWordRange = range
            stop = true
        }
        
        guard let word = firstWord, let range = firstWordRange else {
            return .string(inputString)
        }
        
        return .string(inputString.replacingCharacters(in: range, with: word.localizedCapitalized))
    }
}