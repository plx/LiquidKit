import Foundation
import Testing
@testable import LiquidKit

@Suite(.tags(.filter, .removeLastFilter))
struct RemoveLastFilterTests {
    
    // MARK: - Basic Functionality Tests
    
    @Test("Remove last occurrence from string with multiple occurrences")
    func removeLastFromMultipleOccurrences() throws {
        let filter = RemoveLastFilter()
        
        // Should remove only the last "rain"
        try validateEvaluation(
            of: "I strained to see the train through the rain",
            with: [.string("rain")],
            by: filter,
            yields: "I strained to see the train through the "
        )
        
        // Multiple same words
        try validateEvaluation(
            of: "one two one three one",
            with: [.string("one")],
            by: filter,
            yields: "one two one three "
        )
        
        // Remove last space
        try validateEvaluation(
            of: "a b c d",
            with: [.string(" ")],
            by: filter,
            yields: "a b cd"
        )
    }
    
    @Test("Remove last occurrence when only one occurrence exists")
    func removeLastSingleOccurrence() throws {
        let filter = RemoveLastFilter()
        
        // Single occurrence should be removed
        try validateEvaluation(
            of: "Hello world",
            with: [.string("world")],
            by: filter,
            yields: "Hello "
        )
        
        // Remove at beginning when it's the only occurrence
        try validateEvaluation(
            of: "Hello world",
            with: [.string("Hello")],
            by: filter,
            yields: " world"
        )
        
        // Remove in middle when it's the only occurrence
        try validateEvaluation(
            of: "Hello beautiful world",
            with: [.string("beautiful")],
            by: filter,
            yields: "Hello  world"
        )
    }
    
    @Test("Remove last when substring not found")
    func removeLastNotFound() throws {
        let filter = RemoveLastFilter()
        
        // Substring not found - should return original
        try validateEvaluation(
            of: "Hello world",
            with: [.string("xyz")],
            by: filter,
            yields: "Hello world"
        )
        
        // Case sensitive - should not match
        try validateEvaluation(
            of: "Hello World",
            with: [.string("world")],
            by: filter,
            yields: "Hello World"
        )
    }
    
    @Test("Remove last with empty strings")
    func removeLastEmptyStrings() throws {
        let filter = RemoveLastFilter()
        
        // Empty input string
        try validateEvaluation(
            of: "",
            with: [.string("test")],
            by: filter,
            yields: ""
        )
        
        // Empty search string - should return original
        try validateEvaluation(
            of: "test",
            with: [.string("")],
            by: filter,
            yields: "test"
        )
        
        // Both empty
        try validateEvaluation(
            of: "",
            with: [.string("")],
            by: filter,
            yields: ""
        )
    }
    
    // MARK: - Type Coercion Tests
    
    @Test("Remove last with integer inputs")
    func removeLastIntegerInputs() throws {
        let filter = RemoveLastFilter()
        
        // Integer input with string parameter
        try validateEvaluation(
            of: 12345,
            with: [.string("3")],
            by: filter,
            yields: "1245"
        )
        
        // String input with integer parameter
        try validateEvaluation(
            of: "test123test",
            with: [.integer(123)],
            by: filter,
            yields: "testtest"
        )
        
        // Both integers
        try validateEvaluation(
            of: 123123,
            with: [.integer(123)],
            by: filter,
            yields: "123"
        )
    }
    
    @Test("Remove last with boolean inputs")
    func removeLastBooleanInputs() throws {
        let filter = RemoveLastFilter()
        
        // Boolean input
        try validateEvaluation(
            of: true,
            with: [.string("r")],
            by: filter,
            yields: "tue"
        )
        try validateEvaluation(
            of: false,
            with: [.string("e")],
            by: filter,
            yields: "fals"
        )
        
        // String with boolean parameter
        try validateEvaluation(
            of: "true or false",
            with: [.bool(false)],
            by: filter,
            yields: "true or "
        )
    }
    
    @Test("Remove last with decimal inputs")
    func removeLastDecimalInputs() throws {
        let filter = RemoveLastFilter()
        
        // Decimal input
        try validateEvaluation(
            of: 3.14159,
            with: [.string("1")],
            by: filter,
            yields: "3.1459"
        )
        
        // Multiple decimals in string
        try validateEvaluation(
            of: "1.5 and 2.5",
            with: [.string(".5")],
            by: filter,
            yields: "1.5 and 2"
        )
    }
    
