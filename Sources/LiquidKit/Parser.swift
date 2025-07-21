//
//  Parser.swift
//  Liquid
//
//  Created by YourtionGuo on 28/06/2017.
//
//

import Foundation

/// A class for parsing an array of tokens and converts them into a collection of Node's
open class Parser
{
	private var tokens: [Token]
	private let context: Context
	private var filters: [Filter] = []
  private var operators: [String: any Operator] = [String: any Operator].builtInOperators
	private var tags: [String: [Tag.Type]] = [:]
	private var parseErrors: [Error] = []

	public init(tokens: [Token], context: Context)
	{
		self.tokens = tokens
		self.context = context

		registerFilters()
		registerTags()
		registerOperators()
	}

	open func registerFilters()
	{
		Filter.builtInFilters.forEach(register)
	}

	open func registerTags()
	{
		Tag.builtInTags.forEach(register)
	}

	open func registerOperators()
	{
	}

	/// Parse the given tokens into nodes
	public func parse() throws -> [String]
	{
		try preprocessTokens().compile(using: self) ?? []
	}

	public func register(filter: Filter)
	{
		filters.append(filter)
	}

	public func register(operator: any Operator) {
    operators[`operator`.identifier] = `operator`
	}

	public func register(tag: Tag.Type)
	{
    tags[
      tag.keyword,
      default: []
    ].append(tag)
	}

	/// This method will traverse the provided tokens (which is a linear structure) and create a scoped (nested) data
	/// structure of the code, so that it can be compiled later.
	private func preprocessTokens() throws -> Scope
	{
		var tokenIterator = TokenIterator(tokens)

		let rootScope = Scope()
		var currentScope = rootScope

		while let (tokenIndex, token) = tokenIterator.next()
		{
			switch token
			{
			case .text(let contents) where currentScope.outputState == .enabled:
				currentScope.append(rawOutput: contents)

			case .variable(let contents) where currentScope.outputState == .enabled:
				currentScope.append(
          rawOutput: try compileFilter(
            contents,
            context: currentScope.context
          ).stringValue)
        

			case .tag(let contents):
				guard let tag = compileTag(contents, currentScope: currentScope) else
				{
					// Unknown tag keyword or invalid statement
					break
				}

				// If this tag closes the opener tag of the current scope, then we must leave the current scope.
				if let openerTag = currentScope.tag, let terminatedTags = tag.terminatesScopesWithTags,
					terminatedTags.contains(where: { type(of: openerTag) == $0 })
				{
					// Inform this tag instance that it has closed a tag.
					tag.didTerminate(scope: currentScope, parser: self)
					
					// If this tag also closes the parent scope, we need to jump two scope levels up.
					if tag.terminatesParentScope, let terminatedScope = currentScope.parentScope
					{
						currentScope = terminatedScope
					}

					// If this scope was defined by an iteration tag, we need to check with it if we need another pass.
					if currentScope.outputState != .disabled,
						let iterationTag = currentScope.tag as? IterationTag,
						let tagTokenIndex = currentScope.tagTokenIndex,
						let supplementalContext = iterationTag.supplementalContext
					{
						currentScope.context = supplementalContext
						currentScope.outputState = .enabled
						tokenIterator.setCurrentIndex(tagTokenIndex)
					}
					// Otherwise we just jump back to the parent scope, if present.
					else if let parentScope = currentScope.parentScope
					{
						currentScope = parentScope
					}
					else
					{
						print("[LiquidKit] Error: terminating scope tag scope has no parent scope!!!")
					}
				}

				// If this tag produces output, append that to the current scope's nodes.
				if let output = tag.output
				{
					output.map({ $0.stringValue }).forEach(currentScope.append(rawOutput:))
				}

				// If this tag defines a scope, create it and make it ther current scope.
				if tag.definesScope
				{
					currentScope = currentScope.appendScope(for: tag)
					currentScope.tagTokenIndex = tokenIndex
					currentScope.context = (tag as? IterationTag)?.supplementalContext
					tag.didDefine(scope: currentScope, parser: self)
				}

			default:
				break
			}
		}

		if currentScope !== rootScope
		{
			print("[LiquidKit] Error: Unbalanced scopes!!")
		}

		return rootScope
	}

