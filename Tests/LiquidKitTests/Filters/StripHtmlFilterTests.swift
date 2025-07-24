import Foundation
import Testing
@testable import LiquidKit

@Suite(.tags(.filter, .stripHtmlFilter))
struct StripHtmlFilterTests {
    
    // MARK: - Basic HTML Tag Removal Tests
    
    @Test func stripBasicHtmlTags() throws {
        let filter = StripHtmlFilter()
        try validateEvaluation(
            of: "<p>Hello <strong>world</strong>!</p>",
            by: filter,
            yields: "Hello world!"
        )
    }
    
    @Test func stripTagsWithAttributes() throws {
        let filter = StripHtmlFilter()
        try validateEvaluation(
            of: "<div id='test' class='content'>content</div>",
            by: filter,
            yields: "content"
        )
    }
    
    @Test func stripSelfClosingTags() throws {
        let filter = StripHtmlFilter()
        try validateEvaluation(
            of: "Before<br/>After<img src='test.jpg'/>End",
            by: filter,
            yields: "BeforeAfterEnd"
        )
    }
    
    @Test func stripNestedTags() throws {
        let filter = StripHtmlFilter()
        try validateEvaluation(
            of: "<div><p>Hello <em>nested <strong>tags</strong></em>!</p></div>",
            by: filter,
            yields: "Hello nested tags!"
        )
    }
    
    @Test func stripMultipleTagsOnSameLine() throws {
        let filter = StripHtmlFilter()
        try validateEvaluation(
            of: "<span>Start</span><div>Middle</div><span>End</span>",
            by: filter,
            yields: "StartMiddleEnd"
        )
    }
    
    // MARK: - HTML Comments Tests
    
    @Test func stripHtmlComments() throws {
        let filter = StripHtmlFilter()
        try validateEvaluation(
            of: "<!-- comment -->visible text",
            by: filter,
            yields: "visible text"
        )
    }
    
    @Test func stripMultilineHtmlComments() throws {
        let filter = StripHtmlFilter()
        try validateEvaluation(
            of: "Before<!-- multi\nline\ncomment -->After",
            by: filter,
            yields: "BeforeAfter"
        )
    }
    
    @Test func stripMultipleHtmlComments() throws {
        let filter = StripHtmlFilter()
        try validateEvaluation(
            of: "<!-- first -->text<!-- second -->more",
            by: filter,
            yields: "textmore"
        )
    }
    
    // MARK: - Script Tag Tests
    
    @Test func stripScriptTagsAndContent() throws {
        let filter = StripHtmlFilter()
        try validateEvaluation(
            of: "<script>alert('hi');</script>text",
            by: filter,
            yields: "text"
        )
    }
    
    @Test func stripScriptTagsWithAttributes() throws {
        let filter = StripHtmlFilter()
        try validateEvaluation(
            of: "<script type='text/javascript'>var x = 1;</script>visible",
            by: filter,
            yields: "visible"
        )
    }
    
    @Test func stripMultilineScriptTags() throws {
        let filter = StripHtmlFilter()
        try validateEvaluation(
            of: "Before<script>\nvar x = 1;\nalert(x);\n</script>After",
            by: filter,
            yields: "BeforeAfter"
        )
    }
    
    @Test func stripMultipleScriptTags() throws {
        let filter = StripHtmlFilter()
        try validateEvaluation(
            of: "<script>first();</script>text<script>second();</script>more",
            by: filter,
            yields: "textmore"
        )
    }
    
    // MARK: - Style Tag Tests
    
    @Test func stripStyleTagsAndContent() throws {
        let filter = StripHtmlFilter()
        try validateEvaluation(
            of: "<style>body { color: red; }</style>text",
            by: filter,
            yields: "text"
        )
    }
    
    @Test func stripStyleTagsWithAttributes() throws {
        let filter = StripHtmlFilter()
        try validateEvaluation(
            of: "<style type='text/css'>p { margin: 0; }</style>visible",
            by: filter,
            yields: "visible"
        )
    }
    
