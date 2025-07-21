import Foundation
import Testing
@testable import LiquidKit

/// Error types for Golden Liquid test loading
enum GoldenLiquidError: Error, LocalizedError {
    case resourceNotFound(String)
    case invalidData(String)
    
    var errorDescription: String? {
        switch self {
        case .resourceNotFound(let message):
            return "Resource not found: \(message)"
        case .invalidData(let message):
            return "Invalid data: \(message)"
        }
    }
}

/// Represents the golden-liquid test suite file structure
struct GoldenLiquidSuite: Codable {
    let description: String
    let tests: [GoldenLiquidTestCase]
}

/// Represents a test case from the golden-liquid test suite.
/// Golden-liquid is a standardized test format for Liquid template engines.
///
/// Each test case has:
/// - `name`: A descriptive name for the test
/// - `template`: The Liquid template string to test
/// - One of three outcomes:
///   - `result`: Expected output string for successful rendering
///   - `results`: Array of acceptable output strings (for cases with multiple valid outputs)
///   - `invalid`: Boolean indicating the template should fail to parse/render
/// - Optional fields:
///   - `data`: Context data to use when rendering (arbitrary JSON)
///   - `templates`: Additional named templates (for include/render tags)
///   - `tags`: Tags to categorize or filter tests
struct GoldenLiquidTestCase: Codable {
    /// The name of the test case
    let name: String
    
    /// The Liquid template string to test
    let template: String
    
    /// The expected outcome of rendering the template
    let outcome: Outcome
    
    /// Context data to use when rendering the template
    let data: [String: Token.Value]?
    
    /// Additional named templates for include/render tags
    let templates: [String: String]?
    
    /// Tags for categorizing or filtering tests
    let tags: [String]?
    
    /// Represents the three possible test outcomes
    enum Outcome {
        /// Template should render to this exact string
        case singleResult(String)
        
        /// Template should render to one of these strings
        case multipleResults([String])
        
        /// Template should fail to parse or render
        case invalid
    }
    
    // MARK: - Codable Implementation
    
    enum CodingKeys: String, CodingKey {
        case name
        case template
        case result
        case results
        case invalid
        case data
        case templates
        case tags
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode required fields
        self.name = try container.decode(String.self, forKey: .name)
        self.template = try container.decode(String.self, forKey: .template)
        
        // Decode one of the three outcome fields
        if let result = try container.decodeIfPresent(String.self, forKey: .result) {
            self.outcome = .singleResult(result)
        } else if let results = try container.decodeIfPresent([String].self, forKey: .results) {
            self.outcome = .multipleResults(results)
        } else if let invalid = try container.decodeIfPresent(Bool.self, forKey: .invalid), invalid {
            self.outcome = .invalid
        } else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Test case must have either 'result', 'results', or 'invalid' field"
                )
            )
        }
        
        // Decode optional fields
        if let jsonData = try container.decodeIfPresent([String: JSONValue].self, forKey: .data) {
            self.data = try Self.convertJSONToTokens(jsonData)
        } else {
            self.data = nil
        }
        
        self.templates = try container.decodeIfPresent([String: String].self, forKey: .templates)
        self.tags = try container.decodeIfPresent([String].self, forKey: .tags)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(name, forKey: .name)
        try container.encode(template, forKey: .template)
        
        switch outcome {
        case .singleResult(let result):
            try container.encode(result, forKey: .result)
        case .multipleResults(let results):
            try container.encode(results, forKey: .results)
        case .invalid:
            try container.encode(true, forKey: .invalid)
        }
        
        if let data = data {
            let jsonData = try Self.convertTokensToJSON(data)
            try container.encode(jsonData, forKey: .data)
        }
        
        try container.encodeIfPresent(templates, forKey: .templates)
        try container.encodeIfPresent(tags, forKey: .tags)
    }
    
    // MARK: - JSON to Token Conversion
    
    /// Intermediate type for decoding arbitrary JSON values
    private enum JSONValue: Codable {
        case null
        case bool(Bool)
        case string(String)
        case number(Double)
        case array([JSONValue])
        case object([String: JSONValue])
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            
            if container.decodeNil() {
                self = .null
            } else if let bool = try? container.decode(Bool.self) {
                self = .bool(bool)
            } else if let string = try? container.decode(String.self) {
                self = .string(string)
            } else if let int = try? container.decode(Int.self) {
                self = .number(Double(int))
            } else if let double = try? container.decode(Double.self) {
                self = .number(double)
            } else if let array = try? container.decode([JSONValue].self) {
                self = .array(array)
            } else if let object = try? container.decode([String: JSONValue].self) {
                self = .object(object)
            } else {
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: decoder.codingPath,
                        debugDescription: "Unable to decode JSON value"
                    )
                )
            }
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            
            switch self {
            case .null:
                try container.encodeNil()
            case .bool(let value):
                try container.encode(value)
            case .string(let value):
                try container.encode(value)
            case .number(let value):
                // Encode as Int if it's a whole number
                if value.truncatingRemainder(dividingBy: 1) == 0 {
                    try container.encode(Int(value))
                } else {
                    try container.encode(value)
                }
            case .array(let value):
                try container.encode(value)
            case .object(let value):
                try container.encode(value)
            }
        }
    }
    
    /// Converts JSON values to LiquidKit Token types
    private static func convertJSONToTokens(_ json: [String: JSONValue]) throws -> [String: Token.Value] {
        var result: [String: Token.Value] = [:]
        
        for (key, value) in json {
            result[key] = try convertJSONValueToToken(value)
        }
        
        return result
    }
    
    private static func convertJSONValueToToken(_ value: JSONValue) throws -> Token.Value {
        switch value {
        case .null:
            return .nil
        case .bool(let bool):
            return .bool(bool)
        case .string(let string):
            return .string(string)
        case .number(let number):
            // Determine if it should be an integer or decimal
            if number.truncatingRemainder(dividingBy: 1) == 0 {
                return .integer(Int(number))
            } else {
                return .decimal(Decimal(number))
            }
        case .array(let array):
            let tokens = try array.map { try convertJSONValueToToken($0) }
            return .array(tokens)
        case .object(let object):
            let tokens = try convertJSONToTokens(object)
            return .dictionary(tokens)
        }
    }
    
    /// Converts LiquidKit Tokens back to JSON values for encoding
    private static func convertTokensToJSON(_ tokens: [String: Token.Value]) throws -> [String: JSONValue] {
        var result: [String: JSONValue] = [:]
        
        for (key, token) in tokens {
            result[key] = try convertTokenToJSONValue(token)
        }
        
        return result
    }
    
    private static func convertTokenToJSONValue(_ token: Token.Value) throws -> JSONValue {
        switch token {
        case .nil:
            return .null
        case .bool(let value):
            return .bool(value)
        case .string(let value):
            return .string(value)
        case .integer(let value):
            return .number(Double(value))
        case .decimal(let value):
            return .number(Double(truncating: value as NSNumber))
        case .array(let value):
            let jsonValues = try value.map { try convertTokenToJSONValue($0) }
            return .array(jsonValues)
        case .dictionary(let value):
            let jsonObject = try convertTokensToJSON(value)
            return .object(jsonObject)
        case .range:
            // Ranges can't be represented in JSON, throw an error
            throw EncodingError.invalidValue(
                token,
                EncodingError.Context(
                    codingPath: [],
                    debugDescription: "Cannot encode Token.range to JSON"
                )
            )
        }
    }
}

