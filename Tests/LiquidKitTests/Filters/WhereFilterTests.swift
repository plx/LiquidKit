import Testing
@testable import LiquidKit

@Suite(.tags(.filter, .whereFilter))
struct WhereFilterTests {
    let filter = WhereFilter()
    
    // MARK: - Two-Parameter Mode (Property + Value Matching)
    
    @Test("Two-parameter mode: basic property-value matching")
    func twoParameterBasicMatching() throws {
        let products = Token.Value.array([
            .dictionary(["title": .string("Shirt"), "type": .string("clothing"), "available": .bool(true)]),
            .dictionary(["title": .string("Spatula"), "type": .string("kitchen"), "available": .bool(false)]),
            .dictionary(["title": .string("TV"), "type": .string("electronics"), "available": .bool(true)]),
            .dictionary(["title": .string("Garlic Press"), "type": .string("kitchen"), "available": .bool(true)])
        ])
        
        try validateEvaluation(
            of: products,
            with: [.string("type"), .string("kitchen")],
            by: filter,
            yields: .array([
                .dictionary(["title": .string("Spatula"), "type": .string("kitchen"), "available": .bool(false)]),
                .dictionary(["title": .string("Garlic Press"), "type": .string("kitchen"), "available": .bool(true)])
            ])
        )
    }
    
    @Test("Two-parameter mode: boolean property matching")
    func twoParameterBooleanMatching() throws {
        let products = Token.Value.array([
            .dictionary(["title": .string("Shirt"), "available": .bool(true)]),
            .dictionary(["title": .string("Spatula"), "available": .bool(false)]),
            .dictionary(["title": .string("TV"), "available": .bool(true)])
        ])
        
        try validateEvaluation(
            of: products,
            with: [.string("available"), .bool(true)],
            by: filter,
            yields: .array([
                .dictionary(["title": .string("Shirt"), "available": .bool(true)]),
                .dictionary(["title": .string("TV"), "available": .bool(true)])
            ])
        )
    }
    
    @Test("Two-parameter mode: integer property matching")
    func twoParameterIntegerMatching() throws {
        let products = Token.Value.array([
            .dictionary(["title": .string("Small Shirt"), "size": .integer(1)]),
            .dictionary(["title": .string("Medium Shirt"), "size": .integer(2)]),
            .dictionary(["title": .string("Large Shirt"), "size": .integer(3)]),
            .dictionary(["title": .string("Another Large"), "size": .integer(3)])
        ])
        
        try validateEvaluation(
            of: products,
            with: [.string("size"), .integer(3)],
            by: filter,
            yields: .array([
                .dictionary(["title": .string("Large Shirt"), "size": .integer(3)]),
                .dictionary(["title": .string("Another Large"), "size": .integer(3)])
            ])
        )
    }
    
    @Test("Two-parameter mode: decimal property matching")
    func twoParameterDecimalMatching() throws {
        let products = Token.Value.array([
            .dictionary(["title": .string("Cheap Item"), "price": .decimal(19.99)]),
            .dictionary(["title": .string("Mid Item"), "price": .decimal(29.99)]),
            .dictionary(["title": .string("Expensive Item"), "price": .decimal(39.99)]),
            .dictionary(["title": .string("Another Mid"), "price": .decimal(29.99)])
        ])
        
        try validateEvaluation(
            of: products,
            with: [.string("price"), .decimal(29.99)],
            by: filter,
            yields: .array([
                .dictionary(["title": .string("Mid Item"), "price": .decimal(29.99)]),
                .dictionary(["title": .string("Another Mid"), "price": .decimal(29.99)])
            ])
        )
    }
    
    @Test("Two-parameter mode: no matches returns empty array")
    func twoParameterNoMatches() throws {
        let products = Token.Value.array([
            .dictionary(["title": .string("Shirt"), "type": .string("clothing")]),
            .dictionary(["title": .string("TV"), "type": .string("electronics")])
        ])
        
        try validateEvaluation(
            of: products,
            with: [.string("type"), .string("kitchen")],
            by: filter,
            yields: .array([])
        )
    }
    
