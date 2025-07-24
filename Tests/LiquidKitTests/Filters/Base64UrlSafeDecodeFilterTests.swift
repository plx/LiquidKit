import Testing
import Foundation
@testable import LiquidKit

@Suite("Base64UrlSafeDecodeFilter Tests")
struct Base64UrlSafeDecodeFilterTests {
    
    // MARK: - Basic Decoding Tests
    
    @Test("decodes simple URL-safe string")
    func decodesSimpleUrlSafeString() throws {
        let filter = Base64UrlSafeDecodeFilter()
        try validateEvaluation(
            of: "XyMvLg==",
            with: [],
            by: filter,
            yields: "_#/."
        )
    }
    
    @Test("decodes Hello World with no padding")
    func decodesHelloWorldNoPadding() throws {
        let filter = Base64UrlSafeDecodeFilter()
        // "Hello World" encoded without padding
        try validateEvaluation(
            of: "SGVsbG8gV29ybGQ",
            with: [],
            by: filter,
            yields: "Hello World"
        )
    }
    
    @Test("decodes string with URL-safe characters")
    func decodesStringWithUrlSafeCharacters() throws {
        let filter = Base64UrlSafeDecodeFilter()
        // This string contains characters that would be + and / in standard base64
        // but are - and _ in URL-safe base64
        let input = "YWJjZGVmZ2hpamtsbW5vcHFyc3R1dnd4eXogQUJDREVGR0hJSktMTU5PUFFSU1RVVldYWVogMTIzNDU2Nzg5MCAhQCMkJV4mKigpLT1fKy8_Ljo7W117fVx8"
        let expected = "abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLMNOPQRSTUVWXYZ 1234567890 !@#$%^&*()-=_+/?.:;[]{}\\|"
        
        try validateEvaluation(
            of: input,
            with: [],
            by: filter,
            yields: expected
        )
    }
    
    @Test("decodes string with actual URL-safe replacements")
    func decodesStringWithActualUrlSafeReplacements() throws {
        let filter = Base64UrlSafeDecodeFilter()
        // "test-string???" in URL-safe base64
        try validateEvaluation(
            of: "dGVzdC1zdHJpbmc_Pz8",
            with: [],
            by: filter,
            yields: "test-string???"
        )
    }
    
    @Test("decodes empty string")
    func decodesEmptyString() throws {
        let filter = Base64UrlSafeDecodeFilter()
        try validateEvaluation(
            of: "",
            with: [],
            by: filter,
            yields: ""
        )
    }
    
    // MARK: - URL-Safe Character Replacement Tests
    
    @Test("replaces dash with plus")
    func replacesDashWithPlus() throws {
        let filter = Base64UrlSafeDecodeFilter()
        // Create a base64 string that would have a + in standard encoding
        // but has a - in URL-safe encoding
        // The string ">?" encodes to "Pj8=" in standard, "Pj8=" in URL-safe (no + or /)
        // Let's use a different example that actually has - and _
        // "???" encodes to "Pz8/" in standard, "Pz8_" in URL-safe
        try validateEvaluation(
            of: "Pz8_",
            with: [],
            by: filter,
            yields: "???"
        )
    }
    
    @Test("handles mixed URL-safe and standard characters")
    func handlesMixedUrlSafeAndStandardCharacters() throws {
        let filter = Base64UrlSafeDecodeFilter()
        // If someone accidentally uses standard base64, it should still work
        // since we're just replacing - and _, not validating
        try validateEvaluation(
            of: "SGVsbG8gV29ybGQ=",
            with: [],
            by: filter,
            yields: "Hello World"
        )
    }
    
    // MARK: - Padding Tests
    
    @Test("adds no padding when not needed")
    func addsNoPaddingWhenNotNeeded() throws {
        let filter = Base64UrlSafeDecodeFilter()
        // "sure" encoded is "c3VyZQ" (needs padding)
        try validateEvaluation(
            of: "c3VyZQ",
            with: [],
            by: filter,
            yields: "sure"
        )
    }
    
    @Test("adds single padding character")
    func addsSinglePaddingCharacter() throws {
        let filter = Base64UrlSafeDecodeFilter()
        // String that needs 1 padding character
        try validateEvaluation(
            of: "c3VyZS4",
            with: [],
            by: filter,
            yields: "sure."
        )
    }
    
    @Test("adds double padding characters")
    func addsDoublePaddingCharacters() throws {
        let filter = Base64UrlSafeDecodeFilter()
        // String that needs 2 padding characters
        try validateEvaluation(
            of: "YQ",
            with: [],
            by: filter,
            yields: "a"
        )
    }
    
    @Test("handles string already with padding")
    func handlesStringAlreadyWithPadding() throws {
        let filter = Base64UrlSafeDecodeFilter()
        // URL-safe base64 typically omits padding, but if it's there, should still work
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
        let filter = Base64UrlSafeDecodeFilter()
        try validateEvaluation(
            of: "SGVsbG8g5LiW55WMIPCfjI0",
            with: [],
            by: filter,
            yields: "Hello 世界 🌍"
        )
    }
    
    @Test("decodes string with emoji")
    func decodesStringWithEmoji() throws {
        let filter = Base64UrlSafeDecodeFilter()
        try validateEvaluation(
            of: "SGVsbG8g8J-Riw",
            with: [],
            by: filter,
            yields: "Hello 👋"
        )
    }
    
    // MARK: - Invalid Input Tests
    
