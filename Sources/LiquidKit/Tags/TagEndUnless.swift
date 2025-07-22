import Foundation

package final class TagEndUnless: Tag {
  override package class var keyword: String {
    "endunless"
  }

  override package var terminatesScopesWithTags: [Tag.Type]? {
    [TagUnless.self]
  }
}