import Foundation

/// Implements the `{% else %}` tag, which provides fallback content for conditional and iteration blocks.
/// 
/// The `else` tag defines alternative content that renders when the preceding condition is false or when
/// a for loop has no items to iterate over. It can be used within `{% if %}`, `{% elsif %}`, `{% case %}`,
/// and `{% for %}` blocks. The else clause must be the last conditional branch in its containing block.
/// 
/// ## Examples
/// 
/// Basic if/else usage:
/// ```liquid
/// {% if user.premium %}
///   Welcome, premium member!
/// {% else %}
///   Upgrade to premium for more features.
/// {% endif %}
/// ```
/// 
/// With elsif chains:
/// ```liquid
/// {% if score >= 90 %}
///   Grade: A
/// {% elsif score >= 80 %}
///   Grade: B
/// {% else %}
///   Grade: C or below
/// {% endif %}
/// ```
/// 
/// In for loops (renders when collection is empty):
/// ```liquid
/// {% for product in products %}
///   {{ product.name }}
/// {% else %}
///   No products available.
/// {% endfor %}
/// ```
/// 
/// In case statements:
/// ```liquid
/// {% case color %}
///   {% when 'red' %}
///     Roses are red
///   {% when 'blue' %}
///     Violets are blue
///   {% else %}
///     Unknown color
/// {% endcase %}
/// ```
/// 
/// - Important: The `else` tag must always be the final branch in a conditional structure.
///   No additional `elsif` or `when` tags can follow an `else` tag.
/// - Important: In for loops, the `else` clause only executes when the collection is empty or nil,
///   not when the loop completes normally.
/// 
/// - SeeAlso: ``TagIf``, ``TagElsif``, ``TagFor``, ``TagCase``
/// - SeeAlso: [Shopify Liquid else](https://shopify.github.io/liquid/tags/control-flow/#ifelsif-else)
/// - SeeAlso: [LiquidJS else](https://liquidjs.com/tags/else.html)
/// - SeeAlso: [Python Liquid else](https://liquid.readthedocs.io/en/latest/tags/#else)
package final class TagElse: Tag {
  private var didTerminateScope = false

  override package class var keyword: String {
    "else"
  }

  override package var definesScope: Bool {
    true
  }

  override package var terminatesScopesWithTags: [Tag.Type]? {
    [TagIf.self, TagElsif.self, TagWhen.self]
  }

  override package func didTerminate(scope: Parser.Scope, parser: Parser) {
    super.didTerminate(scope: scope, parser: parser)

    didTerminateScope = true
  }

  override package func didDefine(scope: Parser.Scope, parser: Parser) {
    super.didDefine(scope: scope, parser: parser)

    if scope.parentScope?.tag is TagCase {
      scope.parentScope?.outputState = .enabled
    }
    // We need to check if this else tag isn't part of another if/elsif/when clause, since it can be structurally
    // identical to a for-else clause.
    else if !didTerminateScope, let tagFor = scope.parentScope?.tag as? TagFor {
      scope.outputState = tagFor.itemsCount > 0 ? .disabled : .enabled
    }
  }
}