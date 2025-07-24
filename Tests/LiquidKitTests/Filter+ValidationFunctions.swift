import Testing
@testable import LiquidKit

// MARK: Result Validation

/// Validates that a filter evaluates to an expected result with TokenValueConvertible types.
/// - Parameters:
///   - value: The input value to filter, accepting any `TokenValueConvertible` type.
///   - parameters: Optional parameters for the filter operation.
///   - filter: The filter to test.
///   - expected: The expected result value, accepting any `TokenValueConvertible` type.
///   - explanation: Optional explanation to include in failure messages.
///   - sourceLocation: The source location for test failure reporting.
/// - Throws: Test failures or filter evaluation errors.
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

/// Validates that a filter evaluates to an expected Token.Value result.
/// - Parameters:
///   - value: The input value to filter, accepting any `TokenValueConvertible` type.
///   - parameters: Optional parameters for the filter operation.
///   - filter: The filter to test.
///   - expected: The expected result as a `Token.Value`.
///   - explanation: Optional explanation to include in failure messages.
///   - sourceLocation: The source location for test failure reporting.
/// - Throws: Test failures or filter evaluation errors.
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

/// Validates that a filter evaluates to an expected result with Token.Value types.
/// - Parameters:
///   - value: The input value to filter as a `Token.Value`.
///   - parameters: Optional parameters for the filter operation.
///   - filter: The filter to test.
///   - expected: The expected result as a `Token.Value`.
///   - explanation: Optional explanation to include in failure messages.
///   - sourceLocation: The source location for test failure reporting.
/// - Throws: Test failures or filter evaluation errors.
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

/// Validates that a filter evaluation throws a specific error type.
/// - Parameters:
///   - value: The input value to filter, accepting any `TokenValueConvertible` type.
///   - parameters: Optional parameters for the filter operation.
///   - filter: The filter to test.
///   - errorType: The expected error type that should be thrown.
///   - explanation: Optional explanation to include in failure messages.
///   - sourceLocation: The source location for test failure reporting.
///   - additionalVerification: Optional closure to perform additional error verification.
/// - Throws: Test failures if the wrong error type is thrown or no error occurs.
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

/// Validates that a filter evaluation throws a specific error type with Token.Value input.
/// - Parameters:
///   - value: The input value to filter as a `Token.Value`.
///   - parameters: Optional parameters for the filter operation.
///   - filter: The filter to test.
///   - errorType: The expected error type that should be thrown.
///   - explanation: Optional explanation to include in failure messages.
///   - sourceLocation: The source location for test failure reporting.
///   - additionalVerification: Optional closure to perform additional error verification.
/// - Throws: Test failures if the wrong error type is thrown or no error occurs.
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
    let _ = try filter.evaluate(
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