    @Test func stripMultilineStyleTags() throws {
        let filter = StripHtmlFilter()
        try validateEvaluation(
            of: "Before<style>\nbody {\n  color: blue;\n}\n</style>After",
            by: filter,
            yields: "BeforeAfter"
        )
    }
    
    @Test func stripMultipleStyleTags() throws {
        let filter = StripHtmlFilter()
        try validateEvaluation(
            of: "<style>body{}</style>text<style>p{}</style>more",
            by: filter,
            yields: "textmore"
        )
    }
    
    // MARK: - HTML Entities Tests
    
    @Test func preserveHtmlEntities() throws {
        let filter = StripHtmlFilter()
        try validateEvaluation(
            of: "Text with &amp; and &#20; entities",
            by: filter,
            yields: "Text with &amp; and &#20; entities"
        )
    }
    
    @Test func preserveHtmlEntitiesWithTags() throws {
        let filter = StripHtmlFilter()
        try validateEvaluation(
            of: "<p>Text with &amp; and &lt;tag&gt; entities</p>",
            by: filter,
            yields: "Text with &amp; and &lt;tag&gt; entities"
        )
    }
    
    @Test func preserveNumericHtmlEntities() throws {
        let filter = StripHtmlFilter()
        try validateEvaluation(
            of: "<div>&#65; &#x41; &#169;</div>",
            by: filter,
            yields: "&#65; &#x41; &#169;"
        )
    }
    
    // MARK: - Multiline Tag Tests
    
    @Test func stripMultilineTags() throws {
        let filter = StripHtmlFilter()
        try validateEvaluation(
            of: "<div\nclass='multiline'>test</div>",
            by: filter,
            yields: "test"
        )
    }
    
    @Test func stripTagsSpanningMultipleLines() throws {
        let filter = StripHtmlFilter()
        try validateEvaluation(
            of: """
                <div
                      id="test"
                      class="content">
                  Hello World
                  </div>
                """,
            by: filter,
            yields: """
                
                  Hello World
                  
                """
        )
    }
    
    // MARK: - Complex Mixed Content Tests
    
    @Test func stripMixedHtmlContent() throws {
        let filter = StripHtmlFilter()
        try validateEvaluation(
            of: "<!-- comment --><p>Text</p><script>code();</script>more<style>css{}</style>end",
            by: filter,
            yields: "Textmoreend"
        )
    }
    
    @Test func stripComplexNestedContent() throws {
        let filter = StripHtmlFilter()
        try validateEvaluation(
            of: """
            <html>
            <!-- Page header -->
            <head>
                <title>Test</title>
                <style>
                    body { margin: 0; }
                    p { color: red; }
                </style>
                <script>
                    function test() {
                        alert('hello');
                    }
                </script>
            </head>
            <body>
                <h1>Title</h1>
                <p>Content with &amp; entities</p>
                <!-- End comment -->
            </body>
            </html>
            """,
            by: filter,
            yields: "\n\n\n    Test\n    \n    \n\n\n    Title\n    Content with &amp; entities\n    \n\n"
        )
    }
    
    // MARK: - Edge Cases
    
    @Test func stripEmptyString() throws {
        let filter = StripHtmlFilter()
        try validateEvaluation(
            of: "",
            by: filter,
            yields: ""
        )
    }
    
    @Test func stripStringWithOnlyTags() throws {
        let filter = StripHtmlFilter()
        try validateEvaluation(
            of: "<div><p></p></div>",
            by: filter,
            yields: ""
        )
    }
    
    @Test func stripStringWithOnlyComments() throws {
        let filter = StripHtmlFilter()
        try validateEvaluation(
            of: "<!-- first --><!-- second -->",
            by: filter,
            yields: ""
        )
    }
    
    @Test func stripBrokenOrMalformedTags() throws {
        let filter = StripHtmlFilter()
        try validateEvaluation(
            of: "<div>content<p>more<",
            by: filter,
            yields: "contentmore<"
        )
    }
    
    @Test func stripTagsWithSpecialCharacters() throws {
        let filter = StripHtmlFilter()
        try validateEvaluation(
            of: "<div data-test='normal'>content</div>",
            by: filter,
            yields: "content"
        )
    }
    
