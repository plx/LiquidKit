//
//  OperatorTests.swift
//  LiquidKitTests
//
//  Created by Bruno Philipe on 18/9/18.
//

import XCTest
@testable import LiquidKit

class OperatorTests: XCTestCase
{
	func testEquals() throws
	{
		let lexer = Lexer(templateString: "{% assign filename = \"/index.html\" %}{% if filename == \"/index.html\" %}TRUE{% else %}FALSE{% endif %}{% if filename == 10 %}TRUE{% else %}FALSE{% endif %}{% if filename %}TRUE{% else %}FALSE{% endif %}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = try parser.parse()
		XCTAssertEqual(res, ["TRUE", "FALSE", "TRUE"])
	}

	func testNotEquals() throws
	{
		let lexer = Lexer(templateString: "{% assign filename = \"/index.html\" %}{% if filename != \"/index.html\" %}TRUE{% else %}FALSE{% endif %}{% if filename != 10 %}TRUE{% else %}FALSE{% endif %}{% if 30 != 10 %}TRUE{% else %}FALSE{% endif %}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = try parser.parse()
		XCTAssertEqual(res, ["FALSE", "TRUE", "TRUE"])
	}

	func testGreaterThan() throws
	{
		let lexer = Lexer(templateString: "{% assign size = 650 %}{% if size > 100 %}TRUE{% else %}FALSE{% endif %}{% if size > 987 %}TRUE{% else %}FALSE{% endif %}{% if size > 650 %}TRUE{% else %}FALSE{% endif %}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = try parser.parse()
		XCTAssertEqual(res, ["TRUE", "FALSE", "FALSE"])
	}

	func testLessThan() throws
	{
		let lexer = Lexer(templateString: "{% assign size = 650 %}{% if size < 100 %}TRUE{% else %}FALSE{% endif %}{% if size < 987 %}TRUE{% else %}FALSE{% endif %}{% if size < 650 %}TRUE{% else %}FALSE{% endif %}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = try parser.parse()
		XCTAssertEqual(res, ["FALSE", "TRUE", "FALSE"])
	}

	func testLessThanOrEquals() throws
	{
		let lexer = Lexer(templateString: "{% assign size = 650 %}{% if size <= 100 %}TRUE{% else %}FALSE{% endif %}{% if size <= 987 %}TRUE{% else %}FALSE{% endif %}{% if size <= 650 %}TRUE{% else %}FALSE{% endif %}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = try parser.parse()
		XCTAssertEqual(res, ["FALSE", "TRUE", "TRUE"])
	}

	func testGreaterThanOrEquals() throws
	{
		let lexer = Lexer(templateString: "{% assign size = 650 %}{% if size >= 100 %}TRUE{% else %}FALSE{% endif %}{% if size >= 987 %}TRUE{% else %}FALSE{% endif %}{% if size >= 650 %}TRUE{% else %}FALSE{% endif %}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = try parser.parse()
		XCTAssertEqual(res, ["TRUE", "FALSE", "TRUE"])
	}

	func testContains() throws
	{
		let lexer = Lexer(templateString: "{% assign words = \"alpha,beta,charlie\" | split: \",\" %}{% if words contains \"alpha\" %}TRUE{% else %}FALSE{% endif %}{% if words contains \"delta\" %}TRUE{% else %}FALSE{% endif %}{% if \"astronomy\" contains \"tron\" %}TRUE{% else %}FALSE{% endif %}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = try parser.parse()
		XCTAssertEqual(res, ["TRUE", "FALSE", "TRUE"])
	}

	func testAnd() throws
	{
		let lexer = Lexer(templateString: "{% if true and true %}TRUE{% else %}FALSE{% endif %}{% if true and false %}TRUE{% else %}FALSE{% endif %}{% if false and true %}TRUE{% else %}FALSE{% endif %}{% if false and false %}TRUE{% else %}FALSE{% endif %}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = try parser.parse()
		XCTAssertEqual(res, ["TRUE", "FALSE", "FALSE", "FALSE"])
	}

	func testAndWithTruthyValues() throws
	{
		let lexer = Lexer(templateString: "{% if \"text\" and 1 %}TRUE{% else %}FALSE{% endif %}{% if 0 and \"\" %}TRUE{% else %}FALSE{% endif %}{% if nil and true %}TRUE{% else %}FALSE{% endif %}{% if undefined and \"text\" %}TRUE{% else %}FALSE{% endif %}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = try parser.parse()
		XCTAssertEqual(res, ["TRUE", "TRUE", "FALSE", "FALSE"])
	}

	func testOr() throws
	{
		let lexer = Lexer(templateString: "{% if true or true %}TRUE{% else %}FALSE{% endif %}{% if true or false %}TRUE{% else %}FALSE{% endif %}{% if false or true %}TRUE{% else %}FALSE{% endif %}{% if false or false %}TRUE{% else %}FALSE{% endif %}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = try parser.parse()
		XCTAssertEqual(res, ["TRUE", "TRUE", "TRUE", "FALSE"])
	}

	func testOrWithTruthyValues() throws
	{
		let lexer = Lexer(templateString: "{% if nil or \"text\" %}TRUE{% else %}FALSE{% endif %}{% if false or 0 %}TRUE{% else %}FALSE{% endif %}{% if nil or false %}TRUE{% else %}FALSE{% endif %}{% if \"\" or 1 %}TRUE{% else %}FALSE{% endif %}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = try parser.parse()
		// Note: In current implementation, "nil" is parsed as a string, not actual nil
		XCTAssertEqual(res, ["FALSE", "TRUE", "FALSE", "TRUE"])
	}

	func testCombinedLogicalOperators() throws
	{
		// Test simple combination without relying on precedence
		let lexer = Lexer(templateString: "{% assign a = true %}{% assign b = false %}{% if a and a %}TRUE{% else %}FALSE{% endif %}{% if a or b %}TRUE{% else %}FALSE{% endif %}{% if b or a %}TRUE{% else %}FALSE{% endif %}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = try parser.parse()
		XCTAssertEqual(res, ["TRUE", "TRUE", "TRUE"])
	}
}
