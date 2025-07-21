import Foundation

public protocol Operator: Sendable {
  
  static var operatorIdentifier: String { get }
  var identifier: String { get }
  func apply(_ lhs: Token.Value, _ rhs: Token.Value) -> Token.Value
  
}

extension Operator {
  
  @inlinable
  public var identifier: String {
    Self.operatorIdentifier
  }
}

extension [String: any Operator] {
  
  @usableFromInline
  package static var builtInOperators: Self {
    Self(
      uniqueKeysWithValues: ([
        EqualsOperator(),
        NotEqualsOperator(),
        GreaterThanOperator(),
        GreaterThanOrEqualOperator(),
        LessThanOperator(),
        LessThanOrEqualOperator(),
        ContainsOperator()
      ] as [any Operator]).lazy.map { op in
        (op.identifier, op)
      })
  }
}
