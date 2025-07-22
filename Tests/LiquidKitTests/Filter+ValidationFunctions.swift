import Testing
@testable import LiquidKit

func validateEvaluation(
  of value: some TokenValueConvertible,
  with parameters: [Token.Value] = [],
  by filter: some Filter,
  yields expected: some TokenValueConvertible,
  _ explanation: @autoclosure () -> String? = nil,
  sourceLocation: SourceLocation = #_sourceLocation
) throws {
  let observed = try filter.evaluate(
    value: value,
    parameters: parameters
  )
  #expect(
    observed == expected.tokenValue,
    """
    Unexpected evaluation result for \(String(reflecting: filter))\(explanation().map { " \($0)" } ?? ""):
    
    - value: \(String(reflecting: value))
    - parameters: [ \(String(reflecting: parameters.lazy.map({String(reflecting: $0)}).joined(separator: ", "))) ]
    - filter: \(String(reflecting: filter))
    - expected: \(String(reflecting: expected))
    - observed: \(String(reflecting: observed))
    """,
    sourceLocation: sourceLocation
  )
}

func validateEvaluation(
  of value: some TokenValueConvertible,
  with parameters: [Token.Value] = [],
  by filter: some Filter,
  yields expected: Token.Value,
  _ explanation: @autoclosure () -> String? = nil,
  sourceLocation: SourceLocation = #_sourceLocation
) throws {
  let observed = try filter.evaluate(
    value: value,
    parameters: parameters
  )
  #expect(
    observed == expected,
    """
    Unexpected evaluation result for \(String(reflecting: filter))\(explanation().map { " \($0)" } ?? ""):
    
    - value: \(String(reflecting: value))
    - parameters: [ \(String(reflecting: parameters.lazy.map({String(reflecting: $0)}).joined(separator: ", "))) ]
    - filter: \(String(reflecting: filter))
    - expected: \(String(reflecting: expected))
    - observed: \(String(reflecting: observed))
    """,
    sourceLocation: sourceLocation
  )
}
