import Foundation

@usableFromInline
package struct RstripFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "rstrip"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard case .string(let string) = token else {
            return token
        }
        
        // Remove trailing whitespace
        let result = string.replacingOccurrences(of: "\\s+$", with: "", options: .regularExpression)
        return .string(result)
    }
}