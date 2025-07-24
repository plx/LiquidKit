import Testing
@testable import LiquidKit

/// Tests for the `url_encode` filter
@Suite(.tags(.filter, .urlEncodeFilter))
struct UrlEncodeFilterTests {
    /// System under test
    private let sut = UrlEncodeFilter()
    
    // MARK: - Basic Functionality
    
    @Test("Basic URL encoding - email address")
    func basicEmailEncoding() throws {
        try validateEvaluation(
            of: "john@liquid.com",
            by: sut,
            yields: "john%40liquid.com",
            "Email @ symbol should be encoded as %40"
        )
    }
    
    @Test("Basic URL encoding - space to plus")
    func spaceEncodingToPlus() throws {
        try validateEvaluation(
            of: "Tetsuro Takara",
            by: sut,
            yields: "Tetsuro+Takara",
            "Spaces should be encoded as +"
        )
    }
    
    @Test("Empty string remains empty")
    func emptyString() throws {
        try validateEvaluation(
            of: "",
            by: sut,
            yields: "",
            "Empty string should remain empty"
        )
    }
    
    @Test("Single space becomes plus")
    func singleSpace() throws {
        try validateEvaluation(
            of: " ",
            by: sut,
            yields: "+",
            "Single space should become +"
        )
    }
    
    // MARK: - Special Characters
    
    @Test("Exclamation mark encoding")
    func exclamationMark() throws {
        try validateEvaluation(
            of: "Hello World!",
            by: sut,
            yields: "Hello+World%21",
            "Exclamation mark should be encoded as %21"
        )
    }
    
    @Test("Equal and ampersand encoding")
    func queryStringCharacters() throws {
        try validateEvaluation(
            of: "param=value&other=test",
            by: sut,
            yields: "param%3Dvalue%26other%3Dtest",
            "= should be %3D and & should be %26"
        )
    }
    
    @Test("Common special characters")
    func commonSpecialCharacters() throws {
        try validateEvaluation(
            of: "!@#$%^&*()",
            by: sut,
            yields: "%21%40%23%24%25%5E%26%2A%28%29",
            "All special characters should be percent-encoded"
        )
    }
    
    @Test("Slash and question mark")
    func urlComponents() throws {
        try validateEvaluation(
            of: "path/to/file?query",
            by: sut,
            yields: "path%2Fto%2Ffile%3Fquery",
            "Slashes and question marks should be encoded"
        )
    }
    
    @Test("Brackets and braces")
    func bracketsAndBraces() throws {
        try validateEvaluation(
            of: "[]{}<>",
            by: sut,
            yields: "%5B%5D%7B%7D%3C%3E",
            "Brackets and braces should be encoded"
        )
    }
    
    // MARK: - Safe Characters
    
    @Test("Safe characters remain unchanged")
    func safeCharacters() throws {
        try validateEvaluation(
            of: "safe-string_123.txt~",
            by: sut,
            yields: "safe-string_123.txt~",
            "Alphanumeric, dash, underscore, period, and tilde should not be encoded"
        )
    }
    
    @Test("Alphanumeric characters")
    func alphanumeric() throws {
        try validateEvaluation(
            of: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789",
            by: sut,
            yields: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789",
            "All alphanumeric characters should remain unchanged"
        )
    }
    
    // MARK: - Unicode and International Characters
    
    @Test("UTF-8 encoding - French")
    func frenchCharacters() throws {
        try validateEvaluation(
            of: "café résumé",
            by: sut,
            yields: "caf%C3%A9+r%C3%A9sum%C3%A9",
            "French accented characters should be percent-encoded as UTF-8"
        )
    }
    
    @Test("UTF-8 encoding - Japanese")
    func japaneseCharacters() throws {
        try validateEvaluation(
            of: "こんにちは",
            by: sut,
            yields: "%E3%81%93%E3%82%93%E3%81%AB%E3%81%A1%E3%81%AF",
            "Japanese characters should be percent-encoded as UTF-8"
        )
    }
    
    @Test("UTF-8 encoding - Emoji")
    func emojiCharacters() throws {
        try validateEvaluation(
            of: "Hello 👋 World 🌍",
            by: sut,
            yields: "Hello+%F0%9F%91%8B+World+%F0%9F%8C%8D",
            "Emojis should be percent-encoded as UTF-8"
        )
    }
    
    // MARK: - Edge Cases
    
    @Test("Multiple consecutive spaces")
    func multipleSpaces() throws {
        try validateEvaluation(
            of: "a   b",
            by: sut,
            yields: "a+++b",
            "Multiple spaces should each become +"
        )
    }
    
    @Test("Percent character encoding")
    func percentCharacter() throws {
        try validateEvaluation(
            of: "100%",
            by: sut,
            yields: "100%25",
            "Percent sign should be encoded as %25"
        )
    }
    
    @Test("Plus character encoding")
    func plusCharacter() throws {
        try validateEvaluation(
            of: "1+1=2",
            by: sut,
            yields: "1%2B1%3D2",
            "Plus sign should be encoded as %2B"
        )
    }
    
    @Test("Already encoded string")
    func alreadyEncoded() throws {
        try validateEvaluation(
            of: "already%20encoded",
            by: sut,
            yields: "already%2520encoded",
            "Percent in already encoded strings should be double-encoded"
        )
    }
    
    // MARK: - Non-String Input
    
    @Test("Non-string input - integer")
    func integerInput() throws {
        try validateEvaluation(
            of: Token.Value.integer(42),
            by: sut,
            yields: Token.Value.integer(42),
            "Integer should be returned unchanged"
        )
    }
    
    @Test("Non-string input - decimal")
    func decimalInput() throws {
        try validateEvaluation(
            of: Token.Value.decimal(3.14),
            by: sut,
            yields: Token.Value.decimal(3.14),
            "Decimal should be returned unchanged"
        )
    }
    
    @Test("Non-string input - boolean")
    func booleanInput() throws {
        try validateEvaluation(
            of: Token.Value.bool(true),
            by: sut,
            yields: Token.Value.bool(true),
            "Boolean should be returned unchanged"
        )
    }
    
    @Test("Non-string input - nil")
    func nilInput() throws {
        try validateEvaluation(
            of: Token.Value.nil,
            by: sut,
            yields: Token.Value.nil,
            "Nil should be returned unchanged"
        )
    }
    
    @Test("Non-string input - array")
    func arrayInput() throws {
        let array = Token.Value.array([.string("test")])
        try validateEvaluation(
            of: array,
            by: sut,
            yields: array,
            "Array should be returned unchanged"
        )
    }
    
    @Test("Non-string input - dictionary")
    func dictionaryInput() throws {
        let dict = Token.Value.dictionary(["key": .string("value")])
        try validateEvaluation(
            of: dict,
            by: sut,
            yields: dict,
            "Dictionary should be returned unchanged"
        )
    }
    
    // MARK: - Real-world Examples
    
    @Test("URL with query parameters")
    func urlWithQueryParams() throws {
        try validateEvaluation(
            of: "search=hello world&category=books&price=<20",
            by: sut,
            yields: "search%3Dhello+world%26category%3Dbooks%26price%3D%3C20",
            "Query parameters should be properly encoded"
        )
    }
    
    @Test("Form data with special values")
    func formData() throws {
        try validateEvaluation(
            of: "name=John Doe&email=john@example.com&message=Hello, World!",
            by: sut,
            yields: "name%3DJohn+Doe%26email%3Djohn%40example.com%26message%3DHello%2C+World%21",
            "Form data should be properly encoded"
        )
    }
}

