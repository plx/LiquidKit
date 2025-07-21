import Foundation

@usableFromInline
package struct DowncaseFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "downcase"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard case .string(let inputString) = token else {
            return .nil
        }
        
        return .string(inputString.lowercased())
    }
}