import Foundation

@usableFromInline
package struct AbsFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "abs"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard let decimal = token.decimalValue else {
            return .nil
        }
        
        return .decimal(Swift.abs(decimal))
    }
}