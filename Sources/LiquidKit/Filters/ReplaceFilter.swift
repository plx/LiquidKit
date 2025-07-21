import Foundation

@usableFromInline
package struct ReplaceFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "replace"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard case .string(let string) = token else {
            return token
        }
        
        guard parameters.count >= 2,
              case .string(let search) = parameters[0],
              case .string(let replacement) = parameters[1] else {
            return token
        }
        
        return .string(string.replacingOccurrences(of: search, with: replacement))
    }
}