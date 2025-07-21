import Foundation

@usableFromInline
package struct CompactFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "compact"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard case .array(let array) = token else {
            return token
        }
        
        let compacted = array.filter { $0 != .nil }
        return .array(compacted)
    }
}