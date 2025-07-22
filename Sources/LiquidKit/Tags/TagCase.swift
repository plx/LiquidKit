import Foundation

/// Implements the `{% case %}` tag, which creates a switch statement for conditional execution.
/// 
/// The case tag compares a variable against multiple values using when tags. It's similar
/// to switch statements in other programming languages. Each when tag can specify one or more
/// values to match against, and an optional else tag provides a default case. Unlike some
/// implementations, multiple matching when blocks will all execute.
/// 
/// Basic usage with simple matching:
/// ```liquid
/// {% case product.type %}
///   {% when 'book' %}
///     This is a book!
///   {% when 'electronics' %}
///     This is an electronic item!
///   {% else %}
///     Unknown product type.
/// {% endcase %}
/// ```
/// 
/// Multiple values can be matched in a single when tag:
/// ```liquid
/// {% case day %}
///   {% when 'Saturday', 'Sunday' %}
///     It's the weekend!
///   {% when 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday' %}
///     It's a weekday.
/// {% endcase %}
/// ```
/// 
/// The or operator can also be used to match multiple values:
/// ```liquid
/// {% case title %}
///   {% when 'CEO' or 'CFO' or 'CTO' %}
///     C-level executive
///   {% when 'Manager' or 'Director' %}
///     Middle management
/// {% endcase %}
/// ```
/// 
/// Multiple matching when blocks all execute:
/// ```liquid
/// {% case 'x' %}
///   {% when 'x' %}First match{% when 'x' %}Second match
/// {% endcase %}
/// // Output: First matchSecond match
/// ```
/// 
/// Else blocks can appear anywhere and multiple else blocks are allowed:
/// ```liquid
/// {% case 'z' %}
///   {% when 'x' %}X
///   {% else %}First else
///   {% when 'y' %}Y
///   {% else %}Second else
/// {% endcase %}
/// // Output: First elseSecond else
/// ```
/// 
/// - Important: Text between the case tag and the first when tag is not rendered.
/// - Important: Arrays can be compared directly - if the case value is an array and
///   matches a when value array, the block executes.
/// - Important: Empty when tags (e.g., `{% when %}`) are invalid and cause errors.
/// - Important: When tags can use variables as comparison values, not just literals.
/// 
/// - Warning: Mixing comma-separated values with `or` operators in the same when tag
///   may produce unexpected results.
/// 
/// - SeeAlso: ``TagWhen``
/// - SeeAlso: ``TagIf``
/// - SeeAlso: [liquidjs case](https://liquidjs.com/tags/case.html)
/// - SeeAlso: [python-liquid case](https://liquid.readthedocs.io/en/latest/tags/case/)
/// - SeeAlso: [Shopify Liquid case](https://shopify.github.io/liquid/tags/control-flow/#case--when)
package final class TagCase: Tag {
  override package var tagExpression: [ExpressionSegment] {
    [.variable("conditional")]
  }

  override package class var keyword: String {
    "case"
  }

  override package var definesScope: Bool {
    true
  }

  override package func parse(statement: String, using parser: Parser, currentScope: Parser.Scope) throws {
    try super.parse(statement: statement, using: parser, currentScope: currentScope)

    guard compiledExpression["conditional"] is Token.Value else {
      throw Errors.missingArtifacts
    }
  }

  override package func didDefine(scope: Parser.Scope, parser: Parser) {
    // Prevent rogue text between the `case` tag and the first `when` tag from being output.
    scope.outputState = .disabled
  }
}