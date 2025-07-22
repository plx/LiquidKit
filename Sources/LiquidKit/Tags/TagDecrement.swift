import Foundation

/// Implements the `{% decrement %}` tag, which creates and decrements a persistent counter variable.
/// 
/// The `decrement` tag creates a new counter variable (if it doesn't exist) and decreases its value by one
/// on each call, then outputs the new value. The counter starts at -1 on first use and continues decreasing
/// with each subsequent call. Counter variables are independent of regular template variables and persist
/// across includes and renders within the same template execution context.
/// 
/// ## Examples
/// 
/// Basic counter usage:
/// ```liquid
/// {% decrement counter %}
/// {% decrement counter %}
/// {% decrement counter %}
/// <!-- Outputs: -1 -2 -3 -->
/// ```
/// 
/// Multiple independent counters:
/// ```liquid
/// {% decrement first %} {% decrement second %}
/// {% decrement first %} {% decrement second %}
/// <!-- Outputs: -1 -1 -2 -2 -->
/// ```
/// 
/// Combining with increment:
/// ```liquid
/// {% decrement count %} {% decrement count %}
/// {% increment count %} {% increment count %}
/// <!-- Outputs: -1 -2 -2 -1 -->
/// ```
/// 
/// - Important: Counter variables created by `decrement` are separate from variables created by `assign`.
///   A variable named 'count' created by `assign` is distinct from a counter named 'count'.
/// - Important: Counters are shared with the `{% increment %}` tag - incrementing and decrementing
///   affect the same counter value.
/// - Important: The initial value for a new counter is -1 (not 0), making the first output -1.
/// 
/// - Warning: Counter values persist across template includes and renders within the same execution context,
///   which can lead to unexpected values if you're not tracking counter state.
/// 
/// - SeeAlso: ``TagIncrement``
/// - SeeAlso: [Shopify Liquid decrement](https://shopify.github.io/liquid/tags/variable/#decrement)
/// - SeeAlso: [LiquidJS decrement](https://liquidjs.com/tags/decrement.html)
/// - SeeAlso: [Python Liquid decrement](https://liquid.readthedocs.io/en/latest/tags/#decrement)
package final class TagDecrement: Tag {
  override package var tagExpression: [ExpressionSegment] {
    // example: {% increment IDENTIFIER %}
    [.identifier("assignee")]
  }

  override package class var keyword: String {
    "decrement"
  }

  override package func parse(statement: String, using parser: Parser, currentScope: Parser.Scope) throws {
    try super.parse(statement: statement, using: parser, currentScope: currentScope)

    guard let assignee = compiledExpression["assignee"] as? String else {
      throw Errors.missingArtifacts
    }

    output = [.integer(context.decrementCounter(for: assignee))]
  }
}