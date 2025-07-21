import Foundation

public struct StripNewlinesFilter: Filter {
    public static let filterIdentifier = "strip_newlines"
    
    public init() {}
    
    public func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard case .string(let string) = token else {
            return token
        }
        
        // Remove all newline characters (both \n and \r\n)
        let result = string
            .replacingOccurrences(of: "\r\n", with: "")
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\r", with: "")
        
        return .string(result)
    }
}