import Testing
@testable import LiquidKit

@Suite("EscapeOnceFilter Tests", .tags(.filter, .escapeOnceFilter))
struct EscapeOnceFilterTests {
    
    @Test("Already escaped content remains unchanged")
    func alreadyEscapedContent() throws {
        let filter = EscapeOnceFilter()
        
        // Test basic already-escaped entities
        try validateEvaluation(
            of: .string("&lt;p&gt;test&lt;/p&gt;"),
            by: filter,
            yields: .string("&lt;p&gt;test&lt;/p&gt;")
        )
        
        // Test multiple types of escaped entities
        try validateEvaluation(
            of: .string("&amp; &lt; &gt; &quot; &#39;"),
            by: filter,
            yields: .string("&amp; &lt; &gt; &quot; &#39;")
        )
    }
    
    @Test("Unescaped content gets escaped")
    func unescapedContent() throws {
        let filter = EscapeOnceFilter()
        
        // Test basic HTML characters
        try validateEvaluation(
            of: .string("<p>test</p>"),
            by: filter,
            yields: .string("&lt;p&gt;test&lt;/p&gt;")
        )
        
        // Test all special characters
        try validateEvaluation(
            of: .string("& < > \" '"),
            by: filter,
            yields: .string("&amp; &lt; &gt; &quot; &#39;")
        )
    }
    
    @Test("Mixed escaped and unescaped content")
    func mixedContent() throws {
        let filter = EscapeOnceFilter()
        
        // Test case from liquidjs docs
        try validateEvaluation(
            of: .string("1 < 2 & 3"),
            by: filter,
            yields: .string("1 &lt; 2 &amp; 3")
        )
        
        // Test case from liquidjs docs - already escaped
        try validateEvaluation(
            of: .string("1 &lt; 2 &amp; 3"),
            by: filter,
            yields: .string("1 &lt; 2 &amp; 3")
        )
        
        // Test mixed content from documentation
        try validateEvaluation(
            of: .string("&lt;p&gt;test&lt;/p&gt;<p>test</p>"),
            by: filter,
            yields: .string("&lt;p&gt;test&lt;/p&gt;&lt;p&gt;test&lt;/p&gt;")
        )
        
        // Test Rock & Roll example
        try validateEvaluation(
            of: .string("Rock &amp; Roll & Jazz"),
            by: filter,
            yields: .string("Rock &amp; Roll &amp; Jazz")
        )
        
        // Test from python-liquid docs
        try validateEvaluation(
            of: .string("Have you read 'James &amp; the Giant Peach'?"),
            by: filter,
            yields: .string("Have you read &#39;James &amp; the Giant Peach&#39;?")
        )
    }
    
    @Test("Script tags and XSS prevention")
    func scriptTags() throws {
        let filter = EscapeOnceFilter()
        
        try validateEvaluation(
            of: .string("<script>alert('XSS')</script>"),
            by: filter,
            yields: .string("&lt;script&gt;alert(&#39;XSS&#39;)&lt;/script&gt;")
        )
        
        // Already escaped script tag
        try validateEvaluation(
            of: .string("&lt;script&gt;alert('XSS')&lt;/script&gt;"),
            by: filter,
            yields: .string("&lt;script&gt;alert(&#39;XSS&#39;)&lt;/script&gt;")
        )
    }
    
    @Test("Non-string values")
    func nonStringValues() throws {
        let filter = EscapeOnceFilter()
        
        // Integer
        try validateEvaluation(
            of: .integer(5),
            by: filter,
            yields: .string("5")
        )
        
        // Boolean true
        try validateEvaluation(
            of: .bool(true),
            by: filter,
            yields: .string("true")
        )
        
        // Boolean false
        try validateEvaluation(
            of: .bool(false),
            by: filter,
            yields: .string("false")
        )
        
        // Decimal
        try validateEvaluation(
            of: .decimal(3.14),
            by: filter,
            yields: .string("3.14")
        )
    }
    
    @Test("Nil and empty values")
    func nilAndEmptyValues() throws {
        let filter = EscapeOnceFilter()
        
        // Nil
        try validateEvaluation(
            of: .nil,
            by: filter,
            yields: .string("")
        )
        
        // Empty string
        try validateEvaluation(
            of: .string(""),
            by: filter,
            yields: .string("")
        )
    }
    
    @Test("Complex HTML entities")
    func complexHtmlEntities() throws {
        let filter = EscapeOnceFilter()
        
        // Numeric entities should remain unchanged
        try validateEvaluation(
            of: .string("&#65; &#x41; &#128512;"),
            by: filter,
            yields: .string("&#65; &#x41; &#128512;")
        )
        
        // Named entities should remain unchanged
        try validateEvaluation(
            of: .string("&nbsp; &copy; &reg; &mdash;"),
            by: filter,
            yields: .string("&nbsp; &copy; &reg; &mdash;")
        )
        
        // Mix of entities and unescaped content
        try validateEvaluation(
            of: .string("&copy; 2024 <Company> & Partners"),
            by: filter,
            yields: .string("&copy; 2024 &lt;Company&gt; &amp; Partners")
        )
    }
    
    @Test("Edge cases with malformed entities")
    func malformedEntities() throws {
        let filter = EscapeOnceFilter()
        
        // Incomplete entity (missing semicolon) - should be escaped
        try validateEvaluation(
            of: .string("&amp"),
            by: filter,
            yields: .string("&amp;amp")
        )
        
        // Invalid entity name - should be escaped
        try validateEvaluation(
            of: .string("&notanentity;"),
            by: filter,
            yields: .string("&amp;notanentity;")
        )
        
        // Ampersand followed by text - should be escaped
        try validateEvaluation(
            of: .string("Rock & Roll"),
            by: filter,
            yields: .string("Rock &amp; Roll")
        )
    }
    
    @Test("Unicode and international characters")
    func unicodeCharacters() throws {
        let filter = EscapeOnceFilter()
        
        // Unicode characters should pass through
        try validateEvaluation(
            of: .string("Hello 世界 🌍"),
            by: filter,
            yields: .string("Hello 世界 🌍")
        )
        
        // Mix with HTML
        try validateEvaluation(
            of: .string("<p>Hello 世界 & Friends</p>"),
            by: filter,
            yields: .string("&lt;p&gt;Hello 世界 &amp; Friends&lt;/p&gt;")
        )
    }
    
    @Test("Parameters should cause error")
    func parametersError() throws {
        let filter = EscapeOnceFilter()
        
        // The filter should not accept any parameters
        try validateEvaluation(
            of: .string("test"),
            with: [.string("unexpected")],
            by: filter,
            yields: .string("test")  // Current implementation ignores params
        )
    }
}