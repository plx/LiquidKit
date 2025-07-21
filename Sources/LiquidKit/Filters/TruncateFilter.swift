import Foundation

public struct TruncateFilter: Filter {
    public static let filterIdentifier = "truncate"
    
    public init() {}
    
    public func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard case .string(let string) = token else {
            return token
        }
        
        // Default values
        var length = 50
        var ellipsis = "..."
        
        // Parse parameters
        if parameters.count >= 1 {
            switch parameters[0] {
            case .integer(let l):
                length = l
            case .string(let s):
                if let l = Int(s) {
                    length = l
                }
            default:
                break
            }
        }
        
        if parameters.count >= 2, case .string(let e) = parameters[1] {
            ellipsis = e
        }
        
        // If string is shorter than or equal to length, return as is
        if string.count <= length {
            return .string(string)
        }
        
        // Calculate how much of the string we can keep
        let ellipsisLength = ellipsis.count
        let keepLength = max(0, length - ellipsisLength)
        
        // Truncate and add ellipsis
        let truncated = String(string.prefix(keepLength)) + ellipsis
        return .string(truncated)
    }
}