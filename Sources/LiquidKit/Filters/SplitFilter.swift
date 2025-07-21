import Foundation

@usableFromInline
package struct SplitFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "split"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard case .string(let string) = token else {
            return token
        }
        
        guard let firstParameter = parameters.first else {
            return token
        }
        
        let separator = firstParameter.stringValue
        
        if separator.isEmpty {
            // Split into individual characters
            let characters = string.map { Token.Value.string(String($0)) }
            return .array(characters)
        } else {
            // Split by separator
            let parts = string.components(separatedBy: separator).map { Token.Value.string($0) }
            return .array(parts)
        }
    }
}