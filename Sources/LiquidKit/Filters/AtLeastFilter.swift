import Foundation

@usableFromInline
package struct AtLeastFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "at_least"
    
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
        
        return .decimal(max(inputDecimal, parameterDecimal))
    }
}