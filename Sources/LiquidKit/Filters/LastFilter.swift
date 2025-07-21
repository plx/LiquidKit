import Foundation

@usableFromInline
package struct LastFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "last"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        switch token {
        case .array(let array):
            return array.last ?? .nil
        case .string(let string):
            if let lastCharacter = string.last {
                return .string(String(lastCharacter))
            } else {
                return .nil
            }
        default:
            return .nil
        }
    }
}