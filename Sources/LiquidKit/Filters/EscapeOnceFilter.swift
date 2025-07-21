import Foundation
import HTMLEntities

struct EscapeOnceFilter: Filter {
    static let filterIdentifier = "escape_once"
    
    init() {}
    
    func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        return .string(token.stringValue.htmlUnescape().htmlEscape(decimal: true, useNamedReferences: true))
    }
}