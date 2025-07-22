import Foundation

/// Implements the `{% endtablerow %}` tag, which closes a tablerow loop block.
/// 
/// The `endtablerow` tag marks the end of a `tablerow` loop structure. Every `tablerow` tag must
/// have a corresponding `endtablerow` tag to close the table generation loop. The `endtablerow` tag
/// performs important cleanup by finalizing any incomplete table rows and ensuring proper HTML table
/// structure. When the loop ends with a partially filled row (when the number of items is not evenly
/// divisible by the column count), this tag ensures the final row is properly closed.
///
/// Basic usage with automatic row completion:
/// ```liquid
/// {% tablerow product in products cols:3 %}
///   {{ product.name }}
/// {% endtablerow %}
/// <!-- With 5 products, generates:
/// <tr class="row1">
/// <td class="col1">Product 1</td>
/// <td class="col2">Product 2</td>
/// <td class="col3">Product 3</td>
/// </tr>
/// <tr class="row2">
/// <td class="col1">Product 4</td>
/// <td class="col2">Product 5</td>
/// </tr>
/// -->
/// ```
///
/// The endtablerow tag properly closes rows even when using limit:
/// ```liquid
/// {% tablerow item in items cols:4 limit:6 %}
///   Item {{ item }}
/// {% endtablerow %}
/// <!-- Generates exactly 6 cells across 2 rows -->
/// ```
///
/// Works correctly with break and continue statements:
/// ```liquid
/// {% tablerow i in (1..10) cols:3 %}
///   {% if i == 5 %}{% break %}{% endif %}
///   Number {{ i }}
/// {% endtablerow %}
/// <!-- Loop breaks at 5, endtablerow ensures proper HTML closure -->
/// ```
///
/// - Important: The `endtablerow` tag automatically handles row completion. If a tablerow loop ends
///   mid-row (e.g., 5 items with cols:3), the final `</tr>` tag is properly generated to maintain
///   valid HTML structure.
///
/// - Important: Unlike simple end tags, `endtablerow` contains logic to finalize the table structure
///   by processing any remaining table row iterator state from the parent `tablerow` tag.
///
/// - Warning: Missing an `endtablerow` tag will result in a parsing error and potentially malformed
///   HTML output. Each `tablerow` tag must have exactly one matching `endtablerow` tag.
///
/// - SeeAlso: ``TagTablerow``
/// - SeeAlso: [LiquidJS tablerow](https://liquidjs.com/tags/tablerow.html)
/// - SeeAlso: [Python Liquid tablerow](https://liquid.readthedocs.io/en/latest/tags/tablerow/)
/// - SeeAlso: [Shopify Liquid tablerow](https://shopify.github.io/liquid/tags/iteration/)
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