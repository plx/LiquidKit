import Foundation

package final class TagEndTablerow: Tag {
  override package class var keyword: String {
    "endtablerow"
  }

  override package var terminatesScopesWithTags: [Tag.Type]? {
    [TagTablerow.self]
  }

  override package func didTerminate(scope: Parser.Scope, parser: Parser) {
    super.didTerminate(scope: scope, parser: parser)

    guard let tableRowIterator = (scope.tag as? TagTablerow)?.tableRowIterator else {
      return
    }

    scope.processedStatements.append(contentsOf: tableRowIterator.next())
  }
}