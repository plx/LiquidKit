import Testing
@testable import LiquidKit

@Suite(.tags(.filter, .lstripFilter))
struct LstripFilterTests {
    
    // MARK: - Basic String Tests
    
    @Test("Basic leading space removal")
    func basicLeadingSpace() throws {
        let filter = LstripFilter()
        try validateEvaluation(
            of: .string("  hello"),
            by: filter,
            yields: .string("hello")
        )
    }
    
    @Test("Multiple spaces at beginning")
    func multipleLeadingSpaces() throws {
        let filter = LstripFilter()
        try validateEvaluation(
            of: .string("     hello world"),
            by: filter,
            yields: .string("hello world")
        )
    }
    
    @Test("Preserve trailing spaces")
    func preserveTrailingSpaces() throws {
        let filter = LstripFilter()
        try validateEvaluation(
            of: .string("  hello  "),
            by: filter,
            yields: .string("hello  ")
        )
    }
    
    @Test("Preserve internal spaces")
    func preserveInternalSpaces() throws {
        let filter = LstripFilter()
        try validateEvaluation(
            of: .string("  hello   world  "),
            by: filter,
            yields: .string("hello   world  ")
        )
    }
    
    @Test("No leading whitespace")
    func noLeadingWhitespace() throws {
        let filter = LstripFilter()
        try validateEvaluation(
            of: .string("hello world"),
            by: filter,
            yields: .string("hello world")
        )
    }
    
    // MARK: - Mixed Whitespace Tests
    
    @Test("Tab characters")
    func tabCharacters() throws {
        let filter = LstripFilter()
        try validateEvaluation(
            of: .string("\t\thello"),
            by: filter,
            yields: .string("hello")
        )
    }
    
    @Test("Newline characters")
    func newlineCharacters() throws {
        let filter = LstripFilter()
        try validateEvaluation(
            of: .string("\n\nhello"),
            by: filter,
            yields: .string("hello")
        )
    }
    
    @Test("Carriage return characters")
    func carriageReturnCharacters() throws {
        let filter = LstripFilter()
        try validateEvaluation(
            of: .string("\r\rhello"),
            by: filter,
            yields: .string("hello")
        )
    }
    
    @Test("Mixed whitespace types")
    func mixedWhitespaceTypes() throws {
        let filter = LstripFilter()
        try validateEvaluation(
            of: .string(" \t\r\n  hello  \t\r\n "),
            by: filter,
            yields: .string("hello  \t\r\n ")
        )
    }
    
    @Test("Unicode whitespace")
    func unicodeWhitespace() throws {
        let filter = LstripFilter()
        // Non-breaking space (U+00A0) followed by regular spaces
        try validateEvaluation(
            of: .string("\u{00A0}  hello"),
            by: filter,
            yields: .string("hello")
        )
    }
    
    // MARK: - Edge Cases
    
    @Test("Empty string")
    func emptyString() throws {
        let filter = LstripFilter()
        try validateEvaluation(
            of: .string(""),
            by: filter,
            yields: .string("")
        )
    }
    
    @Test("All whitespace string")
    func allWhitespaceString() throws {
        let filter = LstripFilter()
        try validateEvaluation(
            of: .string("   \t\n  "),
            by: filter,
            yields: .string("")
        )
    }
    
    @Test("Single space")
    func singleSpace() throws {
        let filter = LstripFilter()
        try validateEvaluation(
            of: .string(" "),
            by: filter,
            yields: .string("")
        )
    }
    
    // MARK: - Non-String Input Tests
    
    @Test("Integer input")
    func integerInput() throws {
        let filter = LstripFilter()
        try validateEvaluation(
            of: .integer(123),
            by: filter,
            yields: .string("123")
        )
    }
    
    @Test("Decimal input")
    func decimalInput() throws {
        let filter = LstripFilter()
        try validateEvaluation(
            of: .decimal(45.67),
            by: filter,
            yields: .string("45.67")
        )
    }
    
    @Test("Boolean true input")
    func booleanTrueInput() throws {
        let filter = LstripFilter()
        try validateEvaluation(
            of: .bool(true),
            by: filter,
            yields: .string("true")
        )
    }
    
    @Test("Boolean false input")
    func booleanFalseInput() throws {
        let filter = LstripFilter()
        try validateEvaluation(
            of: .bool(false),
            by: filter,
            yields: .string("false")
        )
    }
    
    @Test("Nil input")
    func nilInput() throws {
        let filter = LstripFilter()
        try validateEvaluation(
            of: .nil,
            by: filter,
            yields: .string("")
        )
    }
    
    @Test("Array input")
    func arrayInput() throws {
        let filter = LstripFilter()
        try validateEvaluation(
            of: .array([.string("a"), .string("b"), .string("c")]),
            by: filter,
            yields: .string("abc")
        )
    }
    
    // MARK: - Parameter Tests
    
    @Test("No parameters allowed")
    func noParametersAllowed() throws {
        let filter = LstripFilter()
        // lstrip should work without any parameters
        try validateEvaluation(
            of: .string("  hello"),
            with: [],
            by: filter,
            yields: .string("hello")
        )
    }
    
    @Test("Extra parameters ignored")
    func extraParametersIgnored() throws {
        let filter = LstripFilter()
        // Extra parameters should be ignored (not cause error in this implementation)
        try validateEvaluation(
            of: .string("  hello"),
            with: [.integer(5)],
            by: filter,
            yields: .string("hello")
        )
    }
    
    // MARK: - Real-world Examples
    
    @Test("Documentation example")
    func documentationExample() throws {
        let filter = LstripFilter()
        try validateEvaluation(
            of: .string("          So much room for activities          "),
            by: filter,
            yields: .string("So much room for activities          ")
        )
    }
    
    @Test("Multi-line text")
    func multiLineText() throws {
        let filter = LstripFilter()
        try validateEvaluation(
            of: .string("  \n  Line 1\n  Line 2"),
            by: filter,
            yields: .string("Line 1\n  Line 2")
        )
    }
}