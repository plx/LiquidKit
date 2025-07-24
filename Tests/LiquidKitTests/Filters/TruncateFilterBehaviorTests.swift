import Testing
@testable import LiquidKit

@Suite("TruncateFilter Behavior Tests", .tags(.filter, .truncateFilter))
struct TruncateFilterBehaviorTests {
    
    @Test("Undefined variable as length uses default")
    func undefinedVariableAsLength() throws {
        let lexer = Lexer(templateString: "{{ \"Ground control to Major Tom.\" | truncate: nosuchthing }}")
        let tokens = lexer.tokenize()
        let parser = Parser(tokens: tokens, context: Context())
        let res = try parser.parse()
        
        // When undefined variable is used, it should use default length of 50
        #expect(res.joined() == "Ground control to Major Tom.")
    }
    
    @Test("Undefined variable as ellipsis uses empty string")
    func undefinedVariableAsEllipsis() throws {
        let lexer = Lexer(templateString: "{{ \"Ground control to Major Tom.\" | truncate: 20, nosuchthing }}")
        let tokens = lexer.tokenize()
        let parser = Parser(tokens: tokens, context: Context())
        let res = try parser.parse()
        
        // Golden liquid test expects this to use empty string for undefined ellipsis
        #expect(res.joined() == "Ground control to Ma")
    }
    
    @Test("Nil value truncate returns empty string")
    func nilValueTruncate() throws {
        let lexer = Lexer(templateString: "{{ nosuchthing | truncate: 5 }}")
        let tokens = lexer.tokenize()
        let parser = Parser(tokens: tokens, context: Context())
        let res = try parser.parse()
        
        // Golden liquid test expects empty string for undefined values
        #expect(res.joined() == "")
    }
}