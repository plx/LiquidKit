import Testing
@testable import LiquidKit

@Suite(.tags(.filter, .findFilter))
struct FindFilterTests {
    let filter = FindFilter()
    
    // MARK: - Basic Property Matching (Two Parameters)
    
    @Test("Finds first object with matching property value")
    func findsFirstMatchingObject() throws {
        let products = Token.Value.array([
            .dictionary(["name": .string("Shirt"), "price": .integer(20)]),
            .dictionary(["name": .string("Pants"), "price": .integer(30)]),
            .dictionary(["name": .string("Pants"), "price": .integer(40)])  // Another pants item
        ])
        
        // Should find the first "Pants" item
        try validateEvaluation(
            of: products,
            with: [.string("name"), .string("Pants")],
            by: filter,
            yields: .dictionary(["name": .string("Pants"), "price": .integer(30)])
        )
    }
    
    @Test("Returns nil when no match found")
    func returnsNilWhenNoMatch() throws {
        let products = Token.Value.array([
            .dictionary(["name": .string("Shirt"), "price": .integer(20)]),
            .dictionary(["name": .string("Pants"), "price": .integer(30)])
        ])
        
        try validateEvaluation(
            of: products,
            with: [.string("name"), .string("Jacket")],
            by: filter,
            yields: .nil
        )
    }
    
    @Test("Matches different value types")
    func matchesDifferentValueTypes() throws {
        let items = Token.Value.array([
            .dictionary(["id": .integer(1), "active": .bool(false)]),
            .dictionary(["id": .integer(2), "active": .bool(true)]),
            .dictionary(["id": .integer(3), "active": .bool(true)])
        ])
        
        // Find by integer
        try validateEvaluation(
            of: items,
            with: [.string("id"), .integer(2)],
            by: filter,
            yields: .dictionary(["id": .integer(2), "active": .bool(true)])
        )
        
        // Find by boolean
        try validateEvaluation(
            of: items,
            with: [.string("active"), .bool(true)],
            by: filter,
            yields: .dictionary(["id": .integer(2), "active": .bool(true)])  // First truthy match
        )
    }
    
    @Test("Handles missing properties")
    func handlesMissingProperties() throws {
        let items = Token.Value.array([
            .dictionary(["name": .string("Item1")]),  // Missing 'category'
            .dictionary(["name": .string("Item2"), "category": .string("electronics")]),
            .dictionary(["name": .string("Item3"), "category": .string("kitchen")])
        ])
        
        try validateEvaluation(
            of: items,
            with: [.string("category"), .string("kitchen")],
            by: filter,
            yields: .dictionary(["name": .string("Item3"), "category": .string("kitchen")])
        )
    }
    
    // MARK: - Truthy Property Matching (One Parameter)
    
    @Test("Finds first object with truthy property")
    func findsFirstTruthyProperty() throws {
        let users = Token.Value.array([
            .dictionary(["name": .string("Alice"), "admin": .bool(false)]),
            .dictionary(["name": .string("Bob")]),  // Missing 'admin'
            .dictionary(["name": .string("Charlie"), "admin": .bool(true)]),
            .dictionary(["name": .string("Dave"), "admin": .bool(true)])
        ])
        
        try validateEvaluation(
            of: users,
            with: [.string("admin")],
            by: filter,
            yields: .dictionary(["name": .string("Charlie"), "admin": .bool(true)])
        )
    }
    
    @Test("Truthy values include non-nil, non-false values")
    func truthyValuesTest() throws {
        let items = Token.Value.array([
            .dictionary(["id": .integer(1), "value": .nil]),
            .dictionary(["id": .integer(2), "value": .bool(false)]),
            .dictionary(["id": .integer(3), "value": .string("")]),  // Empty string is truthy
            .dictionary(["id": .integer(4), "value": .integer(0)])   // Zero is truthy
        ])
        
        // Empty string is truthy in Liquid
        try validateEvaluation(
            of: items,
            with: [.string("value")],
            by: filter,
            yields: .dictionary(["id": .integer(3), "value": .string("")])
        )
    }
    
    // MARK: - String Array Behavior
    
    @Test("String array with substring matching")
    func stringArraySubstringMatching() throws {
        let words = Token.Value.array([
            .string("apple"),
            .string("banana"),
            .string("cherry")
        ])
        
        // Should find "banana" which contains "an"
        try validateEvaluation(
            of: words,
            with: [.string("an")],
            by: filter,
            yields: .string("banana")
        )
    }
    
