import Foundation

@usableFromInline
package struct UrlEncodeFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "url_encode"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard case .string(let string) = token else {
            return token
        }
        
        // URL encode the string
        // Use form encoding which replaces spaces with +
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: "-._~")
        
        if let encoded = string.addingPercentEncoding(withAllowedCharacters: allowed) {
            // Replace percent-encoded spaces with +
            let formEncoded = encoded.replacingOccurrences(of: "%20", with: "+")
            return .string(formEncoded)
        }
        
        // If encoding fails, return original
        return token
    }
}