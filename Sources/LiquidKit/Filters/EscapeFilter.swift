import Foundation
import HTMLEntities

struct EscapeFilter: Filter {
    static let filterIdentifier = "escape"
    
    init() {}
    
    func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        return .string(token.stringValue.htmlEscape(decimal: true, useNamedReferences: true))
    }
}