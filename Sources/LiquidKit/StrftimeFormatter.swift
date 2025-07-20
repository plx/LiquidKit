import Foundation

// MARK: - Native Swift implementation to replace STRFTimeFormatter dependency

/// A native Swift formatter that provides strftime-style date formatting
/// This replaces the STRFTimeFormatter dependency for LiquidKit
package class StrftimeFormatter {
  private var formatString: String = ""
  
  func setFormatString(_ format: String) {
    self.formatString = format
  }
  
  func string(from date: Date) -> String? {
    // Convert strftime format to DateFormatter patterns
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.timeZone = TimeZone.current
    
    // Parse the strftime format and convert to DateFormatter pattern
    var pattern = ""
    var index = formatString.startIndex
    
    while index < formatString.endIndex {
      let char = formatString[index]
      
      if char == "%" && formatString.index(after: index) < formatString.endIndex {
        let nextIndex = formatString.index(after: index)
        let specifier = formatString[nextIndex]
        
        switch specifier {
          // Year
        case "Y":
          pattern += "yyyy"
        case "y":
          pattern += "yy"
          
          // Month
        case "m":
          pattern += "MM"
        case "B":
          pattern += "MMMM"
        case "b", "h":
          pattern += "MMM"
          
          // Day
        case "d":
          pattern += "dd"
        case "e":
          pattern += "d"
        case "j":
          // Day of year (001-366)
          dateFormatter.dateFormat = "DDD"
          return dateFormatter.string(from: date)
          
          // Weekday
        case "A":
          pattern += "EEEE"
        case "a":
          pattern += "EEE"
        case "w":
          pattern += "e"
        case "u":
          pattern += "c"
          
          // Hour
        case "H":
          pattern += "HH"
        case "I":
          pattern += "hh"
        case "k":
          pattern += "H"
        case "l":
          pattern += "h"
          
          // Minute
        case "M":
          pattern += "mm"
          
          // Second
        case "S":
          pattern += "ss"
          
          // AM/PM
        case "p":
          pattern += "a"
        case "P":
          pattern += "a"
          
          // Time zone
        case "Z":
          pattern += "zzz"
        case "z":
          pattern += "Z"
          
          // Date and time
        case "c":
          dateFormatter.dateStyle = .short
          dateFormatter.timeStyle = .short
          return dateFormatter.string(from: date)
        case "x":
          dateFormatter.dateStyle = .short
          dateFormatter.timeStyle = .none
          return dateFormatter.string(from: date)
        case "X":
          dateFormatter.dateStyle = .none
          dateFormatter.timeStyle = .short
          return dateFormatter.string(from: date)
          
          // Other
        case "n":
          pattern += "\n"
        case "t":
          pattern += "\t"
        case "%":
          pattern += "%"
          
          // Week of year
        case "U", "W":
          // Week of year - use week of year
          dateFormatter.dateFormat = "ww"
          return dateFormatter.string(from: date)
          
          // Century
        case "C":
          let year = Calendar.current.component(.year, from: date)
          return String(format: "%02d", year / 100)
          
          // ISO 8601 date
        case "F":
          pattern += "yyyy-MM-dd"
          
          // Milliseconds
        case "L":
          pattern += "SSS"
          
        default:
          // Unknown specifier, keep as is
          pattern += "%"
          pattern += String(specifier)
        }
        
        index = formatString.index(after: nextIndex)
      } else {
        pattern += String(char)
        index = formatString.index(after: index)
      }
    }
    
    dateFormatter.dateFormat = pattern
    return dateFormatter.string(from: date)
  }
}
