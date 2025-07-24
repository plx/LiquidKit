import Testing
@testable import LiquidKit

@Suite(.tags(.filter, .removeFilter))
struct RemoveFilterTests {
    
    // MARK: - Test Helper
    
    private func evaluate(_ template: String, context: Context = Context()) throws -> [String] {
        let lexer = Lexer(templateString: template)
        let tokens = lexer.tokenize()
        let parser = Parser(tokens: tokens, context: context)
        return try parser.parse()
    }
    
    // MARK: - Basic String Removal
    
    @Test("Remove single occurrence")
    func removeSingleOccurrence() throws {
        let result = try evaluate("{{ 'Hello, world!' | remove: 'world' }}")
        #expect(result == ["Hello, !"])
    }
    
    @Test("Remove multiple occurrences")
    func removeMultipleOccurrences() throws {
        let result = try evaluate("{{ 'I strained to see the train through the rain' | remove: 'rain' }}")
        #expect(result == ["I sted to see the t through the "])
    }
    
    @Test("Remove all occurrences of single character")
    func removeAllOccurrencesOfCharacter() throws {
        let result = try evaluate("{{ 'Hello, world!' | remove: 'o' }}")
        #expect(result == ["Hell, wrld!"])
    }
    
    @Test("Remove with empty string parameter")
    func removeEmptyString() throws {
        let result = try evaluate("{{ 'Hello' | remove: '' }}")
        #expect(result == ["Hello"])
    }
    
    @Test("Remove from empty string")
    func removeFromEmptyString() throws {
        let result = try evaluate("{{ '' | remove: 'test' }}")
        #expect(result == [""])
    }
    
    // MARK: - Case Sensitivity
    
    @Test("Remove is case sensitive")
    func removeIsCaseSensitive() throws {
        let result = try evaluate("{{ 'Hello HELLO hello' | remove: 'hello' }}")
        #expect(result == ["Hello HELLO "])
    }
    
    // MARK: - Special Characters
    
    @Test("Remove special characters")
    func removeSpecialCharacters() throws {
        let result1 = try evaluate("{{ '1-800-555-1234' | remove: '-' }}")
        #expect(result1 == ["18005551234"])
        
        let result2 = try evaluate("{{ 'price: $19.99' | remove: '$' }}")
        #expect(result2 == ["price: 19.99"])
    }
    
    @Test("Remove punctuation")
    func removePunctuation() throws {
        let result1 = try evaluate("{{ 'Hello, world! How are you?' | remove: '!' }}")
        #expect(result1 == ["Hello, world How are you?"])
        
        let result2 = try evaluate("{{ 'test.file.txt' | remove: '.' }}")
        #expect(result2 == ["testfiletxt"])
    }
    
    // MARK: - Non-String Input Coercion
    
    @Test("Remove from integer input - should coerce to string")
    func removeFromInteger() throws {
        // Python-liquid behavior: coerces to string
        let result = try evaluate("{{ 12345 | remove: '3' }}")
        #expect(result == ["1245"])
    }
    
    @Test("Remove from decimal input - should coerce to string")
    func removeFromDecimal() throws {
        // Python-liquid behavior: coerces to string
        let result = try evaluate("{{ 123.456 | remove: '.' }}")
        #expect(result == ["123456"])
    }
    
    @Test("Remove from boolean input - should coerce to string")
    func removeFromBoolean() throws {
        // Python-liquid behavior: coerces to string
        let result1 = try evaluate("{{ true | remove: 'r' }}")
        #expect(result1 == ["tue"])
        
        let result2 = try evaluate("{{ false | remove: 'a' }}")
        #expect(result2 == ["flse"])
    }
    
    @Test("Remove from nil input")
    func removeFromNil() throws {
        // nil should remain nil (empty string when rendered)
        let result = try evaluate("{{ nil | remove: 'test' }}")
        #expect(result == [""])
    }
    
    // MARK: - Non-String Parameter Coercion
    
    @Test("Remove with integer parameter - should coerce to string")
    func removeWithIntegerParameter() throws {
        // Python-liquid behavior: coerces parameter to string
        let result = try evaluate("{{ 'test123test' | remove: 123 }}")
        #expect(result == ["testtest"])
    }
    
    @Test("Remove with decimal parameter - should coerce to string")
    func removeWithDecimalParameter() throws {
        // Python-liquid behavior: coerces parameter to string
        let result = try evaluate("{{ 'price: 19.99' | remove: 19.99 }}")
        #expect(result == ["price: "])
    }
    
    @Test("Remove with boolean parameter - should coerce to string")
    func removeWithBooleanParameter() throws {
        // Python-liquid behavior: coerces parameter to string
        let result = try evaluate("{{ 'this is true' | remove: true }}")
        #expect(result == ["this is "])
    }
    
    @Test("Remove with nil parameter")
    func removeWithNilParameter() throws {
        // nil parameter should return original string unchanged
        let result = try evaluate("{{ 'Hello' | remove: nil }}")
        #expect(result == ["Hello"])
    }
    
    // MARK: - Edge Cases
    
    @Test("Remove overlapping patterns")
    func removeOverlappingPatterns() throws {
        let result = try evaluate("{{ 'aaaa' | remove: 'aa' }}")
        #expect(result == [""])
    }
    
    @Test("Remove pattern longer than input")
    func removePatternLongerThanInput() throws {
        let result = try evaluate("{{ 'Hi' | remove: 'Hello' }}")
        #expect(result == ["Hi"])
    }
    
    @Test("Remove entire string")
    func removeEntireString() throws {
        let result = try evaluate("{{ 'test' | remove: 'test' }}")
        #expect(result == [""])
    }
    
    @Test("Remove with whitespace")
    func removeWithWhitespace() throws {
        let result1 = try evaluate("{{ 'Hello   World' | remove: '   ' }}")
        #expect(result1 == ["HelloWorld"])
        
        let result2 = try evaluate("{{ 'Line 1\nLine 2' | remove: '\n' }}")
        #expect(result2 == ["Line 1Line 2"])
    }
    
    // MARK: - Missing Parameters
    
    @Test("Remove with no parameters")
    func removeWithNoParameters() throws {
        // Should return original string unchanged
        let result = try evaluate("{{ 'Hello' | remove }}")
        #expect(result == ["Hello"])
    }
    
    // MARK: - Array and Dictionary Inputs
    
    @Test("Remove from array input")
    func removeFromArray() throws {
        // Arrays should be coerced to string representation by joining elements
        let arrayValue = Token.Value.array([
            Token.Value.string("a"),
            Token.Value.string("b"), 
            Token.Value.string("c")
        ])
        let context = Context(dictionary: ["arr": arrayValue])
        let result = try evaluate("{{ arr | remove: 'b' }}", context: context)
        #expect(result == ["ac"])
    }
    
    @Test("Remove from dictionary input") 
    func removeFromDictionary() throws {
        // Dictionaries return empty string in LiquidKit's current implementation
        // This differs from python-liquid which would serialize the dictionary
        let context = Context(dictionary: ["dict": ["key": "value"]])
        let result = try evaluate("{{ dict | remove: 'a' }}", context: context)
        // Dictionary stringValue returns empty string, so remove filter returns empty string
        #expect(result == [""])
    }
}