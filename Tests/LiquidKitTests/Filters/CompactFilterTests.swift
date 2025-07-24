import Testing
@testable import LiquidKit

@Suite(.tags(.filter, .compactFilter))
struct CompactFilterTests {
    private let filter = CompactFilter()
    
    // MARK: - Basic Functionality
    
    @Test("removes nil values from array")
    func removesNilValues() throws {
        let input = Token.Value.array([.string("a"), .nil, .string("b"), .nil, .string("c")])
        let expected = Token.Value.array([.string("a"), .string("b"), .string("c")])
        
        try validateEvaluation(of: input, by: filter, yields: expected)
    }
    
    @Test("returns empty array when all values are nil")
    func allNilValues() throws {
        let input = Token.Value.array([.nil, .nil, .nil])
        let expected = Token.Value.array([])
        
        try validateEvaluation(of: input, by: filter, yields: expected)
    }
    
    @Test("returns same array when no nil values")
    func noNilValues() throws {
        let input = Token.Value.array([.string("a"), .string("b"), .string("c")])
        let expected = Token.Value.array([.string("a"), .string("b"), .string("c")])
        
        try validateEvaluation(of: input, by: filter, yields: expected)
    }
    
    @Test("returns empty array for empty input")
    func emptyArray() throws {
        let input = Token.Value.array([])
        let expected = Token.Value.array([])
        
        try validateEvaluation(of: input, by: filter, yields: expected)
    }
    
    // MARK: - Preserves Other Values
    
    @Test("preserves false values")
    func preservesFalseValues() throws {
        let input = Token.Value.array([.bool(true), .nil, .bool(false), .nil])
        let expected = Token.Value.array([.bool(true), .bool(false)])
        
        try validateEvaluation(of: input, by: filter, yields: expected)
    }
    
    @Test("preserves zero values")
    func preservesZeroValues() throws {
        let input = Token.Value.array([.integer(1), .nil, .integer(0), .decimal(0.0), .nil])
        let expected = Token.Value.array([.integer(1), .integer(0), .decimal(0.0)])
        
        try validateEvaluation(of: input, by: filter, yields: expected)
    }
    
    @Test("preserves empty strings")
    func preservesEmptyStrings() throws {
        let input = Token.Value.array([.string("hello"), .nil, .string(""), .nil, .string("world")])
        let expected = Token.Value.array([.string("hello"), .string(""), .string("world")])
        
        try validateEvaluation(of: input, by: filter, yields: expected)
    }
    
    @Test("preserves empty arrays and dictionaries")
    func preservesEmptyCollections() throws {
        let input = Token.Value.array([
            .array([.string("a")]),
            .nil,
            .array([]),
            .dictionary(["key": .string("value")]),
            .nil,
            .dictionary([:])
        ])
        let expected = Token.Value.array([
            .array([.string("a")]),
            .array([]),
            .dictionary(["key": .string("value")]),
            .dictionary([:])
        ])
        
        try validateEvaluation(of: input, by: filter, yields: expected)
    }
    
    // MARK: - Mixed Types
    
    @Test("handles mixed types correctly")
    func mixedTypes() throws {
        let input = Token.Value.array([
            .string("text"),
            .nil,
            .integer(42),
            .nil,
            .bool(true),
            .decimal(3.14),
            .nil,
            .array([.string("nested")]),
            .dictionary(["key": .string("value")])
        ])
        let expected = Token.Value.array([
            .string("text"),
            .integer(42),
            .bool(true),
            .decimal(3.14),
            .array([.string("nested")]),
            .dictionary(["key": .string("value")])
        ])
        
        try validateEvaluation(of: input, by: filter, yields: expected)
    }
    
    // MARK: - Non-Array Inputs
    
    @Test("returns string unchanged")
    func nonArrayString() throws {
        let input = Token.Value.string("hello")
        let expected = Token.Value.string("hello")
        
        try validateEvaluation(of: input, by: filter, yields: expected)
    }
    
    @Test("returns integer unchanged")
    func nonArrayInteger() throws {
        let input = Token.Value.integer(42)
        let expected = Token.Value.integer(42)
        
        try validateEvaluation(of: input, by: filter, yields: expected)
    }
    
    @Test("returns nil unchanged")
    func nonArrayNil() throws {
        let input = Token.Value.nil
        let expected = Token.Value.nil
        
        try validateEvaluation(of: input, by: filter, yields: expected)
    }
    
    @Test("returns dictionary unchanged")
    func nonArrayDictionary() throws {
        let input = Token.Value.dictionary(["key": .string("value")])
        let expected = Token.Value.dictionary(["key": .string("value")])
        
        try validateEvaluation(of: input, by: filter, yields: expected)
    }
    
    // MARK: - Edge Cases
    
    @Test("handles nested arrays without flattening")
    func nestedArrays() throws {
        let input = Token.Value.array([
            .array([.string("a"), .nil, .string("b")]),
            .nil,
            .array([.nil, .nil]),
            .array([.string("c")])
        ])
        let expected = Token.Value.array([
            .array([.string("a"), .nil, .string("b")]),
            .array([.nil, .nil]),
            .array([.string("c")])
        ])
        
        try validateEvaluation(of: input, by: filter, yields: expected)
    }
    
    @Test("preserves order of non-nil elements")
    func preservesOrder() throws {
        let input = Token.Value.array([
            .string("first"),
            .nil,
            .string("second"),
            .nil,
            .nil,
            .string("third"),
            .string("fourth"),
            .nil
        ])
        let expected = Token.Value.array([
            .string("first"),
            .string("second"),
            .string("third"),
            .string("fourth")
        ])
        
        try validateEvaluation(of: input, by: filter, yields: expected)
    }
}