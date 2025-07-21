import Foundation

@usableFromInline
package struct ConcatFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "concat"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard case .array(let array) = token else {
            return token
        }
        
        guard !parameters.isEmpty else {
            return token
        }
        
        var result = array
        
        for parameter in parameters {
            if case .array(let otherArray) = parameter {
                result.append(contentsOf: otherArray)
            }
        }
        
        return .array(result)
    }
}