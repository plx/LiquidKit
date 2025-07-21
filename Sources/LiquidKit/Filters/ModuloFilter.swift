import Foundation

@usableFromInline
package struct ModuloFilter: Filter {
  @usableFromInline
  package static let filterIdentifier = "modulo"
  
  @inlinable
  package init() {}
  
  @inlinable
  package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
    guard !parameters.isEmpty else {
      return token
    }
    
    let left = token.doubleValue ?? 0
    let right = parameters[0].doubleValue ?? 0
    
    guard right != 0 else {
      return .integer(0)
    }
    
    let result = left.truncatingRemainder(dividingBy: right)
    
    // If both operands were integers and result is a whole number, return an integer
    if case .integer = token,
       case .integer = parameters[0],
       result == Double(Int(result)) {
      return .integer(Int(result))
    }
    
    return .decimal(Decimal(result))
  }
}