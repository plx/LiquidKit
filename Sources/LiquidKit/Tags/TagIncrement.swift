import Foundation

/// Implements the `{% increment %}` tag, which creates and increments named counters.
/// 
/// The `increment` tag manages independent named counters that start at 0 and increase by 1
/// each time they are called. When first invoked with a counter name, it outputs 0 and sets
/// the counter to 1. Subsequent calls output the current value and increment it. Each counter
/// maintains its own independent state throughout template rendering.
///
/// Basic usage creates and increments a counter:
/// ```liquid
/// {% increment counter %} → 0
/// {% increment counter %} → 1
/// {% increment counter %} → 2
/// ```
///
/// Multiple named counters operate independently:
/// ```liquid
/// {% increment foo %} → 0
/// {% increment bar %} → 0
/// {% increment foo %} → 1
/// {% increment bar %} → 1
/// ```
///
/// Counters are accessible as variables after being incremented:
/// ```liquid
/// {% increment visits %}
/// {% increment visits %}
/// {% if visits > 0 %}
///   Returning visitor (visit #{{ visits }})
/// {% endif %}
/// ```
///
/// - Important: Counter variables created by `increment` are completely independent from variables
///   created by `assign`. A variable named `foo` created by `assign` and a counter named `foo`
///   created by `increment` do not interfere with each other.
///
/// - Important: The `increment` tag outputs the counter value before incrementing it. The first
///   call always outputs 0, not 1.
///
/// - Important: Counters persist across includes but are isolated in rendered templates. Each
///   `render` tag creates a new isolated scope where counters start fresh at 0.
///
/// - Warning: Counter names must be valid identifiers. They cannot contain spaces, dots, or
///   special characters other than hyphens and underscores.
///
/// - SeeAlso: ``TagDecrement``
/// - SeeAlso: [LiquidJS increment](https://liquidjs.com/tags/increment.html)
/// - SeeAlso: [Python Liquid increment](https://liquid.readthedocs.io/en/latest/tags/increment/)
/// - SeeAlso: [Shopify Liquid increment](https://shopify.github.io/liquid/tags/variable/)
package final class TagIncrement: Tag {
  override package var tagExpression: [ExpressionSegment] {
    // example: {% increment IDENTIFIER %}
    [.identifier("assignee")]
  }

  override package class var keyword: String {
    "increment"
  }

  override package func parse(statement: String, using parser: Parser, currentScope: Parser.Scope) throws {
    try super.parse(statement: statement, using: parser, currentScope: currentScope)

    guard let assignee = compiledExpression["assignee"] as? String else {
      throw Errors.missingArtifacts
    }

    output = [.integer(context.incrementCounter(for: assignee))]
  }
}