import Foundation

@usableFromInline
package struct ReverseFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "reverse"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        switch token {
        case .array(let array):
            return .array(array.reversed())
        case .string(let string):
            return .string(String(string.reversed()))
        default:
            return token
        }
    }
}