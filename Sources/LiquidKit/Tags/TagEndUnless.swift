import Foundation

/// Implements the `{% endunless %}` tag, which closes an unless conditional block.
/// 
/// The `endunless` tag marks the end of an `unless` conditional structure. Every `unless` tag must
/// have a corresponding `endunless` tag to close the conditional block. The `endunless` tag has no
/// parameters and simply terminates the inverted conditional logic started by an `unless` tag,
/// including any optional `else` branch. Note that unlike `if` tags, `unless` tags do not support
/// `elsif` branches.
///
/// Basic usage closing a simple unless statement:
/// ```liquid
/// {% unless product.available %}
///   Sorry, this product is out of stock
/// {% endunless %}
/// ```
///
/// With an else branch:
/// ```liquid
/// {% unless user.guest %}
///   Welcome back, {{ user.name }}!
/// {% else %}
///   Please sign in to continue
/// {% endunless %}
/// ```
///
/// Nested unless statements each require their own endunless:
/// ```liquid
/// {% unless collection.products.empty %}
///   <h2>Products in this collection:</h2>
///   {% unless filter.active %}
///     <p>Showing all products</p>
///   {% endunless %}
/// {% endunless %}
/// ```
///
/// Common pattern combining unless with other control structures:
/// ```liquid
/// {% unless user.verified %}
///   <div class="alert">
///     {% if user.email %}
///       Please verify your email address
///     {% else %}
///       Please add and verify an email address
///     {% endif %}
///   </div>
/// {% endunless %}
/// ```
///
/// - Important: The `endunless` tag must appear after an `unless` tag and any optional `else`
///   branch. It cannot be used to close other control structures like `if` or `case`. Each
///   control structure has its own specific end tag.
///
/// - Important: Remember that `unless` blocks execute when conditions are false or nil. The
///   `endunless` tag marks the end of this inverted logic region.
///
/// - Warning: Missing an `endunless` tag will result in a parsing error. Each `unless` tag must
///   have exactly one matching `endunless` tag. Extra or mismatched `endunless` tags will cause
///   template compilation to fail.
///
/// - SeeAlso: ``TagUnless``, ``TagElse``
/// - SeeAlso: [LiquidJS unless/endunless](https://liquidjs.com/tags/unless.html)
/// - SeeAlso: [Python Liquid unless/endunless](https://liquid.readthedocs.io/en/latest/tags/unless/)
/// - SeeAlso: [Shopify Liquid unless/endunless](https://shopify.github.io/liquid/tags/control-flow/)
package final class TagEndUnless: Tag {
  override package class var keyword: String {
    "endunless"
  }

  override package var terminatesScopesWithTags: [Tag.Type]? {
    [TagUnless.self]
  }
}