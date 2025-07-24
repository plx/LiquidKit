import Testing
@testable import LiquidKit

@Suite(.tags(.filter, .sortNaturalFilter))
struct SortNaturalFilterTests {
    let filter = SortNaturalFilter()
    
    // MARK: - Basic String Sorting
    
    @Test func basicStringSorting() throws {
        let input = ["zebra", "octopus", "giraffe", "Sally Snake"]
        try validateEvaluation(
            of: input,
            by: filter,
            yields: ["giraffe", "octopus", "Sally Snake", "zebra"]
        )
    }
    
    @Test func caseInsensitiveSorting() throws {
        let input = ["b", "A", "B", "a", "C"]
        let result = try filter.evaluate(token: .array(input.map { .string($0) }), parameters: [])
        
        guard case .array(let sorted) = result else {
            #expect(Bool(false), "Expected array result")
            return
        }
        
        // Convert back to strings
        let sortedStrings = sorted.compactMap { token -> String? in
            guard case .string(let s) = token else { return nil }
            return s
        }
        
        // Verify case-insensitive ordering (a/A before b/B before C)
        // The order within equal elements (a vs A, b vs B) is not guaranteed
        #expect(sortedStrings.count == 5)
        #expect(sortedStrings[0] == "a" || sortedStrings[0] == "A")
        #expect(sortedStrings[1] == "a" || sortedStrings[1] == "A")
        #expect(sortedStrings[2] == "b" || sortedStrings[2] == "B")
        #expect(sortedStrings[3] == "b" || sortedStrings[3] == "B")
        #expect(sortedStrings[4] == "C")
    }
    
    @Test func mixedCaseWords() throws {
        let input = ["ZEBRA", "apple", "Banana", "APPLE", "zebra", "banana"]
        try validateEvaluation(
            of: input,
            by: filter,
            yields: ["apple", "APPLE", "Banana", "banana", "ZEBRA", "zebra"]
        )
    }
    
    // MARK: - Number Sorting
    
    @Test func integerSorting() throws {
        let input = [30, 1, 1000, 3]
        try validateEvaluation(
            of: input,
            by: filter,
            yields: [1, 3, 30, 1000]
        )
    }
    
    @Test func decimalSorting() throws {
        let input = [3.5, 1.1, 10.0, 2.9]
        try validateEvaluation(
            of: input,
            by: filter,
            yields: [1.1, 2.9, 3.5, 10.0]
        )
    }
    
    @Test func mixedNumberTypes() throws {
        let input: [Token.Value] = [.integer(30), .decimal(1.5), .integer(2), .decimal(29.9)]
        try validateEvaluation(
            of: Token.Value.array(input),
            by: filter,
            yields: Token.Value.array([.decimal(1.5), .integer(2), .decimal(29.9), .integer(30)])
        )
    }
    
    // MARK: - Mixed Type Sorting
    
    @Test func nilValuesSortFirst() throws {
        let input: [Token.Value] = [.string("test"), .nil, .integer(5), .nil, .string("apple")]
        try validateEvaluation(
            of: Token.Value.array(input),
            by: filter,
            yields: Token.Value.array([.nil, .nil, .integer(5), .string("apple"), .string("test")])
        )
    }
    
    @Test func booleanSorting() throws {
        let input: [Token.Value] = [.bool(true), .bool(false), .bool(true), .bool(false)]
        try validateEvaluation(
            of: Token.Value.array(input),
            by: filter,
            yields: Token.Value.array([.bool(false), .bool(false), .bool(true), .bool(true)])
        )
    }
    
    @Test func mixedTypeHierarchy() throws {
        let input: [Token.Value] = [
            .string("zebra"),
            .nil,
            .bool(false),
            .integer(10),
            .bool(true),
            .decimal(5.5),
            .string("apple")
        ]
        try validateEvaluation(
            of: Token.Value.array(input),
            by: filter,
            yields: Token.Value.array([
                .nil,
                .bool(false),
                .bool(true),
                .decimal(5.5),
                .integer(10),
                .string("apple"),
                .string("zebra")
            ])
        )
    }
    
