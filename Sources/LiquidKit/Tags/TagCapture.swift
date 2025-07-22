import Foundation

/// Implements the `{% capture %}` tag, which captures rendered content into a variable.
/// 
/// The capture tag evaluates its content block and stores the resulting string in a variable.
/// Unlike assign, which stores the value of an expression, capture stores the rendered
/// output of everything between the opening and closing tags, including the results of
/// any tags, filters, or variable substitutions within the block.
/// 
/// Basic usage captures simple text:
/// ```liquid
/// {% capture greeting %}Hello, World!{% endcapture %}
/// {{ greeting }}
/// // Output: Hello, World!
/// ```
/// 
/// Capture can include dynamic content and template logic:
/// ```liquid
/// {% capture welcome_message %}
///   Hello, {{ customer.first_name }}.
///   {% if customer.orders_count > 0 %}
///     Thanks for being a loyal customer!
///   {% endif %}
/// {% endcapture %}
/// {{ welcome_message }}
/// // With customer.first_name = "Holly" and customer.orders_count = 5
/// // Output: Hello, Holly.
/// //         Thanks for being a loyal customer!
/// ```
/// 
/// Variables created by capture can be reassigned:
/// ```liquid
/// {% capture some %}hello{% endcapture %}
/// {% assign other = some %}
/// {% assign some = 'foo' %}
/// {{ some }}-{{ other }}
/// // Output: foo-hello
/// ```
/// 
/// Capture supports the same identifier formats as assign:
/// ```liquid
/// {% capture _private %}value{% endcapture %}
/// {% capture item-name %}Product{% endcapture %}
/// {% capture FOO %}BAR{% endcapture %}
/// ```
/// 
/// - Important: The capture tag always produces a string, even if the content
///   appears to be a number or other type.
/// - Important: Whitespace inside the capture block is preserved in the output.
///   Use whitespace control (`{%-` and `-%}`) to manage unwanted whitespace.
/// - Important: Empty capture blocks create empty string variables.
/// 
/// - Warning: Variable names cannot start with a hyphen (e.g., `-foo` is invalid).
/// - Warning: Using only digits as an identifier (e.g., `{% capture 123 %}`) may
///   not work as expected since digits are treated as literals.
/// 
/// - SeeAlso: ``TagAssign``
/// - SeeAlso: [liquidjs capture](https://liquidjs.com/tags/capture.html)
/// - SeeAlso: [python-liquid capture](https://liquid.readthedocs.io/en/latest/tags/capture/)
/// - SeeAlso: [Shopify Liquid capture](https://shopify.github.io/liquid/tags/variable/#capture)
package final class TagCapture: Tag {
  override package var tagExpression: [ExpressionSegment] {
    // example: {% capture IDENTIFIER %}
    [.identifier("assignee")]
  }

  override package class var keyword: String {
    "capture"
  }

  override package var definesScope: Bool {
    true
  }

  override package func parse(statement: String, using parser: Parser, currentScope: Parser.Scope) throws {
    try super.parse(statement: statement, using: parser, currentScope: currentScope)

    guard compiledExpression["assignee"] is String else {
      throw Errors.missingArtifacts
    }
  }
}