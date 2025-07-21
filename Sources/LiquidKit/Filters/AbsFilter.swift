import Foundation

struct AbsFilter: Filter {
    static let filterIdentifier = "abs"
    
    init() {}
    
    func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard let decimal = token.decimalValue else {
            return .nil
        }
        
        return .decimal(Swift.abs(decimal))
    }
}