	internal func compileFilter(_ statement: String, context inputContext: Context? = nil) throws -> Token.Value
	{
		let context = inputContext ?? self.context
		let splitStatement = statement.split(separator: "|")

		if splitStatement.count == 1
		{
			return compileOperators(for: statement, context: context)
		}

		guard let firstStatement = splitStatement.first else {
			return .nil
		}
		var filteredValue = compileOperators(for: String(firstStatement), context: context)

		for filterString in splitStatement[1...]
		{
			let filterComponents = String(filterString).smartSplit(separator: ":")

			guard filterComponents.count <= 2 else
			{
				print("[LiquidKit] Error: bad filter syntax: \(filterString). Stopping filter processing.")
				return filteredValue
			}

			guard let firstComponent = filterComponents.first else {
				continue
			}
			let filterIdentifier = String(firstComponent).trimmingWhitespaces
			let filterParameters: [Token.Value]?

			if filterComponents.count == 1
			{
				filterParameters = []
			}
			else
			{
				guard let lastComponent = filterComponents.last else {
					filterParameters = []
					continue
				}
				filterParameters = String(lastComponent).smartSplit(separator: ",").map({ context.parseString(String($0)) ?? .nil })
			}

			guard let filter = filters.first(where: { $0.identifier == filterIdentifier }) else
			{
				print("[LiquidKit] Error: Unknown filter name: \(filterIdentifier). Stopping filter processing.")
				return filteredValue
			}

			filteredValue = try filter.lambda(filteredValue, filterParameters ?? [])
		}

		return filteredValue
	}

	private func compileTag(_ statement: String, currentScope: Scope) -> Tag?
	{
		let context = currentScope.context ?? self.context
		let statementScanner = Scanner(statement.trimmingWhitespaces)
		let keyword = statementScanner.scan(until: .whitespaces)

		guard keyword.count > 0 else
		{
			print("[LiquidKit] Error: Malformed tag: \"\(statement)\"")
			return nil
		}

		guard let tags = self.tags[String(keyword)], tags.count > 0 else
		{
			print("[LiquidKit] Error: Unknown tag keyword: \"\(keyword)\"")
			return nil
		}

		let statement = statementScanner.content

		for tag in tags
		{
			let tagInstance = tag.init(context: context)

			do
			{
				try tagInstance.parse(statement: statement, using: self, currentScope: currentScope)

				return tagInstance
			}
			catch
			{
				#if DEBUG
				print("[LiquidKit] Error parsing tag: \(error.localizedDescription)")
				#endif
			}
		}

		return nil
	}

	internal func compileOperators(for statement: String, context inputContext: Context? = nil) -> Token.Value
	{
		if statement.count == 0
		{
			return .nil
		}

		let context = inputContext ?? self.context
		let statementNodes = statement.smartSplit(separator: " ").filter({ $0.count > 0 })

		if statementNodes.count <= 1
		{
			return context.parseString(statement) ?? .nil
		}

		var iterator = statementNodes.reversed().makeIterator()
		var lastParsedValue: Token.Value? = nil

		// Liquid parses boolean operators right right to left, and doesn't support parenthesis.
		while let node = iterator.next()
		{
			var secondNode = node

			// Can't perform a logical operation if a previous value wasn't parsed yet.
			if ["or", "and"].contains(node)
			{
				if lastParsedValue == nil
				{
					parseErrors.append(ParseErrors.malformedExpression("Malformed expression: Expected value but found logical operator “\(node)”."))
					return .nil
				}
				else if let nextNode = iterator.next()
				{
					secondNode = nextNode
				}
				else
				{
					parseErrors.append(ParseErrors.malformedExpression("Malformed expression: Expected value but found nothing."))
					return .nil
				}
			}

			guard let secondValue = context.parseString(secondNode) else
			{
				parseErrors.append(ParseErrors.malformedExpression("Malformed expression: Unknown variable “\(secondNode)”."))
				return .nil
			}

			guard let operatorKeyword = iterator.next() else
			{
				parseErrors.append(ParseErrors.malformedExpression("Malformed expression: Expected operator but found nothing."))
				return .nil
			}

      guard let operatorInstance = operators[operatorKeyword] else
			{
				parseErrors.append(ParseErrors.malformedExpression("Malformed expression: Unknown operator “\(operatorKeyword)”."))
				return .nil
			}

			guard let firstNode = iterator.next() else
			{
				parseErrors.append(ParseErrors.malformedExpression("Malformed expression: Expected value before operator “\(operatorKeyword)” but found nothing."))
				return .nil
			}

			guard let firstValue = context.parseString(firstNode) else
			{
				parseErrors.append(ParseErrors.malformedExpression("Malformed expression: Unknown variable “\(node)”."))
				return .nil
			}

			if let lastValue = lastParsedValue
			{
				let currentValue = operatorInstance.apply(firstValue, secondValue)
				switch node
				{
				case "and":
					lastParsedValue = .bool(lastValue.isTruthy && currentValue.isTruthy)

				case "or":
					lastParsedValue = .bool(lastValue.isTruthy || currentValue.isTruthy)

				default:
					parseErrors.append(ParseErrors.malformedExpression("Malformed expression: Unknown logical operator “\(node)”."))
					return .nil
				}
			}
			else
			{
				lastParsedValue = operatorInstance.apply(firstValue, secondValue)
			}
		}

		return lastParsedValue ?? .nil
	}

