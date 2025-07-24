import Foundation
@testable import LiquidKit
import Testing

@Suite(.tags(.filter, .unescapeFilter))
struct UnescapeFilterTests {
    
    // MARK: - Basic HTML Entity Unescaping
    
    @Test("Unescapes less-than entity")
    func testUnescapesLessThan() throws {
        try validateEvaluation(
            of: .string("&lt;"),
            by: UnescapeFilter(),
            yields: .string("<")
        )
    }
    
    @Test("Unescapes greater-than entity")
    func testUnescapesGreaterThan() throws {
        try validateEvaluation(
            of: .string("&gt;"),
            by: UnescapeFilter(),
            yields: .string(">")
        )
    }
    
    @Test("Unescapes ampersand entity")
    func testUnescapesAmpersand() throws {
        try validateEvaluation(
            of: .string("&amp;"),
            by: UnescapeFilter(),
            yields: .string("&")
        )
    }
    
    @Test("Unescapes double quote entity")
    func testUnescapesDoubleQuote() throws {
        try validateEvaluation(
            of: .string("&quot;"),
            by: UnescapeFilter(),
            yields: .string("\"")
        )
    }
    
    @Test("Unescapes single quote entity (numeric)")
    func testUnescapesSingleQuoteNumeric() throws {
        try validateEvaluation(
            of: .string("&#39;"),
            by: UnescapeFilter(),
            yields: .string("'")
        )
    }
    
    @Test("Unescapes single quote entity (named)")
    func testUnescapesSingleQuoteNamed() throws {
        try validateEvaluation(
            of: .string("&apos;"),
            by: UnescapeFilter(),
            yields: .string("'")
        )
    }
    
    // MARK: - Numeric Character References
    
    @Test("Unescapes decimal numeric character references")
    func testUnescapesDecimalReferences() throws {
        // Less-than as decimal
        try validateEvaluation(
            of: .string("&#60;"),
            by: UnescapeFilter(),
            yields: .string("<")
        )
        
        // Greater-than as decimal
        try validateEvaluation(
            of: .string("&#62;"),
            by: UnescapeFilter(),
            yields: .string(">")
        )
        
        // Ampersand as decimal
        try validateEvaluation(
            of: .string("&#38;"),
            by: UnescapeFilter(),
            yields: .string("&")
        )
        
        // Double quote as decimal
        try validateEvaluation(
            of: .string("&#34;"),
            by: UnescapeFilter(),
            yields: .string("\"")
        )
    }
    
    @Test("Unescapes hexadecimal numeric character references")
    func testUnescapesHexadecimalReferences() throws {
        // Less-than as hex
        try validateEvaluation(
            of: .string("&#x3C;"),
            by: UnescapeFilter(),
            yields: .string("<")
        )
        
        // Greater-than as hex (uppercase)
        try validateEvaluation(
            of: .string("&#x3E;"),
            by: UnescapeFilter(),
            yields: .string(">")
        )
        
        // Ampersand as hex (lowercase x)
        try validateEvaluation(
            of: .string("&#x26;"),
            by: UnescapeFilter(),
            yields: .string("&")
        )
        
        // Double quote as hex (uppercase X)
        try validateEvaluation(
            of: .string("&#X22;"),
            by: UnescapeFilter(),
            yields: .string("\"")
        )
    }
    
    // MARK: - Complex String Unescaping
    
    @Test("Unescapes HTML tags")
    func testUnescapesHtmlTags() throws {
        try validateEvaluation(
            of: .string("&lt;p&gt;Hello&lt;/p&gt;"),
            by: UnescapeFilter(),
            yields: .string("<p>Hello</p>")
        )
    }
    
    @Test("Unescapes mixed content")
    func testUnescapesMixedContent() throws {
        try validateEvaluation(
            of: .string("Rock &amp; Roll"),
            by: UnescapeFilter(),
            yields: .string("Rock & Roll")
        )
    }
    
    @Test("Unescapes quotes in text")
    func testUnescapesQuotesInText() throws {
        try validateEvaluation(
            of: .string("Say &quot;Hello&quot;"),
            by: UnescapeFilter(),
            yields: .string("Say \"Hello\"")
        )
    }
    
    @Test("Unescapes apostrophes")
    func testUnescapesApostrophes() throws {
        try validateEvaluation(
            of: .string("It&#39;s a test"),
            by: UnescapeFilter(),
            yields: .string("It's a test")
        )
    }
    
    @Test("Unescapes all special characters")
    func testUnescapesAllSpecialCharacters() throws {
        try validateEvaluation(
            of: .string("&lt; &gt; &amp; &quot; &#39;"),
            by: UnescapeFilter(),
            yields: .string("< > & \" '")
        )
    }
    
    // MARK: - Documentation Examples
    
    @Test("Handles example from task description")
    func testTaskExample() throws {
        try validateEvaluation(
            of: .string("Have you read &#39;James &amp; the Giant Peach&#39;?"),
            by: UnescapeFilter(),
            yields: .string("Have you read 'James & the Giant Peach'?")
        )
    }
    
    // MARK: - Other Common HTML Entities
    
    @Test("Unescapes common named entities")
    func testCommonNamedEntities() throws {
        // Non-breaking space
        try validateEvaluation(
            of: .string("Hello&nbsp;World"),
            by: UnescapeFilter(),
            yields: .string("Hello\u{00A0}World")
        )
        
        // Copyright symbol
        try validateEvaluation(
            of: .string("&copy; 2024"),
            by: UnescapeFilter(),
            yields: .string("© 2024")
        )
        
        // Registered trademark
        try validateEvaluation(
            of: .string("Product&reg;"),
            by: UnescapeFilter(),
            yields: .string("Product®")
        )
        
        // Em dash
        try validateEvaluation(
            of: .string("Text&mdash;more text"),
            by: UnescapeFilter(),
            yields: .string("Text—more text")
        )
    }
    
