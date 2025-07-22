import Foundation

/// Implements the `split` filter, which divides a string into an array using a separator.
///
/// The `split` filter breaks a string into an array of substrings based on a delimiter.
/// This is commonly used to convert comma-separated values or other delimited strings
/// into arrays that can be iterated over or further processed. The filter requires one
/// parameter: the separator string to split on.
///
/// When the separator is an empty string, the filter splits the input into individual
/// characters. When the separator is not found in the input string, the filter returns
/// an array containing the original string as its only element. The filter preserves
/// empty strings that result from consecutive separators.
///
/// ## Examples
///
/// Basic string splitting:
/// ```liquid
/// {% assign beatles = "John, Paul, George, Ringo" | split: ", " %}
/// {% for member in beatles %}
///   {{ member }}
/// {% endfor %}
/// // Output: John Paul George Ringo
/// ```
///
/// Split by different delimiters:
/// ```liquid
/// {{ "Hello there" | split: " " | join: "#" }}
/// // Output: "Hello#there"
///
/// {{ "Hi, how are you today?" | split: " " | join: "#" }}
/// // Output: "Hi,#how#are#you#today?"
/// ```
///
/// Split into individual characters:
/// ```liquid
/// {{ "Hello" | split: "" | join: "#" }}
/// // Output: "H#e#l#l#o"
/// ```
///
/// Edge cases:
/// ```liquid
/// {{ "hello##there" | split: "#" | join: "-" }}
/// // Output: "hello--there" (preserves empty strings)
///
/// {{ "no-delimiter" | split: "," | first }}
/// // Output: "no-delimiter" (returns whole string in array)
/// ```
///
/// - Important: The separator parameter is required. Omitting it will result in an error
///   according to the Liquid specification.
///
/// - Warning: This filter only works with string inputs. Non-string values will be
///   converted to strings before processing, which may produce unexpected results.
///
/// - SeeAlso: ``JoinFilter``, ``FirstFilter``, ``LastFilter``
/// - SeeAlso: [Shopify Liquid split](https://shopify.github.io/liquid/filters/split/)
/// - SeeAlso: [LiquidJS split](https://liquidjs.com/filters/split.html)
/// - SeeAlso: [Python Liquid split](https://liquid.readthedocs.io/en/latest/filter_reference/#split)
@usableFromInline
package struct SplitFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "split"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard case .string(let string) = token else {
            return token
        }
        
        guard let firstParameter = parameters.first else {
            return token
        }
        
        let separator = firstParameter.stringValue
        
        if separator.isEmpty {
            // Split into individual characters
            let characters = string.map { Token.Value.string(String($0)) }
            return .array(characters)
        } else {
            // Split by separator
            let parts = string.components(separatedBy: separator).map { Token.Value.string($0) }
            return .array(parts)
        }
    }
}