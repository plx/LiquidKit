import Foundation

// MARK: TokenValueConvertible

public protocol TokenValueConvertible {
  var tokenValue: Token.Value { get }
}

// MARK: - Conformances

extension Dictionary: TokenValueConvertible where Key == String, Value == TokenValueConvertible {
  public var tokenValue: Token.Value {
    .dictionary(mapValues({ $0.tokenValue }))
  }
}

extension Array: TokenValueConvertible where Element: TokenValueConvertible {
  public var tokenValue: Token.Value {
    .array(map({ $0.tokenValue }))
  }
}

extension Int: TokenValueConvertible {
  public var tokenValue: Token.Value {
    .integer(self)
  }
}

extension String: TokenValueConvertible {
  public var tokenValue: Token.Value {
    .string(self)
  }
}

extension Float: TokenValueConvertible {
  public var tokenValue: Token.Value {
    precondition(isFinite)
    
    return .decimal(Decimal(floatLiteral: Double(self)))
  }
}

extension Double: TokenValueConvertible {
  public var tokenValue: Token.Value {
    precondition(isFinite)
    return .decimal(Decimal(floatLiteral: self))
  }
}

extension Bool: TokenValueConvertible {
  public var tokenValue: Token.Value {
    .bool(self)
  }
}

extension Range: TokenValueConvertible where Bound: SignedInteger {
  public var tokenValue: Token.Value {
    .range(Int(lowerBound)...Int(upperBound - 1))
  }
}

extension ClosedRange: TokenValueConvertible where Bound: SignedInteger {
  public var tokenValue: Token.Value {
    .range(Int(lowerBound)...Int(upperBound))
  }
}

extension Token.Value: TokenValueConvertible {
  public var tokenValue: Token.Value {
    self
  }
}
