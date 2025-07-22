import Foundation

/// Implements the `append` filter, which concatenates a string to the end of another string.
/// 
/// The append filter is used for string concatenation, adding the specified text to the end
/// of the input value. This is one of the fundamental string manipulation filters in Liquid,
/// commonly used for building URLs, file paths, CSS classes, or any scenario where you need
/// to combine strings. Both the input value and the parameter are converted to strings before
/// concatenation, making it flexible for use with various data types.
/// 
/// The filter requires exactly one parameter - the string to append. If no parameter is
/// provided, it results in an error in strict implementations. Any value type can be used
/// as both input and parameter, as they will be converted to strings.
/// 
/// ## Examples
/// 
/// Basic string concatenation:
/// ```liquid
/// {{ "Hello" | append: " World" }}      → Hello World
/// {{ "file" | append: ".txt" }}         → file.txt
/// {{ "/path/to" | append: "/file" }}    → /path/to/file
/// ```
/// 
/// Type conversion:
/// ```liquid
/// {{ "Version " | append: 2.0 }}        → Version 2.0
/// {{ 5 | append: " items" }}            → 5 items
/// {{ true | append: " value" }}         → true value
/// ```
/// 
/// Edge cases:
/// ```liquid
/// {{ nil | append: "text" }}            → text
/// {{ "text" | append: nil }}            → text
/// {{ "" | append: "text" }}             → text
/// ```
/// 
/// > Important: When either the input or parameter is nil/undefined, it is treated as an
/// > empty string for concatenation purposes. This allows for safe concatenation even with
/// > potentially missing values.
/// 
/// > Warning: The append filter requires exactly one parameter. Missing parameters or
/// > multiple parameters will cause an error in strict Liquid implementations, though
/// > this implementation currently returns nil for missing parameters and ignores extras.
/// 
/// - SeeAlso: ``PrependFilter``, ``RemoveFilter``, ``RemoveFirstFilter``, ``ReplaceFilter``
/// - SeeAlso: [LiquidJS append](https://liquidjs.com/filters/append.html)
/// - SeeAlso: [Python Liquid append](https://liquid.readthedocs.io/en/latest/filter_reference/#append)
/// - SeeAlso: [Shopify Liquid append](https://shopify.github.io/liquid/filters/append/)
@usableFromInline
package struct AppendFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "append"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard let stringParameter = parameters.first?.stringValue else
        {
            return .nil
        }
        
        return .string(token.stringValue + stringParameter)
    }
}