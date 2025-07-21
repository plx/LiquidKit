import Foundation

public struct CompactFilter: Filter {
    public static let filterIdentifier = "compact"
    
    public init() {}
    
    public func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard case .array(let array) = token else {
            return token
        }
        
        let compacted = array.filter { $0 != .nil }
        return .array(compacted)
    }
}