    @Test("String array no substring match")
    func stringArrayNoMatch() throws {
        let words = Token.Value.array([
            .string("apple"),
            .string("banana"),
            .string("cherry")
        ])
        
        try validateEvaluation(
            of: words,
            with: [.string("xyz")],
            by: filter,
            yields: .nil
        )
    }
    
    // MARK: - Single String Input
    
    @Test("Single string with substring match")
    func singleStringSubstringMatch() throws {
        // Single strings should be treated as single-element arrays
        try validateEvaluation(
            of: Token.Value.string("Hello World"),
            with: [.string("Wor")],
            by: filter,
            yields: .string("Hello World")
        )
    }
    
    @Test("Single string no substring match")
    func singleStringNoMatch() throws {
        try validateEvaluation(
            of: Token.Value.string("Hello World"),
            with: [.string("xyz")],
            by: filter,
            yields: .nil
        )
    }
    
    // MARK: - Edge Cases
    
    @Test("Empty array returns nil")
    func emptyArrayReturnsNil() throws {
        try validateEvaluation(
            of: Token.Value.array([]),
            with: [.string("property")],
            by: filter,
            yields: .nil
        )
    }
    
    @Test("Nil input returns nil")
    func nilInputReturnsNil() throws {
        try validateEvaluation(
            of: Token.Value.nil,
            with: [.string("property")],
            by: filter,
            yields: .nil
        )
    }
    
    @Test("No parameters returns nil")
    func noParametersReturnsNil() throws {
        let items = Token.Value.array([
            .dictionary(["name": .string("Item")])
        ])
        
        // Should return nil when no parameters provided
        try validateEvaluation(
            of: items,
            with: [],
            by: filter,
            yields: .nil
        )
    }
    
    // MARK: - Mixed Array Types
    
    @Test("Mixed array ignores non-dictionaries for property search")
    func mixedArrayIgnoresNonDictionaries() throws {
        let mixed = Token.Value.array([
            .string("not a dict"),
            .integer(42),
            .dictionary(["type": .string("found"), "value": .integer(1)]),
            .dictionary(["type": .string("found"), "value": .integer(2)])
        ])
        
        try validateEvaluation(
            of: mixed,
            with: [.string("type"), .string("found")],
            by: filter,
            yields: .dictionary(["type": .string("found"), "value": .integer(1)])
        )
    }
    
    // MARK: - Non-Array Inputs
    
    @Test("Single dictionary as input")
    func singleDictionaryInput() throws {
        let dict = Token.Value.dictionary(["name": .string("Test"), "value": .integer(42)])
        
        // Should find when property matches
        try validateEvaluation(
            of: dict,
            with: [.string("name"), .string("Test")],
            by: filter,
            yields: dict
        )
        
        // Should return nil when property doesn't match
        try validateEvaluation(
            of: dict,
            with: [.string("name"), .string("Other")],
            by: filter,
            yields: .nil
        )
    }
    
    @Test("Non-string scalar inputs return nil for property search")
    func nonStringScalarInputs() throws {
        // Numbers don't support property/substring matching
        try validateEvaluation(
            of: Token.Value.integer(42),
            with: [.string("4")],
            by: filter,
            yields: .nil
        )
        
        try validateEvaluation(
            of: Token.Value.decimal(3.14),
            with: [.string("3")],
            by: filter,
            yields: .nil
        )
        
        try validateEvaluation(
            of: Token.Value.bool(true),
            with: [.string("tr")],
            by: filter,
            yields: .nil
        )
    }
    
    // MARK: - Two Parameters with Non-Dictionary Arrays
    
    @Test("String array with two parameters should not match")
    func stringArrayTwoParameters() throws {
        let words = Token.Value.array([
            .string("apple"),
            .string("banana"),
            .string("cherry")
        ])
        
        // Non-dictionary items should not match with two parameters
        try validateEvaluation(
            of: words,
            with: [.string("banana"), .string("banana")],
            by: filter,
            yields: .nil
        )
    }
    
    // MARK: - Complex Nested Data
    
    @Test("Does not search nested properties")
    func doesNotSearchNestedProperties() throws {
        let items = Token.Value.array([
            .dictionary([
                "name": .string("Item1"),
                "meta": .dictionary(["category": .string("electronics")])
            ]),
            .dictionary([
                "name": .string("Item2"),
                "category": .string("electronics")  // Direct property
            ])
        ])
        
        // Should only find direct property, not nested
        try validateEvaluation(
            of: items,
            with: [.string("category"), .string("electronics")],
            by: filter,
            yields: .dictionary([
                "name": .string("Item2"),
                "category": .string("electronics")
            ])
        )
    }
}