    @Test("Remove last with nil inputs")
    func removeLastNilInputs() throws {
        let filter = RemoveLastFilter()
        
        // Nil input should return nil
        try validateEvaluation(
            of: Token.Value.nil,
            with: [.string("test")],
            by: filter,
            yields: Token.Value.nil
        )
        
        // Valid input with nil parameter should return input unchanged
        try validateEvaluation(
            of: "test",
            with: [Token.Value.nil],
            by: filter,
            yields: "test"
        )
    }
    
    @Test("Remove last with array inputs")
    func removeLastArrayInputs() throws {
        let filter = RemoveLastFilter()
        
        // Array input should be converted to string
        let array: Token.Value = .array([.string("a"), .string("b"), .string("c")])
        try validateEvaluation(
            of: array,
            with: [.string("b")],
            by: filter,
            yields: "ac"
        )
        
        // Array with mixed types
        let mixedArray: Token.Value = .array([.integer(1), .string("a"), .integer(2)])
        try validateEvaluation(
            of: mixedArray,
            with: [.string("a")],
            by: filter,
            yields: "12"
        )
    }
    
    // MARK: - Edge Cases
    
    @Test("Remove last with special characters")
    func removeLastSpecialCharacters() throws {
        let filter = RemoveLastFilter()
        
        // Newlines
        try validateEvaluation(
            of: "line1\nline2\nline3",
            with: [.string("\n")],
            by: filter,
            yields: "line1\nline2line3"
        )
        
        // Tabs
        try validateEvaluation(
            of: "col1\tcol2\tcol3",
            with: [.string("\t")],
            by: filter,
            yields: "col1\tcol2col3"
        )
        
        // Unicode
        try validateEvaluation(
            of: "Hello 👋 World 👋",
            with: [.string("👋")],
            by: filter,
            yields: "Hello 👋 World "
        )
    }
    
    @Test("Remove last with overlapping patterns")
    func removeLastOverlappingPatterns() throws {
        let filter = RemoveLastFilter()
        
        // Overlapping pattern
        try validateEvaluation(
            of: "aaaa",
            with: [.string("aa")],
            by: filter,
            yields: "aa"
        )
        
        // Pattern at the very end
        try validateEvaluation(
            of: "testtest",
            with: [.string("test")],
            by: filter,
            yields: "test"
        )
    }
    
    @Test("Remove last with no parameters")
    func removeLastNoParameters() throws {
        let filter = RemoveLastFilter()
        
        // No parameters should return input unchanged
        try validateEvaluation(
            of: "test",
            with: [],
            by: filter,
            yields: "test"
        )
    }
    
    @Test("Remove last with extra parameters")
    func removeLastExtraParameters() throws {
        let filter = RemoveLastFilter()
        
        // Extra parameters should be ignored
        try validateEvaluation(
            of: "test test",
            with: [.string("test"), .string("extra")],
            by: filter,
            yields: "test "
        )
    }
    
    // MARK: - Complex Scenarios
    
    @Test("Remove last with repeated patterns")
    func removeLastRepeatedPatterns() throws {
        let filter = RemoveLastFilter()
        
        // Remove last from repeated pattern
        try validateEvaluation(
            of: "abcabcabc",
            with: [.string("abc")],
            by: filter,
            yields: "abcabc"
        )
        
        // Remove last single character from repeated pattern
        try validateEvaluation(
            of: "ababab",
            with: [.string("b")],
            by: filter,
            yields: "ababa"
        )
    }
    
    @Test("Remove last preserves earlier occurrences") 
    func removeLastPreservesEarlier() throws {
        let filter = RemoveLastFilter()
        
        // URL example - remove last slash
        try validateEvaluation(
            of: "http://example.com/path/",
            with: [.string("/")],
            by: filter,
            yields: "http://example.com/path"
        )
        
        // Path example - remove last dot
        try validateEvaluation(
            of: "file.name.txt",
            with: [.string(".")],
            by: filter,
            yields: "file.nametxt"
        )
    }
}

