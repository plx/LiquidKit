import Testing
@testable import LiquidKit

/// Summary analysis of the golden-liquid test suite without executing tests
@Suite("Golden Liquid Analysis")
struct GoldenLiquidSummaryTest {
    
    @Test("Analyze Test Suite Coverage")
    func analyzeTestSuiteCoverage() throws {
        let allTests = try GoldenLiquidTestCase.loadAllTestCases()
        
        print("\n=== Golden Liquid Test Suite Analysis ===\n")
        print("Total test cases: \(allTests.count)")
        
        // Group by tags
        var tagStats: [String: (total: Int, hasTemplates: Int, isInvalid: Int)] = [:]
        var noTagTests = 0
        
        for test in allTests {
            if let tags = test.tags {
                for tag in tags {
                    var stats = tagStats[tag] ?? (total: 0, hasTemplates: 0, isInvalid: 0)
                    stats.total += 1
                    if test.templates != nil {
                        stats.hasTemplates += 1
                    }
                    if test.shouldFail {
                        stats.isInvalid += 1
                    }
                    tagStats[tag] = stats
                }
            } else {
                noTagTests += 1
            }
        }
        
        // Categorize features
        let filterTags = tagStats.keys.filter { $0.contains("filter") }.sorted()
        let tagTags = tagStats.keys.filter { $0.contains("tag") }.sorted()
        let otherTags = tagStats.keys.filter { !$0.contains("filter") && !$0.contains("tag") }.sorted()
        
        print("\n📊 Test Distribution by Feature Type:")
        print("  Filters: \(filterTags.count) different filters")
        print("  Tags: \(tagTags.count) different tags")
        print("  Other: \(otherTags.count) other categories")
        print("  No tags: \(noTagTests) tests")
        
        // Identify potentially problematic features
        print("\n⚠️  Features requiring external templates:")
        for (tag, stats) in tagStats.sorted(by: { $0.value.hasTemplates > $1.value.hasTemplates }) {
            if stats.hasTemplates > 0 {
                print("  - \(tag): \(stats.hasTemplates)/\(stats.total) tests")
            }
        }
        
        print("\n🔍 Features with many invalid/error tests:")
        for (tag, stats) in tagStats.sorted(by: { $0.value.isInvalid > $1.value.isInvalid }).prefix(10) {
            if stats.isInvalid > 0 {
                let percentage = Double(stats.isInvalid) / Double(stats.total) * 100
                print("  - \(tag): \(stats.isInvalid)/\(stats.total) (\(String(format: "%.0f", percentage))%)")
            }
        }
        
        // List all filters tested
        print("\n📝 Filters covered in test suite:")
        for filter in filterTags {
            if let stats = tagStats[filter] {
                print("  - \(filter) (\(stats.total) tests)")
            }
        }
        
        // List all tags tested
        print("\n📝 Tags covered in test suite:")
        for tag in tagTags {
            if let stats = tagStats[tag] {
                print("  - \(tag) (\(stats.total) tests)")
            }
        }
        
        // Check for known missing features in LiquidKit
        print("\n❓ Features to check in LiquidKit implementation:")
        
        let knownMissingFeatures = [
            ("echo tag", "Echo tag for outputting without capture"),
            ("liquid tag", "Liquid tag for template syntax without delimiters"),
            ("render tag", "Render tag with isolated scope"),
            ("increment tag", "Increment tag for counters"),
            ("decrement tag", "Decrement tag for counters"),
            ("ifchanged tag", "Ifchanged tag for detecting changes"),
            ("tablerow tag", "Tablerow tag for HTML tables"),
            ("cycle tag", "Cycle tag for alternating values")
        ]
        
        for (feature, description) in knownMissingFeatures {
            if let stats = tagStats[feature] {
                print("  - \(feature): \(description) (\(stats.total) tests)")
            }
        }
        
        // Summary recommendations
        print("\n💡 Implementation Recommendations:")
        print("1. Start with basic filters that have many tests (join, split, etc.)")
        print("2. Ensure proper error handling for invalid templates")
        print("3. Implement missing basic tags (echo, cycle, tablerow)")
        print("4. Add support for array indexing with variables")
        print("5. Validate filter arguments properly")
        
        print("\n===========================================\n")
    }
}