import Foundation

@usableFromInline
package struct TruncateWordsFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "truncatewords"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard case .string(let string) = token else {
            return token
        }
        
        // Default values
        var wordCount = 15
        var ellipsis = "..."
        
        // Parse parameters
        if parameters.count >= 1 {
            switch parameters[0] {
            case .integer(let w):
                wordCount = w
            case .string(let s):
                if let w = Int(s) {
                    wordCount = w
                }
            default:
                break
            }
        }
        
        if parameters.count >= 2, case .string(let e) = parameters[1] {
            ellipsis = e
        }
        
        // Split string into words
        let words = string.split(separator: " ", omittingEmptySubsequences: true)
        
        // If we have fewer words than requested, return as is
        if words.count <= wordCount {
            return .string(string)
        }
        
        // Take first n words and join with ellipsis
        let truncated = words.prefix(wordCount).joined(separator: " ") + ellipsis
        return .string(truncated)
    }
}