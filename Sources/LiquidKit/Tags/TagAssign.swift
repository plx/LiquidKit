import Foundation

/// Implements the `{% assign %}` tag, which creates or updates a variable.
/// 
/// The assign tag is used to create new variables or update existing ones in the template's context.
/// Variables created with assign are accessible throughout the template after their declaration.
/// Unlike capture, assign evaluates the right-hand side immediately and stores the resulting value.
/// 
/// Basic usage creates or updates a variable with a literal value:
/// ```liquid
/// {% assign name = "World" %}
/// Hello, {{ name }}!
/// // Output: Hello, World!
/// ```
/// 
/// You can assign the value of an existing variable to a new variable:
/// ```liquid
/// {% assign greeting = "Hello" %}
/// {% assign welcome_message = greeting %}
/// {{ welcome_message }}
/// // Output: Hello
/// ```
/// 
/// Complex values like arrays and hashes can be assigned:
/// ```liquid
/// {% assign my_array = "apple,banana,orange" | split: "," %}
/// {{ my_array[1] }}
/// // Output: banana
/// ```
/// 
/// Variables can use various identifier formats:
/// ```liquid
/// {% assign _private = "value" %}        // Leading underscore
/// {% assign item_1 = "first" %}          // Alphanumeric with underscore
/// {% assign product-name = "Widget" %}   // Hyphens allowed
/// {% assign FOO = "bar" %}               // Uppercase allowed
/// ```
/// 
/// - Important: Variable names cannot start with a hyphen (e.g., `-foo` is invalid).
/// - Important: The assign tag does not support arithmetic operations directly.
///   To perform calculations, use filters like `plus`, `minus`, `times`, or `divided_by`.
/// - Important: Identifiers that are only digits (e.g., `123`) are treated as literals,
///   not variable names, though they can still be assigned values.
/// 
/// - Warning: Liquid does not support operators like `+`, `-`, `*`, or `/` in assign statements.
///   Attempting to use them will result in an error.
/// 
/// - SeeAlso: ``TagCapture``
/// - SeeAlso: [liquidjs assign](https://liquidjs.com/tags/assign.html)
/// - SeeAlso: [python-liquid assign](https://liquid.readthedocs.io/en/latest/tags/assign/)
/// - SeeAlso: [Shopify Liquid assign](https://shopify.github.io/liquid/tags/variable/#assign)
package final class TagAssign: Tag {
  override package var tagExpression: [ExpressionSegment] {
    // example: {% assign IDENTIFIER = "value" %}
    [.identifier("assignee"), .literal("="), .variable("value")]
  }

  override package class var keyword: String {
    "assign"
  }

  override package func parse(statement: String, using parser: Parser, currentScope: Parser.Scope) throws {
    try super.parse(statement: statement, using: parser, currentScope: currentScope)

    guard
      let assignee = compiledExpression["assignee"] as? String,
      let value = compiledExpression["value"] as? Token.Value
    else {
      throw Errors.missingArtifacts
    }

    context.set(value: value, for: assignee)
  }
}