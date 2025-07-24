import Testing
@testable import LiquidKit

@Suite(.tags(.filter, .joinFilter))
struct JoinFilterTests {
    private let filter = JoinFilter()
    
    // MARK: - Basic Array Joining
    
    @Test("Join array of strings with custom separator")
    func joinStringsWithCustomSeparator() throws {
        try validateEvaluation(
            of: ["a", "b", "c"],
            with: [Token.Value.string("#")],
            by: filter,
            yields: "a#b#c"
        )
    }
    
    @Test("Join array of strings with default space separator")
    func joinStringsWithDefaultSeparator() throws {
        try validateEvaluation(
            of: ["a", "b"],
            with: [],
            by: filter,
            yields: "a b"
        )
    }
    
    @Test("Join array of integers")
    func joinIntegers() throws {
        try validateEvaluation(
            of: [1, 2, 3],
            with: [Token.Value.string("-")],
            by: filter,
            yields: "1-2-3"
        )
    }
    
    @Test("Join mixed type array")
    func joinMixedTypes() throws {
        try validateEvaluation(
            of: Token.Value.array([.string("a"), .integer(1), .bool(true)]),
            with: [Token.Value.string(", ")],
            by: filter,
            yields: "a, 1, true"
        )
    }
    
    // MARK: - Special Separators
    
    @Test("Join with empty separator")
    func joinWithEmptySeparator() throws {
        try validateEvaluation(
            of: ["H", "i"],
            with: [Token.Value.string("")],
            by: filter,
            yields: "Hi"
        )
    }
    
    @Test("Join with nil separator")
    func joinWithNilSeparator() throws {
        try validateEvaluation(
            of: ["H", "i"],
            with: [Token.Value.nil],
            by: filter,
            yields: "Hi"
        )
    }
    
    @Test("Join with multi-character separator")
    func joinWithMultiCharSeparator() throws {
        try validateEvaluation(
            of: ["one", "two", "three"],
            with: [Token.Value.string(" and ")],
            by: filter,
            yields: "one and two and three"
        )
    }
    
    // MARK: - Non-Array Inputs
    
    @Test("Join string input (passes through unchanged)")
    func joinStringInput() throws {
        try validateEvaluation(
            of: "a,b",
            with: [Token.Value.string("#")],
            by: filter,
            yields: "a,b"
        )
    }
    
    @Test("Join integer input (passes through unchanged)")
    func joinIntegerInput() throws {
        try validateEvaluation(
            of: 123,
            with: [Token.Value.string("#")],
            by: filter,
            yields: 123
        )
    }
    
    @Test("Join decimal input (passes through unchanged)")
    func joinDecimalInput() throws {
        try validateEvaluation(
            of: 45.67,
            with: [Token.Value.string("#")],
            by: filter,
            yields: 45.67
        )
    }
    
    @Test("Join boolean input (passes through unchanged)")
    func joinBooleanInput() throws {
        try validateEvaluation(
            of: true,
            with: [Token.Value.string("#")],
            by: filter,
            yields: true
        )
    }
    
    @Test("Join dictionary input (passes through unchanged)")
    func joinDictionaryInput() throws {
        let dict = Token.Value.dictionary(["key": .string("value")])
        try validateEvaluation(
            of: dict,
            with: [Token.Value.string("#")],
            by: filter,
            yields: dict
        )
    }
    
    // MARK: - Edge Cases
    
    @Test("Join empty array")
    func joinEmptyArray() throws {
        try validateEvaluation(
            of: Token.Value.array([]),
            with: [Token.Value.string("#")],
            by: filter,
            yields: ""
        )
    }
    
    @Test("Join array with nil elements")
    func joinArrayWithNilElements() throws {
        try validateEvaluation(
            of: Token.Value.array([.string("a"), .nil, .string("b")]),
            with: [Token.Value.string("-")],
            by: filter,
            yields: "a--b"
        )
    }
    
    @Test("Join nil input (passes through unchanged)")
    func joinNilInput() throws {
        try validateEvaluation(
            of: Token.Value.nil,
            with: [Token.Value.string("#")],
            by: filter,
            yields: Token.Value.nil
        )
    }
    
    @Test("Join array with single element")
    func joinSingleElement() throws {
        try validateEvaluation(
            of: ["lonely"],
            with: [Token.Value.string("#")],
            by: filter,
            yields: "lonely"
        )
    }
    
    // MARK: - Ranges
    
    @Test("Join range")
    func joinRange() throws {
        try validateEvaluation(
            of: Token.Value.range(1...5),
            with: [Token.Value.string("#")],
            by: filter,
            yields: "1#2#3#4#5"
        )
    }
    
    @Test("Join range with default separator")
    func joinRangeDefaultSeparator() throws {
        try validateEvaluation(
            of: Token.Value.range(1...3),
            with: [],
            by: filter,
            yields: "1 2 3"
        )
    }
    
    // MARK: - Array Elements String Conversion
    
    @Test("Join array with decimal elements")
    func joinDecimalElements() throws {
        try validateEvaluation(
            of: [1.5, 2.5, 3.5],
            with: [Token.Value.string(", ")],
            by: filter,
            yields: "1.5, 2.5, 3.5"
        )
    }
    
    @Test("Join array with boolean elements")
    func joinBooleanElements() throws {
        try validateEvaluation(
            of: Token.Value.array([.bool(true), .bool(false), .bool(true)]),
            with: [Token.Value.string("-")],
            by: filter,
            yields: "true-false-true"
        )
    }
    
    @Test("Join array with dictionary elements")
    func joinDictionaryElements() throws {
        // Dictionaries convert to "{}" in Liquid
        try validateEvaluation(
            of: Token.Value.array([
                .string("start"),
                .dictionary(["key": .string("value")]),
                .string("end")
            ]),
            with: [Token.Value.string("-")],
            by: filter,
            yields: "start-{}-end"
        )
    }
    
    // MARK: - Parameter Handling
    
    @Test("Join with undefined separator parameter")
    func joinWithUndefinedSeparator() throws {
        // Undefined parameters should result in empty string separator
        try validateEvaluation(
            of: ["a", "b"],
            with: [Token.Value.nil],
            by: filter,
            yields: "ab"
        )
    }
    
    @Test("Join with integer separator (converted to string)")
    func joinWithIntegerSeparator() throws {
        try validateEvaluation(
            of: ["a", "b", "c"],
            with: [Token.Value.integer(123)],
            by: filter,
            yields: "a123b123c"
        )
    }
    
    @Test("Join with decimal separator (converted to string)")
    func joinWithDecimalSeparator() throws {
        try validateEvaluation(
            of: ["x", "y"],
            with: [Token.Value.decimal(1.5)],
            by: filter,
            yields: "x1.5y"
        )
    }
}

