import Testing
@testable import LiquidKit

@Suite(.tags(.filter, .defaultFilter))
struct DefaultFilterIntegrationTests {
    
    // Helper to test a template
    private func renderTemplate(_ template: String, context: Context = Context()) throws -> String {
        let lexer = Lexer(templateString: template)
        let tokens = lexer.tokenize()
        let parser = Parser(tokens: tokens, context: context)
        let nodes = try parser.parse()
        return nodes.joined()
    }
    
    @Test("Integration test for nil replacement")
    func testNilReplacement() throws {
        let result = try renderTemplate("{{ missing | default: 'fallback' }}")
        #expect(result == "fallback")
    }
    
    @Test("Integration test for empty string replacement")
    func testEmptyStringReplacement() throws {
        let context = Context(dictionary: ["empty": ""])
        let result = try renderTemplate("{{ empty | default: 'not empty' }}", context: context)
        #expect(result == "not empty")
    }
    
    @Test("Integration test for empty array replacement")
    func testEmptyArrayReplacement() throws {
        let context = Context(dictionary: ["arr": []])
        let result = try renderTemplate("{{ arr | default: 'no items' }}", context: context)
        #expect(result == "no items")
    }
    
    @Test("Integration test for false replacement")
    func testFalseReplacement() throws {
        let context = Context(dictionary: ["flag": false])
        let result = try renderTemplate("{{ flag | default: 'not set' }}", context: context)
        #expect(result == "not set")
    }
    
    @Test("Integration test for zero not triggering default")
    func testZeroDoesNotTriggerDefault() throws {
        let context = Context(dictionary: ["zero": 0])
        let result = try renderTemplate("{{ zero | default: 'not zero' }}", context: context)
        #expect(result == "0")
    }
    
    @Test("Integration test for whitespace not triggering default")
    func testWhitespaceDoesNotTriggerDefault() throws {
        let context = Context(dictionary: ["space": " "])
        let result = try renderTemplate("{{ space | default: 'not space' }}", context: context)
        #expect(result == " ")
    }
    
    @Test("Multiple defaults in template")
    func testMultipleDefaults() throws {
        let context = Context(dictionary: [
            "name": "",
            "age": 0,
            "active": false,
            "items": []
        ])
        let template = """
        Name: {{ name | default: "Anonymous" }}
        Age: {{ age | default: "Unknown" }}
        Active: {{ active | default: "Yes" }}
        Items: {{ items | default: "None" }}
        """
        let result = try renderTemplate(template, context: context)
        let expected = """
        Name: Anonymous
        Age: 0
        Active: Yes
        Items: None
        """
        #expect(result == expected)
    }
}