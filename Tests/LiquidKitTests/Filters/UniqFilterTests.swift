import Foundation
import Testing
@testable import LiquidKit

@Suite(.tags(.filter, .uniqFilter))
struct UniqFilterTests {
    private let filter = UniqFilter()
    
    // MARK: - Basic Array Deduplication
    
    @Test("Basic string array deduplication")
    func testBasicStringArrayDeduplication() throws {
        // Test the classic example from Liquid documentation
        try validateEvaluation(
            of: ["ants", "bugs", "bees", "bugs", "ants"],
            with: [],
            by: filter,
            yields: Token.Value.array([
                .string("ants"),
                .string("bugs"),
                .string("bees")
            ])
        )
    }
    
    @Test("Integer array deduplication")
    func testIntegerArrayDeduplication() throws {
        try validateEvaluation(
            of: [1, 2, 3, 2, 1, 4],
            with: [],
            by: filter,
            yields: Token.Value.array([
                .integer(1),
                .integer(2),
                .integer(3),
                .integer(4)
            ])
        )
    }
    
    @Test("Mixed type array deduplication")
    func testMixedTypeArrayDeduplication() throws {
        // Test that string "1" and integer 1 are treated as different values
        // This matches liquidjs and python-liquid behavior
        try validateEvaluation(
            of: Token.Value.array([.integer(1), .string("1"), .integer(2), .string("2"), .integer(3)]),
            with: [],
            by: filter,
            yields: Token.Value.array([
                .integer(1),
                .string("1"),
                .integer(2),
                .string("2"),
                .integer(3)
            ])
        )
    }
    
    // MARK: - Order Preservation
    
    @Test("Preserves order of first occurrence")
    func testPreservesOrderOfFirstOccurrence() throws {
        try validateEvaluation(
            of: ["red", "blue", "green", "blue", "red", "yellow"],
            with: [],
            by: filter,
            yields: Token.Value.array([
                .string("red"),
                .string("blue"),
                .string("green"),
                .string("yellow")
            ])
        )
    }
    
    // MARK: - Edge Cases
    
    @Test("Empty array returns empty array")
    func testEmptyArrayReturnsEmptyArray() throws {
        try validateEvaluation(
            of: Token.Value.array([]),
            with: [],
            by: filter,
            yields: Token.Value.array([])
        )
    }
    
    @Test("Array with no duplicates remains unchanged")
    func testArrayWithNoDuplicatesRemainsUnchanged() throws {
        try validateEvaluation(
            of: ["apple", "banana", "cherry"],
            with: [],
            by: filter,
            yields: Token.Value.array([
                .string("apple"),
                .string("banana"),
                .string("cherry")
            ])
        )
    }
    
    @Test("Array with all identical elements returns single element")
    func testArrayWithAllIdenticalElementsReturnsSingleElement() throws {
        try validateEvaluation(
            of: ["same", "same", "same", "same"],
            with: [],
            by: filter,
            yields: Token.Value.array([.string("same")])
        )
    }
    
    // MARK: - Non-Array Inputs
    
    @Test("Non-array string input returns unchanged")
    func testNonArrayStringInputReturnsUnchanged() throws {
        try validateEvaluation(
            of: "hello",
            with: [],
            by: filter,
            yields: "hello"
        )
    }
    
    @Test("Non-array integer input returns unchanged")
    func testNonArrayIntegerInputReturnsUnchanged() throws {
        try validateEvaluation(
            of: 42,
            with: [],
            by: filter,
            yields: 42
        )
    }
    
    @Test("Nil input returns nil")
    func testNilInputReturnsNil() throws {
        try validateEvaluation(
            of: Token.Value.nil,
            with: [],
            by: filter,
            yields: Token.Value.nil
        )
    }
    
    // MARK: - Special Value Types
    
    @Test("Boolean values deduplication")
    func testBooleanValuesDeduplication() throws {
        try validateEvaluation(
            of: Token.Value.array([.bool(true), .bool(false), .bool(true), .bool(false), .bool(true)]),
            with: [],
            by: filter,
            yields: Token.Value.array([.bool(true), .bool(false)])
        )
    }
    
    @Test("Decimal values deduplication")
    func testDecimalValuesDeduplication() throws {
        try validateEvaluation(
            of: [1.5, 2.5, 1.5, 3.5, 2.5],
            with: [],
            by: filter,
            yields: Token.Value.array([
                .decimal(Decimal(1.5)),
                .decimal(Decimal(2.5)),
                .decimal(Decimal(3.5))
            ])
        )
    }
    
    @Test("Nil values in array are handled")
    func testNilValuesInArrayAreHandled() throws {
        // nil values have empty stringValue, so they should be deduplicated
        try validateEvaluation(
            of: Token.Value.array([.nil, .string("a"), .nil, .string("b"), .nil]),
            with: [],
            by: filter,
            yields: Token.Value.array([.nil, .string("a"), .string("b")])
        )
    }
    
    // MARK: - Complex Scenarios
    
    @Test("Integer and Decimal comparison")
    func testIntegerAndDecimalComparison() throws {
        // Test that 1 (integer) and 1.0 (decimal) are considered equal
        try validateEvaluation(
            of: Token.Value.array([.integer(1), .decimal(Decimal(1.0)), .integer(2), .decimal(Decimal(2.0))]),
            with: [],
            by: filter,
            yields: Token.Value.array([
                .integer(1),  // 1.0 is a duplicate of 1
                .integer(2)   // 2.0 is a duplicate of 2
            ])
        )
    }
    
    @Test("String number comparison")
    func testStringNumberComparison() throws {
        // Test that string numbers are different from actual numbers
        try validateEvaluation(
            of: Token.Value.array([.string("1"), .string("1.0"), .integer(1), .decimal(Decimal(1.0))]),
            with: [],
            by: filter,
            yields: Token.Value.array([
                .string("1"),
                .string("1.0"),
                .integer(1)  // decimal 1.0 is duplicate of integer 1
            ])
        )
    }
    
    // Test removed - chaining filters requires full template evaluation
    
    @Test("Dictionary input returns unchanged")
    func testDictionaryInputReturnsUnchanged() throws {
        // Dictionaries should pass through unchanged
        let dict = Token.Value.dictionary(["a": .integer(1), "b": .integer(2)])
        try validateEvaluation(
            of: dict,
            with: [],
            by: filter,
            yields: dict
        )
    }
    
    @Test("Nested arrays are compared by string representation")
    func testNestedArraysAreComparedByStringRepresentation() throws {
        // Arrays concatenate their elements in stringValue
        try validateEvaluation(
            of: Token.Value.array([
                .array([.integer(1), .integer(2)]),
                .array([.integer(1), .integer(2)]),
                .array([.integer(3), .integer(4)])
            ]),
            with: [],
            by: filter,
            yields: Token.Value.array([
                .array([.integer(1), .integer(2)]),
                .array([.integer(3), .integer(4)])
            ])
        )
    }
    
    // MARK: - Property Parameter (Not Supported Yet)
    
    @Test("Property parameter is ignored (current behavior)")
    func testPropertyParameterIsIgnored() throws {
        // The current implementation doesn't support the property parameter
        // This test documents the current behavior
        let products = Token.Value.array([
            .dictionary(["name": .string("Product1"), "company": .string("A")]),
            .dictionary(["name": .string("Product2"), "company": .string("B")]),
            .dictionary(["name": .string("Product3"), "company": .string("A")])
        ])
        
        // With property parameter (should be ignored)
        try validateEvaluation(
            of: products,
            with: [.string("company")],
            by: filter,
            yields: products  // All three products remain unique
        )
    }
}