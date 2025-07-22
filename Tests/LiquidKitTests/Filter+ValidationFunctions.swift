import Testing
@testable import LiquidKit

// MARK: Result Validation

func validateEvaluation(
  of value: some TokenValueConvertible,
  with parameters: [Token.Value] = [],
  by filter: some Filter,
  yields expected: some TokenValueConvertible,
  _ explanation: @autoclosure () -> String? = nil,
  sourceLocation: SourceLocation = #_sourceLocation
) throws {
  try validateEvaluation(
    of: value,
    with: parameters,
    by: filter,
    yields: expected.tokenValue,
    explanation(),
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
  try validateEvaluation(
    of: value.tokenValue,
    with: parameters,
    by: filter,
    yields: expected,
    explanation(),
    sourceLocation: sourceLocation
  )
}

func validateEvaluation(
  of value: Token.Value,
  with parameters: [Token.Value] = [],
  by filter: some Filter,
  yields expected: Token.Value,
  _ explanation: @autoclosure () -> String? = nil,
  sourceLocation: SourceLocation = #_sourceLocation
) throws {
  let observed = try filter.evaluate(
    token: value,
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

// MARK: - Error Validation

func validateEvaluation<ErrorType>(
  of value: some TokenValueConvertible,
  with parameters: [Token.Value] = [],
  by filter: some Filter,
  throws errorType: ErrorType.Type,
  _ explanation: @autoclosure () -> String? = nil,
  sourceLocation: SourceLocation = #_sourceLocation,
  additionalVerification: ((ErrorType) throws -> Void)? = nil
) throws where ErrorType: Error {
  try validateEvaluation(
    of: value.tokenValue,
    with: parameters,
    by: filter,
    throws: errorType,
    explanation(),
    sourceLocation: sourceLocation,
    additionalVerification: additionalVerification
  )
}

func validateEvaluation<ErrorType>(
  of value: Token.Value,
  with parameters: [Token.Value] = [],
  by filter: some Filter,
  throws errorType: ErrorType.Type,
  _ explanation: @autoclosure () -> String? = nil,
  sourceLocation: SourceLocation = #_sourceLocation,
  additionalVerification: ((ErrorType) throws -> Void)? = nil
) throws where ErrorType: Error {
  do {
    let observed = try filter.evaluate(
      token: value,
      parameters: parameters
    )
  }
  catch let failure {
    let error = try #require(
      failure as? ErrorType,
      """
      Encountered an unexpected error type: \(type(of: failure)) for \(String(reflecting: filter))\(explanation().map { " \($0)" } ?? ""):
      
      - value: \(String(reflecting: value))
      - parameters: [ \(String(reflecting: parameters.lazy.map({String(reflecting: $0)}).joined(separator: ", "))) ]
      - filter: \(String(reflecting: filter))
      - errorType: \(String(reflecting: errorType))
      - failure: \(String(reflecting: failure))
      """,
      sourceLocation: sourceLocation
    )
    
    try additionalVerification?(error)
  }
}

