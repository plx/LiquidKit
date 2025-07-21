import Foundation

@usableFromInline
package struct StripFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "strip"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard case .string(let string) = token else {
            return token
        }
        
        // Remove leading and trailing whitespace
        return .string(string.trimmingCharacters(in: .whitespacesAndNewlines))
    }
}