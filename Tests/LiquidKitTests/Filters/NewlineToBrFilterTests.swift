import Testing
@testable import LiquidKit

@Suite(.tags(.filter, .newlineToBrFilter))
struct NewlineToBrFilterTests {
    let filter = NewlineToBrFilter()
    
    // MARK: - Basic String Tests
    
    @Test func testSingleUnixNewline() throws {
        try validateEvaluation(
            of: "First line\nSecond line",
            by: filter,
            yields: "First line<br />Second line"
        )
    }
    
    @Test func testMultipleUnixNewlines() throws {
        try validateEvaluation(
            of: "Line 1\nLine 2\nLine 3",
            by: filter,
            yields: "Line 1<br />Line 2<br />Line 3"
        )
    }
    
    @Test func testWindowsNewlines() throws {
        try validateEvaluation(
            of: "First line\r\nSecond line",
            by: filter,
            yields: "First line<br />Second line"
        )
    }
    
    @Test func testClassicMacNewlines() throws {
        try validateEvaluation(
            of: "First line\rSecond line",
            by: filter,
            yields: "First line<br />Second line"
        )
    }
    
    @Test func testMixedNewlineTypes() throws {
        try validateEvaluation(
            of: "Unix\nWindows\r\nMac\rEnd",
            by: filter,
            yields: "Unix<br />Windows<br />Mac<br />End"
        )
    }
    
    // MARK: - Edge Cases
    
    @Test func testEmptyString() throws {
        try validateEvaluation(
            of: "",
            by: filter,
            yields: ""
        )
    }
    
    @Test func testStringWithoutNewlines() throws {
        try validateEvaluation(
            of: "No newlines here",
            by: filter,
            yields: "No newlines here"
        )
    }
    
    @Test func testLeadingNewline() throws {
        try validateEvaluation(
            of: "\nStart with newline",
            by: filter,
            yields: "<br />Start with newline"
        )
    }
    
    @Test func testTrailingNewline() throws {
        try validateEvaluation(
            of: "End with newline\n",
            by: filter,
            yields: "End with newline<br />"
        )
    }
    
    @Test func testConsecutiveNewlines() throws {
        try validateEvaluation(
            of: "Double\n\nNewlines",
            by: filter,
            yields: "Double<br /><br />Newlines"
        )
    }
    
    @Test func testTripleNewlines() throws {
        try validateEvaluation(
            of: "Triple\n\n\nNewlines",
            by: filter,
            yields: "Triple<br /><br /><br />Newlines"
        )
    }
    
    // MARK: - Special Cases
    
    @Test func testWindowsStyleAtEnd() throws {
        try validateEvaluation(
            of: "End with Windows\r\n",
            by: filter,
            yields: "End with Windows<br />"
        )
    }
    
    @Test func testMixedConsecutiveNewlines() throws {
        try validateEvaluation(
            of: "Mixed\r\n\nNewlines",
            by: filter,
            yields: "Mixed<br /><br />Newlines"
        )
    }
    
    @Test func testOnlyNewlines() throws {
        try validateEvaluation(
            of: "\n\n\n",
            by: filter,
            yields: "<br /><br /><br />"
        )
    }
    
    @Test func testWindowsOnlyNewlines() throws {
        try validateEvaluation(
            of: "\r\n\r\n",
            by: filter,
            yields: "<br /><br />"
        )
    }
    
    // MARK: - Non-String Input Tests
    
    @Test func testIntegerInput() throws {
        try validateEvaluation(
            of: 42,
            by: filter,
            yields: 42
        )
    }
    
    @Test func testDecimalInput() throws {
        try validateEvaluation(
            of: 3.14,
            by: filter,
            yields: 3.14
        )
    }
    
    @Test func testBooleanInput() throws {
        try validateEvaluation(
            of: true,
            by: filter,
            yields: true
        )
    }
    
    @Test func testNilInput() throws {
        try validateEvaluation(
            of: Token.Value.nil,
            by: filter,
            yields: Token.Value.nil
        )
    }
    
    @Test func testArrayInput() throws {
        try validateEvaluation(
            of: ["hello", "world"],
            by: filter,
            yields: ["hello", "world"]
        )
    }
    
    @Test func testDictionaryInput() throws {
        try validateEvaluation(
            of: ["key": "value"],
            by: filter,
            yields: ["key": "value"]
        )
    }
    
    // MARK: - Real World Examples
    
    @Test func testListFormatting() throws {
        try validateEvaluation(
            of: "- apples\n- oranges\n- bananas",
            by: filter,
            yields: "- apples<br />- oranges<br />- bananas"
        )
    }
    
    @Test func testParagraphFormatting() throws {
        try validateEvaluation(
            of: "First paragraph.\n\nSecond paragraph.\n\nThird paragraph.",
            by: filter,
            yields: "First paragraph.<br /><br />Second paragraph.<br /><br />Third paragraph."
        )
    }
    
    @Test func testPoetryFormatting() throws {
        try validateEvaluation(
            of: "Roses are red\nViolets are blue\nSugar is sweet\nAnd so are you",
            by: filter,
            yields: "Roses are red<br />Violets are blue<br />Sugar is sweet<br />And so are you"
        )
    }
    
    // MARK: - Complex Edge Cases
    
    @Test func testCarriageReturnFollowedByNewline() throws {
        // This tests the case where we have \r followed by \n but not as \r\n
        try validateEvaluation(
            of: "First\rSecond\nThird",
            by: filter,
            yields: "First<br />Second<br />Third"
        )
    }
    
    @Test func testAlternatingNewlineTypes() throws {
        try validateEvaluation(
            of: "A\nB\r\nC\rD\nE",
            by: filter,
            yields: "A<br />B<br />C<br />D<br />E"
        )
    }
    
    @Test func testSpecialCharactersWithNewlines() throws {
        try validateEvaluation(
            of: "Special: <>&\"\nMore special: '`",
            by: filter,
            yields: "Special: <>&\"<br />More special: '`"
        )
    }
}