// MARK: - Conformances

extension GoldenLiquidTestCase: CustomTestStringConvertible {
  public var testDescription: String {
    return "\(name): `\(template)`"
  }
}

// MARK: - Convenience Methods

extension GoldenLiquidTestCase {
    /// Loads test cases from a JSON file
    static func loadFromFile(at url: URL) throws -> [GoldenLiquidTestCase] {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode([GoldenLiquidTestCase].self, from: data)
    }
    
    /// Loads test cases from JSON data
    static func loadFromData(_ data: Data) throws -> [GoldenLiquidTestCase] {
        let decoder = JSONDecoder()
        return try decoder.decode([GoldenLiquidTestCase].self, from: data)
    }
    
    /// Loads the golden-liquid test suite from the test bundle resources
    static func loadGoldenLiquidSuite() throws -> GoldenLiquidSuite {
        guard let url = Bundle.module.url(forResource: "golden_liquid", withExtension: "json", subdirectory: "Resources") else {
            throw GoldenLiquidError.resourceNotFound("golden_liquid.json not found in test bundle")
        }
        
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode(GoldenLiquidSuite.self, from: data)
    }
    
    /// Loads all test cases from the golden-liquid test suite in the bundle
    static func loadAllTestCases() throws -> [GoldenLiquidTestCase] {
        let suite = try loadGoldenLiquidSuite()
        return suite.tests
    }
    
    /// Loads test cases filtered by tag from the golden-liquid test suite
    static func loadTestCases(withTag tag: String) throws -> [GoldenLiquidTestCase] {
        let allTests = try loadAllTestCases()
        return allTests.filter { $0.hasTag(tag) }
    }
    
    /// Loads test cases filtered by multiple tags (must have all tags)
    static func loadTestCases(withTags tags: [String]) throws -> [GoldenLiquidTestCase] {
        let allTests = try loadAllTestCases()
        return allTests.filter { testCase in
            tags.allSatisfy { tag in testCase.hasTag(tag) }
        }
    }
    
    /// Loads test cases with mandatory data for use in @Test macro invocations
    /// This function will fatalError if the test data cannot be loaded, which is appropriate
    /// for test setup that should never fail in a properly configured test environment.
    static func mandatoryData(
        withTag testCaseTag: String,
        file: StaticString = #file,
        line: UInt = #line
    ) -> [GoldenLiquidTestCase] {
        do {
            return try GoldenLiquidTestCase.loadTestCases(withTag: testCaseTag)
        }
        catch let error {
            fatalError(
                """
                Unable to load mandatory test-case data!
                
                - tag: \(testCaseTag)
                - error: \(String(reflecting: error))
                - file: \(file)
                - line: \(line)
                """,
                file: file,
                line: line
            )
        }
    }
    
    /// Creates a Context object from this test case's data
    func createContext() -> Context {
        if let data = data {
            return Context(dictionary: data)
        } else {
            return Context()
        }
    }
    
    /// Checks if this test case has a specific tag
    func hasTag(_ tag: String) -> Bool {
        tags?.contains(tag) ?? false
    }
}

// MARK: - Test Helpers

extension GoldenLiquidTestCase {
    /// Validates the rendered output against the expected outcome
    func validate(output: String) -> Bool {
        switch outcome {
        case .singleResult(let expected):
            return output == expected
        case .multipleResults(let acceptableResults):
            return acceptableResults.contains(output)
        case .invalid:
            // If we got here with output, the test failed (should have thrown)
            return false
        }
    }
    
    /// Returns whether this test case expects parsing/rendering to fail
    var shouldFail: Bool {
        if case .invalid = outcome {
            return true
        }
        return false
    }
    
    /// Returns the expected result(s) as a string for debugging
    var expectedDescription: String {
        switch outcome {
        case .singleResult(let result):
            return "Expected: \(result)"
        case .multipleResults(let results):
            return "Expected one of: \(results.joined(separator: " | "))"
        case .invalid:
            return "Expected: parsing/rendering failure"
        }
    }
}
