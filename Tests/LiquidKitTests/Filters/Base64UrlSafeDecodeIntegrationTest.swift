import Testing
import Foundation
@testable import LiquidKit

@Suite("Base64UrlSafeDecodeFilter Integration Tests")
struct Base64UrlSafeDecodeIntegrationTest {
    
    @Test("matches golden liquid test: from string")
    func matchesGoldenLiquidFromString() throws {
        let template = #"{{ "XyMvLg==" | base64_url_safe_decode }}"#
        let lexer = Lexer(templateString: template)
        let tokens = lexer.tokenize()
        let parser = Parser(tokens: tokens, context: Context())
        let result = try parser.parse()
        #expect(result == ["_#/."])
    }
    
    @Test("matches golden liquid test: with URL unsafe characters")
    func matchesGoldenLiquidWithUrlUnsafe() throws {
        let template = #"{{ a | base64_url_safe_decode }}"#
        let context = Context(dictionary: [
            "a": "YWJjZGVmZ2hpamtsbW5vcHFyc3R1dnd4eXogQUJDREVGR0hJSktMTU5PUFFSU1RVVldYWVogMTIzNDU2Nzg5MCAhQCMkJV4mKigpLT1fKy8_Ljo7W117fVx8"
        ])
        let lexer = Lexer(templateString: template)
        let tokens = lexer.tokenize()
        let parser = Parser(tokens: tokens, context: context)
        let result = try parser.parse()
        #expect(result == ["abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLMNOPQRSTUVWXYZ 1234567890 !@#$%^&*()-=_+/?.:;[]{}\\|"])
    }
    
    @Test("matches golden liquid test: undefined left value")
    func matchesGoldenLiquidUndefinedValue() throws {
        let template = #"{{ nosuchthing | base64_url_safe_decode }}"#
        let lexer = Lexer(templateString: template)
        let tokens = lexer.tokenize()
        let parser = Parser(tokens: tokens, context: Context())
        let result = try parser.parse()
        #expect(result == [""])
    }
    
    @Test("matches golden liquid test: not a string (should fail)")
    func matchesGoldenLiquidNotAString() throws {
        let template = #"{{ 5 | base64_url_safe_decode }}"#
        let lexer = Lexer(templateString: template)
        let tokens = lexer.tokenize()
        let parser = Parser(tokens: tokens, context: Context())
        
        // This should throw an error during parsing
        #expect(throws: (any Error).self) {
            _ = try parser.parse()
        }
    }
    
    @Test("matches golden liquid test: unexpected argument (should fail)")
    func matchesGoldenLiquidUnexpectedArgument() throws {
        let template = #"{{ "hello" | base64_url_safe_decode: 5 }}"#
        let lexer = Lexer(templateString: template)
        let tokens = lexer.tokenize()
        let parser = Parser(tokens: tokens, context: Context())
        
        // This should throw an error during parsing
        #expect(throws: (any Error).self) {
            _ = try parser.parse()
        }
    }
}