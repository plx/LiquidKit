import Testing
@testable import LiquidKit

/// Test suite for the first filter to ensure spec compliance with liquidjs/python-liquid
@Suite(.tags(.filter, .firstFilter))
struct FirstFilterTests {
    
    // MARK: - Array Tests
    
    @Test("Returns first element of arrays")
    func testArrayFirst() throws {
        let filter = FirstFilter()
        
        // Basic array with strings
        try validateEvaluation(
            of: Token.Value.array([.string("a"), .string("b"), .string("c")]),
            by: filter,
            yields: "a"
        )
        
        // Array with mixed types
        try validateEvaluation(
            of: Token.Value.array([.string("hello"), .integer(42), .bool(true)]),
            by: filter,
            yields: "hello"
        )
        
        // Array with numbers
        try validateEvaluation(
            of: Token.Value.array([.integer(1), .integer(2), .integer(3)]),
            by: filter,
            yields: 1
        )
        
        // Array with decimals
        try validateEvaluation(
            of: Token.Value.array([.decimal(3.14), .decimal(2.71), .decimal(1.41)]),
            by: filter,
            yields: 3.14
        )
        
        // Array with booleans
        try validateEvaluation(
            of: Token.Value.array([.bool(false), .bool(true)]),
            by: filter,
            yields: false
        )
        
        // Array with nil as first element
        try validateEvaluation(
            of: Token.Value.array([.nil, .string("not nil")]),
            by: filter,
            yields: Token.Value.nil
        )
    }
    
    @Test("Handles empty arrays")
    func testEmptyArray() throws {
        let filter = FirstFilter()
        
        // Empty array should return nil
        try validateEvaluation(
            of: Token.Value.array([]),
            by: filter,
            yields: Token.Value.nil
        )
    }
    
    @Test("Handles single element arrays")
    func testSingleElementArray() throws {
        let filter = FirstFilter()
        
        // Single string element
        try validateEvaluation(
            of: Token.Value.array([.string("only")]),
            by: filter,
            yields: "only"
        )
        
        // Single number element
        try validateEvaluation(
            of: Token.Value.array([.integer(42)]),
            by: filter,
            yields: 42
        )
        
        // Single nil element
        try validateEvaluation(
            of: Token.Value.array([.nil]),
            by: filter,
            yields: Token.Value.nil
        )
    }
    
    @Test("Handles nested arrays")
    func testNestedArrays() throws {
        let filter = FirstFilter()
        
        // First element is an array
        let nestedArray = Token.Value.array([.string("x"), .string("y")])
        try validateEvaluation(
            of: Token.Value.array([nestedArray, .string("b")]),
            by: filter,
            yields: nestedArray
        )
    }
    
    // MARK: - String Tests
    
    @Test("Returns first character of strings")
    func testStringFirst() throws {
        let filter = FirstFilter()
        
        // Basic string
        try validateEvaluation(
            of: "hello",
            by: filter,
            yields: "h"
        )
        
        // Sentence (matching Shopify example)
        try validateEvaluation(
            of: "Ground control to Major Tom.",
            by: filter,
            yields: "G"
        )
        
        // Single character string
        try validateEvaluation(
            of: "a",
            by: filter,
            yields: "a"
        )
        
        // Number as string
        try validateEvaluation(
            of: "123",
            by: filter,
            yields: "1"
        )
        
        // Special characters
        try validateEvaluation(
            of: "!@#$%",
            by: filter,
            yields: "!"
        )
        
        // Unicode characters
        try validateEvaluation(
            of: "🎉Hello",
            by: filter,
            yields: "🎉"
        )
        
        // Accented characters
        try validateEvaluation(
            of: "Café",
            by: filter,
            yields: "C"
        )
    }
    
    @Test("Handles empty strings")
    func testEmptyString() throws {
        let filter = FirstFilter()
        
        // Empty string should return nil
        try validateEvaluation(
            of: "",
            by: filter,
            yields: Token.Value.nil
        )
    }
    
    @Test("Handles whitespace strings")
    func testWhitespaceString() throws {
        let filter = FirstFilter()
        
        // Leading space
        try validateEvaluation(
            of: " hello",
            by: filter,
            yields: " "
        )
        
        // Tab character
        try validateEvaluation(
            of: "\thello",
            by: filter,
            yields: "\t"
        )
        
        // Newline
        try validateEvaluation(
            of: "\nhello",
            by: filter,
            yields: "\n"
        )
    }
    
