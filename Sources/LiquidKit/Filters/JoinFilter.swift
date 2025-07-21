import Foundation

public struct JoinFilter: Filter {
    public static let filterIdentifier = "join"
    
    public init() {}
    
    public func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
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