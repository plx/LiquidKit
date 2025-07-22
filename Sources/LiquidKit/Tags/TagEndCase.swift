import Foundation

package final class TagEndCase: Tag {
  private var shouldTerminateParentScope = false

  override package class var keyword: String {
    "endcase"
  }

  override package var terminatesScopesWithTags: [Tag.Type]? {
    [TagCase.self, TagElse.self]
  }

  override package func didTerminate(scope: Parser.Scope, parser: Parser) {
    shouldTerminateParentScope = scope.tag is TagElse && scope.parentScope?.tag is TagCase
  }

  override package var terminatesParentScope: Bool {
    shouldTerminateParentScope
  }
}