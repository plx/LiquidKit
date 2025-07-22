import Foundation

/// Implements the `{% unless %}` tag, which executes blocks when conditions are false.
/// 
/// The `unless` tag is the logical opposite of the `if` tag. It executes its block only when
/// the condition evaluates to a "falsy" value. This provides a more readable alternative to
/// negated `if` conditions. Unlike `if`, the `unless` tag does not support `elsif` branches,
/// though it does support an optional `else` clause.
///
/// Basic usage executes when a condition is false:
/// ```liquid
/// {% unless product.available %}
///   This product is sold out
/// {% endunless %}
/// ```
///
/// The `else` clause executes when the condition is true:
/// ```liquid
/// {% unless user.admin %}
///   Access denied - admin only
/// {% else %}
///   Welcome, administrator
/// {% endunless %}
/// ```
///
/// Complex conditions work the same as with `if`:
/// ```liquid
/// {% unless product.price > 100 or product.featured %}
///   Regular priced item
/// {% endunless %}
///
/// {% unless collection contains product %}
///   Product not in this collection
/// {% endunless %}
/// ```
///
/// - Important: The same truthiness rules apply as with `if` tags. Values considered "falsy" are:
///   `false`, `nil`, and empty arrays. All other values, including empty strings, zero, and empty
///   hashes, are "truthy" and will prevent the `unless` block from executing.
///
/// - Important: There is no `elsunless` or `elsif` equivalent for `unless` tags. For multiple
///   conditions, use an `if/elsif/else` structure instead.
///
/// - Warning: Double negatives with `unless` can reduce readability. Consider using `if` with
///   appropriate logic instead of complex negated conditions in `unless`.
///
/// - SeeAlso: ``TagIf``, ``TagElse``
/// - SeeAlso: [LiquidJS unless](https://liquidjs.com/tags/unless.html)  
/// - SeeAlso: [Python Liquid unless](https://liquid.readthedocs.io/en/latest/tags/unless/)
/// - SeeAlso: [Shopify Liquid unless](https://shopify.github.io/liquid/tags/control-flow/)
package final class TagUnless: AbstractConditionalTag {
  override package class var keyword: String {
    "unless"
  }

  override package func didDefine(scope: Parser.Scope, parser: Parser) {
    super.didDefine(scope: scope, parser: parser)

    // An `unless` tag should execute if its statement is considered "falsy".
    if let conditional = (compiledExpression["conditional"] as? Token.Value), conditional.isTruthy {
      scope.outputState = .disabled
    } else {
      // No need to set tagKindsToSkip since unless doesn't have elsif
      scope.outputState = .enabled
    }
  }
}