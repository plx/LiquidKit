import Foundation

package final class TagFor: AbstractIterationTag {
  override package class var keyword: String {
    "for"
  }

  override package func makeSupplementalContext(item: Token.Value, iteree: String) -> Context? {
    context.makeSupplement(with: [
      iteree: item,
      "forloop": ForLoop(index: iterated, length: itemsCount).tokenValue,
    ])
  }

  private struct ForLoop: TokenValueConvertible {
    let first: Bool
    let index: Int
    let index0: Int
    let last: Bool
    let length: Int
    let rIndex: Int
    let rIndex0: Int

    init(index: Int, length: Int) {
      self.index = index + 1
      self.index0 = index
      self.first = index == 0
      self.last = index == (length - 1)
      self.length = length
      self.rIndex = length - index
      self.rIndex0 = length - index - 1
    }

    var tokenValue: Token.Value {
      [
        "first": first, "index": index, "index0": index0, "last": last,
        "length": length, "rindex": rIndex, "rindex0": rIndex0,
      ].tokenValue
    }
  }
}