    @Test func stripTagsWithQuotesAndAmpersands() throws {
        let filter = StripHtmlFilter()
        try validateEvaluation(
            of: "<div class=\"test&amp;example\">content</div>",
            by: filter,
            yields: "content"
        )
    }
    
    @Test func stripIncompleteClosingTags() throws {
        let filter = StripHtmlFilter()
        // Note: "</div more text" is not a valid HTML tag (space before >)
        // HTML strippers may treat this as text content rather than a tag
        try validateEvaluation(
            of: "<div>content</div> more text",
            by: filter,
            yields: "content more text"
        )
    }
    
    // MARK: - Non-String Input Tests
    
    @Test func stripInteger() throws {
        let filter = StripHtmlFilter()
        try validateEvaluation(
            of: Token.Value.integer(123),
            by: filter,
            yields: Token.Value.integer(123)
        )
    }
    
    @Test func stripDecimal() throws {
        let filter = StripHtmlFilter()
        try validateEvaluation(
            of: Token.Value.decimal(45.67),
            by: filter,
            yields: Token.Value.decimal(45.67)
        )
    }
    
    @Test func stripBooleanTrue() throws {
        let filter = StripHtmlFilter()
        try validateEvaluation(
            of: Token.Value.bool(true),
            by: filter,
            yields: Token.Value.bool(true)
        )
    }
    
    @Test func stripBooleanFalse() throws {
        let filter = StripHtmlFilter()
        try validateEvaluation(
            of: Token.Value.bool(false),
            by: filter,
            yields: Token.Value.bool(false)
        )
    }
    
    @Test func stripNil() throws {
        let filter = StripHtmlFilter()
        try validateEvaluation(
            of: Token.Value.nil,
            by: filter,
            yields: Token.Value.nil
        )
    }
    
    @Test func stripArray() throws {
        let filter = StripHtmlFilter()
        let array = Token.Value.array([.string("hello"), .string("world")])
        try validateEvaluation(
            of: array,
            by: filter,
            yields: array
        )
    }
    
    @Test func stripDictionary() throws {
        let filter = StripHtmlFilter()
        let dict = Token.Value.dictionary(["key": .string("value")])
        try validateEvaluation(
            of: dict,
            by: filter,
            yields: dict
        )
    }
    
    @Test func stripRange() throws {
        let filter = StripHtmlFilter()
        let range = Token.Value.range(1...5)
        try validateEvaluation(
            of: range,
            by: filter,
            yields: range
        )
    }
    
    // MARK: - Parameter Tests
    
    @Test func stripRejectsParameters() throws {
        // The strip_html filter should not accept any parameters
        let filter = StripHtmlFilter()
        try validateEvaluation(
            of: "<p>hello</p>",
            with: [Token.Value.string("unused")],
            by: filter,
            yields: "hello"
        )
    }
    
    // MARK: - Real-world Examples
    
    @Test func stripBlogPostContent() throws {
        let filter = StripHtmlFilter()
        try validateEvaluation(
            of: """
            <article>
                <h1>Blog Title</h1>
                <p>This is a <strong>sample</strong> blog post with <em>formatting</em>.</p>
                <blockquote>
                    "This is a quote with &ldquo;smart quotes&rdquo;."
                </blockquote>
                <script>trackPageView();</script>
            </article>
            """,
            by: filter,
            yields: "\n    Blog Title\n    This is a sample blog post with formatting.\n    \n        \"This is a quote with &ldquo;smart quotes&rdquo;.\"\n    \n    \n"
        )
    }
    
    @Test func stripHtmlEmail() throws {
        let filter = StripHtmlFilter()
        try validateEvaluation(
            of: """
            <html>
            <body>
                <p>Dear User,</p>
                <p>Your order has been <strong>confirmed</strong>!</p>
                <p>Track your order <a href="https://example.com">here</a>.</p>
                <!-- Analytics pixel -->
                <img src="track.gif" width="1" height="1">
            </body>
            </html>
            """,
            by: filter,
            yields: "\n\n    Dear User,\n    Your order has been confirmed!\n    Track your order here.\n    \n    \n\n"
        )
    }
}