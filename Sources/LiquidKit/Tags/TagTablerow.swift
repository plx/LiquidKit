import Foundation

/// Implements the `{% tablerow %}` tag, which generates HTML tables by iterating over arrays.
/// 
/// The `tablerow` tag creates HTML table rows and cells while iterating through a collection.
/// It automatically wraps content in `<tr>` and `<td>` tags with appropriate CSS classes, and
/// supports the `cols` parameter to control how many columns appear in each row. Like the `for`
/// tag, it provides a special `tablerowloop` object with iteration information.
///
/// Basic usage generates a single-row table:
/// ```liquid
/// {% tablerow product in products %}
///   {{ product.title }}
/// {% endtablerow %}
/// <!-- Output:
/// <tr class="row1">
/// <td class="col1">Product 1</td>
/// <td class="col2">Product 2</td>
/// <td class="col3">Product 3</td>
/// </tr>
/// -->
/// ```
///
/// The `cols` parameter controls column wrapping:
/// ```liquid
/// {% tablerow product in products cols:2 %}
///   {{ product.title }}
/// {% endtablerow %}
/// <!-- Output:
/// <tr class="row1">
/// <td class="col1">Product 1</td>
/// <td class="col2">Product 2</td>
/// </tr>
/// <tr class="row2">
/// <td class="col1">Product 3</td>
/// <td class="col2">Product 4</td>
/// </tr>
/// -->
/// ```
///
/// The `tablerowloop` object provides iteration state similar to `forloop`:
/// ```liquid
/// {% tablerow item in items cols:3 %}
///   Row {{ tablerowloop.row }} Col {{ tablerowloop.col }}
///   {% if tablerowloop.first %}(First){% endif %}
///   {% if tablerowloop.last %}(Last){% endif %}
/// {% endtablerow %}
/// ```
///
/// The `tablerowloop` object contains:
/// - `col`: Current column number (1-based)
/// - `col0`: Current column number (0-based)
/// - `col_first`: true if this is the first column in the row
/// - `col_last`: true if this is the last column in the row
/// - `first`: true if this is the first iteration
/// - `index`: Current iteration (1-based)
/// - `index0`: Current iteration (0-based)
/// - `last`: true if this is the last iteration
/// - `length`: Total number of items
/// - `rindex`: Iterations remaining (counting down)
/// - `rindex0`: Iterations remaining (counting down from length-1)
/// - `row`: Current row number (1-based)
///
/// - Important: The `tablerow` tag only generates `<tr>` and `<td>` tags. You must wrap it in a
///   `<table>` tag to create a complete HTML table.
///
/// - Important: Each `<tr>` tag gets a `class="rowN"` attribute and each `<td>` tag gets a
///   `class="colN"` attribute, where N is the 1-based row or column number within the current row.
///
/// - Warning: The `cols` parameter accepts numeric values and numeric strings. Float values are
///   truncated to integers. Invalid or non-positive values result in single-row output.
///
/// - SeeAlso: ``TagFor``, ``TagBreak``, ``TagContinue``
/// - SeeAlso: [LiquidJS tablerow](https://liquidjs.com/tags/tablerow.html)
/// - SeeAlso: [Python Liquid tablerow](https://liquid.readthedocs.io/en/latest/tags/tablerow/)
/// - SeeAlso: [Shopify Liquid tablerow](https://shopify.github.io/liquid/tags/iteration/)
package final class TagTablerow: AbstractIterationTag {
  package private(set) var tableRowIterator: TableRowIterator? = nil

  override package class var keyword: String {
    "tablerow"
  }

  override package var parameters: [String] {
    ["limit", "offset", "cols"]
  }

  override package func parse(statement: String, using parser: Parser, currentScope: Parser.Scope) throws {
    try super.parse(statement: statement, using: parser, currentScope: currentScope)

    if let columnsCount = (compiledExpression["cols"] as? Token.Value)?.integerValue {
      tableRowIterator = TableRowIterator(columns: columnsCount, itemCount: itemsCount)
    } else {
      tableRowIterator = TableRowIterator(itemCount: itemsCount)
    }
  }

  override package func didDefine(scope: Parser.Scope, parser: Parser) {
    super.didDefine(scope: scope, parser: parser)

    guard let tableRowIterator = tableRowIterator else {
      print("[LiquidKit] Error: tableRowIterator not initialized in TagTablerow")
      return
    }
    scope.processedStatements.append(contentsOf: tableRowIterator.next())
  }

  package class TableRowIterator {
    let columns: Int
    let itemCount: Int

    var currentRow: Int = 0
    var currentColumn: Int = 0
    var currentItem: Int = 0

    init(columns: Int = .max, itemCount: Int) {
      self.columns = columns
      self.itemCount = itemCount
    }

    func next() -> [Parser.Scope.ProcessedStatement] {
      var statements = [Parser.Scope.ProcessedStatement]()

      if currentRow == 0 || currentColumn >= columns {
        currentRow += 1
        currentColumn = 1
      } else {
        currentColumn += 1
      }

      if currentColumn == 1 {
        if currentRow > 1 {
          // End column (speacial case for lest item of previous row on new row)
          statements.append(.output("</td>"))

          // End row
          statements.append(.output("</tr>"))
        }

        // Start row
        statements.append(.output("<tr class=\"row\(currentRow)\">"))
      }

      if currentColumn > 1 {
        // End column
        statements.append(.output("</td>"))
      }

      if currentItem < itemCount {
        // Start column
        statements.append(.output("<td class=\"col\(currentColumn)\">"))
      } else {
        // End row (special case for last item)
        statements.append(.output("</tr>"))
      }

      currentItem += 1

      return statements
    }
  }
}