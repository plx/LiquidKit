import Foundation

public struct SizeFilter: Filter {
    public static let filterIdentifier = "size"
    
    public init() {}
    
    public func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
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