import Foundation

@usableFromInline
package struct NewlineToBrFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "newline_to_br"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
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