import Foundation
import Darwin

@usableFromInline
package struct RoundFilter: Filter {
  @usableFromInline
  package static let filterIdentifier = "round"
  
  @inlinable
  package init() {}
  
  @inlinable
  package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
    guard let value = token.doubleValue else {
      return .nil
    }
    
    // Get precision parameter (default is 0)
    let precision = parameters.first?.integerValue ?? 0
    
    if precision == 0 {
      // Round to nearest integer
      return .decimal(Decimal(Int(Darwin.round(value))))
    } else {
      // Round to specified decimal places
      let multiplier = pow(10.0, Double(precision))
      let rounded = Darwin.round(value * multiplier) / multiplier
      return .decimal(Decimal(rounded))
    }
  }
}