    @Test("Two-parameter mode: missing property excludes item")
    func twoParameterMissingPropertyExcluded() throws {
        let products = Token.Value.array([
            .dictionary(["title": .string("Complete Item"), "type": .string("kitchen")]),
            .dictionary(["title": .string("Incomplete Item")]), // Missing 'type' property
            .dictionary(["title": .string("Another Complete"), "type": .string("kitchen")])
        ])
        
        try validateEvaluation(
            of: products,
            with: [.string("type"), .string("kitchen")],
            by: filter,
            yields: .array([
                .dictionary(["title": .string("Complete Item"), "type": .string("kitchen")]),
                .dictionary(["title": .string("Another Complete"), "type": .string("kitchen")])
            ])
        )
    }
    
    // MARK: - One-Parameter Mode (Truthy Property Filtering)
    
    @Test("One-parameter mode: truthy string property")
    func oneParameterTruthyString() throws {
        let products = Token.Value.array([
            .dictionary(["title": .string("Item 1"), "description": .string("Has description")]),
            .dictionary(["title": .string("Item 2"), "description": .string("")]), // Empty string is truthy in Liquid!
            .dictionary(["title": .string("Item 3")]), // Missing property is falsy
            .dictionary(["title": .string("Item 4"), "description": .string("Another description")]),
            .dictionary(["title": .string("Item 5"), "description": .nil]) // Nil is falsy
        ])
        
        try validateEvaluation(
            of: products,
            with: [.string("description")],
            by: filter,
            yields: .array([
                .dictionary(["title": .string("Item 1"), "description": .string("Has description")]),
                .dictionary(["title": .string("Item 2"), "description": .string("")]), // Empty strings are truthy!
                .dictionary(["title": .string("Item 4"), "description": .string("Another description")])
            ])
        )
    }
    
    @Test("One-parameter mode: truthy boolean property")
    func oneParameterTruthyBoolean() throws {
        let products = Token.Value.array([
            .dictionary(["title": .string("Available Item"), "available": .bool(true)]),
            .dictionary(["title": .string("Unavailable Item"), "available": .bool(false)]),
            .dictionary(["title": .string("Missing Availability")]), // Missing property
            .dictionary(["title": .string("Another Available"), "available": .bool(true)])
        ])
        
        try validateEvaluation(
            of: products,
            with: [.string("available")],
            by: filter,
            yields: .array([
                .dictionary(["title": .string("Available Item"), "available": .bool(true)]),
                .dictionary(["title": .string("Another Available"), "available": .bool(true)])
            ])
        )
    }
    
    @Test("One-parameter mode: truthy integer property")
    func oneParameterTruthyInteger() throws {
        let products = Token.Value.array([
            .dictionary(["title": .string("Item 1"), "count": .integer(5)]), // Positive integer is truthy
            .dictionary(["title": .string("Item 2"), "count": .integer(0)]), // Zero is truthy in Liquid!
            .dictionary(["title": .string("Item 3")]), // Missing property is falsy
            .dictionary(["title": .string("Item 4"), "count": .integer(-3)]) // Negative integer is truthy
        ])
        
        try validateEvaluation(
            of: products,
            with: [.string("count")],
            by: filter,
            yields: .array([
                .dictionary(["title": .string("Item 1"), "count": .integer(5)]),
                .dictionary(["title": .string("Item 2"), "count": .integer(0)]), // Zero is truthy!
                .dictionary(["title": .string("Item 4"), "count": .integer(-3)])
            ])
        )
    }
    
    @Test("One-parameter mode: truthy decimal property")
    func oneParameterTruthyDecimal() throws {
        let products = Token.Value.array([
            .dictionary(["title": .string("Item 1"), "weight": .decimal(1.5)]), // Positive decimal is truthy
            .dictionary(["title": .string("Item 2"), "weight": .decimal(0.0)]), // Zero is truthy in Liquid!
            .dictionary(["title": .string("Item 3")]), // Missing property is falsy
            .dictionary(["title": .string("Item 4"), "weight": .decimal(-2.7)]) // Negative decimal is truthy
        ])
        
        try validateEvaluation(
            of: products,
            with: [.string("weight")],
            by: filter,
            yields: .array([
                .dictionary(["title": .string("Item 1"), "weight": .decimal(1.5)]),
                .dictionary(["title": .string("Item 2"), "weight": .decimal(0.0)]), // Zero is truthy!
                .dictionary(["title": .string("Item 4"), "weight": .decimal(-2.7)])
            ])
        )
    }
    
