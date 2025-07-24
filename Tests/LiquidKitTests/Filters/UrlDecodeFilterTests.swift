import Foundation
import Testing
@testable import LiquidKit

@Suite(.tags(.filter, .urlDecodeFilter))
struct UrlDecodeFilterTests {
    let filter = UrlDecodeFilter()
    
    // MARK: - Basic Percent Encoding Tests
    
    @Test("Decodes basic percent-encoded characters")
    func basicPercentEncoding() throws {
        try validateEvaluation(
            of: .string("Hello%20World%21"),
            by: filter,
            yields: .string("Hello World!")
        )
    }
    
    @Test("Decodes single quotes and exclamation")
    func singleQuotesAndExclamation() throws {
        try validateEvaluation(
            of: .string("%27Stop%21%27"),
            by: filter,
            yields: .string("'Stop!'")
        )
    }
    
    @Test("Decodes @ symbol")
    func atSymbol() throws {
        try validateEvaluation(
            of: .string("user%40example.com"),
            by: filter,
            yields: .string("user@example.com")
        )
    }
    
    // MARK: - Plus Sign Handling Tests
    
    @Test("Converts plus signs to spaces")
    func plusToSpace() throws {
        try validateEvaluation(
            of: .string("Hello+World"),
            by: filter,
            yields: .string("Hello World")
        )
    }
    
    @Test("Handles plus signs and percent encoding together")
    func plusAndPercentEncoding() throws {
        try validateEvaluation(
            of: .string("%27Stop%21%27+said+Fred"),
            by: filter,
            yields: .string("'Stop!' said Fred")
        )
    }
    
    @Test("Decodes encoded plus sign")
    func encodedPlusSign() throws {
        try validateEvaluation(
            of: .string("2%2B2%3D4"),
            by: filter,
            yields: .string("2+2=4")
        )
    }
    
    // MARK: - International Character Tests
    
    @Test("Decodes UTF-8 sequences")
    func utf8Sequences() throws {
        try validateEvaluation(
            of: .string("caf%C3%A9"),
            by: filter,
            yields: .string("café")
        )
    }
    
    @Test("Decodes accented characters with plus signs")
    func accentedWithPlus() throws {
        try validateEvaluation(
            of: .string("caf%C3%A9+r%C3%A9sum%C3%A9"),
            by: filter,
            yields: .string("café résumé")
        )
    }
    
    // MARK: - Form Data Tests
    
    @Test("Decodes form-encoded data")
    func formEncodedData() throws {
        try validateEvaluation(
            of: .string("first+name=John&last+name=Doe"),
            by: filter,
            yields: .string("first name=John&last name=Doe")
        )
    }
    
    @Test("Decodes email in form data")
    func emailInFormData() throws {
        try validateEvaluation(
            of: .string("My+email+address+is+bob%40example.com%21"),
            by: filter,
            yields: .string("My email address is bob@example.com!")
        )
    }
    
    // MARK: - Edge Cases
    
    @Test("Empty string returns empty")
    func emptyString() throws {
        try validateEvaluation(
            of: .string(""),
            by: filter,
            yields: .string("")
        )
    }
    
    @Test("String with no encoding returns unchanged")
    func noEncoding() throws {
        try validateEvaluation(
            of: .string("Hello World"),
            by: filter,
            yields: .string("Hello World")
        )
    }
    
    @Test("Only plus signs")
    func onlyPlusSigns() throws {
        try validateEvaluation(
            of: .string("+++"),
            by: filter,
            yields: .string("   ")
        )
    }
    
    @Test("Only percent signs returns unchanged")
    func onlyPercentSigns() throws {
        try validateEvaluation(
            of: .string("%%%"),
            by: filter,
            yields: .string("%%%")
        )
    }
    
    // MARK: - Invalid Encoding Tests
    
    @Test("Invalid percent sequence returns original")
    func invalidPercentSequence() throws {
        try validateEvaluation(
            of: .string("invalid%ZZ"),
            by: filter,
            yields: .string("invalid%ZZ")
        )
    }
    
    @Test("Incomplete percent encoding returns original")
    func incompletePercentEncoding() throws {
        try validateEvaluation(
            of: .string("test%2"),
            by: filter,
            yields: .string("test%2")
        )
    }
    
    @Test("Single percent at end returns original")
    func singlePercentAtEnd() throws {
        try validateEvaluation(
            of: .string("test%"),
            by: filter,
            yields: .string("test%")
        )
    }
    
    @Test("Mixed valid and invalid encoding returns original")
    func mixedValidInvalid() throws {
        try validateEvaluation(
            of: .string("Hello%20World%ZZ"),
            by: filter,
            yields: .string("Hello%20World%ZZ")
        )
    }
    
    // MARK: - Non-String Input Tests
    
    @Test("Integer input returns unchanged")
    func integerInput() throws {
        try validateEvaluation(
            of: .integer(42),
            by: filter,
            yields: .integer(42)
        )
    }
    
    @Test("Decimal input returns unchanged")
    func decimalInput() throws {
        try validateEvaluation(
            of: .decimal(3.14),
            by: filter,
            yields: .decimal(3.14)
        )
    }
    
    @Test("Boolean input returns unchanged")
    func booleanInput() throws {
        try validateEvaluation(
            of: .bool(true),
            by: filter,
            yields: .bool(true)
        )
    }
    
    @Test("Nil input returns unchanged")
    func nilInput() throws {
        try validateEvaluation(
            of: .nil,
            by: filter,
            yields: .nil
        )
    }
    
    @Test("Array input returns unchanged")
    func arrayInput() throws {
        try validateEvaluation(
            of: .array([.string("test")]),
            by: filter,
            yields: .array([.string("test")])
        )
    }
    
    @Test("Dictionary input returns unchanged")
    func dictionaryInput() throws {
        try validateEvaluation(
            of: .dictionary(["key": .string("value")]),
            by: filter,
            yields: .dictionary(["key": .string("value")])
        )
    }
    
    // MARK: - Special Character Tests
    
    @Test("Decodes common special characters")
    func commonSpecialCharacters() throws {
        try validateEvaluation(
            of: .string("%3C%3E%22%27%26"),
            by: filter,
            yields: .string("<>\"'&")
        )
    }
    
    @Test("Decodes URL query characters")
    func urlQueryCharacters() throws {
        try validateEvaluation(
            of: .string("page%3D1%26sort%3Dasc"),
            by: filter,
            yields: .string("page=1&sort=asc")
        )
    }
    
    @Test("Decodes path separators")
    func pathSeparators() throws {
        try validateEvaluation(
            of: .string("path%2Fto%2Ffile"),
            by: filter,
            yields: .string("path/to/file")
        )
    }
    
    // MARK: - Whitespace Tests
    
    @Test("Decodes various whitespace characters")
    func whitespaceCharacters() throws {
        try validateEvaluation(
            of: .string("tab%09newline%0Acarriage%0D"),
            by: filter,
            yields: .string("tab\tnewline\ncarriage\r")
        )
    }
    
    @Test("Multiple consecutive spaces from plus signs")
    func multipleSpacesFromPlus() throws {
        try validateEvaluation(
            of: .string("word+++word"),
            by: filter,
            yields: .string("word   word")
        )
    }
}