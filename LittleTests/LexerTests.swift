//
//  LexerTests.swift
//  LittleTests
//
//  Created by Marika on 2019-11-07.
//  Copyright © 2019 Marika. All rights reserved.
//

import XCTest
@testable import Little

class LexerTests: XCTestCase {

    // MARK: Test Cases

    func testNumbers() {
        // test the same numbers in different scenarios
        let expected = [
            ExpectedToken(kind: .integer(value: 1),    literal: "1"),
            ExpectedToken(kind: .integer(value: 22),   literal: "22"),
            ExpectedToken(kind: .integer(value: 333),  literal: "333"),
            ExpectedToken(kind: .integer(value: 4444), literal: "4444"),
            ExpectedToken(kind: .endOfFile,            literal: ""),
        ]

        assertTokens(from: "1 22 333 4444", equals: expected)
        assertTokens(from: " 1 22 333 4444", equals: expected)
        assertTokens(from: "  1 22 333 4444", equals: expected)
        assertTokens(from: "1 22 333 4444 ", equals: expected)
        assertTokens(from: "1 22 333 4444  ", equals: expected)
        assertTokens(from: " 1 22 333 4444 ", equals: expected)
        assertTokens(from: "  1 22 333 4444 ", equals: expected)
        assertTokens(from: " 1 22 333 4444  ", equals: expected)
        assertTokens(from: "  1 22 333 4444  ", equals: expected)
    }

    func testSingleOperators() {
        // test the same single character operators in different whitespace scenarios
        let expected = [
            ExpectedToken(kind: .slash,               literal: "/"),
            ExpectedToken(kind: .integer(value: 21),  literal: "21"),
            ExpectedToken(kind: .plus,                literal: "+"),
            ExpectedToken(kind: .integer(value: 3),   literal: "3"),
            ExpectedToken(kind: .minus,               literal: "-"),
            ExpectedToken(kind: .integer(value: 63),  literal: "63"),
            ExpectedToken(kind: .asterisk,            literal: "*"),
            ExpectedToken(kind: .minus,               literal: "-"),
            ExpectedToken(kind: .integer(value: 512), literal: "512"),
            ExpectedToken(kind: .endOfFile,           literal: ""),
        ]

        assertTokens(from: "/21+3-63*-512", equals: expected)
        assertTokens(from: "/ 21+ 3-63 *-512", equals: expected)
        assertTokens(from: " /21+  3-63*  -512 ", equals: expected)
        assertTokens(from: "  / 21 + 3-63*-  512", equals: expected)
        assertTokens(from: " / 21  +  3 - 63 *- 512", equals: expected)
        assertTokens(from: "   /  21  +  3  -  63  *  -  512 ", equals: expected)
        assertTokens(from: "/ 21 + 3 - 63 * -512", equals: expected)
        assertTokens(from: " / 21 +3-63*-512", equals: expected)
        assertTokens(from: " /21+ 3- 63*- 512  ", equals: expected)
    }

    // MARK: Private Methods

    /// Assert that the tokens analyzed from the given input match the given expected tokens.
    /// - Parameter input: The input to analyze.
    /// - Parameter expected: The tokens that are expected to be analyzed.
    private func assertTokens(from input: String, equals expected: [ExpectedToken]) {
        let lexer = Lexer(input: input)

        // tests provide no clean way to do this, so here we are
        var tokens: [Token]!
        XCTAssertNoThrow(tokens = try lexer.analyze())

        // map the analyzed tokens to expected tokens
        let got = tokens.map {
            ExpectedToken(
                kind: $0.kind,
                literal: String(input[$0.range])
            )
        }

        // compare the analyzed and the expected
        XCTAssertEqual(got, expected)
    }
}

// MARK: ExpectedToken

extension LexerTests {
    /// The data structure for defining an expected token result when asserting analyzed tokens.
    ///
    /// This is simply because manually entering the string ranges would be terrible and prone to error.
    private struct ExpectedToken: Equatable {

        // MARK: Public Properties

        /// The expected kind of the token.
        let kind: Token.Kind

        /// The expected string in the range of the token.
        let literal: String
    }
}
