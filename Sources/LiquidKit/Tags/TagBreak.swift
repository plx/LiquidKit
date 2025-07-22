import Foundation

/// Implements the `{% break %}` tag, which exits a for loop early.
/// 
/// The break tag causes the current for loop to stop iterating and exit immediately.
/// It only affects the innermost loop when used in nested loops. Break has no effect
/// outside of a for loop and will be silently ignored in other contexts.
/// 
/// Basic usage exits a loop when a condition is met:
/// ```liquid
/// {% for item in (1..5) %}
///   {% if item == 3 %}
///     {% break %}
///   {% endif %}
///   {{ item }}
/// {% endfor %}
/// // Output: 1 2
/// ```
/// 
/// In nested loops, break only exits the innermost loop:
/// ```liquid
/// {% for i in (1..3) %}
///   {% for j in (1..3) %}
///     {% if j == 2 %}
///       {% break %}
///     {% endif %}
///     {{ i }}-{{ j }}
///   {% endfor %}
/// {% endfor %}
/// // Output: 1-1 2-1 3-1
/// ```
/// 
/// Break can be used with the `offset: continue` parameter in subsequent loops:
/// ```liquid
/// {% for item in (1..6) limit: 4 %}
///   {% if item == 3 %}{% break %}{% endif %}
///   a{{ item }}
/// {% endfor %}
/// {% for item in (1..6) offset: continue %}
///   b{{ item }}
/// {% endfor %}
/// // Output: a1 a2 b5 b6
/// ```
/// 
/// - Important: The break tag only works within for loops. It has no effect in
///   other loop constructs like tablerow (if implemented) or outside of loops entirely.
/// - Important: When a loop is broken, any remaining iterations are skipped, and the
///   forloop.last property may not reflect the expected value.
/// 
/// - SeeAlso: ``TagFor``
/// - SeeAlso: ``TagContinue``
/// - SeeAlso: [liquidjs break](https://liquidjs.com/tags/break.html)
/// - SeeAlso: [python-liquid break](https://liquid.readthedocs.io/en/latest/tags/break/)
/// - SeeAlso: [Shopify Liquid break](https://shopify.github.io/liquid/tags/iteration/#break)
package final class TagBreak: Tag {
  override package class var keyword: String {
    "break"
  }

  override package func parse(statement: String, using parser: Parser, currentScope: Parser.Scope) throws {
    try super.parse(statement: statement, using: parser, currentScope: currentScope)

    if currentScope.outputState == .enabled,
      let forScope = currentScope.scopeDefined(by: [TagFor.kind])
    {
      // If the current scope produces output, finds the nearest iterator and stops its output.
      forScope.outputState = .disabled
    }
  }
}