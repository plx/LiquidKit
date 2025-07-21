import Foundation

@usableFromInline
package struct Base64DecodeFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "base64_decode"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard case .string(let inputString) = token else {
            return .nil
        }
        
        guard let data = Data(base64Encoded: inputString),
              let decodedString = String(data: data, encoding: .utf8) else {
            return .nil
        }
        
        return .string(decodedString)
    }
}