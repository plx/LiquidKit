import Foundation

public struct UpcaseFilter: Filter {
    public static let filterIdentifier = "upcase"
    
    public init() {}
    
    public func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard case .string(let string) = token else {
            return token
        }
        
        return .string(string.uppercased())
    }
}