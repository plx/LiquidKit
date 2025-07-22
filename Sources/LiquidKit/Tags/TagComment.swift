import Foundation

/// Implements the `{% comment %}` tag, which creates a block comment that is not rendered.
/// 
/// The comment tag prevents any content between the opening and closing tags from being
/// rendered in the output. This includes literal text, variables, and even other Liquid
/// tags. Comment blocks are useful for documentation, temporarily disabling code, or
/// adding notes that should not appear in the final output.
/// 
/// Basic usage for simple comments:
/// ```liquid
/// {% comment %}
///   This text will not appear in the output.
///   Neither will this.
/// {% endcomment %}
/// ```
/// 
/// Comments can contain Liquid code that won't be executed:
/// ```liquid
/// {% comment %}
///   {% if user.admin %}
///     {{ secret_data }}
///   {% endif %}
/// {% endcomment %}
/// // Output: (nothing)
/// ```
/// 
/// Nested comment blocks are supported:
/// ```liquid
/// {% comment %}
///   Outer comment
///   {% comment %}
///     Inner comment
///   {% endcomment %}
///   Still in outer comment
/// {% endcomment %}
/// ```
/// 
/// Whitespace control works with comment tags:
/// ```liquid
/// Before
/// {%- comment -%}
///   This comment removes surrounding whitespace
/// {%- endcomment -%}
/// After
/// // Output: BeforeAfter
/// ```
/// 
/// - Important: Everything inside a comment block is ignored during parsing, except
///   for tracking nested comment blocks to find the correct closing tag.
/// - Important: Malformed or incomplete Liquid tags inside comments can still cause
///   parsing errors if they're not properly closed.
/// - Important: The inline comment syntax `{%# ... %}` is a different feature and
///   works differently from block comments.
/// 
/// - Warning: Unclosed nested comment blocks will cause parsing errors.
/// - Warning: Raw blocks inside comments are still processed to find their end tags,
///   which can lead to unexpected parsing behavior.
/// 
/// - SeeAlso: [liquidjs comment](https://liquidjs.com/tags/comment.html)
/// - SeeAlso: [python-liquid comment](https://liquid.readthedocs.io/en/latest/tags/comment/)
/// - SeeAlso: [Shopify Liquid comment](https://shopify.github.io/liquid/tags/comment/)
package final class TagComment: Tag {
  override package class var keyword: String {
    "comment"
  }

  override package var definesScope: Bool {
    true
  }

  override package func didDefine(scope: Parser.Scope, parser: Parser) {
    super.didDefine(scope: scope, parser: parser)

    // Comment tags never produce output
    scope.outputState = .disabled
  }
}