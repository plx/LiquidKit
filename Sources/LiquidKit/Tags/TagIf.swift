import Foundation

package final class TagIf: AbstractConditionalTag {
  override package class var keyword: String {
    "if"
  }

  override package func didDefine(scope: Parser.Scope, parser: Parser) {
    super.didDefine(scope: scope, parser: parser)

    // An `if` tag should execute if its statement is considered "truthy".
    if let conditional = (compiledExpression["conditional"] as? Token.Value), conditional.isTruthy {
      tagKindsToSkip = [TagElsif.kind, TagElse.kind]
    } else {
      scope.outputState = .disabled
    }
  }
}