import Foundation

public struct FirstFilter: Filter {
    public static let filterIdentifier = "first"
    
    public init() {}
    
    public func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
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