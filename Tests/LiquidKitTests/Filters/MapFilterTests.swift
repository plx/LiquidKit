import Testing
@testable import LiquidKit

@Suite(.tags(.filter, .mapFilter))
struct MapFilterTests {
    let filter = MapFilter()
    
    // MARK: - Basic Functionality
    
    @Test("Extract property from array of dictionaries")
    func basicPropertyExtraction() throws {
        let products = Token.Value.array([
            .dictionary(["title": .string("Shirt"), "price": .integer(20)]),
            .dictionary(["title": .string("Pants"), "price": .integer(30)]),
            .dictionary(["title": .string("Shoes"), "price": .integer(50)])
        ])
        
        try validateEvaluation(
            of: products,
            with: [.string("title")],
            by: filter,
            yields: .array([.string("Shirt"), .string("Pants"), .string("Shoes")])
        )
    }
    
    @Test("Extract numeric property")
    func numericPropertyExtraction() throws {
        let items = Token.Value.array([
            .dictionary(["name": .string("Item1"), "quantity": .integer(5)]),
            .dictionary(["name": .string("Item2"), "quantity": .integer(10)]),
            .dictionary(["name": .string("Item3"), "quantity": .integer(15)])
        ])
        
        try validateEvaluation(
            of: items,
            with: [.string("quantity")],
            by: filter,
            yields: .array([.integer(5), .integer(10), .integer(15)])
        )
    }
    
    // MARK: - Missing Properties
    
    @Test("Handle missing property with nil value")
    func missingPropertyReturnsNil() throws {
        let items = Token.Value.array([
            .dictionary(["title": .string("First")]),
            .dictionary(["title": .string("Second")]),
            .dictionary(["name": .string("Third")]) // Missing 'title'
        ])
        
        try validateEvaluation(
            of: items,
            with: [.string("title")],
            by: filter,
            yields: .array([.string("First"), .string("Second"), .nil])
        )
    }
    
    @Test("All elements missing property")
    func allElementsMissingProperty() throws {
        let items = Token.Value.array([
            .dictionary(["name": .string("First")]),
            .dictionary(["name": .string("Second")]),
            .dictionary(["name": .string("Third")])
        ])
        
        try validateEvaluation(
            of: items,
            with: [.string("title")],
            by: filter,
            yields: .array([.nil, .nil, .nil])
        )
    }
    
    // MARK: - Non-Object Elements
    
    @Test("Array containing non-object elements throws error")
    func nonObjectElementsThrowError() throws {
        let mixed = Token.Value.array([
            .dictionary(["title": .string("First")]),
            .dictionary(["title": .string("Second")]),
            .integer(5), // Non-object element
            .array([]) // Another non-object element
        ])
        
        try validateEvaluation(
            of: mixed,
            with: [.string("title")],
            by: filter,
            throws: TemplateSyntaxError.self
        )
    }
    
    @Test("Array with string elements throws error")
    func stringElementsThrowError() throws {
        let strings = Token.Value.array([
            .string("hello"),
            .string("world")
        ])
        
        try validateEvaluation(
            of: strings,
            with: [.string("title")],
            by: filter,
            throws: TemplateSyntaxError.self
        )
    }
    
    // MARK: - Non-Array Inputs
    
    @Test("Integer input throws error")
    func integerInputThrowsError() throws {
        try validateEvaluation(
            of: Token.Value.integer(123),
            with: [.string("title")],
            by: filter,
            throws: TemplateSyntaxError.self
        )
    }
    
    @Test("String input throws error")
    func stringInputThrowsError() throws {
        try validateEvaluation(
            of: Token.Value.string("hello"),
            with: [.string("title")],
            by: filter,
            throws: TemplateSyntaxError.self
        )
    }
    
    @Test("Dictionary input extracts property value")
    func dictionaryInputExtractsProperty() throws {
        let dict = Token.Value.dictionary([
            "title": .string("foo"),
            "some": .string("thing")
        ])
        
        try validateEvaluation(
            of: dict,
            with: [.string("title")],
            by: filter,
            yields: .string("foo")
        )
    }
    
    @Test("Dictionary input with missing property returns nil")
    func dictionaryInputMissingProperty() throws {
        let dict = Token.Value.dictionary([
            "name": .string("foo"),
            "some": .string("thing")
        ])
        
        try validateEvaluation(
            of: dict,
            with: [.string("title")],
            by: filter,
            yields: .nil
        )
    }
    
    // MARK: - Edge Cases
    
    @Test("Empty array returns empty array")
    func emptyArrayReturnsEmptyArray() throws {
        try validateEvaluation(
            of: Token.Value.array([]),
            with: [.string("title")],
            by: filter,
            yields: .array([])
        )
    }
    
    @Test("Nil parameter returns empty result")
    func nilParameterReturnsEmpty() throws {
        let items = Token.Value.array([
            .dictionary(["title": .string("First")]),
            .dictionary(["title": .string("Second")])
        ])
        
        try validateEvaluation(
            of: items,
            with: [.nil],
            by: filter,
            yields: .array([])
        )
    }
    
    @Test("No parameters throws error")
    func noParametersThrowsError() throws {
        let items = Token.Value.array([
            .dictionary(["title": .string("First")])
        ])
        
        try validateEvaluation(
            of: items,
            with: [],
            by: filter,
            throws: TemplateSyntaxError.self
        )
    }
    
    @Test("Multiple parameters uses only first")
    func multipleParametersUsesFirst() throws {
        let items = Token.Value.array([
            .dictionary(["title": .string("First"), "name": .string("Name1")]),
            .dictionary(["title": .string("Second"), "name": .string("Name2")])
        ])
        
        try validateEvaluation(
            of: items,
            with: [.string("title"), .string("name")],
            by: filter,
            yields: .array([.string("First"), .string("Second")])
        )
    }
    
    // MARK: - Nested Properties
    
    @Test("Extract nested property with dot notation")
    func nestedPropertyWithDotNotation() throws {
        let items = Token.Value.array([
            .dictionary([
                "product": .dictionary(["title": .string("Nested1")])
            ]),
            .dictionary([
                "product": .dictionary(["title": .string("Nested2")])
            ])
        ])
        
        try validateEvaluation(
            of: items,
            with: [.string("product.title")],
            by: filter,
            yields: .array([.string("Nested1"), .string("Nested2")])
        )
    }
    
    // MARK: - Special Value Types
    
    @Test("Extract boolean properties")
    func booleanPropertyExtraction() throws {
        let items = Token.Value.array([
            .dictionary(["available": .bool(true)]),
            .dictionary(["available": .bool(false)]),
            .dictionary(["available": .bool(true)])
        ])
        
        try validateEvaluation(
            of: items,
            with: [.string("available")],
            by: filter,
            yields: .array([.bool(true), .bool(false), .bool(true)])
        )
    }
    
    @Test("Extract decimal properties")
    func decimalPropertyExtraction() throws {
        let items = Token.Value.array([
            .dictionary(["price": .decimal(19.99)]),
            .dictionary(["price": .decimal(29.99)]),
            .dictionary(["price": .decimal(39.99)])
        ])
        
        try validateEvaluation(
            of: items,
            with: [.string("price")],
            by: filter,
            yields: .array([.decimal(19.99), .decimal(29.99), .decimal(39.99)])
        )
    }
}

