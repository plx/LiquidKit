
public struct ContainsOperator: Operator {
  
  public static let operatorIdentifier: String = "contains"
  
  public func apply(_ lhs: Token.Value, _ rhs: Token.Value) -> Token.Value {
    switch (lhs, rhs) {
    case (.array(let array), .string(let string)):
      .bool(array.contains(.string(string)))
    case (.string(let haystack), .string(let needle)):
      .bool(haystack.contains(needle))
    default:
      .bool(false)
    }
  }
  
  @inlinable
  package init() { }
}
