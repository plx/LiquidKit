import Foundation

package final class TagElse: Tag {
  private var didTerminateScope = false

  override package class var keyword: String {
    "else"
  }

  override package var definesScope: Bool {
    true
  }

  override package var terminatesScopesWithTags: [Tag.Type]? {
    [TagIf.self, TagElsif.self, TagWhen.self]
  }

  override package func didTerminate(scope: Parser.Scope, parser: Parser) {
    super.didTerminate(scope: scope, parser: parser)

    didTerminateScope = true
  }

  override package func didDefine(scope: Parser.Scope, parser: Parser) {
    super.didDefine(scope: scope, parser: parser)

    if scope.parentScope?.tag is TagCase {
      scope.parentScope?.outputState = .enabled
    }
    // We need to check if this else tag isn't part of another if/elsif/when clause, since it can be structurally
    // identical to a for-else clause.
    else if !didTerminateScope, let tagFor = scope.parentScope?.tag as? TagFor {
      scope.outputState = tagFor.itemsCount > 0 ? .disabled : .enabled
    }
  }
}