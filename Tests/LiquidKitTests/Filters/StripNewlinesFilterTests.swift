import Foundation
import Testing
@testable import LiquidKit

@Suite(.tags(.filter, .stripNewlinesFilter))
struct StripNewlinesFilterTests {
    
    // MARK: - Basic String Tests
    
    @Test("Remove Unix newlines (\\n)")
    func removeUnixNewlines() throws {
        let filter = StripNewlinesFilter()
        try validateEvaluation(
            of: "Line one\nLine two\nLine three",
            by: filter,
            yields: "Line oneLine twoLine three"
        )
    }
    
    @Test("Remove Windows newlines (\\r\\n)")
    func removeWindowsNewlines() throws {
        let filter = StripNewlinesFilter()
        try validateEvaluation(
            of: "Line one\r\nLine two\r\nLine three",
            by: filter,
            yields: "Line oneLine twoLine three"
        )
    }
    
    @Test("Remove Mac newlines (\\r)")
    func removeMacNewlines() throws {
        let filter = StripNewlinesFilter()
        try validateEvaluation(
            of: "Line one\rLine two\rLine three",
            by: filter,
            yields: "Line oneLine twoLine three"
        )
    }
    
    @Test("Remove mixed newline types")
    func removeMixedNewlines() throws {
        let filter = StripNewlinesFilter()
        try validateEvaluation(
            of: "Windows\r\nUnix\nMac\rMixed",
            by: filter,
            yields: "WindowsUnixMacMixed"
        )
    }
    
    @Test("Preserve spaces and tabs")
    func preserveOtherWhitespace() throws {
        let filter = StripNewlinesFilter()
        try validateEvaluation(
            of: "  Hello\n\tWorld  \n  Test  ",
            by: filter,
            yields: "  Hello\tWorld    Test  "
        )
    }
    
    @Test("Documentation example - basic")
    func documentationExampleBasic() throws {
        let filter = StripNewlinesFilter()
        try validateEvaluation(
            of: "Line one\nLine two",
            by: filter,
            yields: "Line oneLine two"
        )
    }
    
    @Test("Documentation example - abc")
    func documentationExampleAbc() throws {
        let filter = StripNewlinesFilter()
        try validateEvaluation(
            of: "a\nb\nc",
            by: filter,
            yields: "abc"
        )
    }
    
    @Test("Documentation example - hello there you")
    func documentationExampleHelloThereYou() throws {
        let filter = StripNewlinesFilter()
        try validateEvaluation(
            of: "hello there\nyou",
            by: filter,
            yields: "hello thereyou"
        )
    }
    
    // MARK: - Edge Cases
    
    @Test("Empty string")
    func emptyString() throws {
        let filter = StripNewlinesFilter()
        try validateEvaluation(
            of: "",
            by: filter,
            yields: ""
        )
    }
    
    @Test("String with only newlines")
    func onlyNewlines() throws {
        let filter = StripNewlinesFilter()
        try validateEvaluation(
            of: "\n\n\n",
            by: filter,
            yields: ""
        )
    }
    
    @Test("String with only mixed newlines")
    func onlyMixedNewlines() throws {
        let filter = StripNewlinesFilter()
        try validateEvaluation(
            of: "\r\n\n\r\r\n",
            by: filter,
            yields: ""
        )
    }
    
    @Test("String without newlines")
    func noNewlines() throws {
        let filter = StripNewlinesFilter()
        try validateEvaluation(
            of: "No newlines here!",
            by: filter,
            yields: "No newlines here!"
        )
    }
    
    @Test("Multiple consecutive newlines")
    func multipleConsecutiveNewlines() throws {
        let filter = StripNewlinesFilter()
        try validateEvaluation(
            of: "Line one\n\n\nLine two",
            by: filter,
            yields: "Line oneLine two"
        )
    }
    
    @Test("Newlines at beginning and end")
    func newlinesAtBeginningAndEnd() throws {
        let filter = StripNewlinesFilter()
        try validateEvaluation(
            of: "\n\nHello World\n\n",
            by: filter,
            yields: "Hello World"
        )
    }
    
    // MARK: - Multi-line String Tests
    
    @Test("Multi-line string with capture tag example")
    func multiLineStringCapture() throws {
        let filter = StripNewlinesFilter()
        let input = """
        Hello
        there
        """
        try validateEvaluation(
            of: input,
            by: filter,
            yields: "Hellothere"
        )
    }
    
    @Test("Complex multi-line text")
    func complexMultiLineText() throws {
        let filter = StripNewlinesFilter()
        let input = """
        First paragraph
        with multiple lines.
        
        Second paragraph
        after blank line.
        """
        try validateEvaluation(
            of: input,
            by: filter,
            yields: "First paragraphwith multiple lines.Second paragraphafter blank line."
        )
    }
    
    // MARK: - Non-String Input Tests
    
