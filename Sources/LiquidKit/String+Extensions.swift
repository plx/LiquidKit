import Foundation

extension String {
  
  @inlinable
  package func findFirstNot(character: Character) -> String.Index? {
    firstIndex { $0 != character }
  }
  
  @inlinable
  package func findLastNot(character: Character) -> String.Index? {
    guard let naivelastIndex = lastIndex(where: { $0 != character }) else {
      return nil
    }
    
    return index(after: naivelastIndex)
  }
  
  @inlinable
  package func trim(character: Character) -> String {
    let first = findFirstNot(character: character) ?? endIndex
    let last = findLastNot(character: character) ?? endIndex
    return String(self[first..<last])
  }
  
  @inlinable
  package var trimmingWhitespaces: String {
    trimmingCharacters(in: .whitespacesAndNewlines)
  }
  
  @inlinable
  package func firstIndex(
    reverse: Bool,
    where predicate: (Character) throws -> Bool
  ) rethrows -> String.Index? {
    guard !isEmpty else { return nil }
    
    return switch reverse {
    case false:
      try firstIndex(where: predicate)
    case true:
      try lastIndex(where: predicate)
    }
  }
}

extension String {
  /// Split a string by a separator leaving quoted phrases together
  func smartSplit(separator: Character = " ") -> [String] {
    var word = ""
    var components: [String] = []
    var separate: Character = separator
    var singleQuoteCount = 0
    var doubleQuoteCount = 0
    
    for character in self {
      if character == "'" { singleQuoteCount += 1 }
      else if character == "\"" { doubleQuoteCount += 1 }
      
      if character == separate {
        
        if separate != separator {
          word.append(separate)
        } else if singleQuoteCount % 2 == 0 && doubleQuoteCount % 2 == 0 && !word.isEmpty {
          components.append(word)
          word = ""
        }
        
        separate = separator
      } else {
        if separate == separator && (character == "'" || character == "\"") {
          separate = character
        }
        word.append(character)
      }
    }
    
    if !word.isEmpty {
      components.append(word)
    }
    
    return components
  }
  
  func split(boundary: String, maxSplits: Int = Int.max, omittingEmptySubsequences: Bool = false) -> [Substring]
  {
    var splits = [Substring]()
    var scannedIndex = startIndex
    
    while let separatorRange = range(of: boundary, range: scannedIndex..<endIndex), splits.count < maxSplits
    {
      let substringRange = scannedIndex..<separatorRange.lowerBound
      let substring = self[substringRange]
      
      if !(omittingEmptySubsequences && substring.count == 0)
      {
        splits.append(substring)
      }
      
      scannedIndex = separatorRange.upperBound
    }
    
    if splits.count < maxSplits - 1
    {
      let remainderSubstring = self[scannedIndex..<endIndex]
      
      if !(omittingEmptySubsequences && remainderSubstring.count == 0)
      {
        splits.append(remainderSubstring)
      }
    }
    
    return splits
  }
  
  var splitKeyPath: (key: String, index: Int?, remainder: String?)?
  {
    let pattern = "(\\w+)(\\[(\\d+)\\])?\\.?"
    
    let regex: NSRegularExpression
    do {
      regex = try NSRegularExpression(pattern: pattern, options: [])
    } catch {
      // This pattern is hardcoded and should never fail
      assertionFailure("Failed to compile keypath regex pattern: \(error)")
      return nil
    }
    
    guard
      let match = regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)),
      match.range(at: 1).location != NSNotFound
    else
    {
      return nil
    }
    
    guard let keyRange = Range(match.range(at: 1), in: self) else {
      return nil
    }
    let key = String(self[keyRange])
    let remainder: String?
    
    if match.range.upperBound < self.utf16.count
    {
      let startIndex = self.index(self.startIndex, offsetBy: match.range.upperBound)
      remainder = String(self[startIndex...])
    }
    else
    {
      remainder = nil
    }
    
    if match.range(at: 3).location != NSNotFound,
        let range = Range(match.range(at: 3), in: self),
       let index = Int(self[range])
    {
      return (key, index, remainder)
    }
    else
    {
      return (key, nil, remainder)
    }
  }
}

