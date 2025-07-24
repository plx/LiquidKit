import Testing
@testable import LiquidKit

@Suite("MapFilter Integration Tests", .tags(.filter, .mapFilter))
struct MapFilterIntegrationTests {
    
    @Test("Full template integration with map filter")
    func templateIntegration() throws {
        // Test case 1: Basic array mapping
        let template1 = "{{ products | map: 'title' | join: ', ' }}"
        let data1: [String: Token.Value] = [
            "products": .array([
                .dictionary(["title": .string("Shirt"), "price": .integer(20)]),
                .dictionary(["title": .string("Pants"), "price": .integer(30)])
            ])
        ]
        
        let lexer1 = Lexer(templateString: template1)
        let tokens1 = lexer1.tokenize()
        let parser1 = Parser(tokens: tokens1, context: Context(dictionary: data1))
        let result1 = try parser1.parse()
        #expect(result1 == ["Shirt, Pants"])
        
        // Test case 2: Missing properties
        let template2 = "{{ items | map: 'price' | join: '#' }}"
        let data2: [String: Token.Value] = [
            "items": .array([
                .dictionary(["price": .integer(10)]),
                .dictionary(["price": .integer(20)]),
                .dictionary(["name": .string("Special")]) // Missing 'price'
            ])
        ]
        
        let lexer2 = Lexer(templateString: template2)
        let tokens2 = lexer2.tokenize()
        let parser2 = Parser(tokens: tokens2, context: Context(dictionary: data2))
        let result2 = try parser2.parse()
        #expect(result2 == ["10#20#"]) // nil renders as empty
        
        // Test case 3: Dictionary input
        let template3 = "{{ product | map: 'title' }}"
        let data3: [String: Token.Value] = [
            "product": .dictionary(["title": .string("Shirt"), "price": .integer(20)])
        ]
        
        let lexer3 = Lexer(templateString: template3)
        let tokens3 = lexer3.tokenize()
        let parser3 = Parser(tokens: tokens3, context: Context(dictionary: data3))
        let result3 = try parser3.parse()
        #expect(result3 == ["Shirt"])
    }
    
    @Test("Error cases in templates")
    func templateErrorCases() throws {
        // Test case 1: Non-array, non-dictionary input
        let template1 = "{{ value | map: 'title' }}"
        let data1: [String: Token.Value] = ["value": .integer(123)]
        
        let lexer1 = Lexer(templateString: template1)
        let tokens1 = lexer1.tokenize()
        let parser1 = Parser(tokens: tokens1, context: Context(dictionary: data1))
        
        #expect(throws: (any Error).self) {
            _ = try parser1.parse()
        }
        
        // Test case 2: Array with non-object elements
        let template2 = "{{ mixed | map: 'title' }}"
        let data2: [String: Token.Value] = [
            "mixed": .array([
                .dictionary(["title": .string("First")]),
                .integer(5)
            ])
        ]
        
        let lexer2 = Lexer(templateString: template2)
        let tokens2 = lexer2.tokenize()
        let parser2 = Parser(tokens: tokens2, context: Context(dictionary: data2))
        
        #expect(throws: (any Error).self) {
            _ = try parser2.parse()
        }
    }
    
    @Test("Nested property access in templates")
    func nestedPropertyAccess() throws {
        let template = "{{ items | map: 'product.details.name' | join: ', ' }}"
        let data: [String: Token.Value] = [
            "items": .array([
                .dictionary([
                    "product": .dictionary([
                        "details": .dictionary([
                            "name": .string("Widget A")
                        ])
                    ])
                ]),
                .dictionary([
                    "product": .dictionary([
                        "details": .dictionary([
                            "name": .string("Widget B")
                        ])
                    ])
                ])
            ])
        ]
        
        let lexer = Lexer(templateString: template)
        let tokens = lexer.tokenize()
        let parser = Parser(tokens: tokens, context: Context(dictionary: data))
        let result = try parser.parse()
        #expect(result == ["Widget A, Widget B"])
    }
}