	internal func parseLiteral(_ literal: String, context: Context?) -> Token.Value?
	{
		return (context ?? self.context).parseString(literal, onlyIfLiteral: true)
	}

	/// Defines a level of scope during parsing. Each time a scope-defining tag is found (such as `if`, `else`, etc…),
	/// a new scope is defined. Closing tags (such as `endif`, `elsif`, etc) terminate scopes.
	open class Scope
	{
		/// The tag that defined this scope level. Is only `nil` on the root scope level.
		let tag: Tag?

		/// The parent scope level, that contains the receiver scope. Is only `nil` on the root scope level.
		let parentScope: Scope?
		
		/// Controls whether the scope allows output statements to be appended to it. Setting this value will also set
		/// the `outputState` of all children scopes recursively.
		var outputState: OutputState = .enabled
		{
			didSet
			{
				for statement in processedStatements
				{
					if case .scope(let scope) = statement
					{
						scope.outputState = outputState
					}
				}
			}
		}

		/// Whether ouptut is halted. This
		var haltedOutput = false

		/// The index of the token that was parsed as the tag that defined this scope
		var tagTokenIndex: Int?

		/// An optional supplemental context.
		var context: Context?

		/// The statements inside the receiver scope.
		var processedStatements: [ProcessedStatement] = []

		init(tag: Tag? = nil, parent: Scope? = nil)
		{
			self.tag = tag
			self.parentScope = parent

			parent?.processedStatements.append(.scope(self))

			if parent?.outputState == .disabled
			{
				outputState = .disabled
			}
		}

		/// Append a raw string to the processed statements of the receiver scope level.
		func append(rawOutput: String)
		{
			processedStatements.append(.output(rawOutput))
		}

		/// Append a tag to the processed statements of the receiver scope level, thus defining a child scope level.
		func appendScope(for tag: Tag) -> Scope
		{
			return Scope(tag: tag, parent: self)
		}

		/// Removes all statements from `processedStatements`.
		func dumpProcessedStatements()
		{
			processedStatements.removeAll()
		}

		/// Looks up the scope chain for the scope that was defined by a tag of kind present in `tagKinds`. If none is
		/// found, returns nil.
		func scopeDefined(by tagKinds: Set<Tag.Kind>) -> Scope?
		{
			if let tag = self.tag, tagKinds.contains(type(of: tag).kind)
			{
				return self
			}
			else
			{
				return parentScope?.scopeDefined(by: tagKinds)
			}
		}

		enum ProcessedStatement
		{
			case output(String)
			case scope(Scope)
		}

		enum OutputState
		{
			/// Output statements can be added to this scope.
			case enabled

			/// Output statements can not be added to this scope.
			case disabled

			/// Output statements can not be added to this scope. However, if this scope was started by an iterator
			/// tag, the state will be set to `.enabled` upon the start of a new iteration.
			case halted
		}
	}

	public enum ParseErrors: Error
	{
		case malformedExpression(String)

		public var localizedDescription: String
		{
			switch self
			{
			case .malformedExpression(let description): return description
			}
		}
	}
}

internal extension Parser.Scope
{
	/// This method will compile the nodes of the receiver scope, depending on its opener tag and the contents of is
	/// nodes and child scopes.
	func compile(using parser: Parser) -> [String]?
	{
		var nodes = [String]()
		var tagClassesToSkip: Set<Tag.Kind>? = nil

		if let outputNodes = tag?.output?.map({ $0.stringValue })
		{
			nodes.append(contentsOf: outputNodes)
		}

		func shouldSkip(scope: Parser.Scope) -> Bool
		{
			guard let classes = tagClassesToSkip, let tag = scope.tag else
			{
				return false
			}

			return classes.contains(type(of: tag).kind)
		}

		for statement in processedStatements
		{
			switch statement
			{
			case .output(let output):
				nodes.append(output)

			case .scope(let childScope) where !shouldSkip(scope: childScope):
				if let childNodes = childScope.compile(using: parser)
				{
					nodes.append(contentsOf: childNodes)
				}

				tagClassesToSkip = childScope.tag?.tagKindsToSkip
				
			default:
				break
			}
		}

		return nodes
	}
}

private struct TokenIterator
{
	private let tokens: [Token]

	private(set) var currentIndex: Int = -1

	init(_ tokens: [Token])
	{
		self.tokens = tokens
	}

	mutating func next() -> (Int, Token)?
	{
		guard currentIndex + 1 < tokens.count else
		{
			return nil
		}

		currentIndex += 1

		return (currentIndex, tokens[currentIndex])
	}

	mutating func setCurrentIndex(_ index: Int)
	{
		currentIndex = index
	}
}

