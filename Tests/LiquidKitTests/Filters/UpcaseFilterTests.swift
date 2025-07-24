import Testing
@testable import LiquidKit

@Suite(.tags(.filter, .upcaseFilter))
struct UpcaseFilterTests {
    
    // MARK: - String Input Tests
    
    @Test("Converts lowercase string to uppercase")
    func testLowercaseToUppercase() throws {
        try validateEvaluation(
            of: "hello",
            by: UpcaseFilter(),
            yields: "HELLO"
        )
    }
    
    @Test("Converts mixed case string to uppercase")
    func testMixedCaseToUppercase() throws {
        try validateEvaluation(
            of: "HeLLo WoRLd",
            by: UpcaseFilter(),
            yields: "HELLO WORLD"
        )
    }
    
    @Test("Leaves uppercase string unchanged")
    func testUppercaseUnchanged() throws {
        try validateEvaluation(
            of: "HELLO WORLD",
            by: UpcaseFilter(),
            yields: "HELLO WORLD"
        )
    }
    
    @Test("Handles empty string")
    func testEmptyString() throws {
        try validateEvaluation(
            of: "",
            by: UpcaseFilter(),
            yields: ""
        )
    }
    
    @Test("Handles string with special characters")
    func testSpecialCharacters() throws {
        try validateEvaluation(
            of: "hello-world_123!@#",
            by: UpcaseFilter(),
            yields: "HELLO-WORLD_123!@#"
        )
    }
    
    @Test("Handles Unicode characters")
    func testUnicodeCharacters() throws {
        try validateEvaluation(
            of: "café naïve über",
            by: UpcaseFilter(),
            yields: "CAFÉ NAÏVE ÜBER"
        )
    }
    
    @Test("Handles string with newlines and tabs")
    func testWhitespaceCharacters() throws {
        try validateEvaluation(
            of: "hello\nworld\ttab",
            by: UpcaseFilter(),
            yields: "HELLO\nWORLD\tTAB"
        )
    }
    
    // MARK: - Non-String Input Tests
    
    @Test("Converts integer to string and uppercases")
    func testIntegerInput() throws {
        try validateEvaluation(
            of: 123,
            by: UpcaseFilter(),
            yields: "123"
        )
    }
    
    @Test("Converts decimal to string and uppercases")
    func testDecimalInput() throws {
        try validateEvaluation(
            of: 45.67,
            by: UpcaseFilter(),
            yields: "45.67"
        )
    }
    
    @Test("Converts boolean true to string and uppercases")
    func testBooleanTrueInput() throws {
        try validateEvaluation(
            of: true,
            by: UpcaseFilter(),
            yields: "TRUE"
        )
    }
    
    @Test("Converts boolean false to string and uppercases")
    func testBooleanFalseInput() throws {
        try validateEvaluation(
            of: false,
            by: UpcaseFilter(),
            yields: "FALSE"
        )
    }
    
    @Test("Handles nil input")
    func testNilInput() throws {
        try validateEvaluation(
            of: Token.Value.nil,
            by: UpcaseFilter(),
            yields: ""
        )
    }
    
    // MARK: - Array Input Tests
    
    @Test("Converts array to string and uppercases")
    func testArrayInput() throws {
        try validateEvaluation(
            of: ["hello", "world"],
            by: UpcaseFilter(),
            yields: "HELLOWORLD"
        )
    }
    
    @Test("Converts mixed array to string and uppercases")
    func testMixedArrayInput() throws {
        let array: [Token.Value] = [
            .string("hello"),
            .integer(123),
            .string("world")
        ]
        try validateEvaluation(
            of: Token.Value.array(array),
            by: UpcaseFilter(),
            yields: "HELLO123WORLD"
        )
    }
    
    // MARK: - Range Input Tests
    
    @Test("Converts range to string and uppercases")
    func testRangeInput() throws {
        try validateEvaluation(
            of: 1...5,
            by: UpcaseFilter(),
            yields: "1..5"
        )
    }
    
    // MARK: - Dictionary Input Tests
    
    @Test("Handles dictionary input")
    func testDictionaryInput() throws {
        let dict: [String: Token.Value] = ["key": .string("value")]
        try validateEvaluation(
            of: Token.Value.dictionary(dict),
            by: UpcaseFilter(),
            yields: ""
        )
    }
    
    // MARK: - Parameter Tests
    
    @Test("Ignores extra parameters")
    func testIgnoresExtraParameters() throws {
        // The filter should work even if parameters are provided (they're ignored)
        try validateEvaluation(
            of: "hello",
            with: [.string("extra"), .integer(123)],
            by: UpcaseFilter(),
            yields: "HELLO"
        )
    }
    
    // MARK: - Edge Cases
    
    @Test("Handles string with only numbers")
    func testNumericString() throws {
        try validateEvaluation(
            of: "12345",
            by: UpcaseFilter(),
            yields: "12345"
        )
    }
    
    @Test("Handles string with mixed alphabets and numbers")
    func testAlphanumericString() throws {
        try validateEvaluation(
            of: "abc123def456",
            by: UpcaseFilter(),
            yields: "ABC123DEF456"
        )
    }
    
    @Test("Handles string with only special characters")
    func testSpecialCharactersOnly() throws {
        try validateEvaluation(
            of: "!@#$%^&*()",
            by: UpcaseFilter(),
            yields: "!@#$%^&*()"
        )
    }
}