import Foundation

package final class TagEndIf: Tag {
  override package class var keyword: String {
    "endif"
  }

  override package var terminatesScopesWithTags: [Tag.Type]? {
    [TagIf.self, TagElse.self, TagElsif.self]
  }
}