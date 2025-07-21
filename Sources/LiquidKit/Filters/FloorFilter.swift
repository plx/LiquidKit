import Foundation
import Darwin

struct FloorFilter: Filter {
  static let filterIdentifier = "floor"
  
  func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
    guard let inputDouble = token.doubleValue else {
      return .nil
    }
    
    return .decimal(Decimal(Int(Darwin.floor(inputDouble))))
  }
}