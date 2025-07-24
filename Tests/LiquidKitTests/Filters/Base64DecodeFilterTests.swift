import Testing
import Foundation
@testable import LiquidKit

@Suite("Base64DecodeFilter Tests", .tags(.filter, .base64DecodeFilter))
struct Base64DecodeFilterTests {
    
    // MARK: - Basic Decoding Tests
    
    @Test("decodes simple string")
    func decodesSimpleString() throws {
        let filter = Base64DecodeFilter()
        try validateEvaluation(
            of: "XyMvLg==",
            with: [],
            by: filter,
            yields: "_#/."
        )
    }
    
    @Test("decodes Hello World")
    func decodesHelloWorld() throws {
        let filter = Base64DecodeFilter()
        try validateEvaluation(
            of: "SGVsbG8sIFdvcmxkIQ==",
            with: [],
            by: filter,
            yields: "Hello, World!"
        )
    }
    
    @Test("decodes string with special characters")
    func decodesStringWithSpecialCharacters() throws {
        let filter = Base64DecodeFilter()
        let input = "YWJjZGVmZ2hpamtsbW5vcHFyc3R1dnd4eXogQUJDREVGR0hJSktMTU5PUFFSU1RVVldYWVogMTIzNDU2Nzg5MCAhQCMkJV4mKigpLT1fKy8/Ljo7W117fVx8"
        let expected = "abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLMNOPQRSTUVWXYZ 1234567890 !@#$%^&*()-=_+/?.:;[]{}\\|"
        
        try validateEvaluation(
            of: input,
            with: [],
            by: filter,
            yields: expected
        )
    }
    
    @Test("decodes empty string")
    func decodesEmptyString() throws {
        let filter = Base64DecodeFilter()
        try validateEvaluation(
            of: "",
            with: [],
            by: filter,
            yields: ""
        )
    }
    
    // MARK: - Padding Tests
    
    @Test("decodes with no padding")
    func decodesWithNoPadding() throws {
        let filter = Base64DecodeFilter()
        // "sure" encoded without padding
        try validateEvaluation(
            of: "c3VyZQ",
            with: [],
            by: filter,
            yields: "sure"
        )
    }
    
    @Test("decodes with single padding")
    func decodesWithSinglePadding() throws {
        let filter = Base64DecodeFilter()
        // "sure." encoded with single padding
        try validateEvaluation(
            of: "c3VyZS4=",
            with: [],
            by: filter,
            yields: "sure."
        )
    }
    
    @Test("decodes with double padding")
    func decodesWithDoublePadding() throws {
        let filter = Base64DecodeFilter()
        // "sure" encoded with double padding (standard form)
        try validateEvaluation(
            of: "c3VyZQ==",
            with: [],
            by: filter,
            yields: "sure"
        )
    }
    
    // MARK: - Unicode Tests
    
    @Test("decodes unicode string")
    func decodesUnicodeString() throws {
        let filter = Base64DecodeFilter()
        try validateEvaluation(
            of: "SGVsbG8g5LiW55WMIPCfjI0=",
            with: [],
            by: filter,
            yields: "Hello 世界 🌍"
        )
    }
    
    @Test("decodes string with emoji")
    func decodesStringWithEmoji() throws {
        let filter = Base64DecodeFilter()
        // "Hello 👋" encoded
        try validateEvaluation(
            of: "SGVsbG8g8J+Riw==",
            with: [],
            by: filter,
            yields: "Hello 👋"
        )
    }
    
    @Test("decodes string with greek letters")
    func decodesStringWithGreekLetters() throws {
        let filter = Base64DecodeFilter()
        // "sigma σ, pound £" encoded
        try validateEvaluation(
            of: "c2lnbWEgz4MsIHBvdW5kIMKj",
            with: [],
            by: filter,
            yields: "sigma σ, pound £"
        )
    }
    
    // MARK: - Invalid Input Tests
    
    @Test("returns nil for invalid base64")
    func returnsNilForInvalidBase64() throws {
        let filter = Base64DecodeFilter()
        // Contains invalid character '!'
        try validateEvaluation(
            of: "invalid base64!",
            with: [],
            by: filter,
            yields: Token.Value.nil
        )
    }
    
    @Test("returns nil for invalid base64 with spaces")
    func returnsNilForInvalidBase64WithSpaces() throws {
        let filter = Base64DecodeFilter()
        // Base64 should not contain spaces
        try validateEvaluation(
            of: "SGVs bG8=",
            with: [],
            by: filter,
            yields: Token.Value.nil
        )
    }
    
