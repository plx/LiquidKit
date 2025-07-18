import Testing
import Foundation
@testable import LiquidKit

struct GoldenLiquidParseTests {
    
    @Test func parseMinimalTestCase() throws {
        let json = """
        {
            "name": "simple variable",
            "template": "Hello {{ name }}",
            "result": "Hello World"
        }
        """
        
        let data = try #require(json.data(using: .utf8))
        let testCase = try JSONDecoder().decode(GoldenLiquidTestCase.self, from: data)
        
        #expect(testCase.name == "simple variable")
        #expect(testCase.template == "Hello {{ name }}")
        
        // Test the outcome enum
        switch testCase.outcome {
        case .singleResult(let result):
            #expect(result == "Hello World")
        default:
            Issue.record("Expected singleResult outcome")
        }
        
        #expect(testCase.data == nil)
        #expect(testCase.templates == nil)
        #expect(testCase.tags == nil)
    }
    
    @Test func parseMultipleResults() throws {
        let json = """
        {
            "name": "multiple outputs",
            "template": "{{ text | upcase }}",
            "results": [
                "HELLO",
                "WORLD",
                "TEST"
            ]
        }
        """
        
        let data = try #require(json.data(using: .utf8))
        let testCase = try JSONDecoder().decode(GoldenLiquidTestCase.self, from: data)
        
        #expect(testCase.name == "multiple outputs")
        #expect(testCase.template == "{{ text | upcase }}")
        
        // Test the outcome enum
        switch testCase.outcome {
        case .multipleResults(let results):
            #expect(results == ["HELLO", "WORLD", "TEST"])
        default:
            Issue.record("Expected multipleResults outcome")
        }
    }
    
    @Test func parseInvalidTestCase() throws {
        let json = """
        {
            "name": "invalid syntax",
            "template": "{{ unclosed",
            "invalid": true
        }
        """
        
        let data = try #require(json.data(using: .utf8))
        let testCase = try JSONDecoder().decode(GoldenLiquidTestCase.self, from: data)
        
        #expect(testCase.name == "invalid syntax")
        #expect(testCase.template == "{{ unclosed")
        
        // Test the outcome enum
        switch testCase.outcome {
        case .invalid:
            // Expected case
            break
        default:
            Issue.record("Expected invalid outcome")
        }
    }
    
    @Test func parseComplexData() throws {
        let json = """
        {
            "name": "complex data structures",
            "template": "{{ user.name }} has {{ products.size }} products",
            "data": {
                "user": {
                    "name": "Alice",
                    "age": 30,
                    "verified": true
                },
                "products": [
                    {"id": 1, "name": "Widget", "price": 9.99},
                    {"id": 2, "name": "Gadget", "price": 19.99}
                ],
                "metadata": {
                    "version": "1.0",
                    "timestamp": 1234567890,
                    "tags": ["new", "featured"],
                    "settings": {
                        "enabled": true,
                        "threshold": 0.75
                    }
                }
            },
            "result": "Alice has 2 products"
        }
        """
        
        let data = try #require(json.data(using: .utf8))
        let testCase = try JSONDecoder().decode(GoldenLiquidTestCase.self, from: data)
        
        #expect(testCase.name == "complex data structures")
        #expect(testCase.template == "{{ user.name }} has {{ products.size }} products")
        
        // Test the outcome enum
        switch testCase.outcome {
        case .singleResult(let result):
            #expect(result == "Alice has 2 products")
        default:
            Issue.record("Expected singleResult outcome")
        }
        
        // Verify data structure
        let testData = try #require(testCase.data)
        
        // Check user object - data is [String: Token], not [String: Any]
        if case .dictionary(let userDict) = testData["user"] {
            if case .string(let name) = userDict["name"] {
                #expect(name == "Alice")
            }
            if case .integer(let age) = userDict["age"] {
                #expect(age == 30)
            }
            if case .bool(let verified) = userDict["verified"] {
                #expect(verified == true)
            }
        } else {
            Issue.record("Expected user to be a dictionary")
        }
        
        // Check products array
        if case .array(let productsArray) = testData["products"] {
            #expect(productsArray.count == 2)
            
            if case .dictionary(let product0) = productsArray[0] {
                if case .integer(let id) = product0["id"] {
                    #expect(id == 1)
                }
                if case .string(let name) = product0["name"] {
                    #expect(name == "Widget")
                }
                if case .decimal(let price) = product0["price"] {
                    #expect(price == 9.99)
                }
            }
        } else {
            Issue.record("Expected products to be an array")
        }
        
        // Check nested metadata
        if case .dictionary(let metadataDict) = testData["metadata"] {
            if case .string(let version) = metadataDict["version"] {
                #expect(version == "1.0")
            }
            if case .integer(let timestamp) = metadataDict["timestamp"] {
                #expect(timestamp == 1234567890)
            }
            
            if case .array(let tagsArray) = metadataDict["tags"] {
                let tagStrings = tagsArray.compactMap { token -> String? in
                    if case .string(let value) = token {
                        return value
                    }
                    return nil
                }
                #expect(tagStrings == ["new", "featured"])
            }
            
            if case .dictionary(let settingsDict) = metadataDict["settings"] {
                if case .bool(let enabled) = settingsDict["enabled"] {
                    #expect(enabled == true)
                }
                if case .decimal(let threshold) = settingsDict["threshold"] {
                    #expect(threshold == 0.75)
                }
            }
        } else {
            Issue.record("Expected metadata to be a dictionary")
        }
    }
    
