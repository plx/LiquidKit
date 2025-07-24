import Testing
@testable import LiquidKit

/// Test suite for the `replace_last` filter functionality.
///
/// This suite validates the behavior of ReplaceLastFilter, which replaces only
/// the last occurrence of a substring with another string. Unlike `replace` which
/// replaces all occurrences, and `replace_first` which replaces only the first,
/// `replace_last` specifically targets the final instance of the search string.
@Suite("Replace Last Filter", .tags(.filter, .replaceLastFilter))
struct ReplaceLastFilterTests {
    
    // MARK: - Basic Functionality Tests
    
    @Test("Basic string replacement")
    func basicReplacement() throws {
        let filter = ReplaceLastFilter()
        
        // Single occurrence - replaces the only occurrence
        try validateEvaluation(
            of: "hello world",
            with: ["world".tokenValue, "there".tokenValue],
            by: filter,
            yields: "hello there",
            "Should replace single occurrence"
        )
        
        // Multiple occurrences - replaces only the last
        try validateEvaluation(
            of: "Take my protein pills and put my helmet on",
            with: ["my".tokenValue, "your".tokenValue],
            by: filter,
            yields: "Take my protein pills and put your helmet on",
            "Should replace only the last 'my'"
        )
        
        // Multiple consecutive occurrences
        try validateEvaluation(
            of: "red red red",
            with: ["red".tokenValue, "blue".tokenValue],
            by: filter,
            yields: "red red blue",
            "Should replace only the last 'red'"
        )
    }
    
    @Test("No match scenarios")
    func noMatchFound() throws {
        let filter = ReplaceLastFilter()
        
        // Search string not found
        try validateEvaluation(
            of: "hello world",
            with: ["foo".tokenValue, "bar".tokenValue],
            by: filter,
            yields: "hello world",
            "Should return original string when search string not found"
        )
        
        // Case sensitive - no match
        try validateEvaluation(
            of: "Hello World",
            with: ["hello".tokenValue, "hi".tokenValue],
            by: filter,
            yields: "Hello World",
            "Should be case sensitive"
        )
    }
    
    // MARK: - Edge Cases
    
    @Test("Empty string handling")
    func emptyStrings() throws {
        let filter = ReplaceLastFilter()
        
        // Empty input string
        try validateEvaluation(
            of: "",
            with: ["a".tokenValue, "b".tokenValue],
            by: filter,
            yields: "",
            "Empty input should return empty string"
        )
        
        // Empty search string - should append replacement at the end
        try validateEvaluation(
            of: "ab",
            with: ["".tokenValue, "X".tokenValue],
            by: filter,
            yields: "abX",
            "Empty search string should append replacement at the end"
        )
        
        // Empty replacement string - removes last occurrence
        try validateEvaluation(
            of: "hello world hello",
            with: ["hello".tokenValue, "".tokenValue],
            by: filter,
            yields: "hello world ",
            "Empty replacement should remove last occurrence"
        )
        
        // Both empty
        try validateEvaluation(
            of: "test",
            with: ["".tokenValue, "".tokenValue],
            by: filter,
            yields: "test",
            "Empty search and replacement should return original"
        )
    }
    
    @Test("Special characters")
    func specialCharacters() throws {
        let filter = ReplaceLastFilter()
        
        // Dots
        try validateEvaluation(
            of: "1.2.3.4",
            with: [".".tokenValue, "-".tokenValue],
            by: filter,
            yields: "1.2.3-4",
            "Should replace last dot"
        )
        
        // Newlines
        try validateEvaluation(
            of: "line1\nline2\nline3",
            with: ["\n".tokenValue, " | ".tokenValue],
            by: filter,
            yields: "line1\nline2 | line3",
            "Should replace last newline"
        )
        
        // Unicode
        try validateEvaluation(
            of: "😀 and 😀 are happy",
            with: ["😀".tokenValue, "😎".tokenValue],
            by: filter,
            yields: "😀 and 😎 are happy",
            "Should handle unicode correctly"
        )
    }
    
    // MARK: - Type Conversion Tests
    
    @Test("Non-string input handling")
    func nonStringInputs() throws {
        let filter = ReplaceLastFilter()
        
        // Integer input
        try validateEvaluation(
            of: 12321,
            with: ["2".tokenValue, "5".tokenValue],
            by: filter,
            yields: "12351",
            "Should convert integer to string and replace"
        )
        
        // Decimal input
        try validateEvaluation(
            of: 3.14159,
            with: ["1".tokenValue, "2".tokenValue],
            by: filter,
            yields: "3.14259",
            "Should convert decimal to string and replace last occurrence"
        )
        
        // Boolean input
        try validateEvaluation(
            of: true,
            with: ["e".tokenValue, "th".tokenValue],
            by: filter,
            yields: "truth",
            "Should convert boolean to string and replace"
        )
        
        // Nil input
        try validateEvaluation(
            of: Token.Value.nil,
            with: ["".tokenValue, "x".tokenValue],
            by: filter,
            yields: "x",
            "Nil input with empty search should append replacement"
        )
        
        // Array input
        try validateEvaluation(
            of: [1, 2, 3],
            with: [", ".tokenValue, " and ".tokenValue],
            by: filter,
            yields: "[1, 2 and 3]",
            "Should convert array to string representation"
        )
        
        // Dictionary input
        try validateEvaluation(
            of: Token.Value.dictionary([:]),
            with: ["}".tokenValue, " empty}".tokenValue],
            by: filter,
            yields: "{ empty}",
            "Should convert dictionary to string representation"
        )
    }
    
