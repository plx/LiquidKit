import Foundation
@testable import LiquidKit
import Testing

@Suite(.tags(.filter, .escapeFilter))
struct EscapeFilterTests {
    
    // MARK: - Basic HTML Character Escaping
    
    @Test("Escapes less-than sign")
    func testEscapesLessThan() throws {
        try validateEvaluation(
            of: .string("<"),
            by: EscapeFilter(),
            yields: .string("&lt;")
        )
    }
    
    @Test("Escapes greater-than sign")
    func testEscapesGreaterThan() throws {
        try validateEvaluation(
            of: .string(">"),
            by: EscapeFilter(),
            yields: .string("&gt;")
        )
    }
    
    @Test("Escapes ampersand")
    func testEscapesAmpersand() throws {
        try validateEvaluation(
            of: .string("&"),
            by: EscapeFilter(),
            yields: .string("&amp;")
        )
    }
    
    @Test("Escapes double quotes")
    func testEscapesDoubleQuotes() throws {
        try validateEvaluation(
            of: .string("\""),
            by: EscapeFilter(),
            yields: .string("&quot;")
        )
    }
    
    @Test("Escapes single quotes")
    func testEscapesSingleQuotes() throws {
        try validateEvaluation(
            of: .string("'"),
            by: EscapeFilter(),
            yields: .string("&#39;")  // Note: liquidjs and python-liquid use &#39;, not &apos;
        )
    }
    
    // MARK: - Complex String Escaping
    
    @Test("Escapes HTML tags")
    func testEscapesHtmlTags() throws {
        try validateEvaluation(
            of: .string("<p>Hello</p>"),
            by: EscapeFilter(),
            yields: .string("&lt;p&gt;Hello&lt;/p&gt;")
        )
    }
    
    @Test("Escapes mixed content")
    func testEscapesMixedContent() throws {
        try validateEvaluation(
            of: .string("Rock & Roll"),
            by: EscapeFilter(),
            yields: .string("Rock &amp; Roll")
        )
    }
    
    @Test("Escapes quotes in text")
    func testEscapesQuotesInText() throws {
        try validateEvaluation(
            of: .string("Say \"Hello\""),
            by: EscapeFilter(),
            yields: .string("Say &quot;Hello&quot;")
        )
    }
    
    @Test("Escapes apostrophes")
    func testEscapesApostrophes() throws {
        try validateEvaluation(
            of: .string("It's a test"),
            by: EscapeFilter(),
            yields: .string("It&#39;s a test")
        )
    }
    
    @Test("Escapes all special characters")
    func testEscapesAllSpecialCharacters() throws {
        try validateEvaluation(
            of: .string("< > & \" '"),
            by: EscapeFilter(),
            yields: .string("&lt; &gt; &amp; &quot; &#39;")
        )
    }
    
    // MARK: - Documentation Examples
    
    @Test("Handles liquidjs documentation example")
    func testLiquidjsExample() throws {
        try validateEvaluation(
            of: .string("Have you read 'James & the Giant Peach'?"),
            by: EscapeFilter(),
            yields: .string("Have you read &#39;James &amp; the Giant Peach&#39;?")
        )
    }
    
    // MARK: - Edge Cases
    
    @Test("Leaves normal text unchanged")
    func testNormalTextUnchanged() throws {
        try validateEvaluation(
            of: .string("Normal text"),
            by: EscapeFilter(),
            yields: .string("Normal text")
        )
    }
    
    @Test("Does not escape forward slash")
    func testDoesNotEscapeForwardSlash() throws {
        try validateEvaluation(
            of: .string("/path/to/file"),
            by: EscapeFilter(),
            yields: .string("/path/to/file")
        )
    }
    
    @Test("Double-escapes already escaped content")
    func testDoubleEscapesAlreadyEscaped() throws {
        try validateEvaluation(
            of: .string("&lt;already escaped&gt;"),
            by: EscapeFilter(),
            yields: .string("&amp;lt;already escaped&amp;gt;")
        )
    }
    
    @Test("Handles empty string")
    func testEmptyString() throws {
        try validateEvaluation(
            of: .string(""),
            by: EscapeFilter(),
            yields: .string("")
        )
    }
    
    // MARK: - Non-String Values
    
    @Test("Converts integers to strings before escaping")
    func testInteger() throws {
        try validateEvaluation(
            of: .integer(42),
            by: EscapeFilter(),
            yields: .string("42")
        )
    }
    
    @Test("Converts decimals to strings before escaping")
    func testDecimal() throws {
        try validateEvaluation(
            of: .decimal(3.14),
            by: EscapeFilter(),
            yields: .string("3.14")
        )
    }
    
    @Test("Converts booleans to strings before escaping")
    func testBoolean() throws {
        try validateEvaluation(
            of: .bool(true),
            by: EscapeFilter(),
            yields: .string("true")
        )
        
        try validateEvaluation(
            of: .bool(false),
            by: EscapeFilter(),
            yields: .string("false")
        )
    }
    
    @Test("Handles nil values")
    func testNil() throws {
        try validateEvaluation(
            of: .nil,
            by: EscapeFilter(),
            yields: .string("")
        )
    }
    
    @Test("Converts arrays to strings before escaping")
    func testArray() throws {
        try validateEvaluation(
            of: .array([.string("<tag>"), .integer(123)]),
            by: EscapeFilter(),
            yields: .string("&lt;tag&gt;123")
        )
    }
    
    @Test("Converts dictionaries to strings before escaping")
    func testDictionary() throws {
        // Dictionaries return empty string as per Token.stringValue implementation
        // This matches the behavior of LiquidKit's Token type
        try validateEvaluation(
            of: .dictionary(["key": .string("<value>")]),
            by: EscapeFilter(),
            yields: .string("")
        )
    }
    
    // MARK: - Parameter Handling
    
    @Test("Ignores extra parameters")
    func testIgnoresExtraParameters() throws {
        try validateEvaluation(
            of: .string("<test>"),
            with: [.string("extra"), .integer(42)],
            by: EscapeFilter(),
            yields: .string("&lt;test&gt;")
        )
    }
    
    // MARK: - Special Characters Not Typically Escaped
    
    @Test("Does not escape other special characters")
    func testOtherSpecialCharacters() throws {
        let specialChars = "!@#$%^*()_+-=[]{}|;:,.<>?/~`"
        let expected = "!@#$%^*()_+-=[]{}|;:,.&lt;&gt;?/~`"
        
        try validateEvaluation(
            of: .string(specialChars),
            by: EscapeFilter(),
            yields: .string(expected)
        )
    }
    
    // MARK: - Unicode and International Characters
    
    @Test("Preserves unicode characters")
    func testUnicodeCharacters() throws {
        try validateEvaluation(
            of: .string("Hello 世界 🌍"),
            by: EscapeFilter(),
            yields: .string("Hello 世界 🌍")
        )
    }
    
    @Test("Escapes HTML in unicode text")
    func testUnicodeWithHtml() throws {
        try validateEvaluation(
            of: .string("<p>Hello 世界</p>"),
            by: EscapeFilter(),
            yields: .string("&lt;p&gt;Hello 世界&lt;/p&gt;")
        )
    }
}

