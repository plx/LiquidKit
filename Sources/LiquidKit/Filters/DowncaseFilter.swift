import Foundation

struct DowncaseFilter: Filter {
    static let filterIdentifier = "downcase"
    
    init() {}
    
    func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard case .string(let inputString) = token else {
            return .nil
        }
        
        return .string(inputString.lowercased())
    }
}