    // MARK: - Property Sorting (Expected to work like liquidjs/python-liquid)
    
    @Test func propertySorting() throws {
        // Test sorting objects by a property value
        let products: [Token.Value] = [
            .dictionary(["name": .string("Widget"), "company": .string("Zenith")]),
            .dictionary(["name": .string("Gadget"), "company": .string("Acme")]),
            .dictionary(["name": .string("Thing"), "company": .string("beta")])
        ]
        
        // Should sort by company property, case-insensitively
        try validateEvaluation(
            of: Token.Value.array(products),
            with: [.string("company")],
            by: filter,
            yields: Token.Value.array([
                .dictionary(["name": .string("Gadget"), "company": .string("Acme")]),
                .dictionary(["name": .string("Thing"), "company": .string("beta")]),
                .dictionary(["name": .string("Widget"), "company": .string("Zenith")])
            ])
        )
    }
    
    @Test func propertySortingMissingProperty() throws {
        // Test sorting when some objects don't have the property
        let items: [Token.Value] = [
            .dictionary(["name": .string("Has title"), "title": .string("Zebra")]),
            .dictionary(["name": .string("No title")]),
            .dictionary(["name": .string("Also has title"), "title": .string("Apple")])
        ]
        
        // Items without the property should sort first (as nil)
        try validateEvaluation(
            of: Token.Value.array(items),
            with: [.string("title")],
            by: filter,
            yields: Token.Value.array([
                .dictionary(["name": .string("No title")]),
                .dictionary(["name": .string("Also has title"), "title": .string("Apple")]),
                .dictionary(["name": .string("Has title"), "title": .string("Zebra")])
            ])
        )
    }
    
    // MARK: - Edge Cases
    
    @Test func emptyArray() throws {
        let input: [Token.Value] = []
        try validateEvaluation(
            of: Token.Value.array(input),
            by: filter,
            yields: Token.Value.array([])
        )
    }
    
    @Test func singleElement() throws {
        let input = ["test"]
        try validateEvaluation(
            of: input,
            by: filter,
            yields: ["test"]
        )
    }
    
    @Test func nonArrayInput() throws {
        // Non-array inputs should be returned unchanged
        try validateEvaluation(
            of: "not an array",
            by: filter,
            yields: "not an array"
        )
        
        try validateEvaluation(
            of: 42,
            by: filter,
            yields: 42
        )
        
        try validateEvaluation(
            of: Token.Value.nil,
            by: filter,
            yields: Token.Value.nil
        )
    }
    
    @Test func duplicateValues() throws {
        let input = ["apple", "banana", "apple", "cherry", "banana"]
        try validateEvaluation(
            of: input,
            by: filter,
            yields: ["apple", "apple", "banana", "banana", "cherry"]
        )
    }
    
    @Test func numericStrings() throws {
        // Test that numeric strings sort as strings, not numbers
        let input = ["10", "2", "1", "20", "100"]
        try validateEvaluation(
            of: input,
            by: filter,
            yields: ["1", "10", "100", "2", "20"] // String order, not numeric
        )
    }
    
    @Test func specialCharacters() throws {
        let input = ["#test", "@hello", "!first", "zebra", "123", "_underscore"]
        let result = try filter.evaluate(token: .array(input.map { .string($0) }), parameters: [])
        
        // Just verify it doesn't crash and returns an array
        guard case .array(let sorted) = result else {
            #expect(Bool(false), "Expected array result")
            return
        }
        #expect(sorted.count == input.count)
    }
    
    @Test func rangeValues() throws {
        // Ranges should be converted to strings for comparison
        let input: [Token.Value] = [
            .range(5...10),
            .string("apple"),
            .range(1...3),
            .string("zebra")
        ]
        
        let result = try filter.evaluate(token: .array(input), parameters: [])
        guard case .array(let sorted) = result else {
            #expect(Bool(false), "Expected array result")
            return
        }
        #expect(sorted.count == 4)
    }
}

