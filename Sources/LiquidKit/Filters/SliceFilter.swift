import Foundation

/// Implements the `slice` filter, which extracts a substring or subarray from the input.
///
/// The `slice` filter works with both strings and arrays, returning a single element or a
/// subsequence starting from a specified index. It accepts one or two parameters: the starting
/// index (which can be negative to count from the end), and optionally the length of the
/// subsequence to extract. When only one parameter is provided, it returns a single character
/// (for strings) or element (for arrays) at that index. With two parameters, it returns a
/// substring or subarray of the specified length starting from the given index.
///
/// The filter handles both positive and negative indices. Positive indices count from the
/// beginning (0-based), while negative indices count from the end (-1 is the last element).
/// For strings: If the starting index is out of bounds, an empty string is returned.
/// For arrays: If the starting index is out of bounds for single element access, nil is
/// returned; for range access, an empty array is returned.
///
/// ## Examples
///
/// String slicing - extract a single character:
/// ```liquid
/// {{ "Liquid" | slice: 0 }}    // Output: "L"
/// {{ "Liquid" | slice: 2 }}    // Output: "q"
/// {{ "Liquid" | slice: -1 }}   // Output: "d"
/// {{ "Liquid" | slice: -2 }}   // Output: "i"
/// ```
///
/// String slicing - extract a substring:
/// ```liquid
/// {{ "Liquid" | slice: 2, 3 }}  // Output: "qui"
/// {{ "Liquid" | slice: 0, 3 }}  // Output: "Liq"
/// {{ "Liquid" | slice: -3, 2 }} // Output: "ui"
/// {{ "Liquid" | slice: -2, 99 }} // Output: "id" (length capped at string end)
/// ```
///
/// Array slicing - extract a single element:
/// ```liquid
/// {% assign beatles = "John, Paul, George, Ringo" | split: ", " %}
/// {{ beatles | slice: 0 }}     // Output: "John"
/// {{ beatles | slice: 1 }}     // Output: "Paul"
/// {{ beatles | slice: -1 }}    // Output: "Ringo"
/// {{ beatles | slice: -2 }}    // Output: "George"
/// ```
///
/// Array slicing - extract a subarray:
/// ```liquid
/// {% assign beatles = "John, Paul, George, Ringo" | split: ", " %}
/// {{ beatles | slice: 1, 2 | join: " " }}  // Output: "Paul George"
/// {{ beatles | slice: -3, 2 | join: " " }} // Output: "Paul George"
/// ```
///
/// Edge cases:
/// ```liquid
/// {{ "hello" | slice: 99 }}     // Output: "" (index out of bounds)
/// {{ "hello" | slice: 1, 0 }}   // Output: "" (zero length)
/// {{ "hello" | slice: -2, -1 }} // Output: "" (negative length)
/// {{ true | slice: 0 }}         // Output: "t" (boolean converted to "true")
/// {{ false | slice: 0, 3 }}     // Output: "fal" (boolean converted to "false")
/// {{ 123 | slice: 1 }}          // Output: "2" (number converted to string)
/// ```
///
/// - Note: This filter works with both strings and arrays, matching the behavior of
///   liquidjs and python-liquid implementations. Non-string, non-array values are
///   converted to strings before processing, with special handling for booleans
///   (true → "true", false → "false").
///
/// - Warning: The filter expects integer parameters. Non-integer values for the
///   index or length parameters are treated as 0 when converted.
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
    // If no parameters provided, return the original value unchanged
    guard !parameters.isEmpty else {
      return token
    }
    
    // Get the start index parameter (required)
    let startIndex = parameters[0].integerValue ?? 0
    
    // Check if we're dealing with an array or a string
    switch token {
    case .array(let array):
      // Array slicing logic
      return sliceArray(array, startIndex: startIndex, parameters: parameters)
      
    case .bool(let value):
      // Special handling for boolean values to match liquidjs/python-liquid behavior
      let boolString = value ? "true" : "false"
      return sliceString(boolString, startIndex: startIndex, parameters: parameters)
      
    default:
      // String slicing logic (for all other types, convert to string first)
      return sliceString(token.stringValue, startIndex: startIndex, parameters: parameters)
    }
  }
  
  /// Slices an array based on the provided parameters
  /// - Parameters:
  ///   - array: The array to slice
  ///   - startIndex: The starting index (can be negative)
  ///   - parameters: All filter parameters
  /// - Returns: A sliced array or single element
  @usableFromInline
  func sliceArray(_ array: [Token.Value], startIndex: Int, parameters: [Token.Value]) -> Token.Value {
    // Calculate the actual start index, handling negative indices
    let actualStart: Int
    if startIndex < 0 {
      // Negative index counts from the end
      actualStart = array.count + startIndex
    } else {
      actualStart = startIndex
    }
    
    // If only one parameter, return single element
    if parameters.count == 1 {
      // Check bounds
      guard actualStart >= 0 && actualStart < array.count else {
        return .nil // Return nil for out of bounds single element access
      }
      return array[actualStart]
    }
    
    // Get the length parameter for range slicing
    let length = parameters[1].integerValue ?? 0
    
    // Return empty array for zero or negative length
    guard length > 0 else {
      return .array([])
    }
    
    // Check if start is out of bounds
    guard actualStart >= 0 && actualStart < array.count else {
      return .array([])
    }
    
    // Calculate end index, clamping to array bounds
    let endIndex = min(actualStart + length, array.count)
    
    // Extract the slice
    let slice = Array(array[actualStart..<endIndex])
    return .array(slice)
  }
  
  /// Slices a string based on the provided parameters
  /// - Parameters:
  ///   - string: The string to slice
  ///   - startIndex: The starting index (can be negative)
  ///   - parameters: All filter parameters
  /// - Returns: A sliced string
  @usableFromInline
  func sliceString(_ string: String, startIndex: Int, parameters: [Token.Value]) -> Token.Value {
    // Calculate the actual start index, handling negative indices
    let actualStart: Int
    if startIndex < 0 {
      // Negative index counts from the end
      actualStart = string.count + startIndex
    } else {
      actualStart = startIndex
    }
    
    // If only one parameter, return single character
    if parameters.count == 1 {
      // Check bounds
      guard actualStart >= 0 && actualStart < string.count else {
        return .string("") // Return empty string for out of bounds
      }
      
      let stringIndex = string.index(string.startIndex, offsetBy: actualStart)
      return .string(String(string[stringIndex]))
    }
    
    // Get the length parameter for substring extraction
    let length = parameters[1].integerValue ?? 0
    
    // Return empty string for zero or negative length
    guard length > 0 else {
      return .string("")
    }
    
    // Check if start is out of bounds
    guard actualStart >= 0 && actualStart < string.count else {
      return .string("")
    }
    
    // Calculate end offset, clamping to string length
    let endOffset = min(actualStart + length, string.count)
    
    // Extract the substring
    let startStringIndex = string.index(string.startIndex, offsetBy: actualStart)
    let endStringIndex = string.index(string.startIndex, offsetBy: endOffset)
    
    return .string(String(string[startStringIndex..<endStringIndex]))
  }
}