    @Test("Non-string parameter handling")
    func nonStringParameters() throws {
        let filter = ReplaceLastFilter()
        
        // Integer search parameter
        try validateEvaluation(
            of: "hello5world5",
            with: [5.tokenValue, "!".tokenValue],
            by: filter,
            yields: "hello5world!",
            "Should convert integer search parameter to string"
        )
        
        // Integer replacement parameter
        try validateEvaluation(
            of: "test test",
            with: ["test".tokenValue, 123.tokenValue],
            by: filter,
            yields: "test 123",
            "Should convert integer replacement to string"
        )
        
        // Nil parameters
        try validateEvaluation(
            of: "hello world",
            with: [Token.Value.nil, "x".tokenValue],
            by: filter,
            yields: "hello worldx",
            "Nil search parameter (empty string) should append replacement"
        )
        
        try validateEvaluation(
            of: "hello world",
            with: ["world".tokenValue, Token.Value.nil],
            by: filter,
            yields: "hello ",
            "Nil replacement parameter should be treated as empty string"
        )
    }
    
    // MARK: - Parameter Validation Tests
    
    @Test("Parameter count validation")
    func parameterValidation() throws {
        let filter = ReplaceLastFilter()
        
        // No parameters
        #expect(throws: TemplateSyntaxError.self, "Should throw error with no parameters") {
            _ = try filter.evaluate(token: "test".tokenValue, parameters: [])
        }
        
        // One parameter
        #expect(throws: TemplateSyntaxError.self, "Should throw error with one parameter") {
            _ = try filter.evaluate(token: "test".tokenValue, parameters: ["x".tokenValue])
        }
        
        // Three parameters
        #expect(throws: TemplateSyntaxError.self, "Should throw error with three parameters") {
            _ = try filter.evaluate(
                token: "test".tokenValue,
                parameters: ["a".tokenValue, "b".tokenValue, "c".tokenValue]
            )
        }
    }
    
    // MARK: - Complex Pattern Tests
    
    @Test("Complex replacement patterns")
    func complexPatterns() throws {
        let filter = ReplaceLastFilter()
        
        // Overlapping patterns
        try validateEvaluation(
            of: "aaaa",
            with: ["aa".tokenValue, "b".tokenValue],
            by: filter,
            yields: "aab",
            "Should replace last occurrence of overlapping pattern"
        )
        
        // Pattern at the end
        try validateEvaluation(
            of: "hello world",
            with: ["world".tokenValue, "universe".tokenValue],
            by: filter,
            yields: "hello universe",
            "Should replace pattern at end of string"
        )
        
        // Pattern at the beginning (with another occurrence later)
        try validateEvaluation(
            of: "world hello world",
            with: ["world".tokenValue, "universe".tokenValue],
            by: filter,
            yields: "world hello universe",
            "Should skip first occurrence and replace last"
        )
        
        // Substring of larger word
        try validateEvaluation(
            of: "cat category cat",
            with: ["cat".tokenValue, "dog".tokenValue],
            by: filter,
            yields: "cat category dog",
            "Should replace last standalone occurrence"
        )
    }
    
    // MARK: - Golden Liquid Compatibility Tests
    
    @Test("Golden Liquid test case compatibility")
    func goldenLiquidCompatibility() throws {
        let filter = ReplaceLastFilter()
        
        // From golden liquid: {{ "hello5" | replace_last: 5, "your" }}
        try validateEvaluation(
            of: "hello5",
            with: [5.tokenValue, "your".tokenValue],
            by: filter,
            yields: "helloyour"
        )
        
        // From golden liquid: {{ 5 | replace_last: 'rain', 'foo' }}
        try validateEvaluation(
            of: 5,
            with: ["rain".tokenValue, "foo".tokenValue],
            by: filter,
            yields: "5"
        )
        
        // From golden liquid: {{ "Take my protein pills and put my helmet on" | replace_last: "my", "your" }}
        try validateEvaluation(
            of: "Take my protein pills and put my helmet on",
            with: ["my".tokenValue, "your".tokenValue],
            by: filter,
            yields: "Take my protein pills and put your helmet on"
        )
        
        // Variable not found cases
        // {{ "Take my protein" | replace_last: nosuchthing, "#" }}
        // nosuchthing is nil
        try validateEvaluation(
            of: "Take my protein",
            with: [Token.Value.nil, "#".tokenValue],
            by: filter,
            yields: "Take my protein#"
        )
        
        // {{ nosuchthing | replace_last: "my", "your" }}
        // nosuchthing is nil
        try validateEvaluation(
            of: Token.Value.nil,
            with: ["my".tokenValue, "your".tokenValue],
            by: filter,
            yields: ""
        )
        
        // {{ "Take my protein pills and put my helmet on" | replace_last: "my", nosuchthing }}
        // nosuchthing is nil
        try validateEvaluation(
            of: "Take my protein pills and put my helmet on",
            with: ["my".tokenValue, Token.Value.nil],
            by: filter,
            yields: "Take my protein pills and put  helmet on"
        )
    }
}

