import Foundation

@usableFromInline
package struct DefaultFilter: Filter {
  @usableFromInline
  package static let filterIdentifier = "default"
  
  @inlinable
  package init() {}
  
  @inlinable
  package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
    // If the value is nil, empty string, or false, return the default value
    switch token {
    case .nil:
      return parameters.isEmpty ? .nil : parameters[0]
    case .string(let str) where str.isEmpty:
      return parameters.isEmpty ? .nil : parameters[0]
    case .bool(false):
      return parameters.isEmpty ? .nil : parameters[0]
    default:
      return token
    }
  }
}