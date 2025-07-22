import Foundation

package final class TagBreak: Tag {
  override package class var keyword: String {
    "break"
  }

  override package func parse(statement: String, using parser: Parser, currentScope: Parser.Scope) throws {
    try super.parse(statement: statement, using: parser, currentScope: currentScope)

    if currentScope.outputState == .enabled,
      let forScope = currentScope.scopeDefined(by: [TagFor.kind])
    {
      // If the current scope produces output, finds the nearest iterator and stops its output.
      forScope.outputState = .disabled
    }
  }
}