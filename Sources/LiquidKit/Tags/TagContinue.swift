import Foundation

package final class TagContinue: Tag {
  override package class var keyword: String {
    "continue"
  }

  override package func parse(statement: String, using parser: Parser, currentScope: Parser.Scope) throws {
    try super.parse(statement: statement, using: parser, currentScope: currentScope)

    if currentScope.outputState == .enabled,
      let forScope = currentScope.scopeDefined(by: [TagFor.kind])
    {
      forScope.outputState = .halted
    }
  }
}