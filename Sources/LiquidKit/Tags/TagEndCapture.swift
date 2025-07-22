import Foundation

package final class TagEndCapture: Tag {
  override package class var keyword: String {
    "endcapture"
  }

  override package var terminatesScopesWithTags: [Tag.Type]? {
    [TagCapture.self]
  }

  override package func didTerminate(scope: Parser.Scope, parser: Parser) {
    if let assigneeName = scope.tag?.compiledExpression["assignee"] as? String,
      let compiledCapturedStatements = scope.compile(using: parser)
    {
      context.set(value: .string(compiledCapturedStatements.joined()), for: assigneeName)
    }

    // Prevent the nodes of the scope from being written to the output when the final compilation happens.
    scope.dumpProcessedStatements()
  }
}