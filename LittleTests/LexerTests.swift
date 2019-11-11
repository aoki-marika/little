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

    func testStrings() {
        // test the same strings in different scenarios
        let expected = [
            ExpectedToken(kind: .integer(value: 0),  literal: "0"),
            ExpectedToken(
                kind: .string(value: ""),
                literal: "\"\""
            ),
            ExpectedToken(kind: .integer(value: 0),  literal: "0"),
            ExpectedToken(kind: .endOfLine,          literal: "\n"),

            ExpectedToken(kind: .integer(value: 10), literal: "10"),
            ExpectedToken(
                kind: .string(value: "teststring"),
                literal: "\"teststring\""
            ),
            ExpectedToken(
                kind: .string(value: "another"),
                literal: "\"another\""
            ),
            ExpectedToken(kind: .integer(value: 10), literal: "10"),
            ExpectedToken(kind: .endOfLine,          literal: "\n"),

            ExpectedToken(kind: .integer(value: 20), literal: "20"),
            ExpectedToken(
                kind: .string(value: "test string with spaces"),
                literal: "\"test string with spaces\""
            ),
            ExpectedToken(
                kind: .string(value: "one"),
                literal: "\"one\""
            ),
            ExpectedToken(kind: .integer(value: 20), literal: "20"),
            ExpectedToken(kind: .endOfLine,          literal: "\n"),

            ExpectedToken(kind: .integer(value: 30), literal: "30"),
            ExpectedToken(
                kind: .string(value: "test-string! with num83r5!!"),
                literal: "\"test-string! with num83r5!!\""
            ),
            ExpectedToken(kind: .integer(value: 30), literal: "30"),
            ExpectedToken(kind: .endOfLine,          literal: "\n"),

            ExpectedToken(kind: .integer(value: 40), literal: "40"),
            ExpectedToken(
                kind: .string(value: "PRINT finally, 20 LET A = B keywords, and A B C variables"),
                literal: "\"PRINT finally, 20 LET A = B keywords, and A B C variables\""
            ),
            ExpectedToken(kind: .integer(value: 40), literal: "40"),
            ExpectedToken(kind: .endOfFile,          literal: ""),
        ]

        assertTokens(from: """
            0 "" 0
            10"teststring" "another" 10
            20 "test string with spaces""one" 20
            30"test-string! with num83r5!!" 30
            40"PRINT finally, 20 LET A = B keywords, and A B C variables"40
        """, equals: expected)

        assertTokens(from: """
            0 "" 0
            10"teststring""another"10
            20"test string with spaces" "one"20
            30 "test-string! with num83r5!!"30
            40   "PRINT finally, 20 LET A = B keywords, and A B C variables"    40
        """, equals: expected)
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

    func testArithmetic() {
        // test arithmetic expressions with all available tokens
        assertTokens(
            from: "7 + 3 * (10 / (12 / (3 + 1) - 1))",
            equals: [
                ExpectedToken(kind: .integer(value: 7),   literal: "7"),
                ExpectedToken(kind: .plus,                literal: "+"),
                ExpectedToken(kind: .integer(value: 3),   literal: "3"),
                ExpectedToken(kind: .asterisk,            literal: "*"),
                ExpectedToken(kind: .leftParentheses,     literal: "("),
                    ExpectedToken(kind: .integer(value: 10),  literal: "10"),
                    ExpectedToken(kind: .slash,               literal: "/"),
                    ExpectedToken(kind: .leftParentheses,     literal: "("),
                        ExpectedToken(kind: .integer(value: 12),  literal: "12"),
                        ExpectedToken(kind: .slash,               literal: "/"),
                        ExpectedToken(kind: .leftParentheses,     literal: "("),
                            ExpectedToken(kind: .integer(value: 3),   literal: "3"),
                            ExpectedToken(kind: .plus,                literal: "+"),
                            ExpectedToken(kind: .integer(value: 1),   literal: "1"),
                        ExpectedToken(kind: .rightParentheses,    literal: ")"),
                        ExpectedToken(kind: .minus,               literal: "-"),
                        ExpectedToken(kind: .integer(value: 1),   literal: "1"),
                    ExpectedToken(kind: .rightParentheses,    literal: ")"),
                ExpectedToken(kind: .rightParentheses,    literal: ")"),
                ExpectedToken(kind: .endOfFile, literal: "")
            ]
        )

        assertTokens(
            from: "7 + 3 * (10 / (12 / (3 + 1) - 1)) / (2 + 3) - 5 - 3 + (8)",
            equals: [
                ExpectedToken(kind: .integer(value: 7),   literal: "7"),
                ExpectedToken(kind: .plus,                literal: "+"),
                ExpectedToken(kind: .integer(value: 3),   literal: "3"),
                ExpectedToken(kind: .asterisk,            literal: "*"),
                ExpectedToken(kind: .leftParentheses,     literal: "("),
                    ExpectedToken(kind: .integer(value: 10),  literal: "10"),
                    ExpectedToken(kind: .slash,               literal: "/"),
                    ExpectedToken(kind: .leftParentheses,     literal: "("),
                        ExpectedToken(kind: .integer(value: 12),  literal: "12"),
                        ExpectedToken(kind: .slash,               literal: "/"),
                        ExpectedToken(kind: .leftParentheses,     literal: "("),
                            ExpectedToken(kind: .integer(value: 3),   literal: "3"),
                            ExpectedToken(kind: .plus,                literal: "+"),
                            ExpectedToken(kind: .integer(value: 1),   literal: "1"),
                        ExpectedToken(kind: .rightParentheses,    literal: ")"),
                        ExpectedToken(kind: .minus,               literal: "-"),
                        ExpectedToken(kind: .integer(value: 1),   literal: "1"),
                    ExpectedToken(kind: .rightParentheses,    literal: ")"),
                ExpectedToken(kind: .rightParentheses,    literal: ")"),
                ExpectedToken(kind: .slash,               literal: "/"),
                ExpectedToken(kind: .leftParentheses,     literal: "("),
                    ExpectedToken(kind: .integer(value: 2),   literal: "2"),
                    ExpectedToken(kind: .plus,                literal: "+"),
                    ExpectedToken(kind: .integer(value: 3),   literal: "3"),
                ExpectedToken(kind: .rightParentheses,    literal: ")"),
                ExpectedToken(kind: .minus,               literal: "-"),
                ExpectedToken(kind: .integer(value: 5),   literal: "5"),
                ExpectedToken(kind: .minus,               literal: "-"),
                ExpectedToken(kind: .integer(value: 3),   literal: "3"),
                ExpectedToken(kind: .plus,                literal: "+"),
                ExpectedToken(kind: .leftParentheses,     literal: "("),
                    ExpectedToken(kind: .integer(value: 8),   literal: "8"),
                ExpectedToken(kind: .rightParentheses,    literal: ")"),
                ExpectedToken(kind: .endOfFile, literal: "")
            ]
        )
    }

    func testLines() {
        // test various valid lines
        assertTokens(
            from: """
            123 5 + 7
            456 2 / 3
            789+25
            32767 20*2
            1+1
            10000+(-5)
            10001-(+5)
            """,
            equals: [
                ExpectedToken(kind: .integer(value: 123),   literal: "123"),
                ExpectedToken(kind: .integer(value: 5),     literal: "5"),
                ExpectedToken(kind: .plus,                  literal: "+"),
                ExpectedToken(kind: .integer(value: 7),     literal: "7"),
                ExpectedToken(kind: .endOfLine,             literal: "\n"),

                ExpectedToken(kind: .integer(value: 456),   literal: "456"),
                ExpectedToken(kind: .integer(value: 2),     literal: "2"),
                ExpectedToken(kind: .slash,                 literal: "/"),
                ExpectedToken(kind: .integer(value: 3),     literal: "3"),
                ExpectedToken(kind: .endOfLine,             literal: "\n"),

                ExpectedToken(kind: .integer(value: 789),   literal: "789"),
                ExpectedToken(kind: .plus,                  literal: "+"),
                ExpectedToken(kind: .integer(value: 25),    literal: "25"),
                ExpectedToken(kind: .endOfLine,             literal: "\n"),

                ExpectedToken(kind: .integer(value: 32767), literal: "32767"),
                ExpectedToken(kind: .integer(value: 20),    literal: "20"),
                ExpectedToken(kind: .asterisk,              literal: "*"),
                ExpectedToken(kind: .integer(value: 2),     literal: "2"),
                ExpectedToken(kind: .endOfLine,             literal: "\n"),

                ExpectedToken(kind: .integer(value: 1),     literal: "1"),
                ExpectedToken(kind: .plus,                  literal: "+"),
                ExpectedToken(kind: .integer(value: 1),     literal: "1"),
                ExpectedToken(kind: .endOfLine,             literal: "\n"),

                ExpectedToken(kind: .integer(value: 10000), literal: "10000"),
                ExpectedToken(kind: .plus,                  literal: "+"),
                ExpectedToken(kind: .leftParentheses,       literal: "("),
                    ExpectedToken(kind: .minus,                 literal: "-"),
                    ExpectedToken(kind: .integer(value: 5),     literal: "5"),
                ExpectedToken(kind: .rightParentheses,      literal: ")"),
                ExpectedToken(kind: .endOfLine,             literal: "\n"),

                ExpectedToken(kind: .integer(value: 10001), literal: "10001"),
                ExpectedToken(kind: .minus,                 literal: "-"),
                ExpectedToken(kind: .leftParentheses,       literal: "("),
                    ExpectedToken(kind: .plus,                  literal: "+"),
                    ExpectedToken(kind: .integer(value: 5),     literal: "5"),
                ExpectedToken(kind: .rightParentheses,      literal: ")"),
                ExpectedToken(kind: .endOfFile,             literal: "")
            ]
        )
    }

    func testVariables() {
        // test various variable usages
        assertTokens(
            from: """
            10 A = 5 / 2
            20 B = A * 3
            C = B / A * 20
            Z = (C - A * B) / -2
            30 PRINT Z
            """,
            equals: [
                ExpectedToken(kind: .integer(value: 10),  literal: "10"),
                ExpectedToken(kind: .variable(name: "A"), literal: "A"),
                ExpectedToken(kind: .equals,              literal: "="),
                ExpectedToken(kind: .integer(value: 5),   literal: "5"),
                ExpectedToken(kind: .slash,               literal: "/"),
                ExpectedToken(kind: .integer(value: 2),   literal: "2"),
                ExpectedToken(kind: .endOfLine,           literal: "\n"),

                ExpectedToken(kind: .integer(value: 20),  literal: "20"),
                ExpectedToken(kind: .variable(name: "B"), literal: "B"),
                ExpectedToken(kind: .equals,              literal: "="),
                ExpectedToken(kind: .variable(name: "A"), literal: "A"),
                ExpectedToken(kind: .asterisk,            literal: "*"),
                ExpectedToken(kind: .integer(value: 3),   literal: "3"),
                ExpectedToken(kind: .endOfLine,           literal: "\n"),

                ExpectedToken(kind: .variable(name: "C"), literal: "C"),
                ExpectedToken(kind: .equals,              literal: "="),
                ExpectedToken(kind: .variable(name: "B"), literal: "B"),
                ExpectedToken(kind: .slash,               literal: "/"),
                ExpectedToken(kind: .variable(name: "A"), literal: "A"),
                ExpectedToken(kind: .asterisk,            literal: "*"),
                ExpectedToken(kind: .integer(value: 20),  literal: "20"),
                ExpectedToken(kind: .endOfLine,           literal: "\n"),

                ExpectedToken(kind: .variable(name: "Z"), literal: "Z"),
                ExpectedToken(kind: .equals,              literal: "="),
                ExpectedToken(kind: .leftParentheses,     literal: "("),
                    ExpectedToken(kind: .variable(name: "C"), literal: "C"),
                    ExpectedToken(kind: .minus,               literal: "-"),
                    ExpectedToken(kind: .variable(name: "A"), literal: "A"),
                    ExpectedToken(kind: .asterisk,            literal: "*"),
                    ExpectedToken(kind: .variable(name: "B"), literal: "B"),
                ExpectedToken(kind: .rightParentheses,    literal: ")"),
                ExpectedToken(kind: .slash,               literal: "/"),
                ExpectedToken(kind: .minus,               literal: "-"),
                ExpectedToken(kind: .integer(value: 2),   literal: "2"),
                ExpectedToken(kind: .endOfLine,           literal: "\n"),

                ExpectedToken(kind: .integer(value: 30),  literal: "30"),
                ExpectedToken(kind: .keywordPrint,        literal: "PRINT"),
                ExpectedToken(kind: .variable(name: "Z"), literal: "Z"),
                ExpectedToken(kind: .endOfFile,           literal: ""),
            ]
        )
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
