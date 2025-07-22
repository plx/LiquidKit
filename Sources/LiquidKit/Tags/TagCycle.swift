import Foundation

package final class TagCycle: Tag {
  private var groupIdentifier: String? {
    guard case .some(.string(let groupIdentifier)) = compiledExpression["group"] as? Token.Value
    else {
      return nil
    }

    return groupIdentifier
  }

  override package class var keyword: String {
    "cycle"
  }

  override package var tagExpression: [ExpressionSegment] {
    // example: {% cycle group:groupIdentifier %}
    [.group("list")]
  }

  override package var parameters: [String] {
    ["group"]
  }

  override package func parse(statement: String, using parser: Parser, currentScope: Parser.Scope) throws {
    try super.parse(statement: statement, using: parser, currentScope: currentScope)

    guard case .some(.array(let groupElements)) = compiledExpression["list"] as? Token.Value else {
      throw Errors.missingArtifacts
    }

    if let cycleOutput = context.next(in: groupElements, identifier: groupIdentifier) {
      output = [cycleOutput]
    }
  }
}