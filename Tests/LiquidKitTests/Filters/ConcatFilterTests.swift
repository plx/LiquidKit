import Foundation
import Testing
@testable import LiquidKit

@Suite(.tags(.filter, .concatFilter))
struct ConcatFilterTests {
    
    // MARK: - Basic Functionality
    
    @Test("Concatenates two arrays of strings")
    func testConcatTwoStringArrays() {
        let filter = ConcatFilter()
        let input = Token.Value.array([.string("a"), .string("b")])
        let param = Token.Value.array([.string("c"), .string("d")])
        
        let result = try! filter.evaluate(token: input, parameters: [param])
        
        #expect(result == .array([.string("a"), .string("b"), .string("c"), .string("d")]))
    }
    
    @Test("Concatenates multiple arrays")
    func testConcatMultipleArrays() {
        let filter = ConcatFilter()
        let input = Token.Value.array([.string("a")])
        let param1 = Token.Value.array([.string("b"), .string("c")])
        let param2 = Token.Value.array([.string("d"), .string("e")])
        
        let result = try! filter.evaluate(token: input, parameters: [param1, param2])
        
        #expect(result == .array([.string("a"), .string("b"), .string("c"), .string("d"), .string("e")]))
    }
    
    @Test("Concatenates arrays with mixed types")
    func testConcatMixedTypes() {
        let filter = ConcatFilter()
        let input = Token.Value.array([.string("a"), .string("b"), .integer(5)])
        let param = Token.Value.array([.string("c"), .string("d")])
        
        let result = try! filter.evaluate(token: input, parameters: [param])
        
        #expect(result == .array([.string("a"), .string("b"), .integer(5), .string("c"), .string("d")]))
    }
    
    @Test("Concatenates with range literal")
    func testConcatWithRange() {
        let filter = ConcatFilter()
        let input = Token.Value.range(1...3)
        let param = Token.Value.array([.integer(5), .integer(6), .integer(7)])
        
        let result = try! filter.evaluate(token: input, parameters: [param])
        
        #expect(result == .array([.integer(1), .integer(2), .integer(3), .integer(5), .integer(6), .integer(7)]))
    }
    
    // MARK: - Non-Array Left Value Behavior
    
    @Test("Non-array left value (string) gets converted to array")
    func testNonArrayLeftValueString() {
        let filter = ConcatFilter()
        let input = Token.Value.string("ab")
        let param = Token.Value.array([.string("c"), .string("d")])
        
        let result = try! filter.evaluate(token: input, parameters: [param])
        
        #expect(result == .array([.string("ab"), .string("c"), .string("d")]))
    }
    
    @Test("Non-array left value (integer) gets converted to array")
    func testNonArrayLeftValueInteger() {
        let filter = ConcatFilter()
        let input = Token.Value.integer(42)
        let param = Token.Value.array([.string("a"), .string("b")])
        
        let result = try! filter.evaluate(token: input, parameters: [param])
        
        #expect(result == .array([.integer(42), .string("a"), .string("b")]))
    }
    
    @Test("Non-array left value (bool) gets converted to array")
    func testNonArrayLeftValueBool() {
        let filter = ConcatFilter()
        let input = Token.Value.bool(true)
        let param = Token.Value.array([.string("a"), .string("b")])
        
        let result = try! filter.evaluate(token: input, parameters: [param])
        
        #expect(result == .array([.bool(true), .string("a"), .string("b")]))
    }
    
    // MARK: - Nested Array Flattening
    
    @Test("Nested arrays get flattened")
    func testNestedArrayFlattening() {
        let filter = ConcatFilter()
        let nested1 = Token.Value.array([.string("a"), .string("x")])
        let deeplyNested = Token.Value.array([.string("y"), .array([.string("z")])])
        let nested2 = Token.Value.array([.string("b"), deeplyNested])
        let input = Token.Value.array([nested1, nested2])
        let param = Token.Value.array([.string("c"), .string("d")])
        
        let result = try! filter.evaluate(token: input, parameters: [param])
        
        #expect(result == .array([.string("a"), .string("x"), .string("b"), .string("y"), .string("z"), .string("c"), .string("d")]))
    }
    
    @Test("Simple nested array flattening")
    func testSimpleNestedArrayFlattening() {
        let filter = ConcatFilter()
        let input = Token.Value.array([.array([.string("a"), .string("b")]), .array([.string("c"), .string("d")])])
        let param = Token.Value.array([.string("e"), .string("f")])
        
        let result = try! filter.evaluate(token: input, parameters: [param])
        
        #expect(result == .array([.string("a"), .string("b"), .string("c"), .string("d"), .string("e"), .string("f")]))
    }
    
    // MARK: - Error Cases
    
    @Test("Non-array parameter throws error")
    func testNonArrayParameterThrows() {
        let filter = ConcatFilter()
        let input = Token.Value.array([.string("a"), .string("b")])
        let param = Token.Value.integer(5)
        
        #expect(throws: FilterError.self) {
            try filter.evaluate(token: input, parameters: [param])
        }
    }
    
    @Test("Missing argument throws error")
    func testMissingArgumentThrows() {
        let filter = ConcatFilter()
        let input = Token.Value.array([.string("a"), .string("b")])
        
        #expect(throws: FilterError.self) {
            try filter.evaluate(token: input, parameters: [])
        }
    }
    
    // MARK: - Nil/Undefined Behavior
    
    @Test("Nil left value treated as empty array")
    func testNilLeftValue() {
        let filter = ConcatFilter()
        let input = Token.Value.nil
        let param = Token.Value.array([.string("c"), .string("d")])
        
        let result = try! filter.evaluate(token: input, parameters: [param])
        
        #expect(result == .array([.string("c"), .string("d")]))
    }
    
    @Test("Nil parameter throws error")
    func testNilParameterThrows() {
        let filter = ConcatFilter()
        let input = Token.Value.array([.string("a"), .string("b")])
        let param = Token.Value.nil
        
        #expect(throws: FilterError.self) {
            try filter.evaluate(token: input, parameters: [param])
        }
    }
    
    // MARK: - Integration with validateEvaluation
    
    @Test("Integration test using validateEvaluation")
    func testIntegrationWithValidateEvaluation() throws {
        try validateEvaluation(
            of: Token.Value.array([.string("apple"), .string("orange")]),
            with: [.array([.string("banana"), .string("grape")])],
            by: ConcatFilter(),
            yields: .array([.string("apple"), .string("orange"), .string("banana"), .string("grape")])
        )
    }
    
    @Test("Integration test with non-array left value")
    func testIntegrationNonArrayLeftValue() throws {
        try validateEvaluation(
            of: Token.Value.string("hello"),
            with: [.array([.string("world")])],
            by: ConcatFilter(),
            yields: .array([.string("hello"), .string("world")])
        )
    }
}

// Note: concatFilter tag is already defined in Tags.swift