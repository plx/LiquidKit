import Foundation

@usableFromInline
package struct CapitalizeFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "capitalize"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        let inputString = token.stringValue
        
        guard inputString.count > 0 else {
            return .nil
        }
        
        var firstWord: String?
        var firstWordRange: Range<String.Index>?
        
        inputString.enumerateSubstrings(in: inputString.startIndex..., options: .byWords) {
            (word, range, _, stop) in
            
            firstWord = word
            firstWordRange = range
            stop = true
        }
        
        guard let word = firstWord, let range = firstWordRange else {
            return .string(inputString)
        }
        
        return .string(inputString.replacingCharacters(in: range, with: word.localizedCapitalized))
    }
}