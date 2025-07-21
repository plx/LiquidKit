import Foundation

@usableFromInline
package struct LstripFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "lstrip"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard case .string(let inputString) = token else {
            return .nil
        }
        
        let charset = CharacterSet.whitespacesAndNewlines
        let firstNonBlankIndex = inputString.firstIndex() {
            char -> Bool in
            
            guard char.unicodeScalars.count == 1, let unichar = char.unicodeScalars.first else {
                return true
            }
            
            return !charset.contains(unichar)
        }
        
        guard let index = firstNonBlankIndex else {
            return .nil
        }
        
        return .string(String(inputString[index...]))
    }
}