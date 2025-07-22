import Testing
@testable import LiquidKit

// MARK: Result Validation

/// Validates that an operator application yields an expected result with TokenValueConvertible types.
/// - Parameters:
///   - operator: The operator to test.
///   - operands: A tuple of left and right operands, accepting any `TokenValueConvertible` types.
///   - expected: The expected result value, accepting any `TokenValueConvertible` type.
///   - explanation: Optional explanation to include in failure messages.
///   - sourceLocation: The source location for test failure reporting.
/// - Throws: Test failures or operator application errors.
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

/// Validates that an operator application yields an expected Token.Value result.
/// - Parameters:
///   - operator: The operator to test.
///   - operands: A tuple of left and right operands, accepting any `TokenValueConvertible` types.
///   - expected: The expected result as a `Token.Value`.
///   - explanation: Optional explanation to include in failure messages.
///   - sourceLocation: The source location for test failure reporting.
/// - Throws: Test failures or operator application errors.
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

/// Validates that an operator application yields an expected result with Token.Value operands.
/// - Parameters:
///   - operator: The operator to test.
///   - operands: A tuple of left and right operands as `Token.Value` types.
///   - expected: The expected result as a `Token.Value`.
///   - explanation: Optional explanation to include in failure messages.
///   - sourceLocation: The source location for test failure reporting.
/// - Throws: Test failures or operator application errors.
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

/// Validates that an operator application throws a specific error type.
/// - Parameters:
///   - operator: The operator to test.
///   - operands: A tuple of left and right operands, accepting any `TokenValueConvertible` types.
///   - errorType: The expected error type that should be thrown.
///   - explanation: Optional explanation to include in failure messages.
///   - sourceLocation: The source location for test failure reporting.
///   - additionalVerification: Optional closure to perform additional error verification.
/// - Throws: Test failures if the wrong error type is thrown or no error occurs.
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

/// Validates that an operator application throws a specific error type with Token.Value operands.
/// - Parameters:
///   - operator: The operator to test.
///   - operands: A tuple of left and right operands as `Token.Value` types.
///   - errorType: The expected error type that should be thrown.
///   - explanation: Optional explanation to include in failure messages.
///   - sourceLocation: The source location for test failure reporting.
///   - additionalVerification: Optional closure to perform additional error verification.
/// - Throws: Test failures if the wrong error type is thrown or no error occurs.
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