    @Test func parseWithTemplatesAndTags() throws {
        let json = """
        {
            "name": "custom tags and templates",
            "template": "{% render 'header' %}\\n{% custom_tag %}\\n{{ content }}",
            "templates": {
                "header": "<h1>{{ title }}</h1>",
                "footer": "<p>Copyright {{ year }}</p>"
            },
            "tags": ["custom", "render"],
            "data": {
                "title": "My Page",
                "content": "Welcome!",
                "year": 2025
            },
            "result": "<h1>My Page</h1>\\nCustom output\\nWelcome!"
        }
        """
        
        let data = try #require(json.data(using: .utf8))
        let testCase = try JSONDecoder().decode(GoldenLiquidTestCase.self, from: data)
        
        #expect(testCase.name == "custom tags and templates")
        #expect(testCase.template == "{% render 'header' %}\n{% custom_tag %}\n{{ content }}")
        
        // Test the outcome enum
        switch testCase.outcome {
        case .singleResult(let result):
            #expect(result == "<h1>My Page</h1>\nCustom output\nWelcome!")
        default:
            Issue.record("Expected singleResult outcome")
        }
        
        // Check templates (not partials)
        let templates = try #require(testCase.templates)
        #expect(templates["header"] == "<h1>{{ title }}</h1>")
        #expect(templates["footer"] == "<p>Copyright {{ year }}</p>")
        
        // Check tags - it's an array of strings, not a dictionary
        let tags = try #require(testCase.tags)
        #expect(tags.count == 2)
        #expect(tags.contains("custom"))
        #expect(tags.contains("render"))
    }
    
    @Test func parseEmptyResults() throws {
        let json = """
        {
            "name": "no output expected",
            "template": "{% comment %}This outputs nothing{% endcomment %}",
            "results": []
        }
        """
        
        let data = try #require(json.data(using: .utf8))
        let testCase = try JSONDecoder().decode(GoldenLiquidTestCase.self, from: data)
        
        #expect(testCase.name == "no output expected")
        
        // Test the outcome enum
        switch testCase.outcome {
        case .multipleResults(let results):
            #expect(results.isEmpty)
        default:
            Issue.record("Expected multipleResults outcome with empty array")
        }
    }
    
