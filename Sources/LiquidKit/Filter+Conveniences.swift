
extension Filter {
  
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
