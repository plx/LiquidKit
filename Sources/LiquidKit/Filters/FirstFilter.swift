import Foundation

@usableFromInline
package struct FirstFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "first"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        switch token {
        case .array(let array):
            return array.first ?? .nil
        case .string(let string):
            if let firstCharacter = string.first {
                return .string(String(firstCharacter))
            } else {
                return .nil
            }
        default:
            return .nil
        }
    }
}