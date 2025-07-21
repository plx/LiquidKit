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
      ReplaceFilter(),
      ReplaceFirstFilter(),
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
      UniqFilter(),
      UpcaseFilter(),
      UrlDecodeFilter(),
      UrlEncodeFilter()
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
		
		guard inputString != "today", inputString != "now" else
		{
			return Date()
		}

		let styles: [DateFormatter.Style] = [.none, .short, .medium, .long, .full]
		let dateFormatter = DateFormatter()

		for dateStyle in styles
		{
			for timeStyle in styles
			{
				dateFormatter.dateStyle = dateStyle
				dateFormatter.timeStyle = timeStyle

				dateFormatter.locale = Locale.current

				if let parsedDate = dateFormatter.date(from: inputString)
				{
					return parsedDate
				}

				dateFormatter.locale = Locale(identifier: "en_US")

				if let parsedDate = dateFormatter.date(from: inputString)
				{
					return parsedDate
				}
			}
		}

		return nil
	}
}