import Foundation

/// Implements the `{% endcase %}` tag, which closes a case statement block.
/// 
/// The `endcase` tag marks the end of a case statement that was opened with `{% case %}`.
/// It terminates the entire case block, including any `{% when %}` branches and optional
/// `{% else %}` clauses. The endcase tag is required to properly close a case statement;
/// omitting it will result in a parsing error.
/// 
/// Basic usage:
/// ```liquid
/// {% case product.type %}
///   {% when 'book' %}
///     It's a book!
///   {% when 'movie' %}
///     It's a movie!
/// {% endcase %}
/// ```
/// 
/// With an else clause:
/// ```liquid
/// {% case shipping_speed %}
///   {% when 'express' %}
///     1-2 business days
///   {% when 'standard' %}
///     5-7 business days
///   {% else %}
///     Contact us for shipping estimate
/// {% endcase %}
/// ```
/// 
/// Case blocks can be nested within other control structures:
/// ```liquid
/// {% for item in cart.items %}
///   {% case item.type %}
///     {% when 'physical' %}
///       Ships to your address
///     {% when 'digital' %}
///       Download after purchase
///   {% endcase %}
/// {% endfor %}
/// ```
/// 
/// - Important: The `endcase` tag must have a matching `{% case %}` tag.
/// - Important: When an `{% else %}` tag is present within the case block,
///   the endcase tag also terminates the else scope along with the parent case scope.
/// - Important: All case blocks must be properly closed with endcase, even if
///   they contain no when branches.
/// 
/// - Warning: Forgetting to close a case block with endcase will cause a parsing
///   error that prevents the template from rendering.
/// 
/// - SeeAlso: ``TagCase``, ``TagWhen``, ``TagElse``
/// - SeeAlso: [liquidjs case](https://liquidjs.com/tags/case.html)
/// - SeeAlso: [python-liquid case](https://liquid.readthedocs.io/en/latest/tags/#case)
/// - SeeAlso: [Shopify Liquid case](https://shopify.github.io/liquid/tags/control-flow/#case-when)
package final class TagEndCase: Tag {
  private var shouldTerminateParentScope = false

  override package class var keyword: String {
    "endcase"
  }

  override package var terminatesScopesWithTags: [Tag.Type]? {
    [TagCase.self, TagElse.self]
  }

  override package func didTerminate(scope: Parser.Scope, parser: Parser) {
    shouldTerminateParentScope = scope.tag is TagElse && scope.parentScope?.tag is TagCase
  }

  override package var terminatesParentScope: Bool {
    shouldTerminateParentScope
  }
}