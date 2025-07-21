import Foundation

@usableFromInline
package struct UpcaseFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "upcase"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard case .string(let string) = token else {
            return token
        }
        
        return .string(string.uppercased())
    }
}