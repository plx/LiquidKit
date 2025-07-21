//
//  LiquidTests.swift
//  LiquidTests
//
//  Created by YourtionGuo on 27/06/2017.
//

import XCTest
@testable import LiquidKit

#if os(Linux)
import SwiftGlibc
import Foundation
#endif

class LiquidTests: XCTestCase {
  func testLexer() throws {
    LexerTests().testCreateToken()
    LexerTests().testTokenize()
  }
  func testParser() throws {
    try ParserTests().testParseText()
    try ParserTests().testParseVariable()
  }

}

extension LiquidTests {
    static var allTests : [(String, (LiquidTests) -> () throws -> Void)] {
        return [
            ("testLexer", testLexer),
            ("testParser", testParser),
        ]
    }
}
