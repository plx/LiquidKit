import Foundation

public struct StripHtmlFilter: Filter {
    public static let filterIdentifier = "strip_html"
    
    public init() {}
    
    public func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard case .string(let string) = token else {
            return token
        }
        
        // Remove HTML tags using regex
        let htmlPattern = "<[^>]+>"
        let result = string.replacingOccurrences(of: htmlPattern, with: "", options: .regularExpression)
        return .string(result)
    }
}