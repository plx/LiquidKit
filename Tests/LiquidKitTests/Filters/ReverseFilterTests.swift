import Testing
@testable import LiquidKit

/// Test suite for the reverse filter to ensure spec compliance
/// 
/// Based on documentation from various Liquid implementations:
/// - LiquidJS and Shopify Liquid: Only reverse arrays, not strings directly
/// - Python Liquid: Reverses arrays but returns strings unchanged
/// - Current LiquidKit: Reverses both arrays and strings directly
@Suite(.tags(.filter, .reverseFilter))
struct ReverseFilterTests {
    
    // MARK: - Array Reversal Tests
    
    @Test("Reverses arrays correctly")
    func testArrayReversal() throws {
        let filter = ReverseFilter()
        
        // Basic array reversal
        try validateEvaluation(
            of: ["apple", "banana", "cherry"],
            by: filter,
            yields: ["cherry", "banana", "apple"],
            "Basic string array reversal"
        )
        
        // Integer array
        try validateEvaluation(
            of: [1, 2, 3, 4, 5],
            by: filter,
            yields: [5, 4, 3, 2, 1],
            "Integer array reversal"
        )
        
        // Mixed type array
        try validateEvaluation(
            of: Token.Value.array([.string("hello"), .integer(42), .bool(true)]),
            by: filter,
            yields: Token.Value.array([.bool(true), .integer(42), .string("hello")]),
            "Mixed type array reversal"
        )
        
        // Single element array
        try validateEvaluation(
            of: ["only"],
            by: filter,
            yields: ["only"],
            "Single element array remains unchanged"
        )
        
        // Empty array
        try validateEvaluation(
            of: Token.Value.array([]),
            by: filter,
            yields: Token.Value.array([]),
            "Empty array remains empty"
        )
    }
    
    // MARK: - String Handling Tests
    
    @Test("Strings pass through unchanged (matching LiquidJS/Shopify behavior)")
    func testStringPassThrough() throws {
        let filter = ReverseFilter()
        
        // Basic string - unchanged
        try validateEvaluation(
            of: "hello",
            by: filter,
            yields: "hello",
            "String passes through unchanged"
        )
        
        // String with spaces - unchanged
        try validateEvaluation(
            of: "Ground control to Major Tom",
            by: filter,
            yields: "Ground control to Major Tom",
            "String with spaces passes through unchanged"
        )
        
        // Empty string - unchanged
        try validateEvaluation(
            of: "",
            by: filter,
            yields: "",
            "Empty string remains empty"
        )
        
        // Single character - unchanged
        try validateEvaluation(
            of: "a",
            by: filter,
            yields: "a",
            "Single character string remains unchanged"
        )
        
        // String with numbers and punctuation - unchanged
        try validateEvaluation(
            of: "Hello, World! 123",
            by: filter,
            yields: "Hello, World! 123",
            "String with mixed characters passes through unchanged"
        )
        
        // Note: To reverse a string in LiquidJS/Shopify style:
        // "hello" | split: "" | reverse | join: ""
        // This would require chaining multiple filters
    }
    
    // MARK: - Non-Collection Type Tests
    
    @Test("Handles non-collection types by returning them unchanged")
    func testNonCollectionTypes() throws {
        let filter = ReverseFilter()
        
        // Integer
        try validateEvaluation(
            of: 123,
            by: filter,
            yields: 123,
            "Integer passes through unchanged"
        )
        
        // Decimal
        try validateEvaluation(
            of: 45.67,
            by: filter,
            yields: 45.67,
            "Decimal passes through unchanged"
        )
        
        // Boolean
        try validateEvaluation(
            of: true,
            by: filter,
            yields: true,
            "Boolean passes through unchanged"
        )
        
        // Nil
        try validateEvaluation(
            of: Token.Value.nil,
            by: filter,
            yields: Token.Value.nil,
            "Nil passes through unchanged"
        )
        
        // Dictionary
        try validateEvaluation(
            of: ["key": "value"],
            by: filter,
            yields: ["key": "value"],
            "Dictionary passes through unchanged"
        )
    }
    
    // MARK: - Parameter Handling Tests
    
    @Test("Ignores extra parameters")
    func testParameterHandling() throws {
        let filter = ReverseFilter()
        
        // Array with extra parameters (should be ignored)
        try validateEvaluation(
            of: ["a", "b", "c"],
            with: [.string("extra"), .integer(42)],
            by: filter,
            yields: ["c", "b", "a"],
            "Extra parameters are ignored for arrays"
        )
        
        // String with extra parameters (should be ignored, string unchanged)
        try validateEvaluation(
            of: "test",
            with: [.bool(true)],
            by: filter,
            yields: "test",
            "Extra parameters are ignored, string passes through unchanged"
        )
    }
    
    // MARK: - Unicode and Special Character Tests
    
    @Test("Handles Unicode characters in strings (unchanged)")
    func testUnicodeHandling() throws {
        let filter = ReverseFilter()
        
        // Basic Unicode - unchanged
        try validateEvaluation(
            of: "café",
            by: filter,
            yields: "café",
            "Unicode string passes through unchanged"
        )
        
        // Emoji string - unchanged
        try validateEvaluation(
            of: "Hello 👋 World",
            by: filter,
            yields: "Hello 👋 World",
            "Emoji string passes through unchanged"
        )
        
        // Array with Unicode strings - reversed
        try validateEvaluation(
            of: ["café", "naïve", "résumé"],
            by: filter,
            yields: ["résumé", "naïve", "café"],
            "Array with Unicode strings is reversed correctly"
        )
    }
    
    // MARK: - Nested Array Tests
    
    @Test("Handles nested arrays")
    func testNestedArrays() throws {
        let filter = ReverseFilter()
        
        // Nested arrays - only reverses the outer array
        try validateEvaluation(
            of: Token.Value.array([
                .array([.integer(1), .integer(2)]),
                .array([.integer(3), .integer(4)]),
                .array([.integer(5), .integer(6)])
            ]),
            by: filter,
            yields: Token.Value.array([
                .array([.integer(5), .integer(6)]),
                .array([.integer(3), .integer(4)]),
                .array([.integer(1), .integer(2)])
            ]),
            "Reverses outer array, inner arrays unchanged"
        )
    }
    
    // MARK: - Spec Compliance Tests
    
    @Test("Matches LiquidJS/Shopify Liquid behavior")
    func testSpecCompliance() throws {
        let filter = ReverseFilter()
        
        // Strings pass through unchanged (matching LiquidJS/Shopify)
        try validateEvaluation(
            of: "hello",
            by: filter,
            yields: "hello",
            "Strings pass through unchanged like LiquidJS/Shopify"
        )
        
        // Arrays are reversed (matching all implementations)
        try validateEvaluation(
            of: ["a", "b", "c"],
            by: filter,
            yields: ["c", "b", "a"],
            "Arrays are reversed as expected"
        )
        
        // To reverse a string, users must split it first
        // Example in Liquid: {{ "hello" | split: "" | reverse | join: "" }}
        // This would produce "olleh" but requires filter chaining
        
        // Note: This implementation now matches LiquidJS and Shopify Liquid.
        // Python Liquid also returns strings unchanged, so we match that too.
        // The previous implementation that reversed strings directly was
        // non-standard and has been corrected.
    }
}