import Foundation

@usableFromInline
package struct StripHtmlFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "strip_html"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard case .string(let string) = token else {
            return token
        }
        
        // Remove HTML tags using regex
        let htmlPattern = "<[^>]+>"
        let result = string.replacingOccurrences(of: htmlPattern, with: "", options: .regularExpression)
        return .string(result)
    }
}