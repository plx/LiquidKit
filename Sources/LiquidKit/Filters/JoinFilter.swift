import Foundation

@usableFromInline
package struct JoinFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "join"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard case .array(let array) = token else {
            return token
        }
        
        let separator: String
        if let firstParameter = parameters.first {
            separator = firstParameter.stringValue
        } else {
            separator = " "
        }
        
        let stringArray = array.map { $0.stringValue }
        return .string(stringArray.joined(separator: separator))
    }
}