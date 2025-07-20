import Foundation

public protocol Operator: Sendable {
  
  static var operatorIdentifier: String { get }
  var identifier: String { get }
  func apply(_ lhs: Token.Value, _ rhs: Token.Value) -> Token.Value
  
}

extension Operator {
  
  public var identifier: String {
    Self.operatorIdentifier
  }
}



/// A class modeling an infix operator
//open class Operator: @unchecked Sendable
//{
//  /// Keyword used to identify the filter.
//  let identifier: String
//
//  /// Function that transforms the input string.
//  let lambda: ((Token.Value, Token.Value) -> Token.Value)
//
//  /// Filter constructor.
//  init(identifier: String, lambda: @escaping @Sendable (Token.Value, Token.Value) -> Token.Value) {
//    self.identifier = identifier
//    self.lambda = lambda
//  }
//}

extension [String: any Operator] {
  
  static var builtInOperators: Self {
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
