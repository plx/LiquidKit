import Foundation

struct AtMostFilter: Filter {
    static let filterIdentifier = "at_most"
    
    init() {}
    
    func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard
            let inputDecimal = token.decimalValue,
            let parameterDecimal = parameters.first?.decimalValue
        else {
            return .nil
        }
        
        return .decimal(min(inputDecimal, parameterDecimal))
    }
}