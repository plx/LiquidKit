import Foundation

package final class TagIncrement: Tag {
  override package var tagExpression: [ExpressionSegment] {
    // example: {% increment IDENTIFIER %}
    [.identifier("assignee")]
  }

  override package class var keyword: String {
    "increment"
  }

  override package func parse(statement: String, using parser: Parser, currentScope: Parser.Scope) throws {
    try super.parse(statement: statement, using: parser, currentScope: currentScope)

    guard let assignee = compiledExpression["assignee"] as? String else {
      throw Errors.missingArtifacts
    }

    output = [.integer(context.incrementCounter(for: assignee))]
  }
}