    @Test("Integer input")
    func integerInput() throws {
        let filter = StripNewlinesFilter()
        try validateEvaluation(
            of: Token.Value.integer(5),
            by: filter,
            yields: Token.Value.integer(5)
        )
    }
    
    @Test("Decimal input")
    func decimalInput() throws {
        let filter = StripNewlinesFilter()
        try validateEvaluation(
            of: Token.Value.decimal(3.14),
            by: filter,
            yields: Token.Value.decimal(3.14)
        )
    }
    
    @Test("Boolean true input")
    func booleanTrueInput() throws {
        let filter = StripNewlinesFilter()
        try validateEvaluation(
            of: Token.Value.bool(true),
            by: filter,
            yields: Token.Value.bool(true)
        )
    }
    
    @Test("Boolean false input")
    func booleanFalseInput() throws {
        let filter = StripNewlinesFilter()
        try validateEvaluation(
            of: Token.Value.bool(false),
            by: filter,
            yields: Token.Value.bool(false)
        )
    }
    
    @Test("Nil input")
    func nilInput() throws {
        let filter = StripNewlinesFilter()
        try validateEvaluation(
            of: Token.Value.nil,
            by: filter,
            yields: Token.Value.nil
        )
    }
    
    @Test("Array input")
    func arrayInput() throws {
        let filter = StripNewlinesFilter()
        let array = Token.Value.array([.string("hello"), .string("world")])
        try validateEvaluation(
            of: array,
            by: filter,
            yields: array
        )
    }
    
    @Test("Dictionary input")
    func dictionaryInput() throws {
        let filter = StripNewlinesFilter()
        let dict = Token.Value.dictionary(["key": .string("value")])
        try validateEvaluation(
            of: dict,
            by: filter,
            yields: dict
        )
    }
    
    @Test("Range input")
    func rangeInput() throws {
        let filter = StripNewlinesFilter()
        let range = Token.Value.range(1...5)
        try validateEvaluation(
            of: range,
            by: filter,
            yields: range
        )
    }
    
    // MARK: - Parameter Tests
    
    @Test("No parameters allowed")
    func noParametersAllowed() throws {
        let filter = StripNewlinesFilter()
        // Should work without parameters
        try validateEvaluation(
            of: "Hello\nWorld",
            with: [],
            by: filter,
            yields: "HelloWorld"
        )
    }
    
    @Test("Extra parameters ignored")
    func extraParametersIgnored() throws {
        let filter = StripNewlinesFilter()
        // Extra parameters should be ignored
        try validateEvaluation(
            of: "Hello\nWorld",
            with: [Token.Value.string("unused")],
            by: filter,
            yields: "HelloWorld"
        )
    }
    
    // MARK: - Real-world Scenarios
    
    @Test("HTML template scenario")
    func htmlTemplateScenario() throws {
        let filter = StripNewlinesFilter()
        let htmlContent = """
        <div>
            <h1>Title</h1>
            <p>Content</p>
        </div>
        """
        try validateEvaluation(
            of: htmlContent,
            by: filter,
            yields: "<div>    <h1>Title</h1>    <p>Content</p></div>"
        )
    }
    
    @Test("CSV data scenario")
    func csvDataScenario() throws {
        let filter = StripNewlinesFilter()
        let csvData = """
        Name,Age,City
        John,30,NYC
        Jane,25,LA
        """
        try validateEvaluation(
            of: csvData,
            by: filter,
            yields: "Name,Age,CityJohn,30,NYCJane,25,LA"
        )
    }
    
    @Test("JSON pretty print scenario")
    func jsonPrettyPrintScenario() throws {
        let filter = StripNewlinesFilter()
        let jsonData = """
        {
          "name": "John",
          "age": 30
        }
        """
        try validateEvaluation(
            of: jsonData,
            by: filter,
            yields: "{  \"name\": \"John\",  \"age\": 30}"
        )
    }
    
    // MARK: - Unicode and Special Cases
    
    @Test("Unicode line separators not removed")
    func unicodeLineSeparatorsNotRemoved() throws {
        let filter = StripNewlinesFilter()
        // Unicode line separator (U+2028) and paragraph separator (U+2029)
        // These should NOT be removed by strip_newlines
        try validateEvaluation(
            of: "Line one\u{2028}Line two\u{2029}Line three",
            by: filter,
            yields: "Line one\u{2028}Line two\u{2029}Line three"
        )
    }
    
    @Test("Form feed not removed")
    func formFeedNotRemoved() throws {
        let filter = StripNewlinesFilter()
        // Form feed (\f) should NOT be removed
        try validateEvaluation(
            of: "Page one\u{000C}Page two",
            by: filter,
            yields: "Page one\u{000C}Page two"
        )
    }
    
    @Test("Vertical tab not removed")
    func verticalTabNotRemoved() throws {
        let filter = StripNewlinesFilter()
        // Vertical tab (\v) should NOT be removed
        try validateEvaluation(
            of: "Line one\u{000B}Line two",
            by: filter,
            yields: "Line one\u{000B}Line two"
        )
    }
}