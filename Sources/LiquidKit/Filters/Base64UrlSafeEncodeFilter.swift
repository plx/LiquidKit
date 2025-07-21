import Foundation

@usableFromInline
package struct Base64UrlSafeEncodeFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "base64_url_safe_encode"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard case .string(let inputString) = token else {
            return .nil
        }
        
        guard let data = inputString.data(using: .utf8) else {
            return .nil
        }
        
        // Create URL-safe base64 string
        let base64String = data.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .trimmingCharacters(in: CharacterSet(charactersIn: "="))
        
        return .string(base64String)
    }
}