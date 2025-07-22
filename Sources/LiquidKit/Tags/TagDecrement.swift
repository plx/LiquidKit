import Foundation

package final class TagDecrement: Tag {
  override package var tagExpression: [ExpressionSegment] {
    // example: {% increment IDENTIFIER %}
    [.identifier("assignee")]
  }

  override package class var keyword: String {
    "decrement"
  }

  override package func parse(statement: String, using parser: Parser, currentScope: Parser.Scope) throws {
    try super.parse(statement: statement, using: parser, currentScope: currentScope)

    guard let assignee = compiledExpression["assignee"] as? String else {
      throw Errors.missingArtifacts
    }

    output = [.integer(context.decrementCounter(for: assignee))]
  }
}