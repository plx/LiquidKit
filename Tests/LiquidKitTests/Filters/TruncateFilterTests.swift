import Testing
@testable import LiquidKit

@Suite("TruncateFilter Tests", .tags(.filter, .truncateFilter))
struct TruncateFilterTests {
    let filter = TruncateFilter()
    
    // MARK: - Basic Functionality Tests
    
    @Test("Basic truncation with default ellipsis")
    func basicTruncation() throws {
        // Test basic truncation to 20 characters with default "..."
        try validateEvaluation(
            of: "Ground control to Major Tom.",
            with: [.integer(20)],
            by: filter,
            yields: "Ground control to..."
        )
    }
    
    @Test("Default length of 50 characters")
    func defaultLength() throws {
        // When no length is specified, should default to 50
        try validateEvaluation(
            of: "Ground control to Major Tom. Ground control to Major Tom.",
            with: [],
            by: filter,
            yields: "Ground control to Major Tom. Ground control to ..."
        )
    }
    
    @Test("Custom ellipsis string")
    func customEllipsis() throws {
        // Test with a custom ellipsis string
        try validateEvaluation(
            of: "Ground control to Major Tom.",
            with: [.integer(25), .string(", and so on")],
            by: filter,
            yields: "Ground control, and so on"
        )
    }
    
    @Test("Empty ellipsis for exact truncation")
    func emptyEllipsis() throws {
        // Empty ellipsis should truncate to exact length
        try validateEvaluation(
            of: "Ground control to Major Tom.",
            with: [.integer(20), .string("")],
            by: filter,
            yields: "Ground control to Ma"
        )
    }
    
    // MARK: - Edge Cases
    
    @Test("String shorter than truncation length")
    func shortString() throws {
        // String shorter than length should remain unchanged
        try validateEvaluation(
            of: "Ground control",
            with: [.integer(20)],
            by: filter,
            yields: "Ground control"
        )
    }
    
    @Test("String exactly at truncation length")
    func exactLengthString() throws {
        // String exactly at length should remain unchanged
        try validateEvaluation(
            of: "12345",
            with: [.integer(5)],
            by: filter,
            yields: "12345"
        )
    }
    
    @Test("Very short truncation length")
    func veryShortLength() throws {
        // Test with length of 3 (just enough for ellipsis)
        try validateEvaluation(
            of: "Hello World",
            with: [.integer(3)],
            by: filter,
            yields: "..."
        )
    }
    
    @Test("Ellipsis longer than truncation length")
    func ellipsisLongerThanLength() throws {
        // When ellipsis is longer than length, should just return ellipsis
        try validateEvaluation(
            of: "Hello World",
            with: [.integer(3), .string("......")],
            by: filter,
            yields: "......"
        )
    }
    
    @Test("Zero length truncation")
    func zeroLength() throws {
        // Zero length should return empty string with default ellipsis
        try validateEvaluation(
            of: "Hello World",
            with: [.integer(0)],
            by: filter,
            yields: "..."
        )
    }
    
    @Test("Negative length truncation")
    func negativeLength() throws {
        // Negative length should be treated as 0
        try validateEvaluation(
            of: "Hello World",
            with: [.integer(-5)],
            by: filter,
            yields: "..."
        )
    }
    
    // MARK: - Non-String Input Tests
    
    @Test("Integer input")
    func integerInput() throws {
        // Non-string values should be returned unchanged
        try validateEvaluation(
            of: 5,
            with: [.integer(10)],
            by: filter,
            yields: 5
        )
    }
    
    @Test("Decimal input")
    func decimalInput() throws {
        // Decimal values should be returned unchanged
        try validateEvaluation(
            of: 3.14159,
            with: [.integer(5)],
            by: filter,
            yields: 3.14159
        )
    }
    
    @Test("Boolean input")
    func booleanInput() throws {
        // Boolean values should be returned unchanged
        try validateEvaluation(
            of: true,
            with: [.integer(5)],
            by: filter,
            yields: true
        )
    }
    
