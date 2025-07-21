import Foundation

struct SliceFilter: Filter {
  static let filterIdentifier = "slice"
  
  func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
    guard !parameters.isEmpty else {
      return token
    }
    
    let string = token.stringValue
    let startIndex = parameters[0].integerValue ?? 0
    
    // Handle single character slice
    if parameters.count == 1 {
      let index: Int
      if startIndex < 0 {
        // Negative index counts from the end
        index = string.count + startIndex
      } else {
        index = startIndex
      }
      
      guard index >= 0 && index < string.count else {
        return .string("")
      }
      
      let stringIndex = string.index(string.startIndex, offsetBy: index)
      return .string(String(string[stringIndex]))
    }
    
    // Handle range slice
    guard parameters.count >= 2 else {
      return .string("")
    }
    
    let length = parameters[1].integerValue ?? 0
    
    // Calculate actual start index
    let actualStart: Int
    if startIndex < 0 {
      actualStart = string.count + startIndex
    } else {
      actualStart = startIndex
    }
    
    // Ensure start is within bounds
    guard actualStart >= 0 && actualStart < string.count && length > 0 else {
      return .string("")
    }
    
    // Calculate end index
    let endOffset = min(actualStart + length, string.count)
    
    let startStringIndex = string.index(string.startIndex, offsetBy: actualStart)
    let endStringIndex = string.index(string.startIndex, offsetBy: endOffset)
    
    return .string(String(string[startStringIndex..<endStringIndex]))
  }
}