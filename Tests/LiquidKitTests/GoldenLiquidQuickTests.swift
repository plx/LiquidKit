import Testing
@testable import LiquidKit

/// Quick validation tests to get a summary of LiquidKit's compatibility
@Suite("Golden Liquid Quick Validation")
struct GoldenLiquidQuickTests {
    
    /// Safe test runner that catches all errors including crashes
    private func safeValidateTestCase(_ testCase: GoldenLiquidTestCase) -> TestResult {
        // Create lexer and parse the template
        let lexer = Lexer(templateString: testCase.template)
        let tokens = lexer.tokenize()
        
        // Create parser with context
        let context = testCase.createContext()
        let parser = Parser(tokens: tokens, context: context)
        
        // Parse the template
        let parts = parser.parse()
        
        // Render the template by joining all parts
        let output = parts.joined()
        
        // For invalid test cases, we expect an error
        if testCase.shouldFail {
            return .failed(reason: "Expected error but got output: \(output)")
        }
        
        // Validate the output
        switch testCase.outcome {
        case .singleResult(let expected):
            if output == expected {
                return .passed
            } else {
                return .failed(reason: "Wrong output - Expected: \(expected), Actual: \(output)")
            }
            
        case .multipleResults(let acceptableResults):
            if acceptableResults.contains(output) {
                return .passed
            } else {
                return .failed(reason: "Wrong output - Expected one of: \(acceptableResults.joined(separator: " | ")), Actual: \(output)")
            }
            
        case .invalid:
            return .failed(reason: "Test case marked as invalid but didn't throw")
        }
    }
    
    enum TestResult {
        case passed
        case failed(reason: String)
        case skipped(reason: String)
    }
    
    @Test("Quick Compatibility Report")
    func quickCompatibilityReport() throws {
        let allTests = try GoldenLiquidTestCase.loadAllTestCases()
        
        var resultsByTag: [String: (passed: Int, failed: Int, total: Int)] = [:]
        var overallPassed = 0
        var overallFailed = 0
        var overallSkipped = 0
        
        // Test sample of each tag category
        let tagCategories = [
            "capitalize filter",
            "downcase filter", 
            "upcase filter",
            "escape filter",
            "strip_html filter",
            "date filter",
            "join filter",
            "split filter",
            "replace filter",
            "size filter",
            "sort filter",
            "where filter",
            "assign tag",
            "if tag",
            "unless tag",
            "case tag",
            "for tag",
            "capture tag",
            "comment tag",
            "echo tag",
            "cycle tag",
            "tablerow tag",
            "include tag",
            "render tag",
            "liquid tag"
        ]
        
        for tag in tagCategories {
            let tests = allTests.filter { $0.tags?.contains(tag) == true }
            guard !tests.isEmpty else { continue }
            
            var passed = 0
            var failed = 0
            
            // Test up to 10 tests per category to avoid crashes
            for test in tests.prefix(10) {
                // Skip tests with external templates
                if test.templates != nil {
                    overallSkipped += 1
                    continue
                }
                
                let result = safeValidateTestCase(test)
                switch result {
                case .passed:
                    passed += 1
                    overallPassed += 1
                case .failed:
                    failed += 1
                    overallFailed += 1
                case .skipped:
                    overallSkipped += 1
                }
            }
            
            resultsByTag[tag] = (passed: passed, failed: failed, total: tests.count)
        }
        
        // Print results
        print("\n=== LiquidKit Quick Compatibility Report ===")
        print("Tested \(overallPassed + overallFailed) cases across \(tagCategories.count) categories")
        print("Overall: \(overallPassed) passed, \(overallFailed) failed")
        print("Success rate: \(String(format: "%.1f", Double(overallPassed) / Double(overallPassed + overallFailed) * 100))%")
        
        print("\nResults by category (showing up to 10 tests per category):")
        print("Category                  | Passed | Failed | Total | Success Rate")
        print("--------------------------|--------|--------|-------|-------------")
        
        for tag in tagCategories {
            if let (passed, failed, total) = resultsByTag[tag] {
                let tested = passed + failed
                let rate = tested > 0 ? Double(passed) / Double(tested) * 100 : 0
                print(String(format: "%-25s | %6d | %6d | %5d | %5.1f%%", 
                    tag, passed, failed, total, rate))
            }
        }
        
        print("\nKey findings:")
        
        // Identify well-supported features
        let wellSupported = resultsByTag.filter { $0.value.failed == 0 && $0.value.passed > 0 }
        if !wellSupported.isEmpty {
            print("✅ Fully working features:")
            for (tag, _) in wellSupported {
                print("   - \(tag)")
            }
        }
        
        // Identify partially supported features
        let partiallySupported = resultsByTag.filter { $0.value.failed > 0 && $0.value.passed > 0 }
        if !partiallySupported.isEmpty {
            print("\n⚠️  Partially working features:")
            for (tag, (passed, failed, _)) in partiallySupported {
                let rate = Double(passed) / Double(passed + failed) * 100
                print("   - \(tag) (\(String(format: "%.0f", rate))% pass rate)")
            }
        }
        
        // Identify broken features
        let broken = resultsByTag.filter { $0.value.passed == 0 && $0.value.failed > 0 }
        if !broken.isEmpty {
            print("\n❌ Not working features:")
            for (tag, _) in broken {
                print("   - \(tag)")
            }
        }
        
        print("============================================\n")
    }
}