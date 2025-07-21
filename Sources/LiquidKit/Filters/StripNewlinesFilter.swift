import Foundation

@usableFromInline
package struct StripNewlinesFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "strip_newlines"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
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