import Testing
@testable import LiquidKit

@Suite(.tags(.filter, .splitFilter))
struct SplitFilterTests {
    private let filter = SplitFilter()
    
    // MARK: - Basic String Splitting
    
    @Test("Split string with comma separator")
    func splitWithComma() throws {
        try validateEvaluation(
            of: "a,b,c",
            with: [Token.Value.string(",")],
            by: filter,
            yields: Token.Value.array([.string("a"), .string("b"), .string("c")])
        )
    }
    
    @Test("Split string with space separator")
    func splitWithSpace() throws {
        try validateEvaluation(
            of: "Hello there",
            with: [Token.Value.string(" ")],
            by: filter,
            yields: Token.Value.array([.string("Hello"), .string("there")])
        )
    }
    
    @Test("Split string with multi-character separator")
    func splitWithMultiCharSeparator() throws {
        try validateEvaluation(
            of: "John, Paul, George, Ringo",
            with: [Token.Value.string(", ")],
            by: filter,
            yields: Token.Value.array([.string("John"), .string("Paul"), .string("George"), .string("Ringo")])
        )
    }
    
    // MARK: - Empty Separator
    
    @Test("Split with empty separator splits into characters")
    func splitWithEmptySeparator() throws {
        try validateEvaluation(
            of: "Hello",
            with: [Token.Value.string("")],
            by: filter,
            yields: Token.Value.array([.string("H"), .string("e"), .string("l"), .string("l"), .string("o")])
        )
    }
    
    @Test("Split with nil separator should split into characters")
    func splitWithNilSeparator() throws {
        // Based on Python Liquid behavior: undefined separator splits by character
        try validateEvaluation(
            of: "Hi",
            with: [Token.Value.nil],
            by: filter,
            yields: Token.Value.array([.string("H"), .string("i")])
        )
    }
    
    // MARK: - No Separator Parameter
    
    @Test("Split without separator parameter should split into characters")
    func splitWithoutSeparator() throws {
        // Based on Python Liquid behavior: missing separator splits by character
        try validateEvaluation(
            of: "abc",
            with: [],
            by: filter,
            yields: Token.Value.array([.string("a"), .string("b"), .string("c")])
        )
    }
    
    // MARK: - Edge Cases with Separators
    
    @Test("Split string that doesn't contain separator")
    func splitWithNonExistentSeparator() throws {
        try validateEvaluation(
            of: "no-delimiter",
            with: [Token.Value.string(",")],
            by: filter,
            yields: Token.Value.array([.string("no-delimiter")])
        )
    }
    
    @Test("Split string with consecutive separators")
    func splitWithConsecutiveSeparators() throws {
        try validateEvaluation(
            of: "hello##there",
            with: [Token.Value.string("#")],
            by: filter,
            yields: Token.Value.array([.string("hello"), .string(""), .string("there")])
        )
    }
    
    @Test("Split string starting with separator")
    func splitStartingWithSeparator() throws {
        try validateEvaluation(
            of: "#start",
            with: [Token.Value.string("#")],
            by: filter,
            yields: Token.Value.array([.string(""), .string("start")])
        )
    }
    
    @Test("Split string ending with separator")
    func splitEndingWithSeparator() throws {
        try validateEvaluation(
            of: "end#",
            with: [Token.Value.string("#")],
            by: filter,
            yields: Token.Value.array([.string("end"), .string("")])
        )
    }
    
    @Test("Split empty string")
    func splitEmptyString() throws {
        try validateEvaluation(
            of: "",
            with: [Token.Value.string(",")],
            by: filter,
            yields: Token.Value.array([.string("")])
        )
    }
    
    @Test("Split empty string with empty separator")
    func splitEmptyStringWithEmptySeparator() throws {
        try validateEvaluation(
            of: "",
            with: [Token.Value.string("")],
            by: filter,
            yields: Token.Value.array([])
        )
    }
    
    // MARK: - Non-String Inputs
    
