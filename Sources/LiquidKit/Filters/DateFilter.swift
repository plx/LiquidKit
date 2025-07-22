import Foundation

/// Implements the `date` filter, which formats dates according to strftime directives.
/// 
/// The `date` filter converts date strings or special date keywords into formatted date strings
/// using the strftime formatting language. This is essential for displaying dates in a human-readable
/// format or converting between different date representations. The filter accepts a wide variety
/// of input formats and can parse most common date string representations.
/// 
/// The filter requires a format string parameter that uses strftime directives. Common directives
/// include `%Y` for 4-digit year, `%m` for month, `%d` for day, `%H` for hour, `%M` for minute,
/// and `%S` for second. The filter also supports special input values "now" and "today" which
/// represent the current date/time.
/// 
/// If the input cannot be parsed as a date or if no format parameter is provided, the filter
/// returns an empty string. This graceful degradation prevents template errors when dealing
/// with potentially invalid date data.
/// 
/// ## Examples
/// 
/// Basic date formatting:
/// ```liquid
/// {{ "March 14, 2016" | date: "%b %d, %y" }}
/// <!-- Output: Mar 14, 16 -->
/// 
/// {{ article.published_at | date: "%a, %b %d, %y" }}
/// <!-- Output: Mon, Mar 14, 16 -->
/// ```
/// 
/// Using different format patterns:
/// ```liquid
/// {{ "2023-12-25" | date: "%B %d, %Y" }}
/// <!-- Output: December 25, 2023 -->
/// 
/// {{ post.date | date: "%Y-%m-%d %H:%M" }}
/// <!-- Output: 2023-12-25 14:30 -->
/// ```
/// 
/// Special date keywords:
/// ```liquid
/// {{ "now" | date: "%Y-%m-%d %H:%M:%S" }}
/// <!-- Output: current date and time -->
/// 
/// {{ "today" | date: "%A, %B %d, %Y" }}
/// <!-- Output: Monday, December 25, 2023 -->
/// ```
/// 
/// - Important: The filter uses strftime format directives, not modern date format patterns.
///   For example, use `%Y` for year, not `yyyy`.
/// 
/// - Important: Invalid dates or missing format parameters return empty strings rather than
///   throwing errors, which can make debugging date issues challenging.
/// 
/// - Warning: Date parsing is locale-dependent and may produce different results in different
///   environments. When possible, use ISO 8601 date formats for consistency.
/// 
/// - SeeAlso: [Shopify Liquid date](https://shopify.github.io/liquid/filters/date/)
/// - SeeAlso: [LiquidJS date](https://liquidjs.com/filters/date.html)
/// - SeeAlso: [strftime reference](https://strftime.org/)
@usableFromInline
package struct DateFilter: Filter {
  @usableFromInline
  package static let filterIdentifier = "date"
  
  @inlinable
  package init() {}
  
  @usableFromInline
  package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
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