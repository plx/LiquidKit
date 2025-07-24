import Testing
import Foundation
@testable import LiquidKit

@Suite("DateFilter", .tags(.filter, .dateFilter))
struct DateFilterTests {
  
  // MARK: - Test Fixtures
  
  /// A fixed date for consistent testing
  private static let testDate = Date(timeIntervalSince1970: 1609459200) // 2021-01-01 00:00:00 UTC
  
  /// The filter instance to test
  private let filter = DateFilter()
  
  // MARK: - Basic Functionality Tests
  
  @Test("Formats date strings with various patterns")
  func formatsDateStrings() throws {
    // Test common date string formats
    try validateEvaluation(
      of: "March 14, 2016",
      with: [.string("%b %d, %y")],
      by: filter,
      yields: "Mar 14, 16"
    )
    
    try validateEvaluation(
      of: "2023-12-25",
      with: [.string("%B %d, %Y")],
      by: filter,
      yields: "December 25, 2023"
    )
    
    try validateEvaluation(
      of: "2023-12-25",
      with: [.string("%Y-%m-%d")],
      by: filter,
      yields: "2023-12-25"
    )
  }
  
  @Test("Handles time components in format strings")
  func handlesTimeComponents() throws {
    // Test date with time
    try validateEvaluation(
      of: "2023-12-25 14:30:45",
      with: [.string("%Y-%m-%d %H:%M:%S")],
      by: filter,
      yields: "2023-12-25 14:30:45"
    )
    
    // Test 12-hour format with AM/PM
    try validateEvaluation(
      of: "2023-12-25 14:30:00",
      with: [.string("%I:%M %p")],
      by: filter,
      yields: "02:30 PM"
    )
  }
  
  @Test("Handles weekday formatting")
  func handlesWeekdayFormatting() throws {
    // January 1, 2021 was a Friday
    try validateEvaluation(
      of: "2021-01-01",
      with: [.string("%A")],
      by: filter,
      yields: "Friday"
    )
    
    try validateEvaluation(
      of: "2021-01-01",
      with: [.string("%a")],
      by: filter,
      yields: "Fri"
    )
  }
  
  // MARK: - Special Values Tests
  
  @Test("Handles 'now' keyword")
  func handlesNowKeyword() throws {
    // Since 'now' returns the current time, we can only test that it returns a non-empty string
    let result = try filter.evaluate(token: .string("now"), parameters: [.string("%Y-%m-%d")])
    
    guard case let .string(dateString) = result else {
      #expect(Bool(false), "Expected string result for 'now'")
      return
    }
    
    #expect(!dateString.isEmpty, "'now' should return a non-empty date string")
    
    // Verify it's a valid date format (YYYY-MM-DD)
    let components = dateString.split(separator: "-")
    #expect(components.count == 3, "Date should have 3 components")
    #expect(components[0].count == 4, "Year should be 4 digits")
    #expect(components[1].count == 2, "Month should be 2 digits")
    #expect(components[2].count == 2, "Day should be 2 digits")
  }
  
  @Test("Handles 'today' keyword")
  func handlesTodayKeyword() throws {
    // 'today' should behave the same as 'now'
    let result = try filter.evaluate(token: .string("today"), parameters: [.string("%Y-%m-%d")])
    
    guard case let .string(dateString) = result else {
      #expect(Bool(false), "Expected string result for 'today'")
      return
    }
    
    #expect(!dateString.isEmpty, "'today' should return a non-empty date string")
  }
  
  // MARK: - Unix Timestamp Tests
  
  @Test("Handles Unix timestamps")
  func handlesUnixTimestamps() throws {
    // Test integer Unix timestamp
    try validateEvaluation(
      of: 1609459200, // 2021-01-01 00:00:00 UTC
      with: [.string("%Y-%m-%d")],
      by: filter,
      yields: "2021-01-01"
    )
    
    // Test string Unix timestamp
    try validateEvaluation(
      of: "1609459200", // 2021-01-01 00:00:00 UTC
      with: [.string("%Y-%m-%d")],
      by: filter,
      yields: "2021-01-01"
    )
    
    // Test floating point Unix timestamp
    try validateEvaluation(
      of: "1609459200.500", // 2021-01-01 00:00:00.500 UTC
      with: [.string("%Y-%m-%d %H:%M:%S")],
      by: filter,
      yields: "2021-01-01 00:00:00"
    )
  }
  
