import Foundation

/// Implements the `{% elsif %}` tag, which adds additional conditional branches to if statements.
/// 
/// The `elsif` tag (also spelled 'elseif' in some implementations) allows you to check multiple conditions
/// in sequence within an if block. When an if condition is false, Liquid evaluates each elsif condition
/// in order until one is true or all conditions have been checked. Only the first true branch executes.
/// 
/// ## Examples
/// 
/// Basic elsif chain:
/// ```liquid
/// {% if product.type == 'book' %}
///   📚 Book: {{ product.title }}
/// {% elsif product.type == 'movie' %}
///   🎬 Movie: {{ product.title }}
/// {% elsif product.type == 'game' %}
///   🎮 Game: {{ product.title }}
/// {% endif %}
/// ```
/// 
/// Multiple conditions with else fallback:
/// ```liquid
/// {% if user.age < 13 %}
///   Content for children
/// {% elsif user.age < 18 %}
///   Content for teens
/// {% elsif user.age < 65 %}
///   Content for adults
/// {% else %}
///   Content for seniors
/// {% endif %}
/// ```
/// 
/// Complex conditions:
/// ```liquid
/// {% if product.available and product.price < 10 %}
///   Bargain!
/// {% elsif product.available and product.featured %}
///   Featured item
/// {% elsif product.coming_soon %}
///   Coming soon
/// {% else %}
///   Not available
/// {% endif %}
/// ```
/// 
/// - Important: Only the first elsif branch with a true condition will execute, even if subsequent
///   elsif conditions would also be true.
/// - Important: You can chain multiple elsif tags, but they must appear after the initial if tag
///   and before any else tag.
/// - Important: The condition in elsif follows the same truthiness rules as if statements:
///   false and nil are falsy, everything else (including empty strings and 0) is truthy.
/// 
/// - SeeAlso: ``TagIf``, ``TagElse``
/// - SeeAlso: [Shopify Liquid elsif](https://shopify.github.io/liquid/tags/control-flow/#ifelsif-else)
/// - SeeAlso: [LiquidJS elsif](https://liquidjs.com/tags/elsif.html)
/// - SeeAlso: [Python Liquid elif](https://liquid.readthedocs.io/en/latest/tags/#elif)
package final class TagElsif: AbstractConditionalTag {
  override package class var keyword: String {
    "elsif"
  }

  override package var terminatesScopesWithTags: [Tag.Type]? {
    [TagIf.self, TagElsif.self]
  }

  override package func didDefine(scope: Parser.Scope, parser: Parser) {
    super.didDefine(scope: scope, parser: parser)

    // An `elsif` tag should execute if its statement is considered "truthy".
    if let conditional = (compiledExpression["conditional"] as? Token.Value), conditional.isTruthy {
      tagKindsToSkip = [TagElsif.kind, TagElse.kind]
    } else {
      scope.outputState = .disabled
    }
  }
}