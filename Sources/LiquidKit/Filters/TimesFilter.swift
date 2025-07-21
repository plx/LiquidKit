import Foundation

@usableFromInline
package struct TimesFilter: Filter {
  @usableFromInline
  package static let filterIdentifier = "times"
  
  @inlinable
  package init() {}
  
  @inlinable
  package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
    guard !parameters.isEmpty else {
      return token
    }
    
    let left = token.doubleValue ?? 0
    let right = parameters[0].doubleValue ?? 0
    let result = left * right
    
    // If both operands were integers, return an integer
    if case .integer = token,
       case .integer = parameters[0],
       result == Double(Int(result)) {
      return .integer(Int(result))
    }
    
    return .decimal(Decimal(result))
  }
}