    // MARK: - Edge Cases
    
    @Test("Leaves normal text unchanged")
    func testNormalTextUnchanged() throws {
        try validateEvaluation(
            of: .string("Normal text"),
            by: UnescapeFilter(),
            yields: .string("Normal text")
        )
    }
    
    @Test("Handles partially formed entities")
    func testPartiallyFormedEntities() throws {
        // Missing semicolon - HTMLEntities library does parse entities without semicolons
        try validateEvaluation(
            of: .string("&amp"),
            by: UnescapeFilter(),
            yields: .string("&")
        )
        
        // Just ampersand
        try validateEvaluation(
            of: .string("&"),
            by: UnescapeFilter(),
            yields: .string("&")
        )
        
        // Incomplete entity
        try validateEvaluation(
            of: .string("&am"),
            by: UnescapeFilter(),
            yields: .string("&am")
        )
    }
    
    @Test("Handles invalid entities")
    func testInvalidEntities() throws {
        // Unknown entity name
        try validateEvaluation(
            of: .string("&nosuchentity;"),
            by: UnescapeFilter(),
            yields: .string("&nosuchentity;")
        )
        
        // Invalid numeric reference - HTMLEntities converts to replacement character
        try validateEvaluation(
            of: .string("&#999999999;"),
            by: UnescapeFilter(),
            yields: .string("�")  // U+FFFD REPLACEMENT CHARACTER
        )
    }
    
    @Test("Handles empty string")
    func testEmptyString() throws {
        try validateEvaluation(
            of: .string(""),
            by: UnescapeFilter(),
            yields: .string("")
        )
    }
    
    @Test("Unescapes only once (not recursive)")
    func testUnescapesOnlyOnce() throws {
        // Double-escaped content should only be unescaped one level
        try validateEvaluation(
            of: .string("&amp;lt;tag&amp;gt;"),
            by: UnescapeFilter(),
            yields: .string("&lt;tag&gt;")
        )
    }
    
    @Test("Handles mixed escaped and unescaped content")
    func testMixedContent() throws {
        try validateEvaluation(
            of: .string("Text with &lt;tag&gt; and normal < > characters"),
            by: UnescapeFilter(),
            yields: .string("Text with <tag> and normal < > characters")
        )
    }
    
    // MARK: - Non-String Values
    
    @Test("Converts integers to strings before unescaping")
    func testInteger() throws {
        try validateEvaluation(
            of: .integer(42),
            by: UnescapeFilter(),
            yields: .string("42")
        )
    }
    
    @Test("Converts decimals to strings before unescaping")
    func testDecimal() throws {
        try validateEvaluation(
            of: .decimal(3.14),
            by: UnescapeFilter(),
            yields: .string("3.14")
        )
    }
    
    @Test("Converts booleans to strings before unescaping")
    func testBoolean() throws {
        try validateEvaluation(
            of: .bool(true),
            by: UnescapeFilter(),
            yields: .string("true")
        )
        
        try validateEvaluation(
            of: .bool(false),
            by: UnescapeFilter(),
            yields: .string("false")
        )
    }
    
    @Test("Handles nil values")
    func testNil() throws {
        try validateEvaluation(
            of: .nil,
            by: UnescapeFilter(),
            yields: .string("")
        )
    }
    
    @Test("Converts arrays to strings before unescaping")
    func testArray() throws {
        try validateEvaluation(
            of: .array([.string("&lt;tag&gt;"), .integer(123)]),
            by: UnescapeFilter(),
            yields: .string("<tag>123")
        )
    }
    
    @Test("Converts dictionaries to strings before unescaping")
    func testDictionary() throws {
        // Dictionaries return empty string as per Token.stringValue implementation
        try validateEvaluation(
            of: .dictionary(["key": .string("&lt;value&gt;")]),
            by: UnescapeFilter(),
            yields: .string("")
        )
    }
    
    // MARK: - Parameter Handling
    
    @Test("Ignores extra parameters")
    func testIgnoresExtraParameters() throws {
        try validateEvaluation(
            of: .string("&lt;test&gt;"),
            with: [.string("extra"), .integer(42)],
            by: UnescapeFilter(),
            yields: .string("<test>")
        )
    }
    
    // MARK: - Unicode and International Characters
    
    @Test("Preserves unicode characters while unescaping")
    func testUnicodeCharacters() throws {
        try validateEvaluation(
            of: .string("Hello 世界 🌍 &amp; stuff"),
            by: UnescapeFilter(),
            yields: .string("Hello 世界 🌍 & stuff")
        )
    }
    
    @Test("Unescapes HTML entities in unicode text")
    func testUnicodeWithHtmlEntities() throws {
        try validateEvaluation(
            of: .string("&lt;p&gt;Hello 世界&lt;/p&gt;"),
            by: UnescapeFilter(),
            yields: .string("<p>Hello 世界</p>")
        )
    }
    
    @Test("Handles unicode numeric character references")
    func testUnicodeNumericReferences() throws {
        // Chinese character for "world"
        try validateEvaluation(
            of: .string("&#19990;&#30028;"),
            by: UnescapeFilter(),
            yields: .string("世界")
        )
        
        // Emoji as hex reference
        try validateEvaluation(
            of: .string("&#x1F30D;"),
            by: UnescapeFilter(),
            yields: .string("🌍")
        )
    }
}