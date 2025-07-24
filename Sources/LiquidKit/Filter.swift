import Foundation
import HTMLEntities


// MARK: - Filter protocol

/// A protocol representing a filter. Filters transform `Token.Value` objects into other `Token.Value` objects, and might
/// accept one or more `Token.Value` parameters. Filters are identified by the `identifier` value, and only one filter
/// can be defined per `identifier`.
public protocol Filter: Sendable {
  
  static var filterIdentifier: String { get }
  var identifier: String { get }
  func evaluate(
    token: Token.Value, 
    parameters: [Token.Value]
  ) throws -> Token.Value
  
}

extension Filter {
  
  @inlinable
  public var identifier: String {
    Self.filterIdentifier
  }
}

extension [String: any Filter]
{
  static let builtInFilters: [String: any Filter] = [String: any Filter](
    uniqueKeysWithValues: ([
      AbsFilter(),
      AppendFilter(),
      AtLeastFilter(),
      AtMostFilter(),
      Base64DecodeFilter(),
      Base64EncodeFilter(),
      Base64UrlSafeDecodeFilter(),
      Base64UrlSafeEncodeFilter(),
      CapitalizeFilter(),
      CeilFilter(),
      CompactFilter(),
      ConcatFilter(),
      DateFilter(),
      DefaultFilter(),
      DividedByFilter(),
      DowncaseFilter(),
      EscapeFilter(),
      EscapeOnceFilter(),
      FirstFilter(),
      FindFilter(),
      FindIndexFilter(),
      FloorFilter(),
      JoinFilter(),
      LastFilter(),
      LstripFilter(),
      MapFilter(),
      MinusFilter(),
      ModuloFilter(),
      NewlineToBrFilter(),
      PlusFilter(),
      PrependFilter(),
      RemoveFilter(),
      RemoveFirstFilter(),
      RemoveLastFilter(),
      RejectFilter(),
      ReplaceFilter(),
      ReplaceFirstFilter(),
      ReplaceLastFilter(),
      ReverseFilter(),
      RoundFilter(),
      RstripFilter(),
      SizeFilter(),
      SliceFilter(),
      SortFilter(),
      SortNaturalFilter(),
      SplitFilter(),
      StripFilter(),
      StripHtmlFilter(),
      StripNewlinesFilter(),
      TimesFilter(),
      TruncateFilter(),
      TruncateWordsFilter(),
      UnescapeFilter(),
      UniqFilter(),
      UpcaseFilter(),
      UrlDecodeFilter(),
      UrlEncodeFilter(),
      WhereFilter()
    ] as [any Filter]).map { filter in (filter.identifier, filter) }
  )
}

public extension Filter
{
	static func parseDate(string inputString: String) -> Date?
	{
		// Check for empty strings first
		guard !inputString.isEmpty else
		{
			return nil
		}
		
		// Handle special keywords "now" and "today" - both return current date/time
		guard inputString != "today", inputString != "now" else
		{
			return Date()
		}
		
		// Check if the input might be a Unix timestamp (all digits, possibly with a decimal point)
		// This matches liquidjs and python-liquid behavior for Unix timestamps
		if let timestamp = Double(inputString) {
			// Unix timestamps are seconds since 1970-01-01 00:00:00 UTC
			return Date(timeIntervalSince1970: timestamp)
		}

		// Create a date formatter with a consistent locale for predictable parsing
		let dateFormatter = DateFormatter()
		dateFormatter.locale = Locale(identifier: "en_US_POSIX")
		// Use UTC for consistent parsing across timezones
		// Dates without timezone info are interpreted as UTC
		dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
		
		// Try common date formats in order of likelihood
		// These formats cover most standard date representations
		let formats = [
			"yyyy-MM-dd",                    // ISO 8601 date only (e.g., "2023-12-25")
			"yyyy-MM-dd HH:mm:ss",           // ISO 8601 with time (e.g., "2023-12-25 14:30:45")
			"yyyy-MM-dd'T'HH:mm:ss",         // ISO 8601 with T separator
			"yyyy-MM-dd'T'HH:mm:ssZ",        // ISO 8601 with timezone
			"yyyy-MM-dd'T'HH:mm:ss.SSSZ",    // ISO 8601 with milliseconds and timezone
			"MMM d, yyyy",                   // Common format (e.g., "March 14, 2016")
			"MMMM d, yyyy",                  // Full month name (e.g., "January 1, 2021")
			"d MMM yyyy",                    // Day first format (e.g., "1 Jan 2021")
			"d MMMM yyyy",                   // Day first with full month
			"MM/dd/yyyy",                    // US format
			"dd/MM/yyyy",                    // European format
			"yyyy/MM/dd",                    // Alternative ISO format
			"EEE, dd MMM yyyy HH:mm:ss zzz", // RFC 2822 format
			"yyyy-MM-dd HH:mm:ss Z",         // ISO with timezone offset
			"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"   // ISO 8601 with milliseconds in UTC
		]
		
		// Try each format until one succeeds
		for format in formats {
			dateFormatter.dateFormat = format
			if let parsedDate = dateFormatter.date(from: inputString) {
				return parsedDate
			}
		}
		
		// As a fallback, try the built-in DateFormatter styles
		// This handles localized date strings
		let styles: [DateFormatter.Style] = [.none, .short, .medium, .long, .full]

		for dateStyle in styles
		{
			for timeStyle in styles
			{
				dateFormatter.dateFormat = nil // Clear custom format
				dateFormatter.dateStyle = dateStyle
				dateFormatter.timeStyle = timeStyle

				// Try with current locale first
				dateFormatter.locale = Locale.current

				if let parsedDate = dateFormatter.date(from: inputString)
				{
					return parsedDate
				}

				// Then try with en_US locale
				dateFormatter.locale = Locale(identifier: "en_US")

				if let parsedDate = dateFormatter.date(from: inputString)
				{
					return parsedDate
				}
			}
		}

		// If all parsing attempts fail, return nil
		return nil
	}
}