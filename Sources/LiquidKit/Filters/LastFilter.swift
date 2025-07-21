import Foundation

public struct LastFilter: Filter {
    public static let filterIdentifier = "last"
    
    public init() {}
    
    public func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
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