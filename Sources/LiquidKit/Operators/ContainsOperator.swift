
public struct ContainsOperator: Operator {
  
  public static let operatorIdentifier: String = "contains"
  
  public func apply(_ lhs: Token.Value, _ rhs: Token.Value) -> Token.Value {
    if case .array(let array) = lhs, case .string(let string) = rhs {
      .bool(array.contains(.string(string)))
    } else if case .string(let haystack) = lhs, case .string(let needle) = rhs {
      .bool(haystack.contains(needle))
    } else {
      .bool(false)
    }
  }
  
  @inlinable
  package init() { }
}
