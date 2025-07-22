import Foundation

package final class TagEndFor: Tag {
  private var shouldTerminateParentScope: Bool = false

  override package class var keyword: String {
    "endfor"
  }

  override package var terminatesScopesWithTags: [Tag.Type]? {
    [TagFor.self, TagElse.self]
  }

  override package func didTerminate(scope: Parser.Scope, parser: Parser) {
    super.didTerminate(scope: scope, parser: parser)

    if scope.tag is TagElse {
      shouldTerminateParentScope = true
    }
  }

  override package var terminatesParentScope: Bool {
    shouldTerminateParentScope
  }
}