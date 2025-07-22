
extension Operator {
  
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
