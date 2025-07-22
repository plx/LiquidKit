import Foundation

/// Implements the `{% continue %}` tag, which skips the current iteration of a for loop.
/// 
/// The `continue` tag causes the for loop to skip the remaining code in the current iteration and move on to the next
/// item in the collection. This tag must be used inside a `{% for %}` loop - using it outside of a loop context will
/// have no effect.
/// 
/// ## Examples
/// 
/// Basic usage to skip specific items:
/// ```liquid
/// {% for item in collection %}
///   {% if item == "skip_me" %}
///     {% continue %}
///   {% endif %}
///   {{ item }}
/// {% endfor %}
/// ```
/// 
/// Using continue with multiple conditions:
/// ```liquid
/// {% for product in products %}
///   {% if product.available == false %}
///     {% continue %}
///   {% endif %}
///   {% if product.price > 100 %}
///     {% continue %}
///   {% endif %}
///   {{ product.name }}: ${{ product.price }}
/// {% endfor %}
/// ```
/// 
/// - Important: The `continue` tag only affects the innermost `for` loop when used in nested loops.
/// - Important: Unlike `break`, `continue` does not prevent the `{% else %}` clause of a for loop from executing
///   if the loop completes normally.
/// 
/// - SeeAlso: ``TagFor``, ``TagBreak``
/// - SeeAlso: [Shopify Liquid continue](https://shopify.github.io/liquid/tags/iteration/#continue)
/// - SeeAlso: [LiquidJS continue](https://liquidjs.com/tags/continue.html)
package final class TagContinue: Tag {
  override package class var keyword: String {
    "continue"
  }

  override package func parse(statement: String, using parser: Parser, currentScope: Parser.Scope) throws {
    try super.parse(statement: statement, using: parser, currentScope: currentScope)

    if currentScope.outputState == .enabled,
      let forScope = currentScope.scopeDefined(by: [TagFor.kind])
    {
      forScope.outputState = .halted
    }
  }
}