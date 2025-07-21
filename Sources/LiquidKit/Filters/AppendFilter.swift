import Foundation

@usableFromInline
package struct AppendFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "append"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard let stringParameter = parameters.first?.stringValue else
        {
            return .nil
        }
        
        return .string(token.stringValue + stringParameter)
    }
}