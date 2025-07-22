import Foundation

package class AbstractConditionalTag: Tag {
  override package var tagExpression: [ExpressionSegment] {
    // example: {% if IDENTIFIER %}
    [.variable("conditional")]
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
}