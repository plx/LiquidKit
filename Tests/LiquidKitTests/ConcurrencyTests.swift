//
//  ConcurrencyTests.swift
//  LiquidKitTests
//
//  Created to test Swift 6 concurrency features.
//

import XCTest
@testable import LiquidKit

class ConcurrencyTests: XCTestCase {
    
    // Test that Token.Value is Sendable
    func testTokenValueIsSendable() async {
        let value: Token.Value = .string("Hello")
        
        // This should compile without warnings in Swift 6 mode
        await withTaskGroup(of: Token.Value.self) { group in
            group.addTask {
                return value
            }
        }
    }
    
    // Test that Lexer is Sendable
    func testLexerIsSendable() async {
        let lexer = Lexer(templateString: "{{ hello }}")
        
        // This should compile without warnings in Swift 6 mode
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                _ = lexer.tokenize()
            }
        }
    }
    
    // Test that TemplateSyntaxError is Sendable
    func testErrorIsSendable() async {
        let error = TemplateSyntaxError("Test error")
        
        // This should compile without warnings in Swift 6 mode
        await withTaskGroup(of: TemplateSyntaxError.self) { group in
            group.addTask {
                return error
            }
        }
    }
}