import Foundation

public struct RemoveFilter: Filter {
    public static let filterIdentifier = "remove"
    
    public init() {}
    
    public func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard case .string(let string) = token else {
            return token
        }
        
        guard parameters.count >= 1,
              case .string(let substring) = parameters[0] else {
            return token
        }
        
        return .string(string.replacingOccurrences(of: substring, with: ""))
    }
}