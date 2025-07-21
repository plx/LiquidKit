import Foundation

struct AtLeastFilter: Filter {
    static let filterIdentifier = "at_least"
    
    init() {}
    
    func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard
            let inputDecimal = token.decimalValue,
            let parameterDecimal = parameters.first?.decimalValue
        else {
            return .nil
        }
        
        return .decimal(max(inputDecimal, parameterDecimal))
    }
}