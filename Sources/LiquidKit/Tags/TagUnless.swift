import Foundation

package final class TagUnless: AbstractConditionalTag {
  override package class var keyword: String {
    "unless"
  }

  override package func didDefine(scope: Parser.Scope, parser: Parser) {
    super.didDefine(scope: scope, parser: parser)

    // An `unless` tag should execute if its statement is considered "falsy".
    if let conditional = (compiledExpression["conditional"] as? Token.Value), conditional.isTruthy {
      scope.outputState = .disabled
    } else {
      // No need to set tagKindsToSkip since unless doesn't have elsif
      scope.outputState = .enabled
    }
  }
}