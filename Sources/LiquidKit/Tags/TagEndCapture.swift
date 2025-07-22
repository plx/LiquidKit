import Foundation

/// Implements the `{% endcapture %}` tag, which closes a capture block.
/// 
/// The `endcapture` tag marks the end of a capture block that was opened with `{% capture %}`.
/// When encountered, it triggers the storage of all rendered content between the opening
/// capture tag and this closing tag into the variable specified in the capture tag. The
/// captured content is stored as a string and can include the results of any Liquid tags,
/// filters, or variable substitutions that were evaluated within the capture block.
/// 
/// Basic usage:
/// ```liquid
/// {% capture my_variable %}
///   This content will be stored in my_variable.
/// {% endcapture %}
/// {{ my_variable }}
/// // Output: This content will be stored in my_variable.
/// ```
/// 
/// Capturing dynamic content:
/// ```liquid
/// {% capture greeting %}
///   Hello, {{ user.name }}!
///   {% if user.is_new %}
///     Welcome to our site!
///   {% endif %}
/// {% endcapture %}
/// ```
/// 
/// Whitespace in captured content is preserved:
/// ```liquid
/// {% capture formatted_text %}
///   Line 1
///   Line 2
///   Line 3
/// {% endcapture %}
/// {{ formatted_text }}
/// // Output includes the line breaks and indentation
/// ```
/// 
/// - Important: The `endcapture` tag must have a matching `{% capture %}` tag.
/// - Important: All content within the capture block is rendered but not output
///   directly; instead, it's stored in the specified variable.
/// - Important: The captured content is always stored as a string, even if it
///   contains only numbers or other data types.
/// 
/// - Warning: Using `endcapture` without a matching `capture` tag will result
///   in a parsing error.
/// 
/// - SeeAlso: ``TagCapture``
/// - SeeAlso: [liquidjs capture](https://liquidjs.com/tags/capture.html)
/// - SeeAlso: [python-liquid capture](https://liquid.readthedocs.io/en/latest/tags/#capture)
/// - SeeAlso: [Shopify Liquid capture](https://shopify.github.io/liquid/tags/variable/#capture)
package final class TagEndCapture: Tag {
  override package class var keyword: String {
    "endcapture"
  }

  override package var terminatesScopesWithTags: [Tag.Type]? {
    [TagCapture.self]
  }

  override package func didTerminate(scope: Parser.Scope, parser: Parser) {
    if let assigneeName = scope.tag?.compiledExpression["assignee"] as? String,
      let compiledCapturedStatements = scope.compile(using: parser)
    {
      context.set(value: .string(compiledCapturedStatements.joined()), for: assigneeName)
    }

    // Prevent the nodes of the scope from being written to the output when the final compilation happens.
    scope.dumpProcessedStatements()
  }
}