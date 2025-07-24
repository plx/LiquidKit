import Testing
@testable import LiquidKit

@Suite(.tags(.filter, .rejectFilter))
struct RejectFilterTests {
    
    // MARK: - Property Truthy/Falsy Tests (One Parameter)
    
    @Test("Rejects items where property is truthy")
    func rejectTruthyProperties() throws {
        let filter = RejectFilter()
        
        // Test data with various truthy/falsy values
        let products: Token.Value = .array([
            .dictionary([
                "title": .string("Product 1"),
                "available": .bool(true)
            ]),
            .dictionary([
                "title": .string("Product 2"),
                "available": .bool(false)
            ]),
            .dictionary([
                "title": .string("Product 3"),
                "available": .nil
            ]),
            .dictionary([
                "title": .string("Product 4")
                // missing "available" property
            ])
        ])
        
        // Reject items where "available" is truthy
        // Should keep Product 2 (false), Product 3 (nil), and Product 4 (missing)
        let expected: Token.Value = .array([
            .dictionary([
                "title": .string("Product 2"),
                "available": .bool(false)
            ]),
            .dictionary([
                "title": .string("Product 3"),
                "available": .nil
            ]),
            .dictionary([
                "title": .string("Product 4")
            ])
        ])
        
        try validateEvaluation(of: products, with: [.string("available")], by: filter, yields: expected)
    }
    
    @Test("Rejects items with truthy string properties")
    func rejectTruthyStringProperties() throws {
        let filter = RejectFilter()
        
        let items: Token.Value = .array([
            .dictionary(["name": .string("Item 1"), "description": .string("Has description")]),
            .dictionary(["name": .string("Item 2"), "description": .string("")]), // empty string is truthy
            .dictionary(["name": .string("Item 3"), "description": .nil]),
            .dictionary(["name": .string("Item 4")]) // missing description
        ])
        
        // Should reject items with any string value (including empty string)
        let expected: Token.Value = .array([
            .dictionary(["name": .string("Item 3"), "description": .nil]),
            .dictionary(["name": .string("Item 4")])
        ])
        
        try validateEvaluation(of: items, with: [.string("description")], by: filter, yields: expected)
    }
    
    @Test("Rejects items with truthy numeric properties")
    func rejectTruthyNumericProperties() throws {
        let filter = RejectFilter()
        
        let items: Token.Value = .array([
            .dictionary(["id": .integer(1), "count": .integer(5)]),
            .dictionary(["id": .integer(2), "count": .integer(0)]), // Note: In LiquidKit, 0 is truthy (only nil and false are falsy)
            .dictionary(["id": .integer(3), "count": .decimal(3.14)]),
            .dictionary(["id": .integer(4), "count": .nil])
        ])
        
        // In LiquidKit, all numeric values (including 0) are truthy
        // Only nil is falsy, so we should only keep the item with nil count
        let expected: Token.Value = .array([
            .dictionary(["id": .integer(4), "count": .nil])
        ])
        
        try validateEvaluation(of: items, with: [.string("count")], by: filter, yields: expected)
    }
    
    // MARK: - Property Value Matching Tests (Two Parameters)
    
    @Test("Rejects items where property equals specific value")
    func rejectByPropertyValue() throws {
        let filter = RejectFilter()
        
        let products: Token.Value = .array([
            .dictionary([
                "title": .string("Vacuum"),
                "type": .string("house")
            ]),
            .dictionary([
                "title": .string("Spatula"),
                "type": .string("kitchen")
            ]),
            .dictionary([
                "title": .string("Television"),
                "type": .string("lounge")
            ]),
            .dictionary([
                "title": .string("Garlic press"),
                "type": .string("kitchen")
            ])
        ])
        
        // Reject products where type equals "kitchen"
        // Should keep only non-kitchen products
        let expected: Token.Value = .array([
            .dictionary([
                "title": .string("Vacuum"),
                "type": .string("house")
            ]),
            .dictionary([
                "title": .string("Television"),
                "type": .string("lounge")
            ])
        ])
        
        try validateEvaluation(of: products, with: [.string("type"), .string("kitchen")], by: filter, yields: expected)
    }
    
