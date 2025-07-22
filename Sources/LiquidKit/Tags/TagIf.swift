import Foundation

/// Implements the `{% if %}` tag, which conditionally executes blocks based on boolean expressions.
/// 
/// The `if` tag evaluates a condition and executes its block only when the condition is "truthy".
/// It can be combined with `elsif` tags to test multiple conditions sequentially, and an optional
/// `else` tag to provide a fallback when all conditions are false. Conditions can use comparison
/// operators, logical operators, and the special `contains` operator.
///
/// Basic usage tests a single condition:
/// ```liquid
/// {% if user %}
///   Hello {{ user.name }}!
/// {% endif %}
/// ```
///
/// Multiple conditions can be tested with `elsif`:
/// ```liquid
/// {% if product.price > 100 %}
///   Expensive item
/// {% elsif product.price > 50 %}
///   Moderate price
/// {% else %}
///   Budget friendly
/// {% endif %}
/// ```
///
/// Complex conditions can use logical operators `and`, `or`, and comparison operators:
/// ```liquid
/// {% if user.age >= 18 and user.country == "US" %}
///   Eligible for service
/// {% endif %}
///
/// {% if product.available or product.preorder %}
///   Can be purchased
/// {% endif %}
/// ```
///
/// The `contains` operator checks for substring or array membership:
/// ```liquid
/// {% if product.title contains "Sale" %}
///   On sale!
/// {% endif %}
///
/// {% if collection.products contains product %}
///   In collection
/// {% endif %}
/// ```
///
/// - Important: In Liquid, the following values are considered "falsy" and will cause the `if`
///   condition to fail: `false`, `nil`, and empty arrays. Everything else, including empty strings,
///   zero, and empty hashes, are considered "truthy".
///
/// - Important: The `elsif` and `else` tags must appear immediately after the `if` block or previous
///   `elsif` block, with no content between them except whitespace.
///
/// - Warning: Unlike some languages, Liquid does not support parentheses for grouping in conditions.
///   Complex conditions must be carefully ordered as operators are evaluated left-to-right with
///   equal precedence.
///
/// - SeeAlso: ``TagUnless``, ``TagCase``, ``TagElsif``, ``TagElse``
/// - SeeAlso: [LiquidJS if](https://liquidjs.com/tags/if.html)
/// - SeeAlso: [Python Liquid if](https://liquid.readthedocs.io/en/latest/tags/if/)
/// - SeeAlso: [Shopify Liquid if](https://shopify.github.io/liquid/tags/control-flow/)
package final class TagIf: AbstractConditionalTag {
  override package class var keyword: String {
    "if"
  }

  override package func didDefine(scope: Parser.Scope, parser: Parser) {
    super.didDefine(scope: scope, parser: parser)

    // An `if` tag should execute if its statement is considered "truthy".
    if let conditional = (compiledExpression["conditional"] as? Token.Value), conditional.isTruthy {
      tagKindsToSkip = [TagElsif.kind, TagElse.kind]
    } else {
      scope.outputState = .disabled
    }
  }
}