import Foundation

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