    @Test("Rejects items with numeric property values")
    func rejectByNumericPropertyValue() throws {
        let filter = RejectFilter()
        
        let items: Token.Value = .array([
            .dictionary(["name": .string("Item A"), "priority": .integer(1)]),
            .dictionary(["name": .string("Item B"), "priority": .integer(2)]),
            .dictionary(["name": .string("Item C"), "priority": .integer(1)]),
            .dictionary(["name": .string("Item D"), "priority": .integer(3)])
        ])
        
        // Reject items where priority equals 1
        let expected: Token.Value = .array([
            .dictionary(["name": .string("Item B"), "priority": .integer(2)]),
            .dictionary(["name": .string("Item D"), "priority": .integer(3)])
        ])
        
        try validateEvaluation(of: items, with: [.string("priority"), .integer(1)], by: filter, yields: expected)
    }
    
    @Test("Keeps items without the specified property when matching value")
    func keepItemsWithoutPropertyWhenMatchingValue() throws {
        let filter = RejectFilter()
        
        let items: Token.Value = .array([
            .dictionary(["name": .string("Item 1"), "status": .string("active")]),
            .dictionary(["name": .string("Item 2"), "status": .string("inactive")]),
            .dictionary(["name": .string("Item 3")]) // missing status
        ])
        
        // When rejecting by "status" = "active", items without status should be kept
        let expected: Token.Value = .array([
            .dictionary(["name": .string("Item 2"), "status": .string("inactive")]),
            .dictionary(["name": .string("Item 3")])
        ])
        
        try validateEvaluation(of: items, with: [.string("status"), .string("active")], by: filter, yields: expected)
    }
    
    // MARK: - Simple Array Tests
    
    @Test("Rejects from simple string array")
    func rejectFromSimpleStringArray() throws {
        let filter = RejectFilter()
        
        let colors: Token.Value = .array([
            .string("red"),
            .string("blue"),
            .string("red"),
            .string("green")
        ])
        
        // Reject "red" values
        let expected: Token.Value = .array([
            .string("blue"),
            .string("green")
        ])
        
        try validateEvaluation(of: colors, with: [.string("red")], by: filter, yields: expected)
    }
    
    @Test("Rejects from simple numeric array")
    func rejectFromSimpleNumericArray() throws {
        let filter = RejectFilter()
        
        let numbers: Token.Value = .array([
            .integer(1),
            .integer(2),
            .integer(3),
            .integer(2),
            .integer(4)
        ])
        
        // Reject value 2
        let expected: Token.Value = .array([
            .integer(1),
            .integer(3),
            .integer(4)
        ])
        
        try validateEvaluation(of: numbers, with: [.integer(2)], by: filter, yields: expected)
    }
    
    @Test("Rejects from mixed type array")
    func rejectFromMixedTypeArray() throws {
        let filter = RejectFilter()
        
        let mixed: Token.Value = .array([
            .string("text"),
            .integer(42),
            .bool(true),
            .string("text"),
            .nil
        ])
        
        // Reject "text" values
        let expected: Token.Value = .array([
            .integer(42),
            .bool(true),
            .nil
        ])
        
        try validateEvaluation(of: mixed, with: [.string("text")], by: filter, yields: expected)
    }
    
    // MARK: - Edge Cases
    
    @Test("Returns empty array for nil input")
    func nilInputReturnsEmptyArray() throws {
        let filter = RejectFilter()
        
        try validateEvaluation(of: Token.Value.nil, with: [.string("property")], by: filter, yields: .array([]))
    }
    
    @Test("Returns empty array for empty array input")
    func emptyArrayReturnsEmptyArray() throws {
        let filter = RejectFilter()
        
        try validateEvaluation(of: Token.Value.array([]), with: [.string("property")], by: filter, yields: .array([]))
    }
    
