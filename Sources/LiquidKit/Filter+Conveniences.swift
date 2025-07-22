
extension Filter {
  
  /// Evaluates the filter with a value that conforms to `TokenValueConvertible`.
  /// - Parameters:
  ///   - value: The input value to be filtered, automatically converted to `Token.Value`.
  ///   - parameters: Optional parameters for the filter operation.
  /// - Returns: The filtered result as a `Token.Value`.
  /// - Throws: An error if the filter evaluation fails.
  package func evaluate(
    value: some TokenValueConvertible,
    parameters: [Token.Value] = []
  ) throws -> Token.Value {
    try evaluate(
      token: value.tokenValue,
      parameters: parameters
    )
  }
  
}
