import Foundation

package class AbstractIterationTag: Tag, IterationTag {
  package var iterator: IndexingIterator<([Token.Value])>?
  package var iterated = 0

  package private(set) var hasSupplementalContext: Bool = true

  package var supplementalContext: Context? {
    guard let item = iterator?.next(), let iteree = compiledExpression["iteree"] as? String else {
      hasSupplementalContext = false
      return nil
    }

    defer {
      iterated += 1
    }

    // Subclasses should override this to provide their own context
    return makeSupplementalContext(item: item, iteree: iteree)
  }

  // To be overridden by subclasses to provide specific supplemental context
  package func makeSupplementalContext(item: Token.Value, iteree: String) -> Context? {
    context.makeSupplement(with: [iteree: item])
  }

  package var itemsCount: Int {
    guard iterator != nil, let iterandValue = compiledExpression["iterand"] as? Token.Value else {
      return 0
    }

    switch iterandValue {
    case .array(let array):
      return array.count

    case .range(let range):
      return range.count

    default:
      return 0
    }
  }

  override package var tagExpression: [ExpressionSegment] {
    // example: {% for IDENTIFIER in IDENTIFIER %}
    [.identifier("iteree"), .literal("in"), .variable("iterand")]
  }

  override package var parameters: [String] {
    ["limit", "offset", "reversed"]
  }

  override package var definesScope: Bool {
    true
  }

  override package func parse(statement: String, using parser: Parser, currentScope: Parser.Scope) throws {
    try super.parse(statement: statement, using: parser, currentScope: currentScope)

    guard
      compiledExpression["iteree"] is String,
      let iterandValue = compiledExpression["iterand"] as? Token.Value
    else {
      throw Errors.missingArtifacts
    }

    var values: [Token.Value]

    switch iterandValue {
    case .array(let array):
      values = array

    case .range(let range):
      values = range.lazy.map({ Token.Value.integer($0) })

    default:
      throw Errors.malformedStatement(
        "Expected array or range parameter for iteration statement, found \(type(of: iterandValue))"
      )
    }

    guard
      !values.reduce(
        false,
        { (allFalsy, value) in allFalsy || value.isFalsy || value.isEmptyString }
      )
    else {
      self.iterator = nil
      return
    }

    if let offset = (compiledExpression["offset"] as? Token.Value)?.integerValue {
      values.removeSubrange(..<offset)
    }

    if let limit = (compiledExpression["limit"] as? Token.Value)?.integerValue {
      guard values.indices.contains(limit) else {
        throw Errors.invalidInvocation(
          "Calculated out-of-range `limit` \(limit) for \(self), cannot finish evaluation!"
        )
      }
      values.removeSubrange(limit...)
    }

    if compiledExpression["reversed"] as? Token.Value == .bool(true) {
      values.reverse()
    }

    self.iterator = values.makeIterator()
  }

  override package func didDefine(scope: Parser.Scope, parser: Parser) {
    super.didDefine(scope: scope, parser: parser)

    if iterator == nil {
      scope.outputState = .disabled
    }
  }
}