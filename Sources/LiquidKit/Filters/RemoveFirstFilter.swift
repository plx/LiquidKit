import Foundation

@usableFromInline
package struct RemoveFirstFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "remove_first"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard case .string(let string) = token else {
            return token
        }
        
        guard parameters.count >= 1,
              case .string(let substring) = parameters[0] else {
            return token
        }
        
        // Find first occurrence and replace only that
        if let range = string.range(of: substring) {
            var result = string
            result.replaceSubrange(range, with: "")
            return .string(result)
        }
        
        return token
    }
}