import Foundation

@usableFromInline
package struct AtMostFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "at_most"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard
            let inputDecimal = token.decimalValue,
            let parameterDecimal = parameters.first?.decimalValue
        else {
            return .nil
        }
        
        return .decimal(min(inputDecimal, parameterDecimal))
    }
}