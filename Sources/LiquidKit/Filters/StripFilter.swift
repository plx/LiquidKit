import Foundation

public struct StripFilter: Filter {
    public static let filterIdentifier = "strip"
    
    public init() {}
    
    public func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard case .string(let string) = token else {
            return token
        }
        
        // Remove leading and trailing whitespace
        return .string(string.trimmingCharacters(in: .whitespacesAndNewlines))
    }
}