    @Test func parseWithAllFields() throws {
        let json = """
        {
            "name": "comprehensive test",
            "template": "{% if show %}{{ greeting }} {% render 'user' %}{% endif %}",
            "data": {
                "show": true,
                "greeting": "Hello",
                "user": {"name": "Bob"}
            },
            "templates": {
                "user": "{{ user.name }}!"
            },
            "tags": ["if", "render"],
            "results": ["Hello Bob!"]
        }
        """
        
        let data = try #require(json.data(using: .utf8))
        let testCase = try JSONDecoder().decode(GoldenLiquidTestCase.self, from: data)
        
        #expect(testCase.name == "comprehensive test")
        #expect(testCase.template == "{% if show %}{{ greeting }} {% render 'user' %}{% endif %}")
        
        // Test the outcome enum
        switch testCase.outcome {
        case .multipleResults(let results):
            #expect(results == ["Hello Bob!"])
        default:
            Issue.record("Expected multipleResults outcome")
        }
        
        #expect(testCase.data != nil)
        #expect(testCase.templates?["user"] == "{{ user.name }}!")
        #expect(testCase.tags?.contains("if") == true)
        #expect(testCase.tags?.contains("render") == true)
    }
    
    @Test func parseNumericData() throws {
        let json = """
        {
            "name": "numeric types",
            "template": "{{ int }} {{ float }} {{ negative }} {{ zero }}",
            "data": {
                "int": 42,
                "float": 3.14159,
                "negative": -17,
                "zero": 0
            },
            "result": "42 3.14159 -17 0"
        }
        """
        
        let data = try #require(json.data(using: .utf8))
        let testCase = try JSONDecoder().decode(GoldenLiquidTestCase.self, from: data)
        
        // Test the outcome enum
        switch testCase.outcome {
        case .singleResult(let result):
            #expect(result == "42 3.14159 -17 0")
        default:
            Issue.record("Expected singleResult outcome")
        }
        
        let testData = try #require(testCase.data)
        
        // Check Token types
        if case .integer(let intValue) = testData["int"] {
            #expect(intValue == 42)
        }
        if case .decimal(let floatValue) = testData["float"] {
            #expect(floatValue == 3.14159)
        }
        if case .integer(let negativeValue) = testData["negative"] {
            #expect(negativeValue == -17)
        }
        if case .integer(let zeroValue) = testData["zero"] {
            #expect(zeroValue == 0)
        }
    }
    
    @Test func parseBooleanData() throws {
        let json = """
        {
            "name": "boolean values",
            "template": "{% if active %}Active{% else %}Inactive{% endif %}",
            "data": {
                "active": true,
                "disabled": false
            },
            "result": "Active"
        }
        """
        
        let data = try #require(json.data(using: .utf8))
        let testCase = try JSONDecoder().decode(GoldenLiquidTestCase.self, from: data)
        
        // Test the outcome enum
        switch testCase.outcome {
        case .singleResult(let result):
            #expect(result == "Active")
        default:
            Issue.record("Expected singleResult outcome")
        }
        
        let testData = try #require(testCase.data)
        
        // Check Token boolean types
        if case .bool(let activeValue) = testData["active"] {
            #expect(activeValue == true)
        }
        if case .bool(let disabledValue) = testData["disabled"] {
            #expect(disabledValue == false)
        }
    }
    
    @Test func parseNullData() throws {
        let json = """
        {
            "name": "null values",
            "template": "{{ missing | default: 'N/A' }}",
            "data": {
                "missing": null,
                "present": "value"
            },
            "result": "N/A"
        }
        """
        
        let data = try #require(json.data(using: .utf8))
        let testCase = try JSONDecoder().decode(GoldenLiquidTestCase.self, from: data)
        
        // Test the outcome enum
        switch testCase.outcome {
        case .singleResult(let result):
            #expect(result == "N/A")
        default:
            Issue.record("Expected singleResult outcome")
        }
        
        let testData = try #require(testCase.data)
        
        // Check Token types - null becomes .nil
        if case .nil = testData["missing"] {
            // Expected
        } else {
            Issue.record("Expected missing to be .nil")
        }
        
        if case .string(let presentValue) = testData["present"] {
            #expect(presentValue == "value")
        }
    }
    