    @Test("Nil input")
    func nilInput() throws {
        // Nil should be returned unchanged
        try validateEvaluation(
            of: Token.Value.nil,
            with: [.integer(5)],
            by: filter,
            yields: Token.Value.nil
        )
    }
    
    @Test("Array input")
    func arrayInput() throws {
        // Array should be returned unchanged
        let array: Token.Value = .array([.string("hello"), .string("world")])
        try validateEvaluation(
            of: array,
            with: [.integer(5)],
            by: filter,
            yields: array
        )
    }
    
    @Test("Dictionary input")
    func dictionaryInput() throws {
        // Dictionary should be returned unchanged
        let dict: Token.Value = .dictionary(["key": .string("value")])
        try validateEvaluation(
            of: dict,
            with: [.integer(5)],
            by: filter,
            yields: dict
        )
    }
    
    // MARK: - Parameter Handling Tests
    
    @Test("String length parameter")
    func stringLengthParameter() throws {
        // String representation of number should work
        try validateEvaluation(
            of: "Ground control to Major Tom.",
            with: [.string("20")],
            by: filter,
            yields: "Ground control to..."
        )
    }
    
    @Test("Non-numeric string length parameter")
    func nonNumericStringLength() throws {
        // Non-numeric string should use default length
        try validateEvaluation(
            of: "Ground control to Major Tom.",
            with: [.string("abc")],
            by: filter,
            yields: "Ground control to Major Tom."
        )
    }
    
    @Test("Decimal length parameter")
    func decimalLengthParameter() throws {
        // Decimal should be truncated to integer
        try validateEvaluation(
            of: "Ground control to Major Tom.",
            with: [.decimal(20.7)],
            by: filter,
            yields: "Ground control to Major Tom."
        )
    }
    
    @Test("Non-string ellipsis parameter")
    func nonStringEllipsis() throws {
        // Non-string ellipsis should use default
        try validateEvaluation(
            of: "Ground control to Major Tom.",
            with: [.integer(20), .integer(123)],
            by: filter,
            yields: "Ground control to..."
        )
    }
    
    @Test("Nil ellipsis parameter")
    func nilEllipsis() throws {
        // Nil ellipsis (undefined variable) should use empty string per liquidjs/python-liquid
        try validateEvaluation(
            of: "Ground control to Major Tom.",
            with: [.integer(20), .nil],
            by: filter,
            yields: "Ground control to Ma"
        )
    }
    
    // MARK: - Unicode and Special Characters
    
    @Test("Unicode string truncation")
    func unicodeString() throws {
        // Test with unicode characters
        try validateEvaluation(
            of: "Hello 👋 World 🌍 Test",
            with: [.integer(10)],
            by: filter,
            yields: "Hello 👋..."
        )
    }
    
    @Test("Emoji truncation")
    func emojiTruncation() throws {
        // Test truncation with emojis
        try validateEvaluation(
            of: "🎉🎊🎈🎆🎇🎄🎃🎁",
            with: [.integer(5)],
            by: filter,
            yields: "🎉🎊..."
        )
    }
    
    @Test("Multi-line string truncation")
    func multilineString() throws {
        // Test with newlines
        try validateEvaluation(
            of: "Line 1\nLine 2\nLine 3",
            with: [.integer(10)],
            by: filter,
            yields: "Line 1\n..."
        )
    }
    
    // MARK: - Special Cases
    
    @Test("Empty string input")
    func emptyString() throws {
        // Empty string should remain empty
        try validateEvaluation(
            of: "",
            with: [.integer(10)],
            by: filter,
            yields: ""
        )
    }
    
    @Test("Single character with truncation")
    func singleCharacter() throws {
        // Single character shorter than length
        try validateEvaluation(
            of: "A",
            with: [.integer(5)],
            by: filter,
            yields: "A"
        )
    }
    
    @Test("Whitespace-only string")
    func whitespaceOnly() throws {
        // Whitespace should be preserved
        try validateEvaluation(
            of: "     ",
            with: [.integer(3)],
            by: filter,
            yields: "..."
        )
    }
}