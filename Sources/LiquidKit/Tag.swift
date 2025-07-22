import Foundation

/// A class representing a Tag. Tag is effectively an abstract class, and should be subclassed to implement individual
/// tag behavior.
open class Tag {
  /// Keyword used to identify the receiver tag.
  open class var keyword: String {
    ""
  }

  /// Expression which defines the structure of the tag's expression.
  open var tagExpression: [ExpressionSegment] {
    []
  }

  /// List of parameters the tag accepts. All parameters are optional and might have arguments.
  open var parameters: [String] {
    []
  }

  /// Storage for the compiled statement expression, which is populated after a successful compilation.
  public internal(set) var compiledExpression: [String: Any] = [:]

  /// The context where variables, counters, and other properties are stored.
  public let context: Context

  /// If true, will create a scope for this tag upon compiling it. One or more closing tgas will need to be defined
  /// to close that scope. Those tags will need the name of this class in its `terminatesScopesWithTags` property.
  open var definesScope: Bool {
    false
  }

  /// If defined, lists which scopes this this tag will close, based on their opener tags.
  open var terminatesScopesWithTags: [Tag.Type]? {
    nil
  }

  /// Whether the parent scope of the scope terminated by this tag should also be terminated.
  open var terminatesParentScope: Bool {
    false
  }

  /// Tags classes that should be skipped after evaluation this tag. This value is only invoked after
  /// `shouldEnter(scope:)` returns.
  open var tagKindsToSkip: Set<Tag.Kind>?

  /// If this tag terminates a scope during preprocessing, the parser will invoke this method with the new scope.
  open func didTerminate(scope: Parser.Scope, parser: Parser) {
  }

  /// If this tag defines a scope during preprocessing, the parser will invoke this method with the new scope.
  open func didDefine(scope: Parser.Scope, parser: Parser) {
  }

  /// If compiling this tag produces an output, this value will be stored here.
  public var output: [Token.Value]? = nil

  public required init(context: Context) {
    self.context = context
  }

  /// Given a string statement, attempts to compile the receiver tag.
  open func parse(statement: String, using parser: Parser, currentScope: Parser.Scope) throws {
    var processedStatement = statement

    // Extract any parameters from the tail of the statement first. Parameters are all optional.
    for parameter in parameters {
      let pattern = "\(parameter)(\\s*:\\s*(\\w+))?"

      // Since NSRegularExpression doesn't support backwards search, we search using this method first.
      guard
        let range = processedStatement.range(
          of: pattern,
          options: [.backwards, .regularExpression]
        )
      else {
        // Parameter not found.
        continue
      }

      let parameterStatement = String(processedStatement[range])

      // Now that we found the parameter range we use NSRegularExpression to extract the capture groups.
      let regex: NSRegularExpression
      do {
        regex = try NSRegularExpression(pattern: pattern, options: [])
      } catch {
        // Pattern is dynamically constructed but should be valid
        print("[LiquidKit] Warning: Failed to compile regex pattern '\(pattern)': \(error)")
        continue
      }

      if let match = regex.firstMatch(
        in: parameterStatement,
        options: [],
        range: NSRange(location: 0, length: parameterStatement.utf16.count)
      ) {
        if match.range(at: 2).location != NSNotFound,
          let valueRange = Range(match.range(at: 2), in: parameterStatement)
        {
          // This parameter has a value, so we parse that value and assign it to the keyword.
          let value = String(parameterStatement[valueRange])
          compiledExpression[parameter] = try parser.compileFilter(value, context: context)
        } else {
          // This parameter is just a keyword with no value, so we just assign true to it.
          compiledExpression[parameter] = Token.Value.bool(true)
        }

        // Remove the parameter from the remaining statement.
        processedStatement.removeSubrange(range)
      }
    }

    let scanner = Scanner(processedStatement.trimmingWhitespaces)

    // Search for the expected segments from left to right. It is up to tags to evaluate if a segment is valid.
    for segment in tagExpression {
      switch segment {
      case .literal(let expectedWord):
        guard !scanner.isEmpty else {
          throw Errors.malformedStatement("Expected literal “\(expectedWord)”, found nothing.")
        }

        let foundWord = scanner.scan(until: .whitespaces, skipEarlyMatches: true)

        guard foundWord == expectedWord else {
          throw Errors.malformedStatement(
            "Unexpected statement “\(foundWord)”, expected “\(expectedWord)”."
          )
        }

        compiledExpression[expectedWord] = foundWord

      case .identifier(let name):
        guard !scanner.isEmpty else {
          throw Errors.malformedStatement("Expected identifier, found nothing.")
        }

        let foundWord = scanner.scan(until: .whitespaces, skipEarlyMatches: true)
        compiledExpression[name] = foundWord

      case .variable(let name):
        guard !scanner.isEmpty else {
          throw Errors.malformedStatement("Expected identifier or literal, found nothing.")
        }

        compiledExpression[name] = try parser.compileFilter(scanner.scanUntilEnd(), context: context)

      case .group(let name):
        guard !scanner.isEmpty else {
          throw Errors.malformedStatement("Expected group list of strings, found nothing.")
        }

        let splitContent = scanner.scanUntilEnd().smartSplit(separator: ",")
        compiledExpression[name] = Token.Value.array(
          splitContent.compactMap(
            {
              parser.parseLiteral($0, context: context)
            })
        )
      }
    }

    // Skip any left whitespace
    _ = scanner.scan(until: CharacterSet.whitespaces.inverted)

    guard scanner.isEmpty else {
      throw Errors.malformedStatement(
        "Expected end of tag expression, but found \(scanner.content)"
      )
    }
  }

  public enum ExpressionSegment {
    /// A literal string. This segment must be matched exactly.
    case literal(String)

    /// An identifier name. This segment will match any valid unquoted identifier string (alphanumeric).
    case identifier(String)

    /// A valid token value. This segment will match any token value, such as a quoted string, a number, or a
    /// variable defined in the receiver's context, and any filters applied to it afterwards. If none of these are
    /// matched, is assigned `Token.Value.nil`.
    case variable(String)

    /// A list of strings separated by commas.
    case group(String)
  }

  public enum Errors: Error {
    case malformedStatement(String)
    case missingArtifacts
    case invalidInvocation(String)

    var localizedDescription: String {
      switch self {
      case .malformedStatement(let description):
        description
      case .missingArtifacts:
        "Compiler error: Compilaton reported success but required artifacts are missing."
      case .invalidInvocation(let description):
        description
      }
    }
  }
}

extension Tag {
  static let builtInTags: [Tag.Type] = [
    TagAssign.self, TagIncrement.self, TagDecrement.self, TagIf.self, TagEndIf.self, TagElse.self,
    TagElsif.self,
    TagCapture.self, TagEndCapture.self, TagUnless.self, TagEndUnless.self, TagCase.self,
    TagEndCase.self,
    TagWhen.self, TagFor.self, TagEndFor.self, TagBreak.self, TagContinue.self, TagCycle.self,
    TagTablerow.self,
    TagEndTablerow.self, TagComment.self, TagEndComment.self,
  ]
}

extension Tag {
  public typealias Kind = Int

  /// The unique kind of the tag. All tags with the same `keyword` have the same `kind`.
  public class var kind: Kind {
    self.keyword.hashValue
  }
}

