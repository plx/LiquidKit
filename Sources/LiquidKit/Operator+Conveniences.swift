
extension Operator {
  
  /// Applies the operator to two values that conform to `TokenValueConvertible`.
  /// - Parameters:
  ///   - lhs: The left-hand side operand, automatically converted to `Token.Value`.
  ///   - rhs: The right-hand side operand, automatically converted to `Token.Value`.
  /// - Returns: The result of the operator application as a `Token.Value`.
  /// - Throws: An error if the operator application fails.
  package func apply(
    _ lhs: some TokenValueConvertible,
    _ rhs: some TokenValueConvertible
  ) throws -> Token.Value {
    try apply(
      lhs.tokenValue,
      rhs.tokenValue
    )
  }

}
