import Testing
@testable import LiquidKit

func validateApplication(
  of operator: some Operator,
  to operands: (some TokenValueConvertible, some TokenValueConvertible),
  yields expected: some TokenValueConvertible,
  _ explanation: @autoclosure () -> String? = nil,
  sourceLocation: SourceLocation = #_sourceLocation
) throws {
  let observed = try `operator`.apply(
    operands.0,
    operands.1
  )
  #expect(
    observed == expected.tokenValue,
    """
    Unexpected evaluation result for \(String(reflecting: `operator`))\(explanation().map { " \($0)" } ?? ""):
    
    - operands: (\(String(reflecting: operands.0)), \(String(reflecting: operands.1)))
    - operator: \(String(reflecting: `operator`))
    - expected: \(String(reflecting: expected))
    - observed: \(String(reflecting: observed))
    """,
    sourceLocation: sourceLocation
  )
}

func validateApplication(
  of operator: some Operator,
  to operands: (Token.Value, Token.Value),
  yields expected: some TokenValueConvertible,
  _ explanation: @autoclosure () -> String? = nil,
  sourceLocation: SourceLocation = #_sourceLocation
) throws {
  let observed = try `operator`.apply(
    operands.0,
    operands.1
  )
  #expect(
    observed == expected.tokenValue,
    """
    Unexpected evaluation result for \(String(reflecting: `operator`))\(explanation().map { " \($0)" } ?? ""):
    
    - operands: (\(String(reflecting: operands.0)), \(String(reflecting: operands.1)))
    - operator: \(String(reflecting: `operator`))
    - expected: \(String(reflecting: expected))
    - observed: \(String(reflecting: observed))
    """,
    sourceLocation: sourceLocation
  )
}
