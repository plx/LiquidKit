import Foundation
import Testing
@testable import LiquidKit

@Suite(.tags(.filter, .stripFilter))
struct StripFilterTests {
    
    // MARK: - Basic String Tests
    
    @Test func stripSpacesFromBothEnds() throws {
        let filter = StripFilter()
        try validateEvaluation(
            of: "  Hello World  ",
            by: filter,
            yields: "Hello World"
        )
    }
    
    @Test func stripTabsFromBothEnds() throws {
        let filter = StripFilter()
        try validateEvaluation(
            of: "\tHello World\t",
            by: filter,
            yields: "Hello World"
        )
    }
    
    @Test func stripNewlinesFromBothEnds() throws {
        let filter = StripFilter()
        try validateEvaluation(
            of: "\nHello World\n",
            by: filter,
            yields: "Hello World"
        )
    }
    
    @Test func stripCarriageReturnsFromBothEnds() throws {
        let filter = StripFilter()
        try validateEvaluation(
            of: "\rHello World\r",
            by: filter,
            yields: "Hello World"
        )
    }
    
    @Test func stripMixedWhitespace() throws {
        let filter = StripFilter()
        try validateEvaluation(
            of: " \t\r\n  hello  \t\r\n ",
            by: filter,
            yields: "hello"
        )
    }
    
    // MARK: - Edge Cases
    
    @Test func stripEmptyString() throws {
        let filter = StripFilter()
        try validateEvaluation(
            of: "",
            by: filter,
            yields: ""
        )
    }
    
    @Test func stripStringWithOnlyWhitespace() throws {
        let filter = StripFilter()
        try validateEvaluation(
            of: "   \t\n\r   ",
            by: filter,
            yields: ""
        )
    }
    
    @Test func stripStringWithNoWhitespace() throws {
        let filter = StripFilter()
        try validateEvaluation(
            of: "no-whitespace",
            by: filter,
            yields: "no-whitespace"
        )
    }
    
    @Test func stripPreservesInternalWhitespace() throws {
        let filter = StripFilter()
        try validateEvaluation(
            of: "  So much room for activities  ",
            by: filter,
            yields: "So much room for activities"
        )
    }
    
    @Test func stripMultipleSpacesBetweenWords() throws {
        let filter = StripFilter()
        try validateEvaluation(
            of: "  multiple   spaces   between   words  ",
            by: filter,
            yields: "multiple   spaces   between   words"
        )
    }
    
    // MARK: - Non-String Input Tests
    
    @Test func stripInteger() throws {
        let filter = StripFilter()
        try validateEvaluation(
            of: Token.Value.integer(123),
            by: filter,
            yields: "123"
        )
    }
    
    @Test func stripDecimal() throws {
        let filter = StripFilter()
        try validateEvaluation(
            of: Token.Value.decimal(45.67),
            by: filter,
            yields: "45.67"
        )
    }
    
    @Test func stripBooleanTrue() throws {
        let filter = StripFilter()
        try validateEvaluation(
            of: Token.Value.bool(true),
            by: filter,
            yields: "true"
        )
    }
    
    @Test func stripBooleanFalse() throws {
        let filter = StripFilter()
        try validateEvaluation(
            of: Token.Value.bool(false),
            by: filter,
            yields: "false"
        )
    }
    
    @Test func stripNil() throws {
        let filter = StripFilter()
        try validateEvaluation(
            of: Token.Value.nil,
            by: filter,
            yields: ""
        )
    }
    
    @Test func stripArray() throws {
        let filter = StripFilter()
        try validateEvaluation(
            of: Token.Value.array([.string("hello"), .string("world")]),
            by: filter,
            yields: "helloworld"
        )
    }
    
    @Test func stripDictionary() throws {
        // Dictionaries convert to empty string
        let filter = StripFilter()
        try validateEvaluation(
            of: Token.Value.dictionary(["key": .string("value")]),
            by: filter,
            yields: ""
        )
    }
    
    @Test func stripRange() throws {
        let filter = StripFilter()
        try validateEvaluation(
            of: Token.Value.range(1...5),
            by: filter,
            yields: "1..5"
        )
    }
    
    // MARK: - Unicode Whitespace Tests
    
    @Test func stripUnicodeWhitespace() throws {
        // Test various Unicode whitespace characters
        let unicodeSpaces = "\u{00A0}Hello\u{2000}World\u{00A0}" // Non-breaking space and en quad
        let filter = StripFilter()
        // Note: Foundation's .whitespacesAndNewlines includes many Unicode spaces
        try validateEvaluation(
            of: unicodeSpaces,
            by: filter,
            yields: "Hello\u{2000}World" // Non-breaking spaces ARE stripped by Foundation
        )
    }
    
    @Test func stripFormFeed() throws {
        let filter = StripFilter()
        try validateEvaluation(
            of: "\u{000C}Hello World\u{000C}", // Form feed
            by: filter,
            yields: "Hello World"
        )
    }
    
    // MARK: - Real-world Examples
    
    @Test func stripUserInput() throws {
        // Simulating user input that might have accidental whitespace
        let filter = StripFilter()
        try validateEvaluation(
            of: "   john.doe@example.com   ",
            by: filter,
            yields: "john.doe@example.com"
        )
    }
    
    @Test func stripMultilineString() throws {
        let multiline = """
        
        This is a
        multiline string
        with whitespace
        
        """
        let filter = StripFilter()
        try validateEvaluation(
            of: multiline,
            by: filter,
            yields: "This is a\nmultiline string\nwith whitespace"
        )
    }
    
    // MARK: - Parameter Tests
    
    @Test func stripRejectsParameters() throws {
        // The strip filter should not accept any parameters
        // This test ensures we don't accidentally process parameters
        let filter = StripFilter()
        try validateEvaluation(
            of: "  hello  ",
            with: [Token.Value.string("unused")],
            by: filter,
            yields: "hello"
        )
    }
}