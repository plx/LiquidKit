import Foundation

/// Implements the `date` filter, which formats dates according to strftime directives.
/// 
/// The `date` filter converts date strings, Unix timestamps, or special date keywords into formatted 
/// date strings using the strftime formatting language. This is essential for displaying dates in a 
/// human-readable format or converting between different date representations. The filter accepts a 
/// wide variety of input formats and can parse most common date string representations.
/// 
/// The filter requires a format string parameter that uses strftime directives. Common directives
/// include `%Y` for 4-digit year, `%m` for month, `%d` for day, `%H` for hour, `%M` for minute,
/// and `%S` for second. The filter also supports special input values "now" and "today" which
/// both return the current date/time.
/// 
/// The filter supports Unix timestamps (seconds since 1970-01-01 00:00:00 UTC) as both integer
/// and string values, matching the behavior of liquidjs and python-liquid implementations.
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
/// Unix timestamps:
/// ```liquid
/// {{ 1609459200 | date: "%Y-%m-%d" }}
/// <!-- Output: 2021-01-01 -->
/// 
/// {{ "1609459200.500" | date: "%Y-%m-%d %H:%M:%S" }}
/// <!-- Output: 2021-01-01 00:00:00 -->
/// ```
/// 
/// - Important: The filter uses strftime format directives, not modern date format patterns.
///   For example, use `%Y` for year, not `yyyy`.
/// 
/// - Important: Invalid dates or missing format parameters return empty strings rather than
///   throwing errors, which can make debugging date issues challenging.
/// 
/// - Note: The implementation parses dates with consistent UTC timezone handling and uses 
///   en_US_POSIX locale for predictable results across different environments. This matches
///   the behavior of other Liquid implementations like liquidjs and python-liquid.
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
    // If no format parameter is provided, return empty string to match Liquid behavior
    guard !parameters.isEmpty else {
      return .string("")
    }
    
    // Extract the format string from the first parameter
    let format = parameters[0].stringValue
    
    // Parse the input date
    // First convert the token to a string representation
    let inputString = token.stringValue
    
    // Try to parse the date using the enhanced parseDate method
    guard let date = Self.parseDate(string: inputString) else {
      // If parsing fails, return empty string (graceful degradation)
      return .string("")
    }
    
    // Format the date using StrftimeFormatter
    let formatter = StrftimeFormatter()
    formatter.setFormatString(format)
    
    // Convert the date to the requested format
    if let formattedDate = formatter.string(from: date) {
      return .string(formattedDate)
    } else {
      // If formatting fails, return empty string
      return .string("")
    }
  }
}