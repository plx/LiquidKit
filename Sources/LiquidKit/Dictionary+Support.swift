
extension Dictionary where Value: AdditiveArithmetic {
  
  @inlinable
  @discardableResult
  package mutating func adjustValue(
    forKey key: Key,
    by amount: Value,
    default: @autoclosure () -> Value = .zero
  ) -> Value {
    let existingValue: Value = self[key, default: `default`()]
    let newValue: Value = existingValue + amount
    self[key] = newValue
    return newValue
  }
  
}

extension Dictionary where Value: AdditiveArithmetic & ExpressibleByIntegerLiteral {
  
  @inlinable
  @discardableResult
  package mutating func incrementValue(
    forKey key: Key,
  ) -> Value {
    adjustValue(forKey: key, by: 1)
  }

  @inlinable
  @discardableResult
  package mutating func decrementValue(
    forKey key: Key,
  ) -> Value {
    adjustValue(forKey: key, by: -1)
  }

}


