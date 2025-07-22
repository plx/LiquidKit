import Foundation

/// Implements the `{% when %}` tag, which defines a branch in a case statement.
/// 
/// The `when` tag specifies one or more values to match against the expression provided to
/// the parent `{% case %}` tag. When a match is found, the content within that when block
/// is rendered. Multiple values can be specified in a single when tag using commas, and
/// unlike some implementations, if multiple when blocks match the case expression, all
/// matching blocks will be executed.
/// 
/// Basic usage with single value matching:
/// ```liquid
/// {% case product.type %}
///   {% when 'book' %}
///     This is a book!
///   {% when 'electronics' %}
///     This is an electronic item!
/// {% endcase %}
/// ```
/// 
/// Multiple values can be matched in a single when tag:
/// ```liquid
/// {% case shipping_method %}
///   {% when 'standard', 'economy' %}
///     Delivery in 5-7 business days
///   {% when 'express', 'priority' %}
///     Delivery in 1-2 business days
/// {% endcase %}
/// ```
/// 
/// Variables can be used as when values:
/// ```liquid
/// {% case selected_option %}
///   {% when preferred_choice %}
///     You selected your preferred option!
///   {% when backup_choice %}
///     You selected your backup option.
/// {% endcase %}
/// ```
/// 
/// Multiple matching when blocks all execute:
/// ```liquid
/// {% case value %}
///   {% when 'x' %}First match
///   {% when 'x' %}Second match
/// {% endcase %}
/// // With value = 'x', outputs: "First matchSecond match"
/// ```
/// 
/// - Important: The `when` tag can only be used inside a `{% case %}` block.
/// - Important: Empty when tags (with no value) will cause a parsing error.
/// - Important: Unlike switch statements in other languages, Liquid does not have
///   fall-through behavior, but it will execute all matching when blocks.
/// - Important: The `or` operator is not supported in when expressions. Use
///   comma-separated values instead.
/// 
/// - Warning: Using logical operators like `and` in when expressions may cause
///   unexpected behavior or parsing errors. Only use comma separation for multiple values.
/// 
/// - SeeAlso: ``TagCase``, ``TagElse``, ``TagEndCase``
/// - SeeAlso: [liquidjs when](https://liquidjs.com/tags/case.html)
/// - SeeAlso: [python-liquid when](https://liquid.readthedocs.io/en/latest/tags/#when)
/// - SeeAlso: [Shopify Liquid when](https://shopify.github.io/liquid/tags/control-flow/#case-when)
package final class TagWhen: Tag {
  override package var tagExpression: [ExpressionSegment] {
    [.variable("comparator")]
  }

  override package class var keyword: String {
    "when"
  }

  override package var definesScope: Bool {
    true
  }

  override package func parse(statement: String, using parser: Parser, currentScope: Parser.Scope) throws {
    try super.parse(statement: statement, using: parser, currentScope: currentScope)

    guard compiledExpression["comparator"] is Token.Value else {
      throw Errors.missingArtifacts
    }
  }

  override package func didDefine(scope: Parser.Scope, parser: Parser) {
    super.didDefine(scope: scope, parser: parser)

    guard
      let tagCase = scope.parentScope?.tag as? TagCase,
      let comparator = compiledExpression["comparator"] as? Token.Value,
      let conditional = tagCase.compiledExpression["conditional"] as? Token.Value
    else {
      scope.outputState = .disabled
      return
    }

    let isMatch = comparator == conditional

    if isMatch {
      tagKindsToSkip = [TagWhen.kind, TagElse.kind]
    }

    scope.outputState = isMatch ? .enabled : .disabled
  }

  override package var terminatesScopesWithTags: [Tag.Type]? {
    [TagWhen.self]
  }
}