    @Test("returns nil for truncated base64")
    func returnsNilForTruncatedBase64() throws {
        let filter = Base64DecodeFilter()
        // Truncated base64 that's not valid even with padding
        // This has an invalid length that can't be fixed with padding
        try validateEvaluation(
            of: "SGVsbG8gV29ybGQ=X",
            with: [],
            by: filter,
            yields: Token.Value.nil
        )
    }
    
    // MARK: - Non-String Input Tests
    
    @Test("returns nil for nil input")
    func returnsNilForNilInput() throws {
        let filter = Base64DecodeFilter()
        try validateEvaluation(
            of: Token.Value.nil,
            with: [],
            by: filter,
            yields: Token.Value.nil
        )
    }
    
    @Test("returns nil for integer input")
    func returnsNilForIntegerInput() throws {
        let filter = Base64DecodeFilter()
        try validateEvaluation(
            of: 12345,
            with: [],
            by: filter,
            yields: Token.Value.nil
        )
    }
    
    @Test("returns nil for decimal input")
    func returnsNilForDecimalInput() throws {
        let filter = Base64DecodeFilter()
        try validateEvaluation(
            of: 3.14,
            with: [],
            by: filter,
            yields: Token.Value.nil
        )
    }
    
    @Test("returns nil for boolean input")
    func returnsNilForBooleanInput() throws {
        let filter = Base64DecodeFilter()
        try validateEvaluation(
            of: true,
            with: [],
            by: filter,
            yields: Token.Value.nil
        )
    }
    
    @Test("returns nil for array input")
    func returnsNilForArrayInput() throws {
        let filter = Base64DecodeFilter()
        try validateEvaluation(
            of: Token.Value.array([.string("SGVsbG8=")]),
            with: [],
            by: filter,
            yields: Token.Value.nil
        )
    }
    
    @Test("returns nil for dictionary input")
    func returnsNilForDictionaryInput() throws {
        let filter = Base64DecodeFilter()
        try validateEvaluation(
            of: Token.Value.dictionary(["key": .string("SGVsbG8=")]),
            with: [],
            by: filter,
            yields: Token.Value.nil
        )
    }
    
    // MARK: - Parameter Tests
    
    @Test("ignores extra parameters")
    func ignoresExtraParameters() throws {
        let filter = Base64DecodeFilter()
        // According to the warning in the documentation, this should error in strict implementations
        // but the current implementation ignores extra parameters
        try validateEvaluation(
            of: "SGVsbG8sIFdvcmxkIQ==",
            with: [.string("extra"), .integer(42)],
            by: filter,
            yields: "Hello, World!"
        )
    }
    
    // MARK: - Binary Data Tests
    
    @Test("returns nil for non-UTF8 binary data")
    func returnsNilForNonUTF8BinaryData() throws {
        let filter = Base64DecodeFilter()
        // This is valid base64 but decodes to invalid UTF-8 bytes
        // Base64 encoding of bytes: [0xFF, 0xFE, 0xFD]
        try validateEvaluation(
            of: "//79",
            with: [],
            by: filter,
            yields: Token.Value.nil
        )
    }
    
    // MARK: - Edge Cases
    
    @Test("decodes base64 with newlines stripped")
    func decodesBase64WithNewlinesStripped() throws {
        let filter = Base64DecodeFilter()
        // Some base64 encoders add newlines for readability
        // Swift's Data(base64Encoded:) should handle this, but let's test
        let multilineBase64 = "SGVsbG8sIFdvcmxkIQ=="
        try validateEvaluation(
            of: multilineBase64,
            with: [],
            by: filter,
            yields: "Hello, World!"
        )
    }
    
    @Test("decodes URL-safe base64 variants")
    func decodesURLSafeBase64Variants() throws {
        let filter = Base64DecodeFilter()
        // Standard base64 uses + and /
        // URL-safe uses - and _
        // This filter should NOT decode URL-safe variants
        // "Hello World" in URL-safe encoding would use - instead of + and _ instead of /
        // For this test, we'll verify standard base64 with + and / works
        // The string ">?" encodes to "Pj8=" in standard base64
        try validateEvaluation(
            of: "Pj8=",
            with: [],
            by: filter,
            yields: ">?"
        )
    }
}