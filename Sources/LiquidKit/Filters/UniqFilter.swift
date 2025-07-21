import Foundation

public struct UniqFilter: Filter {
    public static let filterIdentifier = "uniq"
    
    public init() {}
    
    public func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard case .array(let array) = token else {
            return token
        }
        
        var uniqueValues: [Token.Value] = []
        var seenValues: Set<String> = []
        
        for value in array {
            let stringRepresentation = value.stringValue
            if !seenValues.contains(stringRepresentation) {
                seenValues.insert(stringRepresentation)
                uniqueValues.append(value)
            }
        }
        
        return .array(uniqueValues)
    }
}