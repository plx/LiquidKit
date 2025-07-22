import Foundation
import Darwin

/// Implements the `divided_by` filter, which performs division operations on numeric values.
/// 
/// The `divided_by` filter divides the input value by a given divisor, with different behavior
/// depending on whether the divisor is an integer or a decimal. When dividing by an integer,
/// the result is truncated to an integer (floor division). When dividing by a decimal value,
/// the result maintains decimal precision. This dual behavior allows for both integer arithmetic
/// and precise decimal calculations within the same filter.
/// 
/// The filter properly handles division by zero by throwing an error rather than returning
/// infinity or NaN. This helps catch mathematical errors early and provides clear error messages.
/// Non-numeric inputs or missing divisors return nil, allowing for graceful handling in filter chains.
/// 
/// ## Examples
/// 
/// Integer division (truncated):
/// ```liquid
/// {{ 16 | divided_by: 4 }}
/// <!-- Output: 4 -->
/// 
/// {{ 5 | divided_by: 3 }}
/// <!-- Output: 1 (truncated, not rounded) -->
/// 
/// {{ 7 | divided_by: 2 }}
/// <!-- Output: 3 -->
/// ```
/// 
/// Decimal division (precise):
/// ```liquid
/// {{ 20 | divided_by: 7.0 }}
/// <!-- Output: 2.857142857142857 -->
/// 
/// {{ 10 | divided_by: 3.0 }}
/// <!-- Output: 3.333333333333333 -->
/// ```
/// 
/// Mixed numeric types:
/// ```liquid
/// {{ 9.0 | divided_by: 2 }}
/// <!-- Output: 4 (integer result) -->
/// 
/// {{ 10 | divided_by: 2.0 }}
/// <!-- Output: 5.0 (decimal result) -->
/// ```
/// 
/// - Important: Division by an integer always returns an integer result (floor division),
///   while division by a decimal returns a decimal result. This is not about the input type
///   but the divisor type.
/// 
/// - Warning: Division by zero throws a FilterError with a descriptive message. Ensure your
///   templates handle potential zero divisors appropriately.
/// 
/// - Warning: Very large division results may lose precision due to floating-point limitations.
///   
/// - SeeAlso: ``TimesFilter``
/// - SeeAlso: ``MinusFilter``
/// - SeeAlso: ``PlusFilter``
/// - SeeAlso: ``ModuloFilter``
/// - SeeAlso: [Shopify Liquid divided_by](https://shopify.github.io/liquid/filters/divided_by/)
/// - SeeAlso: [LiquidJS divided_by](https://liquidjs.com/filters/divided_by.html)
/// - SeeAlso: [Python Liquid divided_by](https://liquid.readthedocs.io/en/latest/filters/divided_by/)
@usableFromInline
package struct DividedByFilter: Filter {
  @usableFromInline
  package static let filterIdentifier = "divided_by"
  
  @inlinable
  package init() {}
  
  @inlinable
  package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
    guard let dividendDouble = token.doubleValue, let divisor = parameters.first else {
      return .nil
    }
    
    switch divisor {
    case .integer(let divisorInt):
      guard divisorInt != 0 else {
        throw FilterError.invalidArgument(
          "Attempted to call `divided_by` on `\(token) with 0 as the divisor!"
        )
      }
      return .integer(Int(Darwin.floor(dividendDouble / Double(divisorInt))))
      
    case .decimal:
      guard let divisorDouble = divisor.doubleValue else {
        return .nil
      }
      guard divisorDouble != 0 else {
        throw FilterError.invalidArgument(
          "Attempted to call `divided_by` on `\(token) with 0 as the divisor!"
        )
      }
      return .decimal(Decimal(dividendDouble / divisorDouble))
      
    default:
      return .nil
    }
  }
}

