
/// Implements the `contains` operator, which tests whether a collection contains a specific value or a string contains a substring.
/// 
/// The `contains` operator is one of Liquid's comparison operators that checks for the presence of a value within another value.
/// It has two primary modes of operation: substring matching for strings and element matching for arrays. When used with strings,
/// it performs a case-sensitive substring search. When used with arrays, it checks for exact element matches using string comparison.
/// The operator is commonly used in conditional statements to filter content based on the presence of specific values.
/// 
/// ## String Contains
/// 
/// When both operands are strings, `contains` checks if the right-hand string is a substring of the left-hand string:
/// 
/// ```liquid
/// {% if product.title contains "Pack" %}
///   This product's title contains the word Pack.
/// {% endif %}
/// 
/// {% if "hello world" contains "llo" %}
///   Found substring!
/// {% endif %}
/// ```
/// 
/// ## Array Contains
/// 
/// When the left operand is an array and the right is a string, `contains` checks if the array contains that exact string element:
/// 
/// ```liquid
/// {% if product.tags contains "garden" %}
///   This product has been tagged with "garden".
/// {% endif %}
/// 
/// {% assign fruits = "apple,banana,orange" | split: "," %}
/// {% if fruits contains "banana" %}
///   We have bananas!
/// {% endif %}
/// ```
/// 
/// ## Edge Cases and Special Behavior
/// 
/// The operator handles several edge cases with specific behaviors:
/// 
/// ```liquid
/// // Numbers are converted to strings for comparison
/// {% if "hel9lo" contains 9 %}  // TRUE - 9 is stringified to "9"
/// 
/// // Empty string is contained in every string (matches Ruby/Python behavior)
/// {% if "hello" contains "" %}  // TRUE
/// {% if "" contains "" %}  // TRUE
/// 
/// // Arrays stringify elements for comparison
/// {% assign nums = "1,2,3" | split: "," %}
/// {% if nums contains 2 %}  // TRUE - number 2 is stringified to "2"
/// 
/// // Nil, undefined, and non-string values cannot be found
/// {% if array contains nil %}  // FALSE
/// {% if array contains undefined_var %}  // FALSE
/// {% if array contains false %}  // FALSE - booleans are not stringified
/// 
/// // Non-string/non-array left operands return false
/// {% if 123 contains "2" %}  // FALSE
/// {% if nil contains "anything" %}  // FALSE
/// ```
/// 
/// - Important: The `contains` operator stringifies numbers for comparison but not booleans or nil values. \
///   When checking arrays, it performs exact string matches after stringification, not partial matches. \
///   For example, an array containing "Black and White" will not match a search for "Black".
/// 
/// - Important: This implementation follows the standard Liquid behavior from Ruby/liquidjs/python-liquid. \
///   Dictionary/hash types are not supported as the left operand and will always return false.
/// 
/// - Warning: The operator always returns false for unsupported type combinations rather than throwing \
///   an error. This includes cases like checking if a number contains a string or if nil contains \
///   anything.
/// 
/// - SeeAlso: ``EqualsOperator``
/// - SeeAlso: [Shopify Liquid - Operators](https://shopify.github.io/liquid/basics/operators/)
/// - SeeAlso: [LiquidJS - Operators](https://liquidjs.com/tutorials/operators.html)
/// - SeeAlso: [Python Liquid - Syntax](https://liquid.readthedocs.io/en/latest/syntax/)
public struct ContainsOperator: Operator {
  
  public static let operatorIdentifier: String = "contains"
  
  public func apply(_ lhs: Token.Value, _ rhs: Token.Value) -> Token.Value {
    // First, we need to stringify the right-hand side value for comparison
    // This is necessary because contains always works with string comparisons
    let rhsString: String
    switch rhs {
    case .string(let s):
      rhsString = s
    case .integer(let i):
      rhsString = String(i)
    case .decimal(let d):
      rhsString = String(describing: d)
    case .nil:
      // nil values cannot be found by contains
      return .bool(false)
    case .bool, .array, .dictionary, .range:
      // Other non-string types cannot be searched for
      return .bool(false)
    }
    
    // Now check the left-hand side
    switch lhs {
    case .string(let haystack):
      // String contains: check if the haystack contains the needle substring
      // Special case: empty string is contained in every string (Ruby/Python behavior)
      if rhsString.isEmpty {
        return .bool(true)
      }
      let result = haystack.contains(rhsString)
      return .bool(result)
      
    case .array(let array):
      // Array contains: check if any element in the array equals the search string
      // We need to stringify each array element for comparison
      for element in array {
        let elementString: String
        switch element {
        case .string(let s):
          elementString = s
        case .integer(let i):
          elementString = String(i)
        case .decimal(let d):
          elementString = String(describing: d)
        case .nil, .bool, .array, .dictionary, .range:
          // Skip non-stringifiable values
          continue
        }
        
        // Check if this element matches our search string
        if elementString == rhsString {
          return .bool(true)
        }
      }
      return .bool(false)
      
    case .nil, .integer, .decimal, .bool, .dictionary, .range:
      // All other types as left operand return false
      return .bool(false)
    }
  }
  
  @inlinable
  package init() { }
}
