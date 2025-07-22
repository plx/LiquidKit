import Foundation

package final class TagWhen: Tag {
  override package var tagExpression: [ExpressionSegment] {
    [.variable("comparator")]
  }

  override package class var keyword: String {
    "when"
  }

  override package var definesScope: Bool {
    true
  }

  override package func parse(statement: String, using parser: Parser, currentScope: Parser.Scope) throws {
    try super.parse(statement: statement, using: parser, currentScope: currentScope)

    guard compiledExpression["comparator"] is Token.Value else {
      throw Errors.missingArtifacts
    }
  }

  override package func didDefine(scope: Parser.Scope, parser: Parser) {
    super.didDefine(scope: scope, parser: parser)

    guard
      let tagCase = scope.parentScope?.tag as? TagCase,
      let comparator = compiledExpression["comparator"] as? Token.Value,
      let conditional = tagCase.compiledExpression["conditional"] as? Token.Value
    else {
      scope.outputState = .disabled
      return
    }

    let isMatch = comparator == conditional

    if isMatch {
      tagKindsToSkip = [TagWhen.kind, TagElse.kind]
    }

    scope.outputState = isMatch ? .enabled : .disabled
  }

  override package var terminatesScopesWithTags: [Tag.Type]? {
    [TagWhen.self]
  }
}