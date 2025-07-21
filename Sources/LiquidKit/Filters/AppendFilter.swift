import Foundation

struct AppendFilter: Filter {
    static let filterIdentifier = "append"
    
    init() {}
    
    func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard let stringParameter = parameters.first?.stringValue else
        {
            return .nil
        }
        
        return .string(token.stringValue + stringParameter)
    }
}