import Testing
@testable import LiquidKit

@Suite(.tags(.filter, .rstripFilter))
struct RstripFilterTests {
    
    // MARK: - Basic String Tests
    
    @Test("Basic trailing space removal")
    func basicTrailingSpace() throws {
        let filter = RstripFilter()
        try validateEvaluation(
            of: "hello  ",
            by: filter,
            yields: "hello"
        )
    }
    
    @Test("Multiple spaces at end")
    func multipleTrailingSpaces() throws {
        let filter = RstripFilter()
        try validateEvaluation(
            of: "hello world     ",
            by: filter,
            yields: "hello world"
        )
    }
    
    @Test("Preserve leading spaces")
    func preserveLeadingSpaces() throws {
        let filter = RstripFilter()
        try validateEvaluation(
            of: "  hello  ",
            by: filter,
            yields: "  hello"
        )
    }
    
    @Test("Preserve internal spaces")
    func preserveInternalSpaces() throws {
        let filter = RstripFilter()
        try validateEvaluation(
            of: "  hello   world  ",
            by: filter,
            yields: "  hello   world"
        )
    }
    
    @Test("No trailing whitespace")
    func noTrailingWhitespace() throws {
        let filter = RstripFilter()
        try validateEvaluation(
            of: "hello world",
            by: filter,
            yields: "hello world"
        )
    }
    
    // MARK: - Mixed Whitespace Tests
    
    @Test("Tab characters")
    func tabCharacters() throws {
        let filter = RstripFilter()
        try validateEvaluation(
            of: "hello\t\t",
            by: filter,
            yields: "hello"
        )
    }
    
    @Test("Newline characters")
    func newlineCharacters() throws {
        let filter = RstripFilter()
        try validateEvaluation(
            of: "hello\n\n",
            by: filter,
            yields: "hello"
        )
    }
    
    @Test("Carriage return characters")
    func carriageReturnCharacters() throws {
        let filter = RstripFilter()
        try validateEvaluation(
            of: "hello\r\r",
            by: filter,
            yields: "hello"
        )
    }
    
    @Test("Mixed whitespace types")
    func mixedWhitespaceTypes() throws {
        let filter = RstripFilter()
        try validateEvaluation(
            of: " \t\r\n  hello  \t\r\n ",
            by: filter,
            yields: " \t\r\n  hello"
        )
    }
    
    @Test("Unicode whitespace")
    func unicodeWhitespace() throws {
        let filter = RstripFilter()
        // Non-breaking space (U+00A0) followed by regular spaces
        try validateEvaluation(
            of: "hello  \u{00A0}",
            by: filter,
            yields: "hello"
        )
    }
    
    // MARK: - Edge Cases
    
    @Test("Empty string")
    func emptyString() throws {
        let filter = RstripFilter()
        try validateEvaluation(
            of: "",
            by: filter,
            yields: ""
        )
    }
    
    @Test("All whitespace string")
    func allWhitespaceString() throws {
        let filter = RstripFilter()
        try validateEvaluation(
            of: "   \t\n  ",
            by: filter,
            yields: ""
        )
    }
    
    @Test("Single space")
    func singleSpace() throws {
        let filter = RstripFilter()
        try validateEvaluation(
            of: " ",
            by: filter,
            yields: ""
        )
    }
    
    // MARK: - Non-String Input Tests
    
    @Test("Integer input should be converted to string")
    func integerInput() throws {
        let filter = RstripFilter()
        try validateEvaluation(
            of: 123,
            by: filter,
            yields: "123"
        )
    }
    
    @Test("Decimal input should be converted to string")
    func decimalInput() throws {
        let filter = RstripFilter()
        try validateEvaluation(
            of: 45.67,
            by: filter,
            yields: "45.67"
        )
    }
    
    @Test("Boolean true input should be converted to string")
    func booleanTrueInput() throws {
        let filter = RstripFilter()
        try validateEvaluation(
            of: true,
            by: filter,
            yields: "true"
        )
    }
    
    @Test("Boolean false input should be converted to string")
    func booleanFalseInput() throws {
        let filter = RstripFilter()
        try validateEvaluation(
            of: false,
            by: filter,
            yields: "false"
        )
    }
    
    @Test("Nil input should return empty string")
    func nilInput() throws {
        let filter = RstripFilter()
        try validateEvaluation(
            of: Token.Value.nil,
            by: filter,
            yields: ""
        )
    }
    
    @Test("Array input should be converted to string")
    func arrayInput() throws {
        let filter = RstripFilter()
        try validateEvaluation(
            of: ["a", "b", "c"],
            by: filter,
            yields: "abc"
        )
    }
    
    @Test("Dictionary input should be converted to string")
    func dictionaryInput() throws {
        let filter = RstripFilter()
        // Dictionary rendering might be implementation-specific
        // but should at least not crash and return a string
        let result = try filter.evaluate(
            token: .dictionary(["key": .string("value")]),
            parameters: []
        )
        // Dictionary should be converted to a string representation
        if case .string(_) = result {
            // Success - it was converted to string
        } else {
            Issue.record("Expected dictionary to be converted to string, got: \(result)")
        }
    }
    
    // MARK: - Parameter Tests
    
    @Test("No parameters allowed")
    func noParametersAllowed() throws {
        let filter = RstripFilter()
        // rstrip should work without any parameters
        try validateEvaluation(
            of: "hello  ",
            with: [],
            by: filter,
            yields: "hello"
        )
    }
    
    @Test("Extra parameters ignored")
    func extraParametersIgnored() throws {
        let filter = RstripFilter()
        // Extra parameters should be ignored (not cause error in this implementation)
        try validateEvaluation(
            of: "hello  ",
            with: [Token.Value.integer(5)],
            by: filter,
            yields: "hello"
        )
    }
    
    // MARK: - Real-world Examples
    
    @Test("Documentation example")
    func documentationExample() throws {
        let filter = RstripFilter()
        try validateEvaluation(
            of: "          So much room for activities          ",
            by: filter,
            yields: "          So much room for activities"
        )
    }
    
    @Test("Multi-line text")
    func multiLineText() throws {
        let filter = RstripFilter()
        try validateEvaluation(
            of: "Line 1  \nLine 2  \n",
            by: filter,
            yields: "Line 1  \nLine 2"
        )
    }
    
    @Test("Text with trailing mixed whitespace")
    func textWithTrailingMixedWhitespace() throws {
        let filter = RstripFilter()
        try validateEvaluation(
            of: "Hello World   \t\n\r  ",
            by: filter,
            yields: "Hello World"
        )
    }
    
    @Test("Preserve empty lines in middle")
    func preserveEmptyLinesInMiddle() throws {
        let filter = RstripFilter()
        try validateEvaluation(
            of: "Line 1\n\nLine 2  ",
            by: filter,
            yields: "Line 1\n\nLine 2"
        )
    }
}