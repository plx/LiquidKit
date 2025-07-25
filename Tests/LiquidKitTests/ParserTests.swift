//
//  ParserTests.swift
//  Liquid
//
//  Created by YourtionGuo on 28/06/2017.
//
//

import XCTest
@testable import LiquidKit

class ParserTests: XCTestCase {
    
    func testParseText() throws {
        let lexer = Lexer(templateString: "aab  cc dd")
        let tokens = lexer.tokenize()
        let parser = Parser(tokens: tokens, context: Context())
        let res = try parser.parse()
        XCTAssertEqual(res, ["aab  cc dd"])
    }
    
    func testParseVariable() throws {
        let dic = ["a": "A", "b": "BB", "c": "CCcCC"]
        let lexer = Lexer(templateString: "aab {{ a }} {{b}}c{{c}} d")
        let tokens = lexer.tokenize()
        let parser = Parser(tokens: tokens, context: Context(dictionary: dic))
        let res = try parser.parse()
        XCTAssertEqual(res, ["aab ", "A", " ","BB","c", "CCcCC"," d"])
    }
    
    func testParseVariablePerformance() throws {
        let dic = ["a": "A", "b": "BB", "c": "CCcCC"]
        let lexer = Lexer(templateString: "aab {{ a }} {{b}}c{{c}} d")
        let tokens = lexer.tokenize()
        let parser = Parser(tokens: tokens, context: Context(dictionary: dic))
        measure {
          do {
            _ = try parser.parse()
          }
          catch let error {
            XCTFail(
              "Unexpected error while measuring: \(String(reflecting: error))!"
            )
          }
        }
    }

	func testParseObject() throws
	{
		struct User: TokenValueConvertible
		{
			let name: String
			let email: String
			let postIds: [Int]

			var tokenValue: Token.Value
			{
				return ["name": name, "email": email, "post_ids": postIds].tokenValue
			}
		}

		let values: [String: Token.Value] = [
			"users": [
				User(name: "John", email: "john@example.com", postIds: [2, 5, 6]),
				User(name: "Sarah", email: "sarah@example.com", postIds: [1, 3, 4, 7])
			].tokenValue
		]

		let lexer = Lexer(templateString: "{% for user in users %}{{ user.name }}{{ user.post_ids | first }}{% endfor %}{{ users[1].email }}{{ users.first.email }}{{ users.last.post_ids.first }}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context(dictionary: values))
		var res: [String]? = nil
		measure
		{
      do {
        res = try parser.parse()
      }
      catch let error {
        XCTFail("Unexpected failure while measuring expression: \(String(reflecting: error))!")
      }
		}
    let result = try XCTUnwrap(res)
		XCTAssertEqual(
      result,
      ["John", "2", "Sarah", "1", "sarah@example.com", "john@example.com", "1"]
    )
	}
}
