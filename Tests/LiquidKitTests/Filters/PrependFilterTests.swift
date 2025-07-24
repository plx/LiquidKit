import Testing
import Foundation
@testable import LiquidKit

@Suite(.tags(.filter, .prependFilter))
struct PrependFilterTests {
    private let filter = PrependFilter()
    
    // MARK: - String Inputs
    
    @Test("prepends string to string")
    func prependStringToString() throws {
        try validateEvaluation(
            of: "world",
            with: [Token.Value.string("Hello, ")],
            by: filter,
            yields: "Hello, world"
        )
    }
    
    @Test("prepends empty string to string")
    func prependEmptyStringToString() throws {
        try validateEvaluation(
            of: "world",
            with: [Token.Value.string("")],
            by: filter,
            yields: "world"
        )
    }
    
    @Test("prepends string to empty string")
    func prependStringToEmptyString() throws {
        try validateEvaluation(
            of: "",
            with: [Token.Value.string("Hello")],
            by: filter,
            yields: "Hello"
        )
    }
    
    @Test("prepends empty string to empty string")
    func prependEmptyStringToEmptyString() throws {
        try validateEvaluation(
            of: "",
            with: [Token.Value.string("")],
            by: filter,
            yields: ""
        )
    }
    
    @Test("prepends with special characters")
    func prependSpecialCharacters() throws {
        try validateEvaluation(
            of: "world!",
            with: [Token.Value.string("Hello, 🌍 ")],
            by: filter,
            yields: "Hello, 🌍 world!"
        )
    }
    
    // MARK: - Type Conversion Tests
    
    @Test("prepends string to integer")
    func prependStringToInteger() throws {
        try validateEvaluation(
            of: 42,
            with: [Token.Value.string("Answer: ")],
            by: filter,
            yields: "Answer: 42"
        )
    }
    
    @Test("prepends integer to string")
    func prependIntegerToString() throws {
        try validateEvaluation(
            of: " items",
            with: [Token.Value.integer(5)],
            by: filter,
            yields: "5 items"
        )
    }
    
    @Test("prepends decimal to string")
    func prependDecimalToString() throws {
        try validateEvaluation(
            of: " USD",
            with: [Token.Value.decimal(Decimal(3.14))],
            by: filter,
            yields: "3.14 USD"
        )
    }
    
    @Test("prepends string to decimal")
    func prependStringToDecimal() throws {
        try validateEvaluation(
            of: 3.14159,
            with: [Token.Value.string("Pi: ")],
            by: filter,
            yields: "Pi: 3.14159"
        )
    }
    
    @Test("prepends boolean to string")
    func prependBooleanToString() throws {
        try validateEvaluation(
            of: " value",
            with: [Token.Value.bool(true)],
            by: filter,
            yields: "true value"
        )
        
        try validateEvaluation(
            of: " flag",
            with: [Token.Value.bool(false)],
            by: filter,
            yields: "false flag"
        )
    }
    
    @Test("prepends string to boolean")
    func prependStringToBoolean() throws {
        try validateEvaluation(
            of: true,
            with: [Token.Value.string("Setting: ")],
            by: filter,
            yields: "Setting: true"
        )
        
        try validateEvaluation(
            of: false,
            with: [Token.Value.string("Enabled: ")],
            by: filter,
            yields: "Enabled: false"
        )
    }
    
    // MARK: - Nil Handling
    
    @Test("prepends nil to string")
    func prependNilToString() throws {
        try validateEvaluation(
            of: "text",
            with: [Token.Value.nil],
            by: filter,
            yields: "text"
        )
    }
    
    @Test("prepends string to nil")
    func prependStringToNil() throws {
        try validateEvaluation(
            of: Token.Value.nil,
            with: [Token.Value.string("text")],
            by: filter,
            yields: "text"
        )
    }
    
    @Test("prepends nil to nil")
    func prependNilToNil() throws {
        try validateEvaluation(
            of: Token.Value.nil,
            with: [Token.Value.nil],
            by: filter,
            yields: ""
        )
    }
    
    // MARK: - Complex Types
    
    @Test("prepends string to array")
    func prependStringToArray() throws {
        try validateEvaluation(
            of: ["a", "b", "c"],
            with: [Token.Value.string("Items: ")],
            by: filter,
            yields: "Items: [\"a\", \"b\", \"c\"]"
        )
    }
    
    @Test("prepends array to string")
    func prependArrayToString() throws {
        try validateEvaluation(
            of: " are the items",
            with: [Token.Value.array([.string("x"), .string("y"), .string("z")])],
            by: filter,
            yields: "[\"x\", \"y\", \"z\"] are the items"
        )
    }
    
    @Test("prepends string to dictionary")
    func prependStringToDictionary() throws {
        try validateEvaluation(
            of: ["name": "John", "age": 30],
            with: [Token.Value.string("User: ")],
            by: filter,
            yields: "User: {\"age\": 30, \"name\": \"John\"}"
        )
    }
    
    @Test("prepends dictionary to string")
    func prependDictionaryToString() throws {
        try validateEvaluation(
            of: " is the data",
            with: [Token.Value.dictionary(["key": .string("value")])],
            by: filter,
            yields: "{\"key\": \"value\"} is the data"
        )
    }
    
    @Test("prepends string to range")
    func prependStringToRange() throws {
        try validateEvaluation(
            of: 1...5,
            with: [Token.Value.string("Range: ")],
            by: filter,
            yields: "Range: 1..5"
        )
    }
    
    @Test("prepends range to string")
    func prependRangeToString() throws {
        try validateEvaluation(
            of: " elements",
            with: [Token.Value.range(10...20)],
            by: filter,
            yields: "10..20 elements"
        )
    }
    
    // MARK: - Parameter Edge Cases
    
    @Test("returns nil when no parameters provided")
    func returnsNilWithNoParameters() throws {
        try validateEvaluation(
            of: "text",
            with: [],
            by: filter,
            yields: Token.Value.nil
        )
    }
    
    @Test("ignores extra parameters")
    func ignoresExtraParameters() throws {
        try validateEvaluation(
            of: "world",
            with: [Token.Value.string("Hello, "), Token.Value.string("extra"), Token.Value.string("params")],
            by: filter,
            yields: "Hello, world"
        )
    }
    
    // MARK: - Real-world Examples
    
    @Test("prepends URL scheme")
    func prependURLScheme() throws {
        try validateEvaluation(
            of: "example.com/index.html",
            with: [Token.Value.string("https://")],
            by: filter,
            yields: "https://example.com/index.html"
        )
    }
    
    @Test("prepends file path")
    func prependFilePath() throws {
        try validateEvaluation(
            of: "file.txt",
            with: [Token.Value.string("/home/user/")],
            by: filter,
            yields: "/home/user/file.txt"
        )
    }
    
    @Test("prepends currency symbol")
    func prependCurrencySymbol() throws {
        try validateEvaluation(
            of: 99.99,
            with: [Token.Value.string("$")],
            by: filter,
            yields: "$99.99"
        )
    }
    
    @Test("prepends label to count")
    func prependLabelToCount() throws {
        try validateEvaluation(
            of: 42,
            with: [Token.Value.string("Total: ")],
            by: filter,
            yields: "Total: 42"
        )
    }
}