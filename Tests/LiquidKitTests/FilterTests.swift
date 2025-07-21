//
//  FilterTests.swift
//  LiquidTests
//
//  Created by Bruno Philipe on 10/09/18.
//

import XCTest
@testable import LiquidKit

class FilterTests: XCTestCase
{
	func testFilter_abs() throws
	{
		let lexer = Lexer(templateString: "{{ -7 | abs }}{{ 100 | abs }}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = try parser.parse()
		XCTAssertEqual(res, ["7", "100"])
	}
	
	func testFilter_append() throws
	{
		let lexer = Lexer(templateString: """
{% assign filename = \"/index.html\" %}
{{ \"/my/fancy/url\" | append: \".html\" }}
{{ \"a\" | append: \"b\" | append: \"c\" }}
{{ \"website.com\" | append: filename }}
""")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = try parser.parse()
		XCTAssertEqual(res, ["\n", "/my/fancy/url.html", "\n", "abc", "\n", "website.com/index.html"])
	}
	
	func testFilter_atLeast() throws
	{
		let lexer = Lexer(templateString: "{{ 4 | at_least: 5 }}{{ 4 | at_least: 3 }}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = try parser.parse()
		XCTAssertEqual(res, ["5", "4"])
	}
	
	func testFilter_atMost() throws
	{
		let lexer = Lexer(templateString: "{{ 4 | at_most: 5 }}{{ 4 | at_most: 3 }}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = try parser.parse()
		XCTAssertEqual(res, ["4", "3"])
	}
	
	func testFilter_capitalize() throws
	{
		let lexer = Lexer(templateString: "{{ \"title\" | capitalize }}{{ \"my great title\" | capitalize }}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = try parser.parse()
		XCTAssertEqual(res, ["Title", "My great title"])
	}
	
	func testFilter_ceil() throws
	{
		let lexer = Lexer(templateString: "{{ 1.2 | ceil }}{{ 2.0 | ceil }}{{ 183.357 | ceil }}{{ \"3.5\" | ceil }}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = try parser.parse()
		XCTAssertEqual(res, ["2", "2", "184", "4"])
	}

	func testFilter_concat() throws
	{
		let lexer = Lexer(templateString: """
{% assign fruits = \"apples, oranges, peaches\" | split: \", \" %}
{% assign vegetables = \"carrots, turnips, potatoes\" | split: \", \" %}
{% assign everything = fruits | concat: vegetables %}
{{ everything | join: \", \" }}
{% assign furniture = "chairs, tables, shelves" | split: ", " %}
{% assign everything = fruits | concat: vegetables | concat: furniture %}
{{ everything | join: \", \" }}
""")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = try parser.parse()
		XCTAssertEqual(res, ["\n", "\n", "\n", "apples, oranges, peaches, carrots, turnips, potatoes", "\n", "\n", "\n", "apples, oranges, peaches, carrots, turnips, potatoes, chairs, tables, shelves"])
	}

	func testFilter_compact() throws
	{
		let values: [String: Token.Value] = ["categories": .array([.nil, .string("A"), .nil, .string("B")])]
		let lexer = Lexer(templateString: "{{ categories | compact | first }}{{ categories | compact | join: \",\" }}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context(dictionary: values))
		let res = try parser.parse()
		XCTAssertEqual(res, ["A", "A,B"])
	}
	
	func testFilter_date() throws
	{
		let lexer = Lexer(templateString: "{{ \"March 14, 2016\" | date: \"%b %d, %y\" }}{{ \"March 14, 2016\" | date: \"%a, %b %d, %y\" }}{{ \"March 14, 2016\" | date: \"%Y-%m-%d %H:%M\" }}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = try parser.parse()
		XCTAssertEqual(res, ["Mar 14, 16", "Mon, Mar 14, 16", "2016-03-14 00:00"])
	}
	
	func testFilter_dateWithVariousFormats() throws
	{
		// Test additional strftime format strings
		let lexer = Lexer(templateString: """
{{ "March 14, 2016" | date: "%Y" }}
{{ "March 14, 2016" | date: "%m/%d/%Y" }}
{{ "March 14, 2016" | date: "%B %d, %Y" }}
{{ "March 14, 2016" | date: "%I:%M %p" }}
{{ "March 14, 2016" | date: "%j" }}
""")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = try parser.parse()
		XCTAssertEqual(res, ["2016", "\n", "03/14/2016", "\n", "March 14, 2016", "\n", "12:00 AM", "\n", "074"])
	}
	
	func testFilter_dateWithSpecialInputs() throws
	{
		// Test special date inputs like "now" and "today"
		let lexer = Lexer(templateString: """
{{ "now" | date: "%Y" }}
{{ "today" | date: "%Y" }}
""")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = try parser.parse()
		
		// Check that both return the current year
		let currentYear = Calendar.current.component(.year, from: Date())
		XCTAssertEqual(res, [String(currentYear), "\n", String(currentYear)])
	}
	
	func testFilter_dateWithInvalidInput() throws
	{
		// Test invalid date inputs
		let lexer = Lexer(templateString: """
{{ "not a date" | date: "%Y-%m-%d" }}
{{ "" | date: "%Y-%m-%d" }}
{{ nil | date: "%Y-%m-%d" }}
""")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = try parser.parse()
		XCTAssertEqual(res, ["", "\n", "", "\n", ""])
	}
	
	func testFilter_dateWithMissingFormat() throws
	{
		// Test missing format parameter
		let lexer = Lexer(templateString: "{{ \"March 14, 2016\" | date }}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = try parser.parse()
		XCTAssertEqual(res, [""])
	}
	
	func testFilter_default() throws
	{
		let lexer = Lexer(templateString: "{{ the_number | default: \"42\" }}{{ \"the_number\" | default: \"42\" }}{{ \"\" | default: 42 }}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = try parser.parse()
		XCTAssertEqual(res, ["42", "the_number", "42"])
	}
	
	func testFilter_dividedBy() throws
	{
		let lexer = Lexer(templateString: "{{ 16 | divided_by: 4 }}{{ 5 | divided_by: 3 }}{{ 20 | divided_by: 7.0 }}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = try parser.parse()
		XCTAssertEqual(res, ["4", "1", "2.857142857142857728"])
	}
	
	func testFilter_downcase() throws
	{
		let lexer = Lexer(templateString: "{{ \"Parker Moore\" | downcase }}{{ \"apple\" | downcase }}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = try parser.parse()
		XCTAssertEqual(res, ["parker moore", "apple"])
	}
	
	func testFilter_escape() throws
	{
		let lexer = Lexer(templateString: "{{ \"Have you read 'James & the Giant Peach'?\" | escape }}{{ \"Tetsuro Takara\" | escape }}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = try parser.parse()
		XCTAssertEqual(res, ["Have you read &apos;James &amp; the Giant Peach&apos;?", "Tetsuro Takara"])
	}
	
	func testFilter_escapeOnce() throws
	{
		let lexer = Lexer(templateString: "{{ \"1 < 2 & 3\" | escape_once }}{{ \"1 &lt; 2 &amp; 3\" | escape_once }}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = try parser.parse()
		XCTAssertEqual(res, ["1 &lt; 2 &amp; 3", "1 &lt; 2 &amp; 3"])
	}

	func testFilter_first() throws
	{
		let lexer = Lexer(templateString: "{{ \"4,3,2,1\" | split: \",\" | first }}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = try parser.parse()
		XCTAssertEqual(res, ["4"])
	}

	func testFilter_floor() throws
	{
		let lexer = Lexer(templateString: "{{ 1.2 | floor }}{{ 2.0 | floor }}{{ 183.357 | floor }}{{ \"3.5\" | floor }}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = try parser.parse()
		XCTAssertEqual(res, ["1", "2", "183", "3"])
	}

	func testFilter_last() throws
	{
		let lexer = Lexer(templateString: "{{ \"4,3,2,1\" | split: \",\" | last }}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = try parser.parse()
		XCTAssertEqual(res, ["1"])
	}

	func testFilter_leftStrip() throws
	{
		let lexer = Lexer(templateString: "{{ \"          So much room for activities!          \" | lstrip }}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = try parser.parse()
		XCTAssertEqual(res, ["So much room for activities!          "])
	}

	func testFilter_map() throws
	{
		let values: [String: Token.Value] = ["items": .array([
			.dictionary(["title": .string("Title 1"), "content": .string("alpha")]),
			.dictionary(["title": .string("Title 2"), "content": .string("beta")]),
			.dictionary(["title": .string("Title 3"), "content": .string("charlie")])
		])]

		let lexer = Lexer(templateString: "{{ items | map: \"content\" | join: \", \" }}{{ items | map: \"title\" | first }}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context(dictionary: values))
		let res = try parser.parse()
		XCTAssertEqual(res, ["alpha, beta, charlie", "Title 1"])
	}

	func testFilter_minus() throws
	{
		let lexer = Lexer(templateString: "{{ 4 | minus: 2 }}{{ 16 | minus: 4 }}{{ 183.357 | minus: 12 }}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = try parser.parse()
		XCTAssertEqual(res, ["2", "12", "171.357"])
	}

	func testFilter_modulo() throws
	{
		let lexer = Lexer(templateString: "{{ 3 | modulo: 2 }}{{ 24 | modulo: 7 }}{{ 183.357 | modulo: 12 }}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = try parser.parse()
		XCTAssertEqual(res, ["1", "3", "3.357000000000028672"])
	}

	func testFilter_newlineToBr() throws
	{
		let lexer = Lexer(templateString: "{{ \"\nHello\r\nthere\n\" | newline_to_br }}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = try parser.parse()
		XCTAssertEqual(res, ["<br />Hello<br />there<br />"])
	}

	func testFilter_plus() throws
	{
		let lexer = Lexer(templateString: "{{ 4 | plus: 2 }}{{ 16 | plus: 4 }}{{ 183.357 | plus: 12 }}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = try parser.parse()
		XCTAssertEqual(res, ["6", "20", "195.357"])
	}

	func testFilter_prepend() throws
	{
		let lexer = Lexer(templateString: "{{ \"apples, oranges, and bananas\" | prepend: \"Some fruit: \" }}{{ \"a\" | prepend: \"b\" | prepend: \"c\" }}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = try parser.parse()
		XCTAssertEqual(res, ["Some fruit: apples, oranges, and bananas", "cba"])

		// TODO:
//		{% assign url = "liquidmarkup.com" %}
//		{{ "/index.html" | prepend: url }}
	}

	func testFilter_remove() throws
	{
		let lexer = Lexer(templateString: "{{ \"I strained to see the train through the rain\" | remove: \"rain\" }}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = try parser.parse()
		XCTAssertEqual(res, ["I sted to see the t through the "])
	}

	func testFilter_removeFirst() throws
	{
		let lexer = Lexer(templateString: "{{ \"I strained to see the train through the rain\" | remove_first: \"rain\" }}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = try parser.parse()
		XCTAssertEqual(res, ["I sted to see the train through the rain"])
	}

	func testFilter_replace() throws
	{
		let lexer = Lexer(templateString: "{{ \"Take my protein pills and put my helmet on\" | replace: \"my\", \"your\" }}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = try parser.parse()
		XCTAssertEqual(res, ["Take your protein pills and put your helmet on"])
	}

	func testFilter_replaceFirst() throws
	{
		let lexer = Lexer(templateString: "{{ \"Take my protein pills and put my helmet on\" | replace_first: \"my\", \"your\" }}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = try parser.parse()
		XCTAssertEqual(res, ["Take your protein pills and put my helmet on"])
	}

	func testFilter_reverse() throws
	{
		let lexer = Lexer(templateString: "{{ \"apples, oranges, peaches, plums\" | split: \", \" | reverse | join: \", \" }}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = try parser.parse()
		XCTAssertEqual(res, ["plums, peaches, oranges, apples"])
	}

	func testFilter_round() throws
	{
		let lexer = Lexer(templateString: "{{ 1.2 | round }}{{ 2.7 | round }}{{ 183.357 | round: 2 }}{{ \"3.5\" | round }}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = try parser.parse()
		XCTAssertEqual(res, ["1", "3", "183.36", "4"])
	}

	func testFilter_rightStrip() throws
	{
		let lexer = Lexer(templateString: "{{ \"          So much room for activities!          \" | rstrip }}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = try parser.parse()
		XCTAssertEqual(res, ["          So much room for activities!"])
	}

	func testFilter_size() throws
	{
		let lexer = Lexer(templateString: "{{ \"apples, oranges, peaches, plums\" | split: \", \" | size }}{{ \"Ground control to Major Tom.\" | size }}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = try parser.parse()
		XCTAssertEqual(res, ["4", "28"])
	}

	func testFilter_slice() throws
	{
		let lexer = Lexer(templateString: "{{ \"Liquid\" | slice: 0 }}{{ \"Liquid\" | slice: 2 }}{{ \"Liquid\" | slice: 2, 5 }}{{ \"Liquid\" | slice: -3, 2 }}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = try parser.parse()
		XCTAssertEqual(res, ["L", "q", "quid", "ui"])
	}

	func testFilter_sort() throws
	{
		let lexer = Lexer(templateString: "{{ \"zebra, octopus, giraffe, Sally Snake\" | split: \", \" | sort | join: \", \" }}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = try parser.parse()
		XCTAssertEqual(res, ["Sally Snake, giraffe, octopus, zebra"])
	}

	func testFilter_sortNatural() throws
	{
		let lexer = Lexer(templateString: "{{ \"zebra, octopus, giraffe, Sally Snake\" | split: \", \" | sort_natural | join: \", \" }}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = try parser.parse()
		XCTAssertEqual(res, ["giraffe, octopus, Sally Snake, zebra"])
	}

	func testFilter_split() throws
	{
		let lexer = Lexer(templateString: "{{ \"banana\" | split: \"\" | join: \"-\" }}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = try parser.parse()
		XCTAssertEqual(res, ["b-a-n-a-n-a"])
	}

	func testFilter_split_join() throws
	{
		let lexer = Lexer(templateString: "{{ \"John, Paul, George, Ringo\" | split: \", \" | join: \"-\" }}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = try parser.parse()
		XCTAssertEqual(res, ["John-Paul-George-Ringo"])
	}

	func testFilter_strip() throws
	{
		let lexer = Lexer(templateString: "{{ \"          So much room for activities!          \" | strip }}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = try parser.parse()
		XCTAssertEqual(res, ["So much room for activities!"])
	}

	func testFilter_stripHTML() throws
	{
		let lexer = Lexer(templateString: "{{ \"Have <em>you</em> read <strong>Ulysses</strong>?\" | strip_html }}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = try parser.parse()
		XCTAssertEqual(res, ["Have you read Ulysses?"])
	}

	func testFilter_stripNewlines() throws
	{
		let lexer = Lexer(templateString: "{{ \"Hello\nthere\n\" | strip_newlines }}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = try parser.parse()
		XCTAssertEqual(res, ["Hellothere"])
	}

	func testFilter_times() throws
	{
		let lexer = Lexer(templateString: "{{ 3 | times: 2 }}{{ 24 | times: 7 }}{{ 183.357 | times: 12 }}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = try parser.parse()
		XCTAssertEqual(res, ["6", "168", "2200.284"])
	}

	func testFilter_truncate() throws
	{
		let lexer = Lexer(templateString: "{{ \"Ground control to Major Tom.\" | truncate: 20 }}{{ \"Ground control to Major Tom.\" | truncate: 25, \", and so on\" }}{{ \"Ground control to Major Tom.\" | truncate: 20, \"\" }}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = try parser.parse()
		XCTAssertEqual(res, ["Ground control to...", "Ground control, and so on", "Ground control to Ma"])
	}

	func testFilter_truncateWords() throws
	{
		let lexer = Lexer(templateString: "{{ \"Ground control to Major Tom.\" | truncatewords: 3 }}{{ \"Ground control to Major Tom.\" | truncatewords: 4, \"--\" }}{{ \"Ground control to Major Tom.\" | truncatewords: 2, \"\" }}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = try parser.parse()
		XCTAssertEqual(res, ["Ground control to...", "Ground control to Major--", "Ground control"])
	}

	func testFilter_uniq() throws
	{
		let lexer = Lexer(templateString: "{{ \"ants, bugs, bees, bugs, ants\" | split: \", \" | uniq | join: \", \" }}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = try parser.parse()
		XCTAssertEqual(res, ["ants, bugs, bees"])
	}

	func testFilter_upcase() throws
	{
		let lexer = Lexer(templateString: "{{ \"Parker Moore\" | upcase }}{{ \"APPLE\" | upcase }}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = try parser.parse()
		XCTAssertEqual(res, ["PARKER MOORE", "APPLE"])
	}

	func testFilter_urlDecode() throws
	{
		let lexer = Lexer(templateString: "{{ \"%27Stop%21%27+said+Fred\" | url_decode }}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = try parser.parse()
		XCTAssertEqual(res, ["'Stop!' said Fred"])
	}

	func testFilter_urlEncode() throws
	{
		let lexer = Lexer(templateString: "{{ \"john@liquid.com\" | url_encode }}{{ \"Tetsuro Takara\" | url_encode }}")
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens, context: Context())
		let res = try parser.parse()
		XCTAssertEqual(res, ["john%40liquid.com", "Tetsuro+Takara"])
	}
}
