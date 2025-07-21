import Foundation

public struct UrlDecodeFilter: Filter {
    public static let filterIdentifier = "url_decode"
    
    public init() {}
    
    public func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard case .string(let string) = token else {
            return token
        }
        
        // URL decode the string
        // Replace + with space first (form-encoded data)
        let plusDecoded = string.replacingOccurrences(of: "+", with: " ")
        
        // Then percent decode
        if let decoded = plusDecoded.removingPercentEncoding {
            return .string(decoded)
        }
        
        // If decoding fails, return original
        return token
    }
}