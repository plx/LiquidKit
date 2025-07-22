import Foundation

package final class TagCapture: Tag {
  override package var tagExpression: [ExpressionSegment] {
    // example: {% capture IDENTIFIER %}
    [.identifier("assignee")]
  }

  override package class var keyword: String {
    "capture"
  }

  override package var definesScope: Bool {
    true
  }

  override package func parse(statement: String, using parser: Parser, currentScope: Parser.Scope) throws {
    try super.parse(statement: statement, using: parser, currentScope: currentScope)

    guard compiledExpression["assignee"] is String else {
      throw Errors.missingArtifacts
    }
  }
}