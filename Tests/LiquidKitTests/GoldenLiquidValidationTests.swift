import Testing
@testable import LiquidKit

/// Data-driven validation tests that run the golden-liquid test suite against LiquidKit's implementation.
/// This test suite validates LiquidKit's compatibility with the standard Liquid template language.
@Suite("Golden Liquid Validation Tests")
struct GoldenLiquidValidationTests {
    
    // MARK: - Helper Methods
    
    /// Renders a template with the given context and validates it matches the expected outcome
    private func validateTestCase(_ testCase: GoldenLiquidTestCase) throws {
        do {
            // Create lexer and parse the template
            let lexer = Lexer(templateString: testCase.template)
            let tokens = lexer.tokenize()
            
            // Create parser with context
            let context = testCase.createContext()
            let parser = Parser(tokens: tokens, context: context)
            
            // For invalid test cases, we expect parsing or rendering to throw
            if testCase.shouldFail {
                // Try to parse and render - should throw
                let parts = parser.parse()
                let output = parts.joined()
                
                // If we get here, the test failed (should have thrown)
                throw TestError.expectedFailure("Expected error but got output: \(output)")
            }
            
            // Parse the template
            let parts = parser.parse()
            
            // Render the template by joining all parts
            let output = parts.joined()
            
            // Validate the output
            switch testCase.outcome {
            case .singleResult(let expected):
                if output != expected {
                    throw TestError.wrongOutput(expected: expected, actual: output)
                }
                
            case .multipleResults(let acceptableResults):
                if !acceptableResults.contains(output) {
                    throw TestError.wrongOutput(expected: acceptableResults.joined(separator: " | "), actual: output)
                }
                
            case .invalid:
                throw TestError.expectedFailure("Test case marked as invalid but didn't throw")
            }
        } catch let error as TestError {
            throw error
        } catch {
            // For tests that should fail, any error is success
            if testCase.shouldFail {
                return
            }
            throw error
        }
    }
    
    enum TestError: Error {
        case expectedFailure(String)
        case wrongOutput(expected: String, actual: String)
        
        var localizedDescription: String {
            switch self {
            case .expectedFailure(let msg):
                return "Expected failure: \(msg)"
            case .wrongOutput(let expected, let actual):
                return "Wrong output - Expected: \(expected), Actual: \(actual)"
            }
        }
    }
    
    // MARK: - Filter Tests
    
    @Test("Capitalize Filter", arguments: try! GoldenLiquidTestCase.loadTestCases(withTag: "capitalize filter"))
    func testCapitalizeFilter(_ testCase: GoldenLiquidTestCase) throws {
        try validateTestCase(testCase)
    }
    
    @Test("Downcase Filter", arguments: try! GoldenLiquidTestCase.loadTestCases(withTag: "downcase filter"))
    func testDowncaseFilter(_ testCase: GoldenLiquidTestCase) throws {
        try validateTestCase(testCase)
    }
    
    @Test("Upcase Filter", arguments: try! GoldenLiquidTestCase.loadTestCases(withTag: "upcase filter"))
    func testUpcaseFilter(_ testCase: GoldenLiquidTestCase) throws {
        try validateTestCase(testCase)
    }
    
    @Test("Escape Filter", arguments: try! GoldenLiquidTestCase.loadTestCases(withTag: "escape filter"))
    func testEscapeFilter(_ testCase: GoldenLiquidTestCase) throws {
        try validateTestCase(testCase)
    }
    
    @Test("Strip HTML Filter", arguments: try! GoldenLiquidTestCase.loadTestCases(withTag: "strip_html filter"))
    func testStripHtmlFilter(_ testCase: GoldenLiquidTestCase) throws {
        try validateTestCase(testCase)
    }
    
    @Test("Date Filter", arguments: try! GoldenLiquidTestCase.loadTestCases(withTag: "date filter"))
    func testDateFilter(_ testCase: GoldenLiquidTestCase) throws {
        try validateTestCase(testCase)
    }
    
    @Test("Join Filter", arguments: try! GoldenLiquidTestCase.loadTestCases(withTag: "join filter"))
    func testJoinFilter(_ testCase: GoldenLiquidTestCase) throws {
        try validateTestCase(testCase)
    }
    
