import Foundation

public struct ReverseFilter: Filter {
    public static let filterIdentifier = "reverse"
    
    public init() {}
    
    public func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
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