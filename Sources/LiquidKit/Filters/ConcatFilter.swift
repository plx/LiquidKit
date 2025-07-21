import Foundation

public struct ConcatFilter: Filter {
    public static let filterIdentifier = "concat"
    
    public init() {}
    
    public func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard case .array(let array) = token else {
            return token
        }
        
        guard !parameters.isEmpty else {
            return token
        }
        
        var result = array
        
        for parameter in parameters {
            if case .array(let otherArray) = parameter {
                result.append(contentsOf: otherArray)
            }
        }
        
        return .array(result)
    }
}