    @Test("Split Filter", arguments: try! GoldenLiquidTestCase.loadTestCases(withTag: "split filter"))
    func testSplitFilter(_ testCase: GoldenLiquidTestCase) throws {
        try validateTestCase(testCase)
    }
    
    @Test("Replace Filter", arguments: try! GoldenLiquidTestCase.loadTestCases(withTag: "replace filter"))
    func testReplaceFilter(_ testCase: GoldenLiquidTestCase) throws {
        try validateTestCase(testCase)
    }
    
    @Test("Size Filter", arguments: try! GoldenLiquidTestCase.loadTestCases(withTag: "size filter"))
    func testSizeFilter(_ testCase: GoldenLiquidTestCase) throws {
        try validateTestCase(testCase)
    }
    
    @Test("Sort Filter", arguments: try! GoldenLiquidTestCase.loadTestCases(withTag: "sort filter"))
    func testSortFilter(_ testCase: GoldenLiquidTestCase) throws {
        try validateTestCase(testCase)
    }
    
    @Test("Where Filter", arguments: try! GoldenLiquidTestCase.loadTestCases(withTag: "where filter"))
    func testWhereFilter(_ testCase: GoldenLiquidTestCase) throws {
        try validateTestCase(testCase)
    }
    
    // MARK: - Basic Tag Tests
    
    @Test("Comment Tag Tests", arguments: try! GoldenLiquidTestCase.loadTestCases(withTag: "comment tag"))
    func testCommentTag(_ testCase: GoldenLiquidTestCase) throws {
        try validateTestCase(testCase)
    }
    
    @Test("Raw Tag Tests", arguments: try! GoldenLiquidTestCase.loadTestCases(withTag: "raw tag"))
    func testRawTag(_ testCase: GoldenLiquidTestCase) throws {
        try validateTestCase(testCase)
    }
    
    @Test("Assign Tag Tests", arguments: try! GoldenLiquidTestCase.loadTestCases(withTag: "assign tag"))
    func testAssignTag(_ testCase: GoldenLiquidTestCase) throws {
        try validateTestCase(testCase)
    }
    
    @Test("Capture Tag Tests", arguments: try! GoldenLiquidTestCase.loadTestCases(withTag: "capture tag"))
    func testCaptureTag(_ testCase: GoldenLiquidTestCase) throws {
        try validateTestCase(testCase)
    }
    
    // MARK: - Control Flow Tests
    
    @Test("If/Else Tag Tests", arguments: try! GoldenLiquidTestCase.loadTestCases(withTag: "if tag"))
    func testIfTag(_ testCase: GoldenLiquidTestCase) throws {
        try validateTestCase(testCase)
    }
    
    @Test("Unless Tag Tests", arguments: try! GoldenLiquidTestCase.loadTestCases(withTag: "unless tag"))
    func testUnlessTag(_ testCase: GoldenLiquidTestCase) throws {
        try validateTestCase(testCase)
    }
    
    @Test("Case/When Tag Tests", arguments: try! GoldenLiquidTestCase.loadTestCases(withTag: "case tag"))
    func testCaseTag(_ testCase: GoldenLiquidTestCase) throws {
        try validateTestCase(testCase)
    }
    
    // MARK: - Loop Tests
    
    @Test("For Loop Tests", arguments: try! GoldenLiquidTestCase.loadTestCases(withTag: "for tag"))
    func testForLoop(_ testCase: GoldenLiquidTestCase) throws {
        try validateTestCase(testCase)
    }
    
    @Test("Cycle Tag Tests", arguments: try! GoldenLiquidTestCase.loadTestCases(withTag: "cycle tag"))
    func testCycleTag(_ testCase: GoldenLiquidTestCase) throws {
        try validateTestCase(testCase)
    }
    
    @Test("Tablerow Tag Tests", arguments: try! GoldenLiquidTestCase.loadTestCases(withTag: "tablerow tag"))
    func testTablerowTag(_ testCase: GoldenLiquidTestCase) throws {
        try validateTestCase(testCase)
    }
    
    // MARK: - Variable and Output Tests
    
    @Test("Variable Output Tests", arguments: try! GoldenLiquidTestCase.loadTestCases(withTag: "variable"))
    func testVariableOutput(_ testCase: GoldenLiquidTestCase) throws {
        try validateTestCase(testCase)
    }
    
