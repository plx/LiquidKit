import Foundation

/// Implements the `{% endif %}` tag, which closes an if conditional block.
/// 
/// The `endif` tag marks the end of an `if` conditional structure. Every `if` tag must have
/// a corresponding `endif` tag to close the conditional block. The `endif` tag has no parameters
/// and simply terminates the conditional logic started by an `if` tag, including any intermediate
/// `elsif` or `else` branches.
///
/// Basic usage with a simple if statement:
/// ```liquid
/// {% if user.name %}
///   Hello {{ user.name }}!
/// {% endif %}
/// ```
///
/// With elsif and else branches:
/// ```liquid
/// {% if product.type == "book" %}
///   Read more about {{ product.title }}
/// {% elsif product.type == "movie" %}
///   Watch the trailer for {{ product.title }}
/// {% else %}
///   Check out {{ product.title }}
/// {% endif %}
/// ```
///
/// Nested if statements each require their own endif:
/// ```liquid
/// {% if user %}
///   Welcome back!
///   {% if user.vip %}
///     Enjoy your VIP benefits
///   {% endif %}
/// {% endif %}
/// ```
///
/// - Important: The `endif` tag must appear after an `if` tag and any optional `elsif` or `else`
///   branches. It cannot appear on its own or be used to close other control structures like
///   `unless` or `case`.
///
/// - Warning: Forgetting an `endif` tag will result in a parsing error. Each `if` tag must have
///   exactly one matching `endif` tag. Extra or missing `endif` tags will cause template
///   compilation to fail.
///
/// - SeeAlso: ``TagIf``, ``TagElse``, ``TagElsif``
/// - SeeAlso: [LiquidJS if/endif](https://liquidjs.com/tags/if.html)
/// - SeeAlso: [Python Liquid if/endif](https://liquid.readthedocs.io/en/latest/tags/if/)
/// - SeeAlso: [Shopify Liquid if/endif](https://shopify.github.io/liquid/tags/control-flow/)
package final class TagEndIf: Tag {
  override package class var keyword: String {
    "endif"
  }

  override package var terminatesScopesWithTags: [Tag.Type]? {
    [TagIf.self, TagElse.self, TagElsif.self]
  }
}