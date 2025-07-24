import Foundation

public enum Token {
  /// A token representing a piece of text.
  case text(String)

  /// A token representing a variable.
  case variable(String)

  /// A token representing a template tag.
  case tag(String)

  /// An enum whose instances are used to represent token variable values.
  public indirect enum Value {
    case `nil`
    case bool(Bool)
    case string(String)
    case integer(Int)
    case decimal(Decimal)
//    case positiveInfinity
//    case negativeInfinity
//    case nan
    case array([Value])
    case dictionary([String: Value])
    case range(ClosedRange<Int>)

    /// Returns a string value or representation of the receiver.
    ///
    /// * If the receiver is an integer or decimal enum, returns its value embedded in a string using `"\()"`.
    /// * If the receiver is a string enum, returns its value.
    /// * For any other enum value, returns an empty string.
    public var stringValue: String {
      switch self {
      case .decimal(let decimal):
        "\(decimal)"
//      case .positiveInfinity:
//        "inf"
//      case .negativeInfinity:
//        "-inf"
//      case .nan:
//        "NaN"
      case .integer(let integer):
        "\(integer)"
      case .string(let string):
        string
      case .array(let array):
        array.lazy.map({ $0.stringValue }).joined()
      case .range(let range):
        "\(range.lowerBound)..\(range.upperBound)"
      default:
        ""
      }
    }

    /// Returns the decimal value of the receiver.
    ///
    /// * If the receiver is an integer enum, returns its value cast to Decimal.
    /// * If the receiver is a decimal enum, returns its value.
    /// * If the receiver is a string enum, attempts to parse its value as a Decimal, which might return `nil`.
    /// * For any other enum value, returns `nil`.
    public var decimalValue: Decimal? {
      switch self {
      case .decimal(let decimal):
        decimal
      case .integer(let integer):
        Decimal(integer)
      case .string(let string):
        Decimal(string: string)
      default:
        nil
      }
    }

    /// Returns the double value of the receiver.
    ///
    /// * If the receiver is an integer enum, returns its value cast to Double.
    /// * If the receiver is a decimal enum, returns its value cast to Double.
    /// * If the receiver is a string enum, attempts to parse its value as a Double, which might return `nil`.
    /// * For any other enum value, returns `nil`.
    public var doubleValue: Double? {
      switch self {
      case .decimal(let decimal):
        (decimal as NSNumber).doubleValue
      case .integer(let integer):
        Double(integer)
      case .string(let string):
        Double(string)
      default:
        nil
      }
    }
        
    package var numericComparisonValue: Double {
      doubleValue ?? 0.0
    }

    /// Returns the integer value of the receiver.
    ///
    /// * If the receiver is an integer enum, returns its value.
    /// * If the receiver is a decimal enum, returns its value cast to Int.
    /// * If the receiver is a string enum, attempts to parse its value as an Int, which might return `nil`.
    /// * For any other enum value, returns `nil`.
    public var integerValue: Int? {
      switch self {
      case .decimal(let decimal):
        (decimal as NSNumber).intValue
      case .integer(let integer):
        integer
      case .string(let string):
        Int(string)
      default:
        nil
      }
    }

    /// Returns `true` if the receiver is either `.nil` or `.bool(false)`. Otherwise returns `false`.
    public var isFalsy: Bool {
      switch self {
      case .bool(false), .nil:
        true
      default:
        false
      }
    }

    /// Returns `false` if the receiver is either `.nil` or `.bool(false)`. Otherwise returns `true`.
    public var isTruthy: Bool {
      !isFalsy
    }

    /// Returns `true` if the receiver is a string enum and its value is an empty string. For all other cases
    /// returns `false`.
    public var isEmptyString: Bool {
      guard case .string(let string) = self else { return false }
      return string.isEmpty
    }

  }
}

extension Token: Sendable { }
extension Token: Equatable { }
extension Token: Hashable { }
extension Token: Codable { }

extension Token.Value: Sendable { }
extension Token.Value: Equatable { }
extension Token.Value: Hashable { }
extension Token.Value: Codable { }