    @Test("Echo Tag Tests", arguments: try! GoldenLiquidTestCase.loadTestCases(withTag: "echo tag"))
    func testEchoTag(_ testCase: GoldenLiquidTestCase) throws {
        try validateTestCase(testCase)
    }
    
    // MARK: - Advanced Feature Tests
    
    @Test("Include Tag Tests", arguments: try! GoldenLiquidTestCase.loadTestCases(withTag: "include tag"))
    func testIncludeTag(_ testCase: GoldenLiquidTestCase) throws {
        if testCase.templates != nil {
            Issue.record("Include tag with templates not yet supported")
            return
        }
        try validateTestCase(testCase)
    }
    
    @Test("Render Tag Tests", arguments: try! GoldenLiquidTestCase.loadTestCases(withTag: "render tag"))
    func testRenderTag(_ testCase: GoldenLiquidTestCase) throws {
        if testCase.templates != nil {
            Issue.record("Render tag with templates not yet supported")
            return
        }
        try validateTestCase(testCase)
    }
    
    @Test("Liquid Tag Tests", arguments: try! GoldenLiquidTestCase.loadTestCases(withTag: "liquid tag"))
    func testLiquidTag(_ testCase: GoldenLiquidTestCase) throws {
        // Liquid tag is a newer feature that allows Liquid syntax without delimiters
        Issue.record("Liquid tag not yet implemented")
    }
    
    // MARK: - Operator Tests
    
    @Test("Operator Tests", arguments: try! GoldenLiquidTestCase.loadTestCases(withTag: "operators"))
    func testOperators(_ testCase: GoldenLiquidTestCase) throws {
        try validateTestCase(testCase)
    }
    
    // MARK: - Whitespace Control Tests
    
    @Test("Whitespace Control Tests", arguments: try! GoldenLiquidTestCase.loadTestCases(withTag: "whitespace"))
    func testWhitespaceControl(_ testCase: GoldenLiquidTestCase) throws {
        // Whitespace control with {%- and -%} may not be fully implemented
        try validateTestCase(testCase)
    }
    
    // MARK: - Error Handling Tests
    
    @Test("Error Handling Tests", arguments: try! GoldenLiquidTestCase.loadTestCases(withTag: "errors"))
    func testErrorHandling(_ testCase: GoldenLiquidTestCase) throws {
        try validateTestCase(testCase)
    }
    
    // MARK: - Summary Test
    
    @Test("Overall Test Suite Summary")
    func testSuiteSummary() throws {
        let allTests = try GoldenLiquidTestCase.loadAllTestCases()
        
        // Group tests by tag for analysis
        var tagCounts: [String: Int] = [:]
        var testsWithoutTags = 0
        
        for test in allTests {
            if let tags = test.tags {
                for tag in tags {
                    tagCounts[tag, default: 0] += 1
                }
            } else {
                testsWithoutTags += 1
            }
        }
        
        // Print summary
        print("\n=== Golden Liquid Test Suite Summary ===")
        print("Total test cases: \(allTests.count)")
        print("Tests without tags: \(testsWithoutTags)")
        print("\nTest counts by tag:")
        
        let sortedTags = tagCounts.sorted { $0.value > $1.value }
        for (tag, count) in sortedTags {
            print("  \(tag): \(count)")
        }
        
        // Count outcome types
        var singleResult = 0
        var multipleResults = 0
        var invalid = 0
        
        for test in allTests {
            switch test.outcome {
            case .singleResult:
                singleResult += 1
            case .multipleResults:
                multipleResults += 1
            case .invalid:
                invalid += 1
            }
        }
        
        print("\nOutcome types:")
        print("  Single result: \(singleResult)")
        print("  Multiple results: \(multipleResults)")
        print("  Invalid (should error): \(invalid)")
        print("=======================================\n")
    }
    
    // MARK: - Comprehensive Test for All Cases
    
