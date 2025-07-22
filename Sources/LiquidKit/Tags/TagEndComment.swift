import Foundation

/// Implements the `{% endcomment %}` tag, which closes a comment block.
/// 
/// The `endcomment` tag marks the end of a comment block that was opened with `{% comment %}`.
/// Everything between the opening comment tag and this closing tag is completely ignored
/// during template rendering and will not appear in the output. This includes literal text,
/// Liquid variables, tags, and any other content.
/// 
/// Basic usage:
/// ```liquid
/// {% comment %}
///   This text will not appear in the output.
///   Neither will this {{ variable }}.
/// {% endcomment %}
/// ```
/// 
/// Comments can span multiple lines and contain any content:
/// ```liquid
/// {% comment %}
///   TODO: Implement this feature
///   {% if user.admin %}
///     Show admin panel
///   {% endif %}
///   The above code is commented out and won't execute.
/// {% endcomment %}
/// ```
/// 
/// Nested comments are supported:
/// ```liquid
/// {% comment %}
///   Outer comment starts here
///   {% comment %}
///     This is a nested comment
///   {% endcomment %}
///   Still inside the outer comment
/// {% endcomment %}
/// ```
/// 
/// - Important: The `endcomment` tag must have a matching `{% comment %}` tag.
/// - Important: Comment blocks completely prevent any processing of their contents,
///   making them useful for temporarily disabling code or adding developer notes.
/// - Important: Unlike HTML comments, Liquid comments are processed server-side
///   and never appear in the rendered output.
/// 
/// - Warning: Unclosed comment blocks will cause parsing errors. Always ensure
///   every `{% comment %}` has a corresponding `{% endcomment %}`.
/// 
/// - SeeAlso: ``TagComment``
/// - SeeAlso: [liquidjs comment](https://liquidjs.com/tags/comment.html)
/// - SeeAlso: [python-liquid comment](https://liquid.readthedocs.io/en/latest/tags/comment/)
/// - SeeAlso: [Shopify Liquid comment](https://shopify.github.io/liquid/tags/comment/)
package final class TagEndComment: Tag {
  override package class var keyword: String {
    "endcomment"
  }

  override package var terminatesScopesWithTags: [Tag.Type]? {
    [TagComment.self]
  }
}