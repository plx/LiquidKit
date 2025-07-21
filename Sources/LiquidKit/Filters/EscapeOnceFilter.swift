import Foundation
import HTMLEntities

@usableFromInline
package struct EscapeOnceFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "escape_once"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        return .string(token.stringValue.htmlUnescape().htmlEscape(decimal: true, useNamedReferences: true))
    }
}