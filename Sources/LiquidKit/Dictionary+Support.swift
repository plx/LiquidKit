
extension Dictionary where Value: AdditiveArithmetic & ExpressibleByIntegerLiteral {
  
  @inlinable
  @discardableResult
  package mutating func incrementValue(
    forKey key: Key,
  ) -> Value {
    switch self[key] {
    case .some(let value):
      self[key] = value + 1
      return value
    case .none:
      self[key] = 1
      return 0
    }
  }

  @inlinable
  @discardableResult
  package mutating func decrementValue(
    forKey key: Key,
  ) -> Value {
    let value = self[key, default: 0] - 1
    self[key] = value
    return value
  }

}


