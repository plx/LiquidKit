import Foundation

/// Implements the `{% endfor %}` tag, which closes a for loop block.
/// 
/// The `endfor` tag marks the end of a for loop that was opened with `{% for %}`.
/// It terminates the loop block and, if an `{% else %}` clause is present within
/// the for loop (which executes when the collection is empty), it also properly
/// closes that else scope. The endfor tag is required to complete any for loop
/// structure in Liquid templates.
/// 
/// Basic for loop closure:
/// ```liquid
/// {% for product in products %}
///   {{ product.name }}
/// {% endfor %}
/// ```
/// 
/// With an else clause for empty collections:
/// ```liquid
/// {% for item in collection %}
///   {{ item.title }}
/// {% else %}
///   No items found in the collection.
/// {% endfor %}
/// ```
/// 
/// Nested loops require matching endfor tags:
/// ```liquid
/// {% for category in categories %}
///   <h2>{{ category.name }}</h2>
///   {% for product in category.products %}
///     {{ product.name }}
///   {% endfor %}
/// {% endfor %}
/// ```
/// 
/// For loops with parameters still require endfor:
/// ```liquid
/// {% for item in items limit: 5 offset: 10 %}
///   {{ item }}
/// {% endfor %}
/// ```
/// 
/// - Important: Every `{% for %}` tag must have a matching `{% endfor %}` tag.
/// - Important: When a for loop contains an `{% else %}` clause, the endfor tag
///   terminates both the else scope and the parent for scope.
/// - Important: The endfor tag restores any loop variables that were shadowed
///   by the for loop's iteration variable.
/// 
/// - Warning: Omitting the endfor tag will cause a parsing error and prevent
///   the template from rendering.
/// - Warning: Mismatched for/endfor pairs in nested loops can lead to unexpected
///   behavior or parsing errors.
/// 
/// - SeeAlso: ``TagFor``, ``TagElse``, ``TagBreak``, ``TagContinue``
/// - SeeAlso: [liquidjs for](https://liquidjs.com/tags/for.html)
/// - SeeAlso: [python-liquid for](https://liquid.readthedocs.io/en/latest/tags/#for)
/// - SeeAlso: [Shopify Liquid for](https://shopify.github.io/liquid/tags/iteration/#for)
package final class TagEndFor: Tag {
  private var shouldTerminateParentScope: Bool = false

  override package class var keyword: String {
    "endfor"
  }

  override package var terminatesScopesWithTags: [Tag.Type]? {
    [TagFor.self, TagElse.self]
  }

  override package func didTerminate(scope: Parser.Scope, parser: Parser) {
    super.didTerminate(scope: scope, parser: parser)

    if scope.tag is TagElse {
      shouldTerminateParentScope = true
    }
  }

  override package var terminatesParentScope: Bool {
    shouldTerminateParentScope
  }
}