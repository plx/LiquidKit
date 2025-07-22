import Foundation

/// Implements the `{% cycle %}` tag, which loops through a list of values outputting the next value on each call.
/// 
/// The `cycle` tag iterates through a comma-separated list of values, outputting one value per call and returning
/// to the first value after reaching the end. This is commonly used for alternating styles like table row colors
/// or CSS classes. Cycle accepts an optional `group` parameter to maintain multiple independent cycles.
/// 
/// ## Examples
/// 
/// Basic alternating pattern:
/// ```liquid
/// {% for row in table %}
///   <tr class="{% cycle 'odd', 'even' %}">
///     <td>{{ row }}</td>
///   </tr>
/// {% endfor %}
/// ```
/// 
/// Using named groups for independent cycles:
/// ```liquid
/// {% cycle 'red', 'green', 'blue' group: 'colors' %}
/// {% cycle 'small', 'large' group: 'sizes' %}
/// {% cycle 'red', 'green', 'blue' group: 'colors' %}
/// {% cycle 'small', 'large' group: 'sizes' %}
/// <!-- Outputs: red small green large -->
/// ```
/// 
/// Cycling through multiple values:
/// ```liquid
/// {% for item in items %}
///   <div class="{% cycle 'first', 'second', 'third', 'fourth' %}">
///     {{ item }}
///   </div>
/// {% endfor %}
/// ```
/// 
/// - Important: Cycles without a group parameter share state based on their value list, so identical
///   value lists will continue from where the previous cycle left off.
/// - Important: Each unique group maintains its own independent counter, allowing multiple cycles
///   to run simultaneously without interference.
/// 
/// - Warning: The cycle tag outputs its value immediately when called - it cannot be assigned to a variable.
///   Use `{% capture %}` if you need to store the cycle value.
/// 
/// - SeeAlso: ``TagFor``, ``TagCapture``
/// - SeeAlso: [Shopify Liquid cycle](https://shopify.github.io/liquid/tags/iteration/#cycle)
/// - SeeAlso: [LiquidJS cycle](https://liquidjs.com/tags/cycle.html)
/// - SeeAlso: [Python Liquid cycle](https://liquid.readthedocs.io/en/latest/tags/#cycle)
package final class TagCycle: Tag {
  private var groupIdentifier: String? {
    guard case .some(.string(let groupIdentifier)) = compiledExpression["group"] as? Token.Value
    else {
      return nil
    }

    return groupIdentifier
  }

  override package class var keyword: String {
    "cycle"
  }

  override package var tagExpression: [ExpressionSegment] {
    // example: {% cycle group:groupIdentifier %}
    [.group("list")]
  }

  override package var parameters: [String] {
    ["group"]
  }

  override package func parse(statement: String, using parser: Parser, currentScope: Parser.Scope) throws {
    try super.parse(statement: statement, using: parser, currentScope: currentScope)

    guard case .some(.array(let groupElements)) = compiledExpression["list"] as? Token.Value else {
      throw Errors.missingArtifacts
    }

    if let cycleOutput = context.next(in: groupElements, identifier: groupIdentifier) {
      output = [cycleOutput]
    }
  }
}