    @Test("Handles single dictionary as input")
    func singleDictionaryInput() throws {
        let filter = RejectFilter()
        
        let singleDict: Token.Value = .dictionary([
            "name": .string("Item"),
            "active": .bool(true)
        ])
        
        // Rejecting truthy "active" should return empty array
        try validateEvaluation(of: singleDict, with: [.string("active")], by: filter, yields: .array([]))
        
        // Rejecting falsy "inactive" should keep the item
        let expected: Token.Value = .array([singleDict])
        try validateEvaluation(of: singleDict, with: [.string("inactive")], by: filter, yields: expected)
    }
    
    @Test("Handles non-array scalar inputs")
    func nonArrayScalarInputs() throws {
        let filter = RejectFilter()
        
        // String input - should reject if it matches parameter
        try validateEvaluation(of: "hello", with: [.string("hello")], by: filter, yields: .array([]))
        try validateEvaluation(of: "hello", with: [.string("world")], by: filter, yields: .array([.string("hello")]))
        
        // Integer input
        try validateEvaluation(of: 42, with: [.integer(42)], by: filter, yields: .array([]))
        try validateEvaluation(of: 42, with: [.integer(100)], by: filter, yields: .array([.integer(42)]))
        
        // Boolean input
        try validateEvaluation(of: true, with: [.bool(true)], by: filter, yields: .array([]))
        try validateEvaluation(of: false, with: [.bool(true)], by: filter, yields: .array([.bool(false)]))
    }
    
    @Test("Returns original array when no parameters provided")
    func noParametersReturnsOriginal() throws {
        let filter = RejectFilter()
        
        let array: Token.Value = .array([
            .string("a"),
            .string("b"),
            .string("c")
        ])
        
        // Should return original array when no parameters
        try validateEvaluation(of: array, with: [], by: filter, yields: array)
    }
    
    @Test("Handles range input")
    func rangeInput() throws {
        let filter = RejectFilter()
        
        let range: Token.Value = .range(1...5)
        
        // Range is treated as a single-element array
        // When rejecting a non-matching value, range should be kept
        try validateEvaluation(of: range, with: [.string("something")], by: filter, yields: .array([range]))
    }
    
    // MARK: - Behavior Consistency Tests
    
    @Test("Reject filter is opposite of where filter")
    func rejectIsOppositeOfWhere() throws {
        let rejectFilter = RejectFilter()
        let whereFilter = WhereFilter()
        
        let products: Token.Value = .array([
            .dictionary(["name": .string("A"), "available": .bool(true)]),
            .dictionary(["name": .string("B"), "available": .bool(false)]),
            .dictionary(["name": .string("C")])
        ])
        
        // Test one-parameter mode
        let whereResult = try whereFilter.evaluate(token: products, parameters: [.string("available")])
        let rejectResult = try rejectFilter.evaluate(token: products, parameters: [.string("available")])
        
        // Where should keep item A (true), reject should keep B (false) and C (missing)
        let whereExpected: Token.Value = .array([
            .dictionary(["name": .string("A"), "available": .bool(true)])
        ])
        let rejectExpected: Token.Value = .array([
            .dictionary(["name": .string("B"), "available": .bool(false)]),
            .dictionary(["name": .string("C")])
        ])
        
        #expect(whereResult == whereExpected)
        #expect(rejectResult == rejectExpected)
        
        // Test two-parameter mode
        let products2: Token.Value = .array([
            .dictionary(["name": .string("X"), "type": .string("book")]),
            .dictionary(["name": .string("Y"), "type": .string("toy")]),
            .dictionary(["name": .string("Z"), "type": .string("book")])
        ])
        
        let whereResult2 = try whereFilter.evaluate(token: products2, parameters: [.string("type"), .string("book")])
        let rejectResult2 = try rejectFilter.evaluate(token: products2, parameters: [.string("type"), .string("book")])
        
        // Where should keep X and Z, reject should keep only Y
        let whereExpected2: Token.Value = .array([
            .dictionary(["name": .string("X"), "type": .string("book")]),
            .dictionary(["name": .string("Z"), "type": .string("book")])
        ])
        let rejectExpected2: Token.Value = .array([
            .dictionary(["name": .string("Y"), "type": .string("toy")])
        ])
        
        #expect(whereResult2 == whereExpected2)
        #expect(rejectResult2 == rejectExpected2)
    }
}

