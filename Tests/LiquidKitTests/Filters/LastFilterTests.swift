import Testing
@testable import LiquidKit

/// Test suite for the last filter to ensure spec compliance with liquidjs/python-liquid
@Suite(.tags(.filter, .lastFilter))
struct LastFilterTests {
    
    // MARK: - Array Tests
    
    @Test("Returns last element of arrays")
    func testArrayLast() throws {
        let filter = LastFilter()
        
        // Basic array with strings
        try validateEvaluation(
            of: Token.Value.array([.string("a"), .string("b"), .string("c")]),
            by: filter,
            yields: "c"
        )
        
        // Array with mixed types
        try validateEvaluation(
            of: Token.Value.array([.string("hello"), .integer(42), .bool(true)]),
            by: filter,
            yields: true
        )
        
        // Array with numbers
        try validateEvaluation(
            of: Token.Value.array([.integer(1), .integer(2), .integer(3)]),
            by: filter,
            yields: 3
        )
        
        // Array with decimals
        try validateEvaluation(
            of: Token.Value.array([.decimal(1.5), .decimal(2.5), .decimal(3.5)]),
            by: filter,
            yields: 3.5
        )
        
        // Single element array
        try validateEvaluation(
            of: Token.Value.array([.string("only")]),
            by: filter,
            yields: "only"
        )
        
        // Array with nil values
        try validateEvaluation(
            of: Token.Value.array([.string("a"), .nil, .string("c")]),
            by: filter,
            yields: "c"
        )
        
        // Array ending with nil
        try validateEvaluation(
            of: Token.Value.array([.string("a"), .string("b"), .nil]),
            by: filter,
            yields: Token.Value.nil
        )
    }
    
    @Test("Returns nil for empty arrays")
    func testEmptyArray() throws {
        let filter = LastFilter()
        
        try validateEvaluation(
            of: Token.Value.array([]),
            by: filter,
            yields: Token.Value.nil
        )
    }
    
    // MARK: - String Tests
    
    @Test("Returns nil for strings to match python-liquid")
    func testStringBehavior() throws {
        let filter = LastFilter()
        
        // Non-empty string should return nil (matching python-liquid)
        try validateEvaluation(
            of: "hello",
            by: filter,
            yields: Token.Value.nil
        )
        
        // Single character string
        try validateEvaluation(
            of: "x",
            by: filter,
            yields: Token.Value.nil
        )
        
        // Multi-character string
        try validateEvaluation(
            of: "Ground control to Major Tom",
            by: filter,
            yields: Token.Value.nil
        )
        
        // Empty string
        try validateEvaluation(
            of: "",
            by: filter,
            yields: Token.Value.nil
        )
        
        // String with unicode
        try validateEvaluation(
            of: "Hello 👋 World",
            by: filter,
            yields: Token.Value.nil
        )
    }
    
    // MARK: - Non-Collection Type Tests
    
    @Test("Returns nil for non-collection types")
    func testNonCollectionTypes() throws {
        let filter = LastFilter()
        
        // Integer
        try validateEvaluation(
            of: 42,
            by: filter,
            yields: Token.Value.nil
        )
        
        // Decimal
        try validateEvaluation(
            of: 3.14159,
            by: filter,
            yields: Token.Value.nil
        )
        
        // Boolean true
        try validateEvaluation(
            of: true,
            by: filter,
            yields: Token.Value.nil
        )
        
        // Boolean false
        try validateEvaluation(
            of: false,
            by: filter,
            yields: Token.Value.nil
        )
        
        // Nil
        try validateEvaluation(
            of: Token.Value.nil,
            by: filter,
            yields: Token.Value.nil
        )
    }
    
    @Test("Returns nil for dictionaries")
    func testDictionaryBehavior() throws {
        let filter = LastFilter()
        
        // Dictionary (hash)
        try validateEvaluation(
            of: Token.Value.dictionary(["a": .integer(1), "b": .integer(2)]),
            by: filter,
            yields: Token.Value.nil
        )
        
        // Empty dictionary
        try validateEvaluation(
            of: Token.Value.dictionary([:]),
            by: filter,
            yields: Token.Value.nil
        )
    }
    
    @Test("Returns nil for ranges")
    func testRangeBehavior() throws {
        let filter = LastFilter()
        
        // Range
        try validateEvaluation(
            of: Token.Value.range(1...5),
            by: filter,
            yields: Token.Value.nil
        )
        
        // Single element range
        try validateEvaluation(
            of: Token.Value.range(1...1),
            by: filter,
            yields: Token.Value.nil
        )
    }
    
    // MARK: - Edge Cases
    
    @Test("Handles nested arrays correctly")
    func testNestedArrays() throws {
        let filter = LastFilter()
        
        // Array containing arrays
        let innerArray1 = Token.Value.array([.string("a"), .string("b")])
        let innerArray2 = Token.Value.array([.string("c"), .string("d")])
        
        try validateEvaluation(
            of: Token.Value.array([innerArray1, innerArray2]),
            by: filter,
            yields: innerArray2
        )
    }
    
    @Test("Ignores extra parameters")
    func testExtraParameters() throws {
        let filter = LastFilter()
        
        // Extra parameters should be ignored
        try validateEvaluation(
            of: Token.Value.array([.string("a"), .string("b"), .string("c")]),
            with: [.string("ignored"), .integer(42)],
            by: filter,
            yields: "c"
        )
    }
    
    // MARK: - Integration Tests
    
    @Test("Works with split string arrays")
    func testSplitStringIntegration() throws {
        let filter = LastFilter()
        
        // Simulating: "Ground control to Major Tom." | split: " " | last
        let splitArray = Token.Value.array([
            .string("Ground"),
            .string("control"),
            .string("to"),
            .string("Major"),
            .string("Tom.")
        ])
        
        try validateEvaluation(
            of: splitArray,
            by: filter,
            yields: "Tom."
        )
    }
}