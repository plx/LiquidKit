import Foundation
import Testing
@testable import LiquidKit

@Suite(.tags(.filter, .base64UrlSafeEncodeFilter))
struct Base64UrlSafeEncodeFilterTests {
    
    // MARK: - Basic String Encoding Tests
    
    @Test("URL-safe base64 encoding of simple strings")
    func testSimpleStringEncoding() throws {
        let filter = Base64UrlSafeEncodeFilter()
        
        // Test basic strings
        try validateEvaluation(
            of: .string("Hello, World!"),
            by: filter,
            yields: .string("SGVsbG8sIFdvcmxkIQ") // No padding in URL-safe encoding
        )
        
        // Test string with characters that differ in URL-safe encoding
        try validateEvaluation(
            of: .string("_#/."),
            by: filter,
            yields: .string("XyMvLg") // No padding
        )
    }
    
    @Test("URL-safe encoding handles special characters correctly")
    func testSpecialCharacterReplacement() throws {
        let filter = Base64UrlSafeEncodeFilter()
        
        // Test input that would produce + and / in standard base64
        // The string "???" produces standard base64: "Pz8/"
        // URL-safe should be: "Pz8_" (/ replaced with _, no padding)
        try validateEvaluation(
            of: .string("???"),
            by: filter,
            yields: .string("Pz8_")
        )
        
        // Test input that would produce + in standard base64
        // The string ">?" produces standard base64: "Pj8="
        // URL-safe should be: "Pj8" (no + to replace, but padding removed)
        try validateEvaluation(
            of: .string(">?"),
            by: filter,
            yields: .string("Pj8")
        )
    }
    
    @Test("URL-safe encoding removes padding characters")
    func testPaddingRemoval() throws {
        let filter = Base64UrlSafeEncodeFilter()
        
        // Test strings that would have different amounts of padding
        // "A" -> standard: "QQ==", URL-safe: "QQ"
        try validateEvaluation(
            of: .string("A"),
            by: filter,
            yields: .string("QQ")
        )
        
        // "AB" -> standard: "QUI=", URL-safe: "QUI"
        try validateEvaluation(
            of: .string("AB"),
            by: filter,
            yields: .string("QUI")
        )
        
        // "ABC" -> standard: "QUJD", URL-safe: "QUJD" (no padding needed)
        try validateEvaluation(
            of: .string("ABC"),
            by: filter,
            yields: .string("QUJD")
        )
    }
    
    // MARK: - Non-String Input Tests
    
    @Test("URL-safe encoding handles numeric inputs")
    func testNumericInputs() throws {
        let filter = Base64UrlSafeEncodeFilter()
        
        // Integer input should be converted to string first
        try validateEvaluation(
            of: .integer(5),
            by: filter,
            yields: .string("NQ") // "5" encoded without padding
        )
        
        // Decimal input
        try validateEvaluation(
            of: .decimal(3.14),
            by: filter,
            yields: .string("My4xNA") // "3.14" encoded without padding
        )
    }
    
    @Test("URL-safe encoding handles boolean inputs")
    func testBooleanInputs() throws {
        let filter = Base64UrlSafeEncodeFilter()
        
        // true -> "true"
        try validateEvaluation(
            of: .bool(true),
            by: filter,
            yields: .string("dHJ1ZQ") // "true" encoded without padding
        )
        
        // false -> "false"
        try validateEvaluation(
            of: .bool(false),
            by: filter,
            yields: .string("ZmFsc2U") // "false" encoded without padding
        )
    }
    
    @Test("URL-safe encoding handles nil values")
    func testNilInput() throws {
        let filter = Base64UrlSafeEncodeFilter()
        
        // nil should return empty string
        try validateEvaluation(
            of: Token.Value.nil,
            by: filter,
            yields: .string("")
        )
    }
    
    @Test("URL-safe encoding handles array inputs")
    func testArrayInput() throws {
        let filter = Base64UrlSafeEncodeFilter()
        
        // Arrays are concatenated without separators in Liquid
        try validateEvaluation(
            of: .array([.string("a"), .string("b"), .string("c")]),
            by: filter,
            yields: .string("YWJj") // "abc" encoded without padding
        )
        
        // Mixed array
        try validateEvaluation(
            of: .array([.string("hello"), .integer(123)]),
            by: filter,
            yields: .string("aGVsbG8xMjM") // "hello123" encoded without padding
        )
    }
    
    @Test("URL-safe encoding handles dictionary inputs")
    func testDictionaryInput() throws {
        let filter = Base64UrlSafeEncodeFilter()
        
        // Dictionaries render as empty strings in Liquid
        try validateEvaluation(
            of: .dictionary(["key": .string("value")]),
            by: filter,
            yields: .string("")
        )
    }
    
    @Test("URL-safe encoding handles range inputs")
    func testRangeInput() throws {
        let filter = Base64UrlSafeEncodeFilter()
        
        // Ranges should render as their string representation
        try validateEvaluation(
            of: .range(1...5),
            by: filter,
            yields: .string("MS4uNQ") // "1..5" encoded without padding
        )
    }
    
    // MARK: - Edge Cases
    
    @Test("URL-safe encoding handles empty string")
    func testEmptyString() throws {
        let filter = Base64UrlSafeEncodeFilter()
        
        try validateEvaluation(
            of: .string(""),
            by: filter,
            yields: .string("")
        )
    }
    
    @Test("URL-safe encoding handles unicode characters")
    func testUnicodeCharacters() throws {
        let filter = Base64UrlSafeEncodeFilter()
        
        // Emoji
        try validateEvaluation(
            of: .string("🔥"),
            by: filter,
            yields: .string("8J-UpQ") // UTF-8 encoded emoji, URL-safe
        )
        
        // Unicode text
        try validateEvaluation(
            of: .string("Café"),
            by: filter,
            yields: .string("Q2Fmw6k") // UTF-8 encoded, no padding
        )
    }
    
    // MARK: - Parameter Handling
    
    @Test("URL-safe encoding with parameters throws error")
    func testParameterHandling() throws {
        let filter = Base64UrlSafeEncodeFilter()
        
        // The filter should not accept any parameters
        try validateEvaluation(
            of: .string("test"),
            with: [.string("extra")],
            by: filter,
            throws: TemplateSyntaxError.self
        )
    }
}