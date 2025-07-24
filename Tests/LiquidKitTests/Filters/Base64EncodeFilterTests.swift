import Testing
import Foundation
@testable import LiquidKit

@Suite("Base64EncodeFilter Tests", .tags(.filter, .base64EncodeFilter))
struct Base64EncodeFilterTests {
    
    @Test("encodes simple string")
    func encodesSimpleString() throws {
        let filter = Base64EncodeFilter()
        try validateEvaluation(
            of: .string("_#/."),
            with: [],
            by: filter,
            yields: .string("XyMvLg==")
        )
    }
    
    @Test("encodes string with special characters")
    func encodesStringWithSpecialCharacters() throws {
        let filter = Base64EncodeFilter()
        let input = "abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLMNOPQRSTUVWXYZ 1234567890 !@#$%^&*()-=_+/?.:;[]{}\\|"
        let expected = "YWJjZGVmZ2hpamtsbW5vcHFyc3R1dnd4eXogQUJDREVGR0hJSktMTU5PUFFSU1RVVldYWVogMTIzNDU2Nzg5MCAhQCMkJV4mKigpLT1fKy8/Ljo7W117fVx8"
        
        try validateEvaluation(
            of: .string(input),
            with: [],
            by: filter,
            yields: .string(expected)
        )
    }
    
    @Test("encodes Hello World")
    func encodesHelloWorld() throws {
        let filter = Base64EncodeFilter()
        try validateEvaluation(
            of: .string("Hello, World!"),
            with: [],
            by: filter,
            yields: .string("SGVsbG8sIFdvcmxkIQ==")
        )
    }
    
    @Test("encodes empty string")
    func encodesEmptyString() throws {
        let filter = Base64EncodeFilter()
        try validateEvaluation(
            of: .string(""),
            with: [],
            by: filter,
            yields: .string("")
        )
    }
    
    @Test("encodes integer as string")
    func encodesIntegerAsString() throws {
        let filter = Base64EncodeFilter()
        // Number 5 should be converted to string "5" and then encoded
        try validateEvaluation(
            of: .integer(5),
            with: [],
            by: filter,
            yields: .string("NQ==")
        )
    }
    
    @Test("encodes decimal as string")
    func encodesDecimalAsString() throws {
        let filter = Base64EncodeFilter()
        // Decimal 3.14 should be converted to string "3.14" and then encoded
        try validateEvaluation(
            of: .decimal(3.14),
            with: [],
            by: filter,
            yields: .string("My4xNA==")
        )
    }
    
    @Test("encodes boolean true as string")
    func encodesBooleanTrueAsString() throws {
        let filter = Base64EncodeFilter()
        // Boolean true should be converted to string "true" and then encoded
        try validateEvaluation(
            of: .bool(true),
            with: [],
            by: filter,
            yields: .string("dHJ1ZQ==")
        )
    }
    
    @Test("encodes boolean false as string")
    func encodesBooleanFalseAsString() throws {
        let filter = Base64EncodeFilter()
        // Boolean false should be converted to string "false" and then encoded
        try validateEvaluation(
            of: .bool(false),
            with: [],
            by: filter,
            yields: .string("ZmFsc2U=")
        )
    }
    
    @Test("returns empty string for nil")
    func returnsEmptyStringForNil() throws {
        let filter = Base64EncodeFilter()
        try validateEvaluation(
            of: .nil,
            with: [],
            by: filter,
            yields: .string("")
        )
    }
    
    @Test("encodes unicode string")
    func encodesUnicodeString() throws {
        let filter = Base64EncodeFilter()
        try validateEvaluation(
            of: .string("Hello 世界 🌍"),
            with: [],
            by: filter,
            yields: .string("SGVsbG8g5LiW55WMIPCfjI0=")
        )
    }
    
    @Test("encodes array as string representation")
    func encodesArrayAsString() throws {
        let filter = Base64EncodeFilter()
        // Arrays should be converted to their string representation
        // In Liquid, arrays are displayed as concatenated values
        try validateEvaluation(
            of: .array([.string("a"), .string("b"), .string("c")]),
            with: [],
            by: filter,
            yields: .string("YWJj") // "abc" encoded
        )
    }
    
    @Test("encodes dictionary as string representation")
    func encodesDictionaryAsString() throws {
        let filter = Base64EncodeFilter()
        // Dictionaries in Liquid typically render as empty or their string representation
        // Based on Liquid behavior, dictionaries often render as empty
        try validateEvaluation(
            of: .dictionary(["key": .string("value")]),
            with: [],
            by: filter,
            yields: .string("")
        )
    }
    
    @Test("throws error with unexpected parameters")
    func throwsErrorWithUnexpectedParameters() throws {
        let filter = Base64EncodeFilter()
        #expect(throws: Error.self) {
            try filter.evaluate(
                token: .string("hello"),
                parameters: [.integer(5)]
            )
        }
    }
}