    // MARK: - Non-Collection Types
    
    @Test("Handles non-collection types")
    func testNonCollectionTypes() throws {
        let filter = FirstFilter()
        
        // Integer - should return nil per current implementation
        try validateEvaluation(
            of: 42,
            by: filter,
            yields: Token.Value.nil
        )
        
        // Decimal - should return nil
        try validateEvaluation(
            of: 3.14159,
            by: filter,
            yields: Token.Value.nil
        )
        
        // Boolean - should return nil
        try validateEvaluation(
            of: true,
            by: filter,
            yields: Token.Value.nil
        )
        
        try validateEvaluation(
            of: false,
            by: filter,
            yields: Token.Value.nil
        )
        
        // Nil - should return nil
        try validateEvaluation(
            of: Token.Value.nil,
            by: filter,
            yields: Token.Value.nil
        )
    }
    
    // MARK: - Dictionary/Hash Tests
    
    @Test("Handles dictionary types")
    func testDictionaryTypes() throws {
        let filter = FirstFilter()
        
        // Dictionary should return nil (not a supported collection type)
        try validateEvaluation(
            of: Token.Value.dictionary(["a": .string("1"), "b": .string("2")]),
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
    
    // MARK: - Range Tests
    
    @Test("Handles range types")
    func testRangeTypes() throws {
        let filter = FirstFilter()
        
        // Range should return nil (not a supported collection type in current implementation)
        try validateEvaluation(
            of: Token.Value.range(1...5),
            by: filter,
            yields: Token.Value.nil
        )
        
        // Larger range
        try validateEvaluation(
            of: Token.Value.range(10...100),
            by: filter,
            yields: Token.Value.nil
        )
    }
    
    // MARK: - Parameter Handling
    
    @Test("Ignores parameters")
    func testParameterHandling() throws {
        let filter = FirstFilter()
        
        // First filter should ignore any parameters passed to it
        try validateEvaluation(
            of: Token.Value.array([.string("a"), .string("b")]),
            with: [.string("ignored"), .integer(42)],
            by: filter,
            yields: "a"
        )
        
        // String with parameters
        try validateEvaluation(
            of: "hello",
            with: [.string("world")],
            by: filter,
            yields: "h"
        )
    }
    
    // MARK: - Integration Tests
    
    @Test("Works with split filter output")
    func testWithSplitFilterOutput() throws {
        let filter = FirstFilter()
        
        // Simulating the result of "Ground control to Major Tom." | split: " "
        let splitResult = Token.Value.array([
            .string("Ground"),
            .string("control"),
            .string("to"),
            .string("Major"),
            .string("Tom.")
        ])
        
        try validateEvaluation(
            of: splitResult,
            by: filter,
            yields: "Ground"
        )
    }
    
    @Test("Works with compact filter output")
    func testWithCompactFilterOutput() throws {
        let filter = FirstFilter()
        
        // Simulating the result of categories | compact
        let compactResult = Token.Value.array([.string("A"), .string("B")])
        
        try validateEvaluation(
            of: compactResult,
            by: filter,
            yields: "A"
        )
    }
    
    // MARK: - Edge Cases
    
    @Test("Handles very long arrays")
    func testLongArrays() throws {
        let filter = FirstFilter()
        
        // Create array with 1000 elements
        let elements = (0..<1000).map { Token.Value.integer($0) }
        
        try validateEvaluation(
            of: Token.Value.array(elements),
            by: filter,
            yields: 0
        )
    }
    
    @Test("Handles very long strings")
    func testLongStrings() throws {
        let filter = FirstFilter()
        
        // Create a long string starting with 'X'
        let longString = "X" + String(repeating: "y", count: 10000)
        
        try validateEvaluation(
            of: longString,
            by: filter,
            yields: "X"
        )
    }
    
    @Test("Handles arrays with complex nested structures")
    func testComplexNestedStructures() throws {
        let filter = FirstFilter()
        
        // First element is a dictionary
        let dict = Token.Value.dictionary(["key": .string("value")])
        try validateEvaluation(
            of: Token.Value.array([dict, .string("second")]),
            by: filter,
            yields: dict
        )
        
        // First element is a range
        let range = Token.Value.range(1...10)
        try validateEvaluation(
            of: Token.Value.array([range, .string("second")]),
            by: filter,
            yields: range
        )
    }
}