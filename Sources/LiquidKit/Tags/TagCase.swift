import Foundation

package final class TagCase: Tag {
  override package var tagExpression: [ExpressionSegment] {
    [.variable("conditional")]
  }

  override package class var keyword: String {
    "case"
  }

  override package var definesScope: Bool {
    true
  }

  override package func parse(statement: String, using parser: Parser, currentScope: Parser.Scope) throws {
    try super.parse(statement: statement, using: parser, currentScope: currentScope)

    guard compiledExpression["conditional"] is Token.Value else {
      throw Errors.missingArtifacts
    }
  }

  override package func didDefine(scope: Parser.Scope, parser: Parser) {
    // Prevent rogue text between the `case` tag and the first `when` tag from being output.
    scope.outputState = .disabled
  }
}