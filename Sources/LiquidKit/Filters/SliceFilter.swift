import Foundation

/// Implements the `slice` filter, which extracts a substring or subarray from the input.
///
/// The `slice` filter returns a single character or a substring starting from a specified index.
/// It accepts one or two parameters: the starting index (which can be negative to count from
/// the end), and optionally the length of the substring to extract. When only one parameter
/// is provided, it returns a single character at that index. With two parameters, it returns
/// a substring of the specified length starting from the given index.
///
/// The filter handles both positive and negative indices. Positive indices count from the
/// beginning (0-based), while negative indices count from the end (-1 is the last character).
/// If the starting index is out of bounds or the length is zero or negative, an empty string
/// is returned.
///
/// ## Examples
///
/// Extract a single character:
/// ```liquid
/// {{ "Liquid" | slice: 0 }}    // Output: "L"
/// {{ "Liquid" | slice: 2 }}    // Output: "q"
/// {{ "Liquid" | slice: -1 }}   // Output: "d"
/// {{ "Liquid" | slice: -2 }}   // Output: "i"
/// ```
///
/// Extract a substring:
/// ```liquid
/// {{ "Liquid" | slice: 2, 3 }}  // Output: "qui"
/// {{ "Liquid" | slice: 0, 3 }}  // Output: "Liq"
/// {{ "Liquid" | slice: -3, 2 }} // Output: "ui"
/// {{ "Liquid" | slice: -2, 99 }} // Output: "id" (length capped at string end)
/// ```
///
/// Edge cases:
/// ```liquid
/// {{ "hello" | slice: 99 }}     // Output: "" (index out of bounds)
/// {{ "hello" | slice: 1, 0 }}   // Output: "" (zero length)
/// {{ "hello" | slice: -2, -1 }} // Output: "" (negative length)
/// {{ 123 | slice: 1 }}          // Output: "" (non-string input)
/// ```
///
/// - Important: This filter only works with string inputs. Non-string values are converted
///   to strings before processing, which may produce unexpected results. Array slicing is
///   not currently supported in this implementation.
///
/// - Warning: The filter expects integer parameters. Passing non-integer values for the
///   index or length parameters will cause the filter to fail or produce invalid results
///   according to the Liquid specification.
///
/// - SeeAlso: ``JoinFilter``, ``FirstFilter``, ``LastFilter``
/// - SeeAlso: [Shopify Liquid slice](https://shopify.github.io/liquid/filters/slice/)
/// - SeeAlso: [LiquidJS slice](https://liquidjs.com/filters/slice.html)
/// - SeeAlso: [Python Liquid slice](https://liquid.readthedocs.io/en/latest/filter_reference/#slice)
@usableFromInline
package struct SliceFilter: Filter {
  @usableFromInline
  package static let filterIdentifier = "slice"
  
  @inlinable
  package init() {}
  
  @inlinable
  package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
    guard !parameters.isEmpty else {
      return token
    }
    
    let string = token.stringValue
    let startIndex = parameters[0].integerValue ?? 0
    
    // Handle single character slice
    if parameters.count == 1 {
      let index: Int
      if startIndex < 0 {
        // Negative index counts from the end
        index = string.count + startIndex
      } else {
        index = startIndex
      }
      
      guard index >= 0 && index < string.count else {
        return .string("")
      }
      
      let stringIndex = string.index(string.startIndex, offsetBy: index)
      return .string(String(string[stringIndex]))
    }
    
    // Handle range slice
    guard parameters.count >= 2 else {
      return .string("")
    }
    
    let length = parameters[1].integerValue ?? 0
    
    // Calculate actual start index
    let actualStart: Int
    if startIndex < 0 {
      actualStart = string.count + startIndex
    } else {
      actualStart = startIndex
    }
    
    // Ensure start is within bounds
    guard actualStart >= 0 && actualStart < string.count && length > 0 else {
      return .string("")
    }
    
    // Calculate end index
    let endOffset = min(actualStart + length, string.count)
    
    let startStringIndex = string.index(string.startIndex, offsetBy: actualStart)
    let endStringIndex = string.index(string.startIndex, offsetBy: endOffset)
    
    return .string(String(string[startStringIndex..<endStringIndex]))
  }
}