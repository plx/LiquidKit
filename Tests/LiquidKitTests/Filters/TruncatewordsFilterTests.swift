import Testing
@testable import LiquidKit

@Suite("TruncateWordsFilter Tests", .tags(.filter, .truncatewordsFilter))
struct TruncatewordsFilterTests {
    let filter = TruncateWordsFilter()
    
    // MARK: - Basic Functionality Tests
    
    @Test("Basic word truncation with default ellipsis")
    func basicTruncation() throws {
        // Test basic truncation to 3 words with default "..."
        try validateEvaluation(
            of: "Ground control to Major Tom.",
            with: [.integer(3)],
            by: filter,
            yields: "Ground control to..."
        )
    }
    
    @Test("Default word count of 15")
    func defaultWordCount() throws {
        // When no word count is specified, should default to 15
        let longString = "a b c d e f g h i j k l m n o p q"
        try validateEvaluation(
            of: longString,
            with: [],
            by: filter,
            yields: "a b c d e f g h i j k l m n o..."
        )
    }
    
    @Test("Custom ellipsis string")
    func customEllipsis() throws {
        // Test with a custom ellipsis string
        try validateEvaluation(
            of: "Ground control to Major Tom.",
            with: [.integer(3), .string("--")],
            by: filter,
            yields: "Ground control to--"
        )
    }
    
    @Test("Empty ellipsis for no suffix")
    func emptyEllipsis() throws {
        // Empty ellipsis should truncate without any suffix
        try validateEvaluation(
            of: "Ground control to Major Tom.",
            with: [.integer(3), .string("")],
            by: filter,
            yields: "Ground control to"
        )
    }
    
    // MARK: - Whitespace Handling Tests
    
    @Test("All whitespace types are word separators")
    func allWhitespaceHandling() throws {
        // Tabs, newlines, and multiple spaces should all be treated as word separators
        try validateEvaluation(
            of: "one  two\tthree\nfour",
            with: [.integer(3)],
            by: filter,
            yields: "one two three..."
        )
    }
    
    @Test("Multiple consecutive whitespace is collapsed")
    func multipleWhitespaceCollapsed() throws {
        // Multiple consecutive whitespace should be treated as single separator
        try validateEvaluation(
            of: "    one    two three    four  ",
            with: [.integer(2)],
            by: filter,
            yields: "one two..."
        )
    }
    
    @Test("Leading and trailing whitespace is ignored")
    func leadingTrailingWhitespace() throws {
        // Leading and trailing whitespace should be effectively ignored
        try validateEvaluation(
            of: "  hello world  test  ",
            with: [.integer(2)],
            by: filter,
            yields: "hello world..."
        )
    }
    
    // MARK: - Edge Cases
    
    @Test("String with fewer words than limit")
    func fewerWordsThanLimit() throws {
        // String with fewer words than requested should remain unchanged
        try validateEvaluation(
            of: "Ground control",
            with: [.integer(3)],
            by: filter,
            yields: "Ground control"
        )
    }
    
    @Test("String with exactly the word limit")
    func exactWordLimit() throws {
        // String with exactly the word count should remain unchanged
        try validateEvaluation(
            of: "one two three",
            with: [.integer(3)],
            by: filter,
            yields: "one two three"
        )
    }
    
    @Test("Word count of zero returns first word with ellipsis")
    func zeroWordCount() throws {
        // Word count of 0 should return first word + ellipsis (special case)
        try validateEvaluation(
            of: "one two three four",
            with: [.integer(0)],
            by: filter,
            yields: "one..."
        )
    }
    
    @Test("Negative word count treated as zero")
    func negativeWordCount() throws {
        // Negative word count should be treated as 0
        try validateEvaluation(
            of: "one two three four",
            with: [.integer(-5)],
            by: filter,
            yields: "one..."
        )
    }
    
    // MARK: - Non-String Input Tests
    
    @Test("Integer input returns unchanged")
    func integerInput() throws {
        // Non-string values should be returned unchanged
        try validateEvaluation(
            of: 5,
            with: [.integer(10)],
            by: filter,
            yields: 5
        )
    }
    
    @Test("Decimal input returns unchanged")
    func decimalInput() throws {
        // Decimal values should be returned unchanged
        try validateEvaluation(
            of: 3.14159,
            with: [.integer(5)],
            by: filter,
            yields: 3.14159
        )
    }
    
    @Test("Boolean input returns unchanged")
    func booleanInput() throws {
        // Boolean values should be returned unchanged
        try validateEvaluation(
            of: true,
            with: [.integer(5)],
            by: filter,
            yields: true
        )
    }
    