    @Test("Run All Tests and Generate Report")
    func testAllGoldenLiquidCases() throws {
        let allTests = try GoldenLiquidTestCase.loadAllTestCases()
        var passed = 0
        var failed = 0
        var skipped = 0
        var errorsByCategory: [String: Int] = [:]
        var failureDetails: [(name: String, error: String, tags: [String]?)] = []
        
        for testCase in allTests {
            // Skip tests that require external templates
            if testCase.templates != nil {
                skipped += 1
                continue
            }
            
            // Skip liquid tag tests (not implemented)
            if testCase.tags?.contains("liquid tag") == true {
                skipped += 1
                continue
            }
            
            do {
                try validateTestCase(testCase)
                passed += 1
            } catch {
                failed += 1
                let errorMsg = error.localizedDescription
                failureDetails.append((name: testCase.name, error: errorMsg, tags: testCase.tags))
                
                // Categorize errors
                if errorMsg.contains("Unknown tag") {
                    errorsByCategory["Unknown tag", default: 0] += 1
                } else if errorMsg.contains("Unknown filter") {
                    errorsByCategory["Unknown filter", default: 0] += 1
                } else if errorMsg.contains("Expected failure") {
                    errorsByCategory["Missing validation", default: 0] += 1
                } else if errorMsg.contains("Wrong output") {
                    errorsByCategory["Wrong output", default: 0] += 1
                } else if errorMsg.contains("Fatal error") || errorMsg.contains("precondition") {
                    errorsByCategory["Crash/Fatal", default: 0] += 1
                } else {
                    errorsByCategory["Other", default: 0] += 1
                }
            }
        }
        
        print("\n=== LiquidKit Golden Liquid Test Results ===")
        print("Total tests: \(allTests.count)")
        print("Executed: \(passed + failed)")
        print("Skipped: \(skipped)")
        print("Passed: \(passed)")
        print("Failed: \(failed)")
        print("Success rate: \(String(format: "%.1f", Double(passed) / Double(passed + failed) * 100))%")
        
        print("\nError Categories:")
        for (category, count) in errorsByCategory.sorted(by: { $0.value > $1.value }) {
            print("  \(category): \(count)")
        }
        
        // Group failures by tag
        var failuresByTag: [String: Int] = [:]
        for failure in failureDetails {
            if let tags = failure.tags {
                for tag in tags {
                    failuresByTag[tag, default: 0] += 1
                }
            } else {
                failuresByTag["No tags", default: 0] += 1
            }
        }
        
        print("\nFailures by tag:")
        for (tag, count) in failuresByTag.sorted(by: { $0.value > $1.value }).prefix(20) {
            print("  \(tag): \(count)")
        }
        
        print("\nSample failures:")
        for failure in failureDetails.prefix(10) {
            print("  - \(failure.name)")
            print("    Error: \(failure.error)")
            if let tags = failure.tags {
                print("    Tags: \(tags.joined(separator: ", "))")
            }
        }
        
        if failureDetails.count > 10 {
            print("  ... and \(failureDetails.count - 10) more failures")
        }
        
        print("============================================\n")
    }
}

// MARK: - Test Discovery Helpers

extension GoldenLiquidValidationTests {
    /// Helper to identify which features need implementation based on failing tests
    @Test("Feature Gap Analysis")
    func analyzeFeatureGaps() throws {
        _ = try GoldenLiquidTestCase.loadAllTestCases()
        
        // Features we know are not implemented
        let unimplementedFeatures = [
            "liquid tag",      // Liquid tag (newer syntax)
            "render tag",      // Render tag with isolated scope
            "include tag"      // Include tag with external templates
        ]
        
        // Features that might have partial implementation
        let partialFeatures = [
            "strict",          // Strict mode
            "tablerow tag",    // Tablerow tag
            "cycle tag",       // Cycle tag
            "ifchanged tag",   // Ifchanged tag
            "increment tag",   // Increment tag
            "decrement tag"    // Decrement tag
        ]
        
        print("\n=== Feature Implementation Status ===")
        
        for feature in unimplementedFeatures {
            let tests = try GoldenLiquidTestCase.loadTestCases(withTag: feature)
            print("\(feature) (NOT IMPLEMENTED): \(tests.count) tests")
        }
        
        print("\nPartially implemented features:")
        for feature in partialFeatures {
            let tests = try GoldenLiquidTestCase.loadTestCases(withTag: feature)
            print("\(feature): \(tests.count) tests")
        }
        
        print("=====================================\n")
    }
}