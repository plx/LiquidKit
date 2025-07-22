import Foundation

package final class TagEndComment: Tag {
  override package class var keyword: String {
    "endcomment"
  }

  override package var terminatesScopesWithTags: [Tag.Type]? {
    [TagComment.self]
  }
}