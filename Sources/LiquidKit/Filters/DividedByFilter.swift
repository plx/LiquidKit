import Foundation
import Darwin

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

