import Foundation

package final class TagElsif: AbstractConditionalTag {
  override package class var keyword: String {
    "elsif"
  }

  override package var terminatesScopesWithTags: [Tag.Type]? {
    [TagIf.self, TagElsif.self]
  }

  override package func didDefine(scope: Parser.Scope, parser: Parser) {
    super.didDefine(scope: scope, parser: parser)

    // An `elsif` tag should execute if its statement is considered "truthy".
    if let conditional = (compiledExpression["conditional"] as? Token.Value), conditional.isTruthy {
      tagKindsToSkip = [TagElsif.kind, TagElse.kind]
    } else {
      scope.outputState = .disabled
    }
  }
}