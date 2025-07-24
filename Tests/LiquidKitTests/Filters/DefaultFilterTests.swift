import Testing
@testable import LiquidKit

@Suite(.tags(.filter, .defaultFilter))
struct DefaultFilterTests {
    private let filter = DefaultFilter()
    
    // MARK: - Nil Value Tests
    
    @Test("Nil values should use the default")
    func testNilValue() throws {
        try validateEvaluation(
            of: Token.Value.nil,
            with: [.string("replacement")],
            by: filter,
            yields: "replacement"
        )
    }
    
    @Test("Nil with no default parameter returns nil")
    func testNilWithNoDefault() throws {
        try validateEvaluation(
            of: Token.Value.nil,
            with: [],
            by: filter,
            yields: Token.Value.nil
        )
    }
    
    // MARK: - Empty String Tests
    
    @Test("Empty strings should use the default")
    func testEmptyString() throws {
        try validateEvaluation(
            of: "",
            with: [.string("default value")],
            by: filter,
            yields: "default value"
        )
    }
    
    @Test("Whitespace-only strings should NOT use the default")
    func testWhitespaceString() throws {
        try validateEvaluation(
            of: " ",
            with: [.string("default")],
            by: filter,
            yields: " "
        )
        
        try validateEvaluation(
            of: "  \t\n  ",
            with: [.string("default")],
            by: filter,
            yields: "  \t\n  "
        )
    }
    
    @Test("Non-empty strings should pass through unchanged")
    func testNonEmptyString() throws {
        try validateEvaluation(
            of: "hello",
            with: [.string("default")],
            by: filter,
            yields: "hello"
        )
    }
    
    // MARK: - Boolean Tests
    
    @Test("False should use the default")
    func testFalseValue() throws {
        try validateEvaluation(
            of: false,
            with: [.string("default for false")],
            by: filter,
            yields: "default for false"
        )
    }
    
    @Test("True should pass through unchanged")
    func testTrueValue() throws {
        try validateEvaluation(
            of: true,
            with: [.string("default")],
            by: filter,
            yields: true
        )
    }
    
    // MARK: - Empty Array Tests
    
    @Test("Empty arrays should use the default according to Shopify spec")
    func testEmptyArray() throws {
        // According to Shopify documentation, empty arrays should trigger the default
        try validateEvaluation(
            of: Token.Value.array([]),
            with: [.string("default for empty")],
            by: filter,
            yields: "default for empty"  // Now correctly replaces empty arrays
        )
    }
    
    @Test("Non-empty arrays should pass through unchanged")
    func testNonEmptyArray() throws {
        let array = Token.Value.array([.string("item")])
        try validateEvaluation(
            of: array,
            with: [.string("default")],
            by: filter,
            yields: array
        )
    }
    
    // MARK: - Numeric Tests
    
    @Test("Zero should NOT use the default")
    func testZeroInteger() throws {
        try validateEvaluation(
            of: 0,
            with: [.string("default")],
            by: filter,
            yields: 0
        )
    }
    
    @Test("Zero decimal should NOT use the default")
    func testZeroDecimal() throws {
        try validateEvaluation(
            of: 0.0,
            with: [.string("default")],
            by: filter,
            yields: 0.0
        )
    }
    
    @Test("Positive numbers pass through unchanged")
    func testPositiveNumbers() throws {
        try validateEvaluation(
            of: 42,
            with: [.string("default")],
            by: filter,
            yields: 42
        )
        
        try validateEvaluation(
            of: 3.14,
            with: [.string("default")],
            by: filter,
            yields: 3.14
        )
    }
    
    @Test("Negative numbers pass through unchanged")
    func testNegativeNumbers() throws {
        try validateEvaluation(
            of: -5,
            with: [.string("default")],
            by: filter,
            yields: -5
        )
        
        try validateEvaluation(
            of: -2.5,
            with: [.string("default")],
            by: filter,
            yields: -2.5
        )
    }
    
    // MARK: - Dictionary Tests
    
    @Test("Empty dictionaries should pass through unchanged in current implementation")
    func testEmptyDictionary() throws {
        let emptyDict = Token.Value.dictionary([:])
        try validateEvaluation(
            of: emptyDict,
            with: [.string("default")],
            by: filter,
            yields: emptyDict
        )
    }
    
    @Test("Non-empty dictionaries pass through unchanged")
    func testNonEmptyDictionary() throws {
        let dict = Token.Value.dictionary(["key": .string("value")])
        try validateEvaluation(
            of: dict,
            with: [.string("default")],
            by: filter,
            yields: dict
        )
    }
    
    // MARK: - Range Tests
    
    @Test("Ranges pass through unchanged")
    func testRange() throws {
        let range = Token.Value.range(CountableClosedRange(uncheckedBounds: (1, 5)))
        try validateEvaluation(
            of: range,
            with: [.string("default")],
            by: filter,
            yields: range
        )
    }
    
    // MARK: - Default Value Type Tests
    
    @Test("Default value can be of any type")
    func testDefaultValueTypes() throws {
        // String default
        try validateEvaluation(
            of: Token.Value.nil,
            with: [.string("text")],
            by: filter,
            yields: "text"
        )
        
        // Integer default
        try validateEvaluation(
            of: Token.Value.nil,
            with: [.integer(42)],
            by: filter,
            yields: 42
        )
        
        // Boolean default
        try validateEvaluation(
            of: Token.Value.nil,
            with: [.bool(true)],
            by: filter,
            yields: true
        )
        
        // Array default
        let arrayDefault = Token.Value.array([.string("a"), .string("b")])
        try validateEvaluation(
            of: Token.Value.nil,
            with: [arrayDefault],
            by: filter,
            yields: arrayDefault
        )
    }
    
    // MARK: - Multiple Parameters Tests
    
    @Test("Only first parameter is used as default")
    func testMultipleParameters() throws {
        try validateEvaluation(
            of: Token.Value.nil,
            with: [.string("first"), .string("second"), .string("third")],
            by: filter,
            yields: "first"
        )
    }
    
    // MARK: - Edge Cases
    
    @Test("Empty string default replaces nil")
    func testEmptyStringAsDefault() throws {
        try validateEvaluation(
            of: Token.Value.nil,
            with: [.string("")],
            by: filter,
            yields: ""
        )
    }
    
    @Test("Nil default replaces nil with nil")
    func testNilAsDefault() throws {
        try validateEvaluation(
            of: Token.Value.nil,
            with: [Token.Value.nil],
            by: filter,
            yields: Token.Value.nil
        )
    }
}