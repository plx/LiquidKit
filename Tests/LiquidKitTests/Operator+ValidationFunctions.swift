import Testing
@testable import LiquidKit

// MARK: Result Validation

func validateApplication(
  of operator: some Operator,
  to operands: (some TokenValueConvertible, some TokenValueConvertible),
  yields expected: some TokenValueConvertible,
  _ explanation: @autoclosure () -> String? = nil,
  sourceLocation: SourceLocation = #_sourceLocation
) throws {
  try validateApplication(
    of: `operator`,
    to: operands,
    yields: expected.tokenValue,
    explanation(),
    sourceLocation: sourceLocation
  )
}

func validateApplication(
  of operator: some Operator,
  to operands: (some TokenValueConvertible, some TokenValueConvertible),
  yields expected: Token.Value,
  _ explanation: @autoclosure () -> String? = nil,
  sourceLocation: SourceLocation = #_sourceLocation
) throws {
  let observed = try `operator`.apply(
    operands.0,
    operands.1
  )
  #expect(
    observed == expected,
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
  yields expected: Token.Value,
  _ explanation: @autoclosure () -> String? = nil,
  sourceLocation: SourceLocation = #_sourceLocation
) throws {
  let observed = try `operator`.apply(
    operands.0,
    operands.1
  )
  #expect(
    observed == expected,
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

// MARK: - Error Validation

func validateApplication<ErrorType>(
  of operator: some Operator,
  to operands: (some TokenValueConvertible, some TokenValueConvertible),
  throws errorType: ErrorType.Type,
  _ explanation: @autoclosure () -> String? = nil,
  sourceLocation: SourceLocation = #_sourceLocation,
  additionalVerification: ((ErrorType) throws -> Void)? = nil
) throws where ErrorType: Error {
  do {
    let observed = try `operator`.apply(
      operands.0,
      operands.1
    )
  }
  catch let failure {
    let error = try #require(
      failure as? ErrorType,
      """
      Encountered an unexpected error type: \(type(of: failure)) for \(String(reflecting: `operator`))\(explanation().map { " \($0)" } ?? ""):
      
      - operands: (\(String(reflecting: operands.0)), \(String(reflecting: operands.1)))
      - operator: \(String(reflecting: `operator`))
      - errorType: \(String(reflecting: errorType))
      - failure: \(String(reflecting: failure))
      """,
      sourceLocation: sourceLocation
    )
    
    try additionalVerification?(error)
  }
}

func validateApplication<ErrorType>(
  of operator: some Operator,
  to operands: (Token.Value, Token.Value),
  throws errorType: ErrorType.Type,
  _ explanation: @autoclosure () -> String? = nil,
  sourceLocation: SourceLocation = #_sourceLocation,
  additionalVerification: ((ErrorType) throws -> Void)? = nil
) throws where ErrorType: Error {
  do {
    let observed = try `operator`.apply(
      operands.0,
      operands.1
    )
  }
  catch let failure {
    let error = try #require(
      failure as? ErrorType,
      """
      Encountered an unexpected error type: \(type(of: failure)) for \(String(reflecting: `operator`))\(explanation().map { " \($0)" } ?? ""):
      
      - operands: (\(String(reflecting: operands.0)), \(String(reflecting: operands.1)))
      - operator: \(String(reflecting: `operator`))
      - errorType: \(String(reflecting: errorType))
      - failure: \(String(reflecting: failure))
      """,
      sourceLocation: sourceLocation
    )
    
    try additionalVerification?(error)
  }
}
