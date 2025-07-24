import Foundation

/// Implements the `minus` filter, which subtracts a number from another number.
/// 
/// The `minus` filter performs arithmetic subtraction, subtracting the filter parameter
/// from the input value. Both the input and parameter are converted to numeric values
/// before the operation. The filter intelligently preserves numeric types: if both
/// operands are integers and the result is a whole number, it returns an integer;
/// otherwise, it returns a decimal value.
/// 
/// String values that can be parsed as numbers are automatically converted. Strings
/// containing decimal points (e.g., "2.0") or negative exponents (e.g., "1e-2") are
/// treated as decimal values, preserving the decimal type in the result. Non-numeric
/// strings and nil values are treated as 0. Invalid numeric strings (e.g., "123abc") 
/// are also treated as 0. This lenient conversion behavior allows the filter to work 
/// with various data types without throwing errors, making templates more robust when 
/// dealing with user input or dynamic data.
/// 
/// ## Examples
/// 
/// Basic integer subtraction:
/// ```liquid
/// {{ 10 | minus: 2 }}
/// // Output: 8
/// ```
/// 
/// Decimal subtraction:
/// ```liquid
/// {{ 10.1 | minus: 2.2 }}
/// // Output: 7.9
/// ```
/// 
/// String to number conversion:
/// ```liquid
/// {{ "10.1" | minus: "2.2" }}
/// // Output: 7.9
/// ```
/// 
/// Non-numeric string handling:
/// ```liquid
/// {{ "foo" | minus: "2.0" }}
/// // Output: -2.0
/// ```
/// 
/// Nil value handling:
/// ```liquid
/// {{ nosuchthing | minus: 2 }}
/// // Output: -2
/// ```
/// 
/// Mixed integer and decimal:
/// ```liquid
/// {{ 10 | minus: 2.0 }}
/// // Output: 8.0
/// ```
/// 
/// - Important: The filter preserves integer types when possible. If both input and
///   parameter are integers and the result has no fractional part, an integer is returned.
/// 
/// - SeeAlso: ``PlusFilter``, ``TimesFilter``, ``DividedByFilter``, ``ModuloFilter``
/// - SeeAlso: [LiquidJS Documentation](https://liquidjs.com/filters/minus.html)
/// - SeeAlso: [Python Liquid Documentation](https://liquid.readthedocs.io/en/latest/filter_reference/#minus)
/// - SeeAlso: [Shopify Liquid Documentation](https://shopify.github.io/liquid/filters/minus/)
@usableFromInline
package struct MinusFilter: Filter {
  @usableFromInline
  package static let filterIdentifier = "minus"
  
  @inlinable
  package init() {}
  
  @inlinable
  package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
    // If no parameters provided, return the input unchanged
    guard !parameters.isEmpty else {
      return token
    }
    
    // Helper to parse numeric strings more strictly
    // Returns nil if the string is not a valid number
    func parseNumericString(_ s: String) -> Decimal? {
      let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines)
      
      // Empty string is not a valid number
      if trimmed.isEmpty {
        return nil
      }
      
      // Try to parse with Decimal
      guard let decimal = Decimal(string: trimmed) else {
        return nil
      }
      
      // Verify the entire string was consumed by checking with Double
      // Double is stricter about what it accepts
      if Double(trimmed) != nil {
        return decimal
      }
      
      // If Double can't parse it, the string has invalid characters
      return nil
    }
    
    // Get the numeric value and track if it's integer-like
    let leftValue: Decimal
    let leftIsInteger: Bool
    
    switch token {
    case .integer(let i):
      leftValue = Decimal(i)
      leftIsInteger = true
    case .decimal(let d):
      leftValue = d
      leftIsInteger = false
    case .string(let s):
      if let parsed = parseNumericString(s) {
        leftValue = parsed
        // Check if the string represents an integer (no decimal point or exponent with decimal)
        let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines)
        let hasDecimalPoint = trimmed.contains(".") || trimmed.lowercased().contains("e-")
        
        // If it has a decimal point or negative exponent, it's not an integer
        if hasDecimalPoint {
          leftIsInteger = false
        } else if let double = Double(exactly: parsed as NSNumber),
                  double >= Double(Int.min) && double <= Double(Int.max) && double == floor(double) {
          // No decimal point and the value is a whole number within Int bounds
          leftIsInteger = true
        } else {
          leftIsInteger = false
        }
      } else {
        // Non-numeric string becomes 0 and is treated as integer
        leftValue = 0
        leftIsInteger = true
      }
    default:
      // nil, bool, array, dict, range all become 0 and are treated as integer
      leftValue = 0
      leftIsInteger = true
    }
    
    let rightValue: Decimal
    let rightIsInteger: Bool
    
    switch parameters[0] {
    case .integer(let i):
      rightValue = Decimal(i)
      rightIsInteger = true
    case .decimal(let d):
      rightValue = d
      rightIsInteger = false
    case .string(let s):
      if let parsed = parseNumericString(s) {
        rightValue = parsed
        // Check if the string represents an integer (no decimal point or exponent with decimal)
        let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines)
        let hasDecimalPoint = trimmed.contains(".") || trimmed.lowercased().contains("e-")
        
        // If it has a decimal point or negative exponent, it's not an integer
        if hasDecimalPoint {
          rightIsInteger = false
        } else if let double = Double(exactly: parsed as NSNumber),
                  double >= Double(Int.min) && double <= Double(Int.max) && double == floor(double) {
          // No decimal point and the value is a whole number within Int bounds
          rightIsInteger = true
        } else {
          rightIsInteger = false
        }
      } else {
        // Non-numeric string becomes 0 and is treated as integer
        rightValue = 0
        rightIsInteger = true
      }
    default:
      // nil, bool, array, dict, range all become 0 and are treated as integer
      rightValue = 0
      rightIsInteger = true
    }
    
    // Perform the subtraction
    let result = leftValue - rightValue
    
    // If both values are integer-like and the result fits in an Int, return integer
    if leftIsInteger && rightIsInteger,
       let doubleResult = Double(exactly: result as NSNumber),
       doubleResult >= Double(Int.min) && doubleResult <= Double(Int.max),
       doubleResult == floor(doubleResult) {
      return .integer(Int(doubleResult))
    }
    
    // Otherwise return decimal
    return .decimal(result)
  }
}