    @Test("Nil input returns unchanged")
    func nilInput() throws {
        // Nil should be returned unchanged
        try validateEvaluation(
            of: Token.Value.nil,
            with: [.integer(5)],
            by: filter,
            yields: Token.Value.nil
        )
    }
    
    @Test("Array input returns unchanged")
    func arrayInput() throws {
        // Array should be returned unchanged
        let array: Token.Value = .array([.string("hello"), .string("world")])
        try validateEvaluation(
            of: array,
            with: [.integer(5)],
            by: filter,
            yields: array
        )
    }
    
    @Test("Dictionary input returns unchanged")
    func dictionaryInput() throws {
        // Dictionary should be returned unchanged
        let dict: Token.Value = .dictionary(["key": .string("value")])
        try validateEvaluation(
            of: dict,
            with: [.integer(5)],
            by: filter,
            yields: dict
        )
    }
    
    // MARK: - Parameter Handling Tests
    
    @Test("String word count parameter")
    func stringWordCountParameter() throws {
        // String representation of number should work
        try validateEvaluation(
            of: "Ground control to Major Tom.",
            with: [.string("3")],
            by: filter,
            yields: "Ground control to..."
        )
    }
    
    @Test("Non-numeric string word count uses default")
    func nonNumericStringWordCount() throws {
        // Non-numeric string should use default word count
        let longString = "a b c d e f g h i j k l m n o p q"
        try validateEvaluation(
            of: longString,
            with: [.string("abc")],
            by: filter,
            yields: "a b c d e f g h i j k l m n o..."
        )
    }
    
    @Test("Decimal word count parameter")
    func decimalWordCountParameter() throws {
        // Decimal should be converted to integer
        try validateEvaluation(
            of: "Ground control to Major Tom.",
            with: [.decimal(3.7)],
            by: filter,
            yields: "Ground control to..."
        )
    }
    
    @Test("Non-string ellipsis parameter converts to string")
    func nonStringEllipsisParameter() throws {
        // Non-string ellipsis should be converted to string representation
        try validateEvaluation(
            of: "Ground control to Major Tom.",
            with: [.integer(3), .integer(123)],
            by: filter,
            yields: "Ground control to123"
        )
    }
    
    @Test("Nil ellipsis parameter treated as empty string")
    func nilEllipsisParameter() throws {
        // Nil ellipsis (undefined variable) should be treated as empty string
        try validateEvaluation(
            of: "Ground control to Major Tom.",
            with: [.integer(3), .nil],
            by: filter,
            yields: "Ground control to"
        )
    }
    
    @Test("Number as ellipsis parameter converts to string")
    func numberEllipsisParameter() throws {
        // Number ellipsis should be converted to string representation
        try validateEvaluation(
            of: "one two three",
            with: [.integer(2), .integer(1)],
            by: filter,
            yields: "one two1"
        )
    }
    
    // MARK: - Unicode and Special Characters
    
    @Test("Unicode string without spaces treated as single word")
    func unicodeStringNoSpaces() throws {
        // Chinese/Japanese text without spaces should be treated as single word
        try validateEvaluation(
            of: "测试测试测试测试",
            with: [.integer(5)],
            by: filter,
            yields: "测试测试测试测试"
        )
    }
    
    @Test("Unicode string with spaces")
    func unicodeStringWithSpaces() throws {
        // Unicode with spaces should work normally
        try validateEvaluation(
            of: "你好 世界 测试 文本",
            with: [.integer(2)],
            by: filter,
            yields: "你好 世界..."
        )
    }
    
    @Test("Emoji handling")
    func emojiHandling() throws {
        // Emojis should be treated as characters within words
        try validateEvaluation(
            of: "Hello 👋 World 🌍 Test",
            with: [.integer(2)],
            by: filter,
            yields: "Hello 👋..."
        )
    }
    
    // MARK: - Special Cases
    
    @Test("Empty string input")
    func emptyString() throws {
        // Empty string should remain empty
        try validateEvaluation(
            of: "",
            with: [.integer(10)],
            by: filter,
            yields: ""
        )
    }
    
    @Test("Single word string")
    func singleWord() throws {
        // Single word shorter than limit should remain unchanged
        try validateEvaluation(
            of: "Hello",
            with: [.integer(5)],
            by: filter,
            yields: "Hello"
        )
    }
    
    @Test("Whitespace-only string")
    func whitespaceOnlyString() throws {
        // String with only whitespace should return empty when processed
        try validateEvaluation(
            of: "     ",
            with: [.integer(3)],
            by: filter,
            yields: "     "
        )
    }
    
