import Testing
import Foundation
@testable import LiquidKit

@Suite(.tags(.filter, .findIndexFilter))
struct FindIndexFilterTests {
    private let filter = FindIndexFilter()
    
    // MARK: - Basic Array of Objects Tests
    
    @Test func findIndexByPropertyValue() throws {
        let products = Token.Value.array([
            .dictionary(["name": .string("Shirt"), "price": .integer(20)]),
            .dictionary(["name": .string("Pants"), "price": .integer(30)]),
            .dictionary(["name": .string("Shoes"), "price": .integer(50)])
        ])
        
        // Find index of item with name = "Pants"
        try validateEvaluation(
            of: products,
            with: [.string("name"), .string("Pants")],
            by: filter,
            yields: 1,
            "Should find index 1 for Pants"
        )
        
        // Find index of item with price = 50
        try validateEvaluation(
            of: products,
            with: [.string("price"), .integer(50)],
            by: filter,
            yields: 2,
            "Should find index 2 for price 50"
        )
    }
    
    @Test func findIndexNotFound() throws {
        let products = Token.Value.array([
            .dictionary(["name": .string("Shirt"), "price": .integer(20)]),
            .dictionary(["name": .string("Pants"), "price": .integer(30)])
        ])
        
        // Search for non-existent value
        try validateEvaluation(
            of: products,
            with: [.string("name"), .string("Hat")],
            by: filter,
            yields: Token.Value.nil,
            "Should return nil when value not found"
        )
        
        // Search for non-existent property
        try validateEvaluation(
            of: products,
            with: [.string("color"), .string("Red")],
            by: filter,
            yields: Token.Value.nil,
            "Should return nil when property doesn't exist"
        )
    }
    
    @Test func findIndexFirstMatch() throws {
        let items = Token.Value.array([
            .dictionary(["type": .string("A"), "value": .integer(1)]),
            .dictionary(["type": .string("B"), "value": .integer(2)]),
            .dictionary(["type": .string("A"), "value": .integer(3)])
        ])
        
        // Should return first matching index
        try validateEvaluation(
            of: items,
            with: [.string("type"), .string("A")],
            by: filter,
            yields: 0,
            "Should return index of first match"
        )
    }
    
    // MARK: - Different Value Type Matching
    
    @Test func findIndexWithDifferentValueTypes() throws {
        let mixed = Token.Value.array([
            .dictionary(["id": .integer(100), "active": .bool(true)]),
            .dictionary(["id": .integer(200), "active": .bool(false)]),
            .dictionary(["id": .integer(300), "active": .bool(true)])
        ])
        
        // Match boolean value
        try validateEvaluation(
            of: mixed,
            with: [.string("active"), .bool(false)],
            by: filter,
            yields: 1,
            "Should match boolean false at index 1"
        )
        
        // Match integer value
        try validateEvaluation(
            of: mixed,
            with: [.string("id"), .integer(300)],
            by: filter,
            yields: 2,
            "Should match integer 300 at index 2"
        )
    }
    
    @Test func findIndexWithNilValues() throws {
        let items = Token.Value.array([
            .dictionary(["name": .string("Alice"), "age": .nil]),
            .dictionary(["name": .string("Bob"), "age": .integer(25)]),
            .dictionary(["name": .string("Charlie"), "age": .nil])
        ])
        
        // Match nil value
        try validateEvaluation(
            of: items,
            with: [.string("age"), .nil],
            by: filter,
            yields: 0,
            "Should match nil value at index 0"
        )
    }
    
    // MARK: - Edge Cases
    
    @Test func findIndexEmptyArray() throws {
        let empty = Token.Value.array([])
        
        try validateEvaluation(
            of: empty,
            with: [.string("any"), .string("value")],
            by: filter,
            yields: Token.Value.nil,
            "Should return nil for empty array"
        )
    }
    
    @Test func findIndexNilInput() throws {
        try validateEvaluation(
            of: Token.Value.nil,
            with: [.string("any"), .string("value")],
            by: filter,
            yields: Token.Value.nil,
            "Should return nil for nil input"
        )
    }
    
    // MARK: - Non-Array Inputs (Edge Cases)
    
    @Test func findIndexSingleDictionary() throws {
        let user = Token.Value.dictionary([
            "name": .string("Alice"),
            "active": .bool(true)
        ])
        
        // When dictionary has matching property/value
        try validateEvaluation(
            of: user,
            with: [.string("name"), .string("Alice")],
            by: filter,
            yields: 0,
            "Should return 0 when single dictionary matches"
        )
        
        // When dictionary doesn't match
        try validateEvaluation(
            of: user,
            with: [.string("name"), .string("Bob")],
            by: filter,
            yields: Token.Value.nil,
            "Should return nil when single dictionary doesn't match"
        )
    }
    
    @Test func findIndexSingleString() throws {
        // String contains substring
        try validateEvaluation(
            of: "hello world",
            with: [.string("world")],
            by: filter,
            yields: 0,
            "Should return 0 when string contains substring"
        )
        
        // String doesn't contain substring
        try validateEvaluation(
            of: "hello",
            with: [.string("world")],
            by: filter,
            yields: Token.Value.nil,
            "Should return nil when string doesn't contain substring"
        )
    }
    
    @Test func findIndexArrayOfStrings() throws {
        let fruits = Token.Value.array([
            .string("apple"),
            .string("banana"),
            .string("cherry")
        ])
        
        // Find string containing substring
        try validateEvaluation(
            of: fruits,
            with: [.string("err")],
            by: filter,
            yields: 2,
            "Should find 'cherry' at index 2"
        )
        
        // No match
        try validateEvaluation(
            of: fruits,
            with: [.string("xyz")],
            by: filter,
            yields: Token.Value.nil,
            "Should return nil when no string contains substring"
        )
    }
    
    // MARK: - Parameter Validation
    
    @Test func findIndexMissingParameters() throws {
        let items = Token.Value.array([
            .dictionary(["name": .string("Test")])
        ])
        
        // No parameters - should return nil (or throw error in strict mode)
        try validateEvaluation(
            of: items,
            with: [],
            by: filter,
            yields: Token.Value.nil,
            "Should return nil when no parameters provided"
        )
    }
    
    // MARK: - Single Parameter Behavior
    
    @Test func findIndexSingleParameterWithObjects() throws {
        // Test that single parameter with objects returns nil (no truthy check)
        let users = Token.Value.array([
            .dictionary(["name": .string("Alice")]),
            .dictionary(["name": .string("Bob"), "admin": .bool(true)]),
            .dictionary(["name": .string("Charlie"), "admin": .bool(false)])
        ])
        
        // Single parameter with objects should return nil
        try validateEvaluation(
            of: users,
            with: [.string("admin")],
            by: filter,
            yields: Token.Value.nil,
            "Should return nil for single parameter with objects (no truthy check)"
        )
    }
    
    @Test func findIndexSingleParameterStringSearch() throws {
        let words = Token.Value.array([
            .string("apple"),
            .string("banana"),
            .string("apricot")
        ])
        
        // Single parameter substring search
        try validateEvaluation(
            of: words,
            with: [.string("ap")],
            by: filter,
            yields: 0,
            "Should find first string containing 'ap'"
        )
    }
}