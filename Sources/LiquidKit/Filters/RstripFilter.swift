import Foundation

public struct RstripFilter: Filter {
    public static let filterIdentifier = "rstrip"
    
    public init() {}
    
    public func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard case .string(let string) = token else {
            return token
        }
        
        // Remove trailing whitespace
        let result = string.replacingOccurrences(of: "\\s+$", with: "", options: .regularExpression)
        return .string(result)
    }
}