    @Test("One-parameter mode: truthy array property")
    func oneParameterTruthyArray() throws {
        let products = Token.Value.array([
            .dictionary(["title": .string("Item 1"), "tags": .array([.string("tag1"), .string("tag2")])]), // Non-empty array is truthy
            .dictionary(["title": .string("Item 2"), "tags": .array([])]), // Empty array is truthy in Liquid!
            .dictionary(["title": .string("Item 3")]), // Missing property is falsy
            .dictionary(["title": .string("Item 4"), "tags": .array([.string("tag3")])]) // Non-empty array is truthy
        ])
        
        try validateEvaluation(
            of: products,
            with: [.string("tags")],
            by: filter,
            yields: .array([
                .dictionary(["title": .string("Item 1"), "tags": .array([.string("tag1"), .string("tag2")])]),
                .dictionary(["title": .string("Item 2"), "tags": .array([])]), // Empty arrays are truthy!
                .dictionary(["title": .string("Item 4"), "tags": .array([.string("tag3")])])
            ])
        )
    }
    
    @Test("One-parameter mode: truthy dictionary property")
    func oneParameterTruthyDictionary() throws {
        let products = Token.Value.array([
            .dictionary(["title": .string("Item 1"), "meta": .dictionary(["key": .string("value")])]), // Non-empty dict is truthy
            .dictionary(["title": .string("Item 2"), "meta": .dictionary([:])]), // Empty dict is truthy in Liquid!
            .dictionary(["title": .string("Item 3")]), // Missing property is falsy
            .dictionary(["title": .string("Item 4"), "meta": .dictionary(["other": .string("data")])]) // Non-empty dict is truthy
        ])
        
        try validateEvaluation(
            of: products,
            with: [.string("meta")],
            by: filter,
            yields: .array([
                .dictionary(["title": .string("Item 1"), "meta": .dictionary(["key": .string("value")])]),
                .dictionary(["title": .string("Item 2"), "meta": .dictionary([:])]), // Empty dictionaries are truthy!
                .dictionary(["title": .string("Item 4"), "meta": .dictionary(["other": .string("data")])])
            ])
        )
    }
    
    @Test("One-parameter mode: all items missing property returns empty")
    func oneParameterAllMissingProperty() throws {
        let products = Token.Value.array([
            .dictionary(["title": .string("Item 1")]),
            .dictionary(["title": .string("Item 2")]),
            .dictionary(["name": .string("Item 3")]) // Different property
        ])
        
        try validateEvaluation(
            of: products,
            with: [.string("description")],
            by: filter,
            yields: .array([])
        )
    }
    
    // MARK: - Non-Array Input Handling
    
    @Test("Single dictionary with matching property-value")
    func singleDictionaryMatching() throws {
        let product = Token.Value.dictionary([
            "title": .string("Test Product"),
            "type": .string("kitchen")
        ])
        
        try validateEvaluation(
            of: product,
            with: [.string("type"), .string("kitchen")],
            by: filter,
            yields: .array([product])
        )
    }
    
    @Test("Single dictionary with non-matching property-value")
    func singleDictionaryNonMatching() throws {
        let product = Token.Value.dictionary([
            "title": .string("Test Product"),
            "type": .string("electronics")
        ])
        
        try validateEvaluation(
            of: product,
            with: [.string("type"), .string("kitchen")],
            by: filter,
            yields: .array([])
        )
    }
    
    @Test("Single dictionary with truthy property")
    func singleDictionaryTruthy() throws {
        let product = Token.Value.dictionary([
            "title": .string("Test Product"),
            "available": .bool(true)
        ])
        
        try validateEvaluation(
            of: product,
            with: [.string("available")],
            by: filter,
            yields: .array([product])
        )
    }
    
    @Test("Single dictionary with falsy property")
    func singleDictionaryFalsy() throws {
        let product = Token.Value.dictionary([
            "title": .string("Test Product"),
            "available": .bool(false)
        ])
        
        try validateEvaluation(
            of: product,
            with: [.string("available")],
            by: filter,
            yields: .array([])
        )
    }
    
