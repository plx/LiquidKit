import Foundation
import HTMLEntities

@usableFromInline
package struct EscapeFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "escape"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        return .string(token.stringValue.htmlEscape(decimal: true, useNamedReferences: true))
    }
}