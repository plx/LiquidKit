import Foundation

public struct NewlineToBrFilter: Filter {
    public static let filterIdentifier = "newline_to_br"
    
    public init() {}
    
    public func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard case .string(let string) = token else {
            return token
        }
        
        // Replace all newline characters with <br />
        let result = string
            .replacingOccurrences(of: "\r\n", with: "<br />")
            .replacingOccurrences(of: "\n", with: "<br />")
            .replacingOccurrences(of: "\r", with: "<br />")
        
        return .string(result)
    }
}