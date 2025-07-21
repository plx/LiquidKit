import Foundation

@usableFromInline
package struct Base64UrlSafeDecodeFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "base64_url_safe_decode"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard case .string(let inputString) = token else {
            return .nil
        }
        
        // Convert URL-safe base64 to standard base64
        var base64String = inputString
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        // Add padding if necessary
        let remainder = base64String.count % 4
        if remainder > 0 {
            base64String += String(repeating: "=", count: 4 - remainder)
        }
        
        guard let data = Data(base64Encoded: base64String),
              let decodedString = String(data: data, encoding: .utf8) else {
            return .nil
        }
        
        return .string(decodedString)
    }
}