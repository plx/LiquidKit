import Foundation

@usableFromInline
package struct SizeFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "size"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        switch token {
        case .array(let array):
            return .integer(array.count)
        case .dictionary(let dictionary):
            return .integer(dictionary.count)
        case .string(let string):
            return .integer(string.count)
        default:
            return .integer(0)
        }
    }
}