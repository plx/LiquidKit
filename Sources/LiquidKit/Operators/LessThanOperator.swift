
public struct LessThanOperator: Operator {
  
  public static let operatorIdentifier: String = "<"
  
  public func apply(_ lhs: Token.Value, _ rhs: Token.Value) -> Token.Value {
    .bool(lhs.numericComparisonValue < rhs.numericComparisonValue)
  }
  
  @inlinable
  package init() { }
}
