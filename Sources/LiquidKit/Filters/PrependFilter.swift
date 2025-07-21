import Foundation

@usableFromInline
package struct PrependFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "prepend"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard case .string(let string) = token else {
            return token
        }
        
        guard parameters.count >= 1,
              case .string(let prefix) = parameters[0] else {
            return token
        }
        
        return .string(prefix + string)
    }
}