import Foundation

@usableFromInline
package struct MapFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "map"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard case .array(let array) = token else {
            return token
        }
        
        guard let firstParameter = parameters.first else {
            return token
        }
        
        let key = firstParameter.stringValue
        
        let mappedValues = array.compactMap { item -> Token.Value? in
            if case .dictionary(let dict) = item {
                return dict[key] ?? .nil
            }
            return nil
        }
        
        return .array(mappedValues)
    }
}