import Foundation

@usableFromInline
package struct UniqFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "uniq"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
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