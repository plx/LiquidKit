//
//  LexerTests.swift
//  Liquid
//
//  Created by YourtionGuo on 28/06/2017.
//
//

import XCTest
@testable import LiquidKit

class LexerTests: XCTestCase {
    
    func testCreateToken() {
        let lexer = Lexer(templateString: "")
        
        let variable = lexer.createToken(string: "{{ a }}")
        XCTAssertEqual(variable, .variable( "a"))
        
        let tag = lexer.createToken(string: "{% b %}")
        XCTAssertEqual(tag, .tag( "b"))
    }
    
    func testTokenize() {
        let lexer = Lexer(templateString: "aab {{ a }} cc{%d%}{{ e}}")
        let tokens = lexer.tokenize()
        XCTAssertEqual(tokens.count, 5)
        XCTAssertEqual(tokens[0], .text( "aab "))
        XCTAssertEqual(tokens[1], .variable( "a"))
        XCTAssertEqual(tokens[2], .text( " cc"))
        XCTAssertEqual(tokens[3], .tag( "d"))
        XCTAssertEqual(tokens[4], .variable( "e"))
        
        let empty = Lexer(templateString: "{{ a").tokenize()
        XCTAssertEqual(empty.count, 1)
        XCTAssertEqual(empty[0], .text(""))
        
    }
    
    func testTokenizePerformance() {
        let lexer = Lexer(templateString: "aab {{ a }} cc{%d%}")
        measure {
            _ = lexer.tokenize()
        }
    }

}
