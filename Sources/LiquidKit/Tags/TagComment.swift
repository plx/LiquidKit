import Foundation

package final class TagComment: Tag {
  override package class var keyword: String {
    "comment"
  }

  override package var definesScope: Bool {
    true
  }

  override package func didDefine(scope: Parser.Scope, parser: Parser) {
    super.didDefine(scope: scope, parser: parser)

    // Comment tags never produce output
    scope.outputState = .disabled
  }
}