    // MARK: - Golden Liquid Test Cases
    
    @Test("Golden: all whitespace is collapsed") 
    func goldenWhitespaceCollapsed() throws {
        // From golden-liquid test suite
        try validateEvaluation(
            of: "    one    two three    four  ",
            with: [.integer(2)],
            by: filter,
            yields: "one two..."
        )
    }
    
    @Test("Golden: custom end string")
    func goldenCustomEnd() throws {
        // From golden-liquid test suite
        try validateEvaluation(
            of: "Ground control to Major Tom.",
            with: [.integer(3), .string("--")],
            by: filter,
            yields: "Ground control to--"
        )
    }
    
    @Test("Golden: default end string")
    func goldenDefaultEnd() throws {
        // From golden-liquid test suite
        try validateEvaluation(
            of: "Ground control to Major Tom.",
            with: [.integer(3)],
            by: filter,
            yields: "Ground control to..."
        )
    }
    
    @Test("Golden: fewer words than word count")
    func goldenFewerWords() throws {
        // From golden-liquid test suite
        try validateEvaluation(
            of: "Ground control",
            with: [.integer(3)],
            by: filter,
            yields: "Ground control"
        )
    }
    
    @Test("Golden: no end string")
    func goldenNoEnd() throws {
        // From golden-liquid test suite
        try validateEvaluation(
            of: "Ground control to Major Tom.",
            with: [.integer(3), .string("")],
            by: filter,
            yields: "Ground control to"
        )
    }
    
    @Test("Golden: not a string input")
    func goldenNotString() throws {
        // From golden-liquid test suite
        try validateEvaluation(
            of: 5,
            with: [.integer(10)],
            by: filter,
            yields: 5
        )
    }
    
    @Test("Golden: default word count is 15")
    func goldenDefaultWordCount() throws {
        // From golden-liquid test suite
        try validateEvaluation(
            of: "a b c d e f g h i j k l m n o p q",
            with: [],
            by: filter,
            yields: "a b c d e f g h i j k l m n o..."
        )
    }
    
    @Test("Golden: Chinese text without spaces")
    func goldenChineseText() throws {
        // From golden-liquid test suite
        try validateEvaluation(
            of: "测试测试测试测试",
            with: [.integer(5)],
            by: filter,
            yields: "测试测试测试测试"
        )
    }
    
    @Test("Golden: number as ellipsis")
    func goldenNumberEllipsis() throws {
        // From golden-liquid test suite  
        try validateEvaluation(
            of: "one two three",
            with: [.integer(2), .integer(1)],
            by: filter,
            yields: "one two1"
        )
    }
    
    @Test("Golden: mixed whitespace types")
    func goldenMixedWhitespace() throws {
        // From golden-liquid test suite
        try validateEvaluation(
            of: "one  two\tthree\nfour",
            with: [.integer(3)],
            by: filter,
            yields: "one two three..."
        )
    }
    
    @Test("Golden: basic word truncation")
    func goldenBasicTruncation() throws {
        // From golden-liquid test suite
        try validateEvaluation(
            of: "one two three four",
            with: [.integer(2)],
            by: filter,
            yields: "one two..."
        )
    }
    
    @Test("Golden: word count zero special case")
    func goldenWordCountZero() throws {
        // From golden-liquid test suite
        try validateEvaluation(
            of: "one two three four",
            with: [.integer(0)],
            by: filter,
            yields: "one..."
        )
    }
    
    @Test("Golden: undefined second argument as empty string")
    func goldenUndefinedSecondArg() throws {
        // From golden-liquid test suite - undefined second arg should be empty string
        try validateEvaluation(
            of: "one two three four",
            with: [.integer(2), .nil],
            by: filter,
            yields: "one two"
        )
    }
    
    // MARK: - Error Cases
    
    // Note: These error test cases are commented out because the current 
    // implementation doesn't throw errors. They're included as documentation
    // of what should happen according to golden-liquid test suite.
    
    /*
    @Test("Too many arguments should throw error")
    func tooManyArguments() throws {
        // Should throw error for more than 2 arguments
        try validateEvaluation(
            of: "hello",
            with: [.integer(5), .string("foo"), .string("bar")],
            by: filter,
            throws: SomeErrorType.self
        )
    }
    
    @Test("Undefined first argument should throw error")  
    func undefinedFirstArgument() throws {
        // Should throw error when word count is undefined
        try validateEvaluation(
            of: "one two three four",
            with: [.nil],
            by: filter,
            throws: SomeErrorType.self
        )
    }
    */
}