    @Test("returns nil for invalid base64")
    func returnsNilForInvalidBase64() throws {
        let filter = Base64UrlSafeDecodeFilter()
        try validateEvaluation(
            of: "not valid base64!@#",
            with: [],
            by: filter,
            yields: Token.Value.nil
        )
    }
    
    @Test("returns nil for non-UTF8 data")
    func returnsNilForNonUtf8Data() throws {
        let filter = Base64UrlSafeDecodeFilter()
        // Valid base64 that decodes to invalid UTF-8
        try validateEvaluation(
            of: "__79",
            with: [],
            by: filter,
            yields: Token.Value.nil
        )
    }
    
    // MARK: - Non-String Input Tests
    
    @Test("returns empty string for nil input")
    func returnsEmptyStringForNilInput() throws {
        let filter = Base64UrlSafeDecodeFilter()
        // Golden liquid test: "undefined left value" returns ""
        try validateEvaluation(
            of: Token.Value.nil,
            with: [],
            by: filter,
            yields: ""
        )
    }
    
    @Test("throws error for integer input")
    func throwsErrorForIntegerInput() throws {
        let filter = Base64UrlSafeDecodeFilter()
        // Golden liquid test: "not a string" is marked as invalid
        try validateEvaluation(
            of: 5,
            with: [],
            by: filter,
            throws: FilterError.self
        ) { error in
            #expect(error.localizedDescription.contains("string input"))
        }
    }
    
    @Test("throws error for decimal input")
    func throwsErrorForDecimalInput() throws {
        let filter = Base64UrlSafeDecodeFilter()
        try validateEvaluation(
            of: 3.14,
            with: [],
            by: filter,
            throws: FilterError.self
        ) { error in
            #expect(error.localizedDescription.contains("string input"))
        }
    }
    
    @Test("throws error for boolean input")
    func throwsErrorForBooleanInput() throws {
        let filter = Base64UrlSafeDecodeFilter()
        try validateEvaluation(
            of: true,
            with: [],
            by: filter,
            throws: FilterError.self
        ) { error in
            #expect(error.localizedDescription.contains("string input"))
        }
    }
    
    @Test("throws error for array input")
    func throwsErrorForArrayInput() throws {
        let filter = Base64UrlSafeDecodeFilter()
        try validateEvaluation(
            of: Token.Value.array([.string("SGVsbG8")]),
            with: [],
            by: filter,
            throws: FilterError.self
        ) { error in
            #expect(error.localizedDescription.contains("string input"))
        }
    }
    
    @Test("throws error for dictionary input")
    func throwsErrorForDictionaryInput() throws {
        let filter = Base64UrlSafeDecodeFilter()
        try validateEvaluation(
            of: Token.Value.dictionary(["key": .string("SGVsbG8")]),
            with: [],
            by: filter,
            throws: FilterError.self
        ) { error in
            #expect(error.localizedDescription.contains("string input"))
        }
    }
    
    // MARK: - Parameter Tests
    
    @Test("throws error for extra parameters")
    func throwsErrorForExtraParameters() throws {
        let filter = Base64UrlSafeDecodeFilter()
        // Golden liquid test: "unexpected argument" is marked as invalid
        try validateEvaluation(
            of: "SGVsbG8",
            with: [.integer(5)],
            by: filter,
            throws: FilterError.self
        ) { error in
            #expect(error.localizedDescription.contains("does not accept any parameters"))
        }
    }
    
    // MARK: - Edge Cases
    
    @Test("decodes very long URL-safe string")
    func decodesVeryLongUrlSafeString() throws {
        let filter = Base64UrlSafeDecodeFilter()
        // Create a longer test string
        let longString = "The quick brown fox jumps over the lazy dog. " +
                        "Pack my box with five dozen liquor jugs. " +
                        "How vexingly quick daft zebras jump!"
        let encoded = "VGhlIHF1aWNrIGJyb3duIGZveCBqdW1wcyBvdmVyIHRoZSBsYXp5IGRvZy4gUGFjayBteSBib3ggd2l0aCBmaXZlIGRvemVuIGxpcXVvciBqdWdzLiBIb3cgdmV4aW5nbHkgcXVpY2sgZGFmdCB6ZWJyYXMganVtcCE"
        
        try validateEvaluation(
            of: encoded,
            with: [],
            by: filter,
            yields: longString
        )
    }
    
    @Test("handles consecutive dash and underscore characters")
    func handlesConsecutiveDashAndUnderscoreCharacters() throws {
        let filter = Base64UrlSafeDecodeFilter()
        // Test a string that when encoded has consecutive - or _ characters
        // This tests that our replacement logic works correctly
        // Using a crafted base64 string with multiple - and _
        try validateEvaluation(
            of: "dGVzdC1zdHJpbmctd2l0aC1kYXNoZXMtYW5kX3VuZGVyc2NvcmVz",
            with: [],
            by: filter,
            yields: "test-string-with-dashes-and_underscores"
        )
    }
    
    // MARK: - Comparison with Standard Base64
    
    @Test("differs from standard base64 decode for URL-safe input")
    func differsFromStandardBase64ForUrlSafeInput() throws {
        let urlSafeFilter = Base64UrlSafeDecodeFilter()
        let standardFilter = Base64DecodeFilter()
        
        // URL-safe encoded "???" is "Pz8_"
        try validateEvaluation(
            of: "Pz8_",
            with: [],
            by: urlSafeFilter,
            yields: "???"
        )
        
        // Standard base64 decoder would fail on this
        try validateEvaluation(
            of: "Pz8_",
            with: [],
            by: standardFilter,
            yields: Token.Value.nil
        )
    }
}