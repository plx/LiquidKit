import Foundation

struct DateFilter: Filter {
  static let filterIdentifier = "date"
  
  func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
    // Get the format parameter (required)
    guard !parameters.isEmpty else {
      return .string("")
    }
    
    let format = parameters[0].stringValue
    
    // Parse the input date
    let inputString = token.stringValue
    guard let date = Self.parseDate(string: inputString) else {
      return .string("")
    }
    
    // Format the date using StrftimeFormatter
    let formatter = StrftimeFormatter()
    formatter.setFormatString(format)
    
    if let formattedDate = formatter.string(from: date) {
      return .string(formattedDate)
    } else {
      return .string("")
    }
  }
}