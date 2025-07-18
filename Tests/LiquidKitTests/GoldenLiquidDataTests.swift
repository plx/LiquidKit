import XCTest
@testable import LiquidKit

/// Tests for loading and validating the golden-liquid test suite data
final class GoldenLiquidDataTests: XCTestCase {
    
    // MARK: - Basic Resource Loading Tests
    
    func testLoadGoldenLiquidResource() throws {
        // Test that we can find and load the golden_liquid.json resource
        let url = try XCTUnwrap(
            Bundle.module.url(forResource: "golden_liquid", withExtension: "json", subdirectory: "Resources"),
            "Should find golden_liquid.json in test bundle resources"
        )
        
        // Verify the file exists and is readable
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path), "golden_liquid.json should exist at path")
        
        // Try to load the data
        let data = try Data(contentsOf: url)
        XCTAssertGreaterThan(data.count, 0, "golden_liquid.json should not be empty")
    }
    
    func testDecodeGoldenLiquidSuite() throws {
        // Test that we can decode the suite structure
        let suite = try GoldenLiquidTestCase.loadGoldenLiquidSuite()
        
        XCTAssertEqual(suite.description, "Golden Liquid test suite", "Suite should have expected description")
        XCTAssertGreaterThan(suite.tests.count, 0, "Suite should contain test cases")
    }
    
    func testLoadAllTestCases() throws {
        // Test the convenience method for loading all test cases
        let testCases = try GoldenLiquidTestCase.loadAllTestCases()
        
        XCTAssertGreaterThan(testCases.count, 100, "Should have many test cases (golden-liquid has hundreds)")
        
        // Verify that all test cases have required fields
        for testCase in testCases {
            XCTAssertFalse(testCase.name.isEmpty, "Test case should have a name")
            XCTAssertFalse(testCase.template.isEmpty, "Test case should have a template")
        }
    }
    
    // MARK: - Test Case Structure Validation
    
    func testTestCaseOutcomes() throws {
        let testCases = try GoldenLiquidTestCase.loadAllTestCases()
        
        var singleResultCount = 0
        var multipleResultsCount = 0
        var invalidCount = 0
        
        for testCase in testCases {
            switch testCase.outcome {
            case .singleResult:
                singleResultCount += 1
            case .multipleResults:
                multipleResultsCount += 1
            case .invalid:
                invalidCount += 1
            }
        }
        
        XCTAssertGreaterThan(singleResultCount, 0, "Should have test cases with single results")
        XCTAssertGreaterThan(invalidCount, 0, "Should have test cases that expect invalid templates")
        
        print("Test case outcome distribution:")
        print("  Single result: \(singleResultCount)")
        print("  Multiple results: \(multipleResultsCount)")
        print("  Invalid: \(invalidCount)")
    }
    
    func testTestCaseData() throws {
        let testCases = try GoldenLiquidTestCase.loadAllTestCases()
        
        let casesWithData = testCases.filter { $0.data != nil }
        XCTAssertGreaterThan(casesWithData.count, 0, "Should have test cases with context data")
        
        // Verify we can create contexts from the data
        for testCase in casesWithData.prefix(10) {
            let context = testCase.createContext()
            XCTAssertNotNil(context, "Should be able to create context from test case data")
        }
    }
    
    func testTestCaseTags() throws {
        let testCases = try GoldenLiquidTestCase.loadAllTestCases()
        
        let casesWithTags = testCases.filter { $0.tags != nil && !$0.tags!.isEmpty }
        XCTAssertGreaterThan(casesWithTags.count, 0, "Should have test cases with tags")
        
        // Collect all unique tags
        var allTags = Set<String>()
        for testCase in casesWithTags {
            if let tags = testCase.tags {
                allTags.formUnion(tags)
            }
        }
        
        print("Found \(allTags.count) unique tags:")
        for tag in allTags.sorted() {
            let count = testCases.filter { $0.hasTag(tag) }.count
            print("  \(tag): \(count) test cases")
        }
    }
    
    // MARK: - Filtering Tests
    
    func testLoadTestCasesWithTag() throws {
        // Try to load test cases with a specific tag
        // First, find a tag that exists
        let allTests = try GoldenLiquidTestCase.loadAllTestCases()
        let testWithTag = allTests.first { $0.tags != nil && !$0.tags!.isEmpty }
        
        if let tag = testWithTag?.tags?.first {
            let filteredTests = try GoldenLiquidTestCase.loadTestCases(withTag: tag)
            XCTAssertGreaterThan(filteredTests.count, 0, "Should find tests with tag '\(tag)'")
            
            // Verify all returned tests have the tag
            for test in filteredTests {
                XCTAssertTrue(test.hasTag(tag), "Filtered test should have the requested tag")
            }
        }
    }
    
    func testLoadTestCasesWithMultipleTags() throws {
        // Try to load test cases that have multiple specific tags
        let allTests = try GoldenLiquidTestCase.loadAllTestCases()
        
        // Find tests that have at least 2 tags
        let testsWithMultipleTags = allTests.filter { ($0.tags?.count ?? 0) >= 2 }
        
        if let testCase = testsWithMultipleTags.first,
           let tags = testCase.tags?.prefix(2) {
            let requiredTags = Array(tags)
            let filteredTests = try GoldenLiquidTestCase.loadTestCases(withTags: requiredTags)
            
            XCTAssertGreaterThan(filteredTests.count, 0, "Should find tests with tags \(requiredTags)")
            
            // Verify all returned tests have all required tags
            for test in filteredTests {
                for tag in requiredTags {
                    XCTAssertTrue(test.hasTag(tag), "Filtered test should have all requested tags")
                }
            }
        }
    }
    
    // MARK: - Data Type Conversion Tests
    
    func testJSONToTokenConversion() throws {
        let testCases = try GoldenLiquidTestCase.loadAllTestCases()
        
        // Find test cases with various data types
        for testCase in testCases {
            if let data = testCase.data {
                for (key, value) in data {
                    switch value {
                    case .nil:
                        print("Found nil value for key: \(key)")
                    case .bool(let b):
                        print("Found bool \(b) for key: \(key)")
                    case .string(let s):
                        print("Found string '\(s)' for key: \(key)")
                    case .integer(let i):
                        print("Found integer \(i) for key: \(key)")
                    case .decimal(let d):
                        print("Found decimal \(d) for key: \(key)")
                    case .array(let a):
                        print("Found array with \(a.count) elements for key: \(key)")
                    case .dictionary(let d):
                        print("Found dictionary with \(d.count) keys for key: \(key)")
                    case .range:
                        print("Found range for key: \(key)")
                    }
                    
                    // We found at least one data value, that's enough for this test
                    return
                }
            }
        }
        
        XCTFail("Should have found at least one test case with data")
    }
    
    // MARK: - Sample Test Execution
    
    func testSampleTestCaseExecution() throws {
        // Load a few test cases and try to execute them
        let testCases = try GoldenLiquidTestCase.loadAllTestCases()
        
        // Find a simple test case that should succeed
        let simpleTest = testCases.first { testCase in
            testCase.template.contains("{{") &&
            !testCase.shouldFail &&
            testCase.data == nil &&
            testCase.templates == nil
        }
        
        if let test = simpleTest {
            print("Testing: \(test.name)")
            print("Template: \(test.template)")
            print(test.expectedDescription)
            
            // This is just to verify the test case structure is valid
            // Actual execution will be done in integration tests
            XCTAssertNotNil(test.outcome, "Test case should have an outcome")
        }
    }
    
    // MARK: - Performance Tests
    
    func testLoadingPerformance() throws {
        // Measure how long it takes to load and parse all test cases
        measure {
            do {
                _ = try GoldenLiquidTestCase.loadAllTestCases()
            } catch {
                XCTFail("Failed to load test cases: \(error)")
            }
        }
    }
}