    @Test("Single dictionary missing property")
    func singleDictionaryMissingProperty() throws {
        let product = Token.Value.dictionary([
            "title": .string("Test Product")
        ])
        
        try validateEvaluation(
            of: product,
            with: [.string("type"), .string("kitchen")],
            by: filter,
            yields: .array([])
        )
    }
    
    // MARK: - Edge Cases
    
    @Test("Empty array returns empty array")
    func emptyArrayReturnsEmpty() throws {
        try validateEvaluation(
            of: Token.Value.array([]),
            with: [.string("property")],
            by: filter,
            yields: .array([])
        )
    }
    
    @Test("Nil input returns empty array")
    func nilInputReturnsEmpty() throws {
        try validateEvaluation(
            of: Token.Value.nil,
            with: [.string("property")],
            by: filter,
            yields: .array([])
        )
    }
    
    @Test("No parameters returns original array")
    func noParametersReturnsOriginal() throws {
        let products = Token.Value.array([
            .dictionary(["title": .string("Item 1")]),
            .dictionary(["title": .string("Item 2")])
        ])
        
        try validateEvaluation(
            of: products,
            with: [],
            by: filter,
            yields: products
        )
    }
    
    // MARK: - Non-Dictionary Array Elements (Should be ignored/filtered out)
    
    @Test("Array with mixed dictionary and non-dictionary elements filters only dictionaries")
    func mixedArrayFiltersDictionaries() throws {
        let mixed = Token.Value.array([
            .dictionary(["title": .string("Product 1"), "type": .string("kitchen")]),
            .string("Not a dictionary"), // Should be ignored
            .dictionary(["title": .string("Product 2"), "type": .string("kitchen")]),
            .integer(42), // Should be ignored
            .dictionary(["title": .string("Product 3"), "type": .string("electronics")]),
            .array([.string("also not a dictionary")]) // Should be ignored
        ])
        
        try validateEvaluation(
            of: mixed,
            with: [.string("type"), .string("kitchen")],
            by: filter,
            yields: .array([
                .dictionary(["title": .string("Product 1"), "type": .string("kitchen")]),
                .dictionary(["title": .string("Product 2"), "type": .string("kitchen")])
            ])
        )
    }
    
    @Test("Array with only non-dictionary elements returns empty")
    func onlyNonDictionariesReturnsEmpty() throws {
        let nonDictionaries = Token.Value.array([
            .string("Not a dictionary"),
            .integer(42),
            .bool(true),
            .decimal(3.14),
            .array([.string("nested")])
        ])
        
        try validateEvaluation(
            of: nonDictionaries,
            with: [.string("property")],
            by: filter,
            yields: .array([])
        )
    }
    
    // MARK: - Non-Array, Non-Dictionary Inputs (Should return empty array)
    
    @Test("String input returns empty array")
    func stringInputReturnsEmpty() throws {
        try validateEvaluation(
            of: Token.Value.string("not an array"),
            with: [.string("property")],
            by: filter,
            yields: .array([])
        )
    }
    
    @Test("Integer input returns empty array")
    func integerInputReturnsEmpty() throws {
        try validateEvaluation(
            of: Token.Value.integer(42),
            with: [.string("property")],
            by: filter,
            yields: .array([])
        )
    }
    
    @Test("Boolean input returns empty array")
    func booleanInputReturnsEmpty() throws {
        try validateEvaluation(
            of: Token.Value.bool(true),
            with: [.string("property")],
            by: filter,
            yields: .array([])
        )
    }
    
    @Test("Decimal input returns empty array")
    func decimalInputReturnsEmpty() throws {
        try validateEvaluation(
            of: Token.Value.decimal(3.14),
            with: [.string("property")],
            by: filter,
            yields: .array([])
        )
    }
    
    @Test("Range input returns empty array")
    func rangeInputReturnsEmpty() throws {
        try validateEvaluation(
            of: Token.Value.range(1...5),
            with: [.string("property")],
            by: filter,
            yields: .array([])
        )
    }
}