  // MARK: - Error Handling Tests
  
  @Test("Returns empty string for invalid dates")
  func returnsEmptyStringForInvalidDates() throws {
    // Invalid date strings
    try validateEvaluation(
      of: "not a date",
      with: [.string("%Y-%m-%d")],
      by: filter,
      yields: ""
    )
    
    try validateEvaluation(
      of: "2023-13-45", // Invalid month and day
      with: [.string("%Y-%m-%d")],
      by: filter,
      yields: ""
    )
    
    try validateEvaluation(
      of: "",
      with: [.string("%Y-%m-%d")],
      by: filter,
      yields: ""
    )
  }
  
  @Test("Returns empty string when format parameter is missing")
  func returnsEmptyStringWhenFormatMissing() throws {
    try validateEvaluation(
      of: "2023-12-25",
      with: [],
      by: filter,
      yields: ""
    )
  }
  
  @Test("Handles nil input")
  func handlesNilInput() throws {
    try validateEvaluation(
      of: Token.Value.nil,
      with: [.string("%Y-%m-%d")],
      by: filter,
      yields: ""
    )
  }
  
  // MARK: - Format String Edge Cases
  
  @Test("Handles complex format strings")
  func handlesComplexFormatStrings() throws {
    // Test multiple format specifiers
    try validateEvaluation(
      of: "2021-01-01 15:30:45",
      with: [.string("%A, %B %d, %Y at %I:%M %p")],
      by: filter,
      yields: "Friday, January 01, 2021 at 03:30 PM"
    )
  }
  
  @Test("Handles literal percent signs")
  func handlesLiteralPercentSigns() throws {
    try validateEvaluation(
      of: "2023-12-25",
      with: [.string("%%Y = %Y")],
      by: filter,
      yields: "%Y = 2023"
    )
  }
  
  @Test("Handles unknown format specifiers")
  func handlesUnknownFormatSpecifiers() throws {
    // Unknown specifiers should be preserved
    try validateEvaluation(
      of: "2023-12-25",
      with: [.string("%Y %Q %m")],
      by: filter,
      yields: "2023 %Q 12"
    )
  }
  
  // MARK: - Locale and Timezone Tests
  
  @Test("Uses consistent locale for formatting")
  func usesConsistentLocale() throws {
    // Should use en_US_POSIX locale for consistent output
    try validateEvaluation(
      of: "January 1, 2021",
      with: [.string("%B")],
      by: filter,
      yields: "January"
    )
  }
  
  // MARK: - Additional strftime Format Tests
  
  @Test("Handles day of year formatting")
  func handlesDayOfYear() throws {
    // January 1st is day 001
    try validateEvaluation(
      of: "2021-01-01",
      with: [.string("%j")],
      by: filter,
      yields: "001"
    )
    
    // December 31st in non-leap year is day 365
    try validateEvaluation(
      of: "2021-12-31",
      with: [.string("%j")],
      by: filter,
      yields: "365"
    )
  }
  
  @Test("Handles century formatting")
  func handlesCentury() throws {
    try validateEvaluation(
      of: "2023-12-25",
      with: [.string("%C")],
      by: filter,
      yields: "20"
    )
    
    try validateEvaluation(
      of: "1999-12-31",
      with: [.string("%C")],
      by: filter,
      yields: "19"
    )
  }
  
  @Test("Handles ISO 8601 date format")
  func handlesISO8601() throws {
    try validateEvaluation(
      of: "2023-12-25",
      with: [.string("%F")],
      by: filter,
      yields: "2023-12-25"
    )
  }
  
  // MARK: - Parameter Type Tests
  
  @Test("Handles non-string format parameters")
  func handlesNonStringFormatParameters() throws {
    // Non-string format should use stringValue which converts 123 to "123"
    // Since "123" doesn't contain any format specifiers, it should just return "123"
    try validateEvaluation(
      of: "2023-12-25",
      with: [.integer(123)],
      by: filter,
      yields: "123" // The format string "123" has no format specifiers, so it returns as-is
    )
  }
}