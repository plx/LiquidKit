import Foundation

@usableFromInline
package struct Base64EncodeFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "base64_encode"
    
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
        
        return .string(data.base64EncodedString())
    }
}