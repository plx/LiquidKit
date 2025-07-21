import Foundation

public struct Lexer: Sendable {
	let templateString: String
	
	public init(templateString: String) {
		self.templateString = templateString
	}
	
	func createToken(string: String) -> Token {
		var stripped: String
		{
			let start = string.index(string.startIndex, offsetBy: 2)
			let end = string.index(string.endIndex, offsetBy: -2)
			return String(string[start..<end]).trim(character: " ")
		}
		
		if string.hasPrefix("{{")
		{
			return .variable(stripped)
		}
		else if string.hasPrefix("{%")
		{
			return .tag(stripped)
		}
		
		return .text(string)
	}
	
	/// Returns an array of tokens from a given template string.
	public func tokenize() -> [Token]
	{
		let scanner = Scanner(templateString)
		let map = ["{{": "}}", "{%": "%}"]
		var tokens: [Token] = []
		
		while !scanner.isEmpty
		{
			if let (scanned, text) = scanner.scan(until: ["{{", "{%"])
			{
				if !text.isEmpty
				{
					tokens.append(createToken(string: text))
				}
				
				guard let end = map[scanned] else {
					print("[LiquidKit] Error: No matching end delimiter for '\(scanned)'")
					continue
				}
				let result = scanner.scan(until: end, returnUntil: true)
				
				if createToken(string: result) == .tag("raw")
				{
					// Entered raw mode. Must find the {% endraw %} tag now.
					let rawContent = scanner.scan(until: "{% endraw %}", returnUntil: false)
					tokens.append(.text(rawContent))
				}
				else
				{
					tokens.append(createToken(string: result))
				}
			}
			else
			{
				tokens.append(createToken(string: scanner.content))
				scanner.content = ""
			}
		}
		
		return tokens
	}
}


class Scanner
{
	var content: String
	
	init(_ content: String)
	{
		self.content = content
	}
	
	var isEmpty: Bool
	{
		return content.isEmpty
	}
	
	func scan(until: String, returnUntil: Bool = false) -> String
	{
		if until.isEmpty
		{
			return ""
		}
		
		var index = content.startIndex
		while index != content.endIndex
		{
			let substring = String(content[index...])
			
			if substring.hasPrefix(until)
			{
				let result = String(content[..<index])
				content = substring
				
				if returnUntil
				{
					content = String(content[until.endIndex...])
					return result + until
				}
				
				return result
			}
			
			index = content.index(after: index)
		}
		
		content = ""
		return ""
	}
	
	func scan(until: [String]) -> (String, String)?
	{
		if until.isEmpty
		{
			return nil
		}
		
		var index = content.startIndex
		while index != content.endIndex
		{
			let substring = String(content[index...])
			for string in until
			{
				if substring.hasPrefix(string)
				{
					let result = String(content[..<index])
					content = substring
					return (string, result)
				}
			}
			
			index = content.index(after: index)
		}
		
		return nil
	}

	/// Scans the content until a character from the provided character set is found. If no such character is found,
	/// scans to the end of the content and returns its value.
	///
	/// - Parameter charset: The lookup character set.
	/// - Returns: The scanned string.
	func scan(until charset: CharacterSet, skipEarlyMatches: Bool = false) -> String
	{
		// If skipEarlyMatches is true, we first scan to chars that would not match the provided charset.
		if skipEarlyMatches
		{
			_ = scan(until: charset.inverted)
		}

		let finalIndex = content.rangeOfCharacter(from: charset)?.lowerBound ?? content.endIndex
		let scannedString = String(content[..<finalIndex])
		content = String(content[finalIndex...])
		return scannedString
	}

	func scanUntilEnd() -> String
	{
		defer
		{
			content = ""
		}

		return content
	}
}
