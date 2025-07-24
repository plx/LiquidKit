import Testing
@testable import LiquidKit

@Suite(.tags(.filter, .downcaseFilter))
struct DowncaseFilterTests {
    
    // MARK: - String Input Tests
    
    @Test("Converts uppercase string to lowercase")
    func testUppercaseToLowercase() throws {
        try validateEvaluation(
            of: "HELLO",
            by: DowncaseFilter(),
            yields: "hello"
        )
    }
    
    @Test("Converts mixed case string to lowercase")
    func testMixedCaseToLowercase() throws {
        try validateEvaluation(
            of: "HeLLo WoRLd",
            by: DowncaseFilter(),
            yields: "hello world"
        )
    }
    
    @Test("Leaves lowercase string unchanged")
    func testLowercaseUnchanged() throws {
        try validateEvaluation(
            of: "hello world",
            by: DowncaseFilter(),
            yields: "hello world"
        )
    }
    
    @Test("Handles empty string")
    func testEmptyString() throws {
        try validateEvaluation(
            of: "",
            by: DowncaseFilter(),
            yields: ""
        )
    }
    
    @Test("Handles string with special characters")
    func testSpecialCharacters() throws {
        try validateEvaluation(
            of: "HELLO-WORLD_123!@#",
            by: DowncaseFilter(),
            yields: "hello-world_123!@#"
        )
    }
    
    @Test("Handles Unicode characters")
    func testUnicodeCharacters() throws {
        try validateEvaluation(
            of: "CAFÉ NAÏVE ÜBER",
            by: DowncaseFilter(),
            yields: "café naïve über"
        )
    }
    
    // MARK: - Non-String Input Tests
    
    @Test("Converts integer to string and downcases")
    func testIntegerInput() throws {
        try validateEvaluation(
            of: 123,
            by: DowncaseFilter(),
            yields: "123"
        )
    }
    
    @Test("Converts decimal to string and downcases")
    func testDecimalInput() throws {
        try validateEvaluation(
            of: 45.67,
            by: DowncaseFilter(),
            yields: "45.67"
        )
    }
    
    @Test("Converts boolean true to string and downcases")
    func testBooleanTrueInput() throws {
        try validateEvaluation(
            of: true,
            by: DowncaseFilter(),
            yields: "true"
        )
    }
    
    @Test("Converts boolean false to string and downcases")
    func testBooleanFalseInput() throws {
        try validateEvaluation(
            of: false,
            by: DowncaseFilter(),
            yields: "false"
        )
    }
    
    @Test("Handles nil input")
    func testNilInput() throws {
        try validateEvaluation(
            of: Token.Value.nil,
            by: DowncaseFilter(),
            yields: ""
        )
    }
    
    // MARK: - Array Input Tests
    
    @Test("Converts array to string and downcases")
    func testArrayInput() throws {
        try validateEvaluation(
            of: ["HELLO", "WORLD"],
            by: DowncaseFilter(),
            yields: "helloworld"
        )
    }
    
    @Test("Converts mixed array to string and downcases")
    func testMixedArrayInput() throws {
        let array: [Token.Value] = [
            .string("HELLO"),
            .integer(123),
            .string("WORLD")
        ]
        try validateEvaluation(
            of: Token.Value.array(array),
            by: DowncaseFilter(),
            yields: "hello123world"
        )
    }
    
    // MARK: - Range Input Tests
    
    @Test("Converts range to string and downcases")
    func testRangeInput() throws {
        try validateEvaluation(
            of: 1...5,
            by: DowncaseFilter(),
            yields: "1..5"
        )
    }
    
    // MARK: - Dictionary Input Tests
    
    @Test("Handles dictionary input")
    func testDictionaryInput() throws {
        let dict: [String: Token.Value] = ["key": .string("VALUE")]
        try validateEvaluation(
            of: Token.Value.dictionary(dict),
            by: DowncaseFilter(),
            yields: ""
        )
    }
    
    // MARK: - Parameter Tests
    
    @Test("Ignores extra parameters")
    func testIgnoresExtraParameters() throws {
        // The filter should work even if parameters are provided (they're ignored)
        try validateEvaluation(
            of: "HELLO",
            with: [.string("extra"), .integer(123)],
            by: DowncaseFilter(),
            yields: "hello"
        )
    }
}