    @Test("Split integer input should convert to string first")
    func splitIntegerInput() throws {
        try validateEvaluation(
            of: 12345,
            with: [Token.Value.string("")],
            by: filter,
            yields: Token.Value.array([.string("1"), .string("2"), .string("3"), .string("4"), .string("5")])
        )
    }
    
    @Test("Split decimal input should convert to string first")
    func splitDecimalInput() throws {
        try validateEvaluation(
            of: 1.5,
            with: [Token.Value.string(".")],
            by: filter,
            yields: Token.Value.array([.string("1"), .string("5")])
        )
    }
    
    @Test("Split boolean input should convert to string first")
    func splitBooleanInput() throws {
        try validateEvaluation(
            of: true,
            with: [Token.Value.string("")],
            by: filter,
            yields: Token.Value.array([.string("t"), .string("r"), .string("u"), .string("e")])
        )
    }
    
    @Test("Split nil input should return nil")
    func splitNilInput() throws {
        try validateEvaluation(
            of: Token.Value.nil,
            with: [Token.Value.string(",")],
            by: filter,
            yields: Token.Value.nil
        )
    }
    
    @Test("Split array input should convert to string representation")
    func splitArrayInput() throws {
        // Arrays convert to their string representation in Liquid
        try validateEvaluation(
            of: Token.Value.array([.string("a"), .string("b")]),
            with: [Token.Value.string("")],
            by: filter,
            yields: Token.Value.array([.string("["), .string("]")])
        )
    }
    
    @Test("Split dictionary input should convert to string representation")
    func splitDictionaryInput() throws {
        // Dictionaries convert to "{}" in Liquid
        try validateEvaluation(
            of: Token.Value.dictionary(["key": .string("value")]),
            with: [Token.Value.string("")],
            by: filter,
            yields: Token.Value.array([.string("{"), .string("}")])
        )
    }
    
    @Test("Split range input should convert to string representation")
    func splitRangeInput() throws {
        // Ranges should convert to their string representation
        try validateEvaluation(
            of: Token.Value.range(1...3),
            with: [Token.Value.string(".")],
            by: filter,
            yields: Token.Value.array([.string("1"), .string(""), .string("3")])
        )
    }
    
    // MARK: - Non-String Separator Parameters
    
    @Test("Split with integer separator converts to string")
    func splitWithIntegerSeparator() throws {
        try validateEvaluation(
            of: "1231",
            with: [Token.Value.integer(3)],
            by: filter,
            yields: Token.Value.array([.string("12"), .string("1")])
        )
    }
    
    @Test("Split with decimal separator converts to string")
    func splitWithDecimalSeparator() throws {
        try validateEvaluation(
            of: "1.5x2.5",
            with: [Token.Value.decimal(2.5)],
            by: filter,
            yields: Token.Value.array([.string("1.5x"), .string("")])
        )
    }
    
    @Test("Split with boolean separator converts to string")
    func splitWithBooleanSeparator() throws {
        try validateEvaluation(
            of: "atrueb",
            with: [Token.Value.bool(true)],
            by: filter,
            yields: Token.Value.array([.string("a"), .string("b")])
        )
    }
    
    // MARK: - Special Cases
    
    @Test("Split string containing only separator")
    func splitStringContainingOnlySeparator() throws {
        try validateEvaluation(
            of: "#",
            with: [Token.Value.string("#")],
            by: filter,
            yields: Token.Value.array([.string(""), .string("")])
        )
    }
    
    @Test("Split string with separator that is substring of content")
    func splitWithSubstringSeparator() throws {
        try validateEvaluation(
            of: "abcabc",
            with: [Token.Value.string("ca")],
            by: filter,
            yields: Token.Value.array([.string("ab"), .string("bc")])
        )
    }
    
    @Test("Split with newline separator")
    func splitWithNewlineSeparator() throws {
        try validateEvaluation(
            of: "line1\nline2\nline3",
            with: [Token.Value.string("\n")],
            by: filter,
            yields: Token.Value.array([.string("line1"), .string("line2"), .string("line3")])
        )
    }
}