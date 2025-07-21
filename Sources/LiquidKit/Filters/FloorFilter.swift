import Foundation
import Darwin

@usableFromInline
package struct FloorFilter: Filter {
  @usableFromInline
  package static let filterIdentifier = "floor"
  
  @inlinable
  package init() {}
  
  @inlinable
  package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
    guard let inputDouble = token.doubleValue else {
      return .nil
    }
    
    return .decimal(Decimal(Int(Darwin.floor(inputDouble))))
  }
}