import Foundation

public struct ReplaceFirstFilter: Filter {
    public static let filterIdentifier = "replace_first"
    
    public init() {}
    
    public func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard case .string(let string) = token else {
            return token
        }
        
        guard parameters.count >= 2,
              case .string(let search) = parameters[0],
              case .string(let replacement) = parameters[1] else {
            return token
        }
        
        // Find first occurrence and replace only that
        if let range = string.range(of: search) {
            var result = string
            result.replaceSubrange(range, with: replacement)
            return .string(result)
        }
        
        return token
    }
}