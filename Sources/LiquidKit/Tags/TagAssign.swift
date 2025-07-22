import Foundation

package final class TagAssign: Tag {
  override package var tagExpression: [ExpressionSegment] {
    // example: {% assign IDENTIFIER = "value" %}
    [.identifier("assignee"), .literal("="), .variable("value")]
  }

  override package class var keyword: String {
    "assign"
  }

  override package func parse(statement: String, using parser: Parser, currentScope: Parser.Scope) throws {
    try super.parse(statement: statement, using: parser, currentScope: currentScope)

    guard
      let assignee = compiledExpression["assignee"] as? String,
      let value = compiledExpression["value"] as? Token.Value
    else {
      throw Errors.missingArtifacts
    }

    context.set(value: value, for: assignee)
  }
}