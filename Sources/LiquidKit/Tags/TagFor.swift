import Foundation

/// Implements the `{% for %}` tag, which iterates over arrays and ranges.
/// 
/// The `for` tag repeatedly executes a block of code for each item in an array, hash, or range.
/// During each iteration, the current item is assigned to a specified variable, and a special
/// `forloop` object is available that provides information about the current iteration state.
/// The tag supports parameters like `limit`, `offset`, and `reversed` to control iteration behavior.
///
/// Basic usage iterates through arrays assigning each element to a variable:
/// ```liquid
/// {% for product in collection.products %}
///   {{ product.title }}
/// {% endfor %}
/// ```
///
/// When iterating over hashes, each item is a key-value pair that can be accessed:
/// ```liquid
/// {% for item in hash %}
///   Key: {{ item[0] }}, Value: {{ item[1] }}
/// {% endfor %}
/// ```
///
/// The `forloop` object provides extensive iteration metadata:
/// ```liquid
/// {% for item in items %}
///   {% if forloop.first %}First item: {% endif %}
///   Item {{ forloop.index }} of {{ forloop.length }}
///   {% if forloop.last %}Last item{% endif %}
/// {% endfor %}
/// ```
///
/// The `forloop` object contains these properties:
/// - `first`: true if this is the first iteration
/// - `index`: 1-based current iteration number
/// - `index0`: 0-based current iteration number
/// - `last`: true if this is the last iteration
/// - `length`: total number of items being iterated
/// - `rindex`: iterations remaining (counting down from length)
/// - `rindex0`: iterations remaining (counting down from length-1)
///
/// Nested loops can access parent loop information via `parentloop`:
/// ```liquid
/// {% for group in groups %}
///   {% for item in group.items %}
///     Group {{ forloop.parentloop.index }}, Item {{ forloop.index }}
///   {% endfor %}
/// {% endfor %}
/// ```
///
/// - Important: The `forloop` variable is only available within the loop body and goes out of scope
///   immediately after the loop ends. The loop variable itself also has block scope.
///
/// - Important: When iterating over ranges like `(1..5)`, the range is inclusive of both endpoints,
///   producing the values 1, 2, 3, 4, and 5.
///
/// - Warning: If the collection being iterated is nil or not iterable, the loop body is skipped
///   entirely without error.
///
/// - SeeAlso: ``TagBreak``, ``TagContinue``, ``TagCycle``
/// - SeeAlso: [LiquidJS for](https://liquidjs.com/tags/for.html)
/// - SeeAlso: [Python Liquid for](https://liquid.readthedocs.io/en/latest/tags/for/)
/// - SeeAlso: [Shopify Liquid for](https://shopify.github.io/liquid/tags/iteration/)
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