    @Test func parseArrayData() throws {
        let json = """
        {
            "name": "array operations",
            "template": "{% for item in items %}{{ item }}{% unless forloop.last %}, {% endunless %}{% endfor %}",
            "data": {
                "items": ["apple", "banana", "cherry"],
                "numbers": [1, 2, 3, 4, 5],
                "mixed": ["text", 123, true, null]
            },
            "result": "apple, banana, cherry"
        }
        """
        
        let data = try #require(json.data(using: .utf8))
        let testCase = try JSONDecoder().decode(GoldenLiquidTestCase.self, from: data)
        
        // Test the outcome enum
        switch testCase.outcome {
        case .singleResult(let result):
            #expect(result == "apple, banana, cherry")
        default:
            Issue.record("Expected singleResult outcome")
        }
        
        let testData = try #require(testCase.data)
        
        // Check array of strings
        if case .array(let itemsArray) = testData["items"] {
            #expect(itemsArray.count == 3)
            let itemStrings = itemsArray.compactMap { token -> String? in
                if case .string(let value) = token {
                    return value
                }
                return nil
            }
            #expect(itemStrings == ["apple", "banana", "cherry"])
        }
        
        // Check array of numbers
        if case .array(let numbersArray) = testData["numbers"] {
            #expect(numbersArray.count == 5)
            let numbers = numbersArray.compactMap { token -> Int? in
                if case .integer(let value) = token {
                    return value
                }
                return nil
            }
            #expect(numbers == [1, 2, 3, 4, 5])
        }
        
        // Check mixed array
        if case .array(let mixedArray) = testData["mixed"] {
            #expect(mixedArray.count == 4)
            
            if case .string(let str) = mixedArray[0] {
                #expect(str == "text")
            }
            if case .integer(let num) = mixedArray[1] {
                #expect(num == 123)
            }
            if case .bool(let bool) = mixedArray[2] {
                #expect(bool == true)
            }
            if case .nil = mixedArray[3] {
                // Expected
            } else {
                Issue.record("Expected nil at index 3")
            }
        }
    }
    
    @Test func parseEscapedStrings() throws {
        let json = """
        {
            "name": "escaped characters",
            "template": "{{ quote }}",
            "data": {
                "quote": "She said, \\"Hello!\\"",
                "path": "C:\\\\Users\\\\Name",
                "newline": "Line 1\\nLine 2",
                "tab": "Col1\\tCol2"
            },
            "result": "She said, \\"Hello!\\""
        }
        """
        
        let data = try #require(json.data(using: .utf8))
        let testCase = try JSONDecoder().decode(GoldenLiquidTestCase.self, from: data)
        
        // Test the outcome enum
        switch testCase.outcome {
        case .singleResult(let result):
            #expect(result == "She said, \"Hello!\"")
        default:
            Issue.record("Expected singleResult outcome")
        }
        
        let testData = try #require(testCase.data)
        
        // Check Token string values
        if case .string(let quoteValue) = testData["quote"] {
            #expect(quoteValue == "She said, \"Hello!\"")
        }
        if case .string(let pathValue) = testData["path"] {
            #expect(pathValue == "C:\\Users\\Name")
        }
        if case .string(let newlineValue) = testData["newline"] {
            #expect(newlineValue == "Line 1\nLine 2")
        }
        if case .string(let tabValue) = testData["tab"] {
            #expect(tabValue == "Col1\tCol2")
        }
    }
    
    @Test func parseUnicodeData() throws {
        let json = """
        {
            "name": "unicode support",
            "template": "{{ greeting }} {{ emoji }}",
            "data": {
                "greeting": "你好",
                "emoji": "🎉🌟✨",
                "mixed": "Hello 世界! 🌍"
            },
            "result": "你好 🎉🌟✨"
        }
        """
        
        let data = try #require(json.data(using: .utf8))
        let testCase = try JSONDecoder().decode(GoldenLiquidTestCase.self, from: data)
        
        // Test the outcome enum
        switch testCase.outcome {
        case .singleResult(let result):
            #expect(result == "你好 🎉🌟✨")
        default:
            Issue.record("Expected singleResult outcome")
        }
        
        let testData = try #require(testCase.data)
        
        // Check Token string values with unicode
        if case .string(let greetingValue) = testData["greeting"] {
            #expect(greetingValue == "你好")
        }
        if case .string(let emojiValue) = testData["emoji"] {
            #expect(emojiValue == "🎉🌟✨")
        }
        if case .string(let mixedValue) = testData["mixed"] {
            #expect(mixedValue == "Hello 世界! 🌍")
        }
    }
}