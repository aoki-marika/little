//
//  ParserTests.swift
//  LittleTests
//
//  Created by Marika on 2019-11-07.
//  Copyright © 2019 Marika. All rights reserved.
//

import XCTest
@testable import Little

class ParserTests: XCTestCase {

    // MARK: Test Cases

    func testAssignment() {
        // test different assignment statements
        assertLines(
            from: """
            A = 5
            10 B = A / 2
            20 C = B * 25 - A
            Z = A / B / C
            """,
            equals: [
                // A = 5
                ExpectedLine(
                    number: nil,
                    statement: .assignment(
                        variable: "A",
                        value: Expression(root: .integer(value: 5))
                    ),
                    literal: "A = 5"
                ),
                // 10 B = A / 2
                ExpectedLine(
                    number: 10,
                    statement: .assignment(
                        variable: "B",
                        value: Expression(root: .binaryOperator(
                            token: .slash,
                            left: .variable(name: "A"),
                            right: .integer(value: 2)
                        ))
                    ),
                    literal: "10 B = A / 2"
                ),
                // 20 C = B * 25 - A
                ExpectedLine(
                    number: 20,
                    statement: .assignment(
                        variable: "C",
                        value: Expression(root: .binaryOperator(
                            token: .minus,
                            left: .binaryOperator(
                                token: .asterisk,
                                left: .variable(name: "B"),
                                right: .integer(value: 25)
                            ),
                            right: .variable(name: "A")
                        ))
                    ),
                    literal: "20 C = B * 25 - A"
                ),
                // Z = A / B / C
                ExpectedLine(
                    number: nil,
                    statement: .assignment(
                        variable: "Z",
                        value: Expression(root: .binaryOperator(
                            token: .slash,
                            left: .variable(name: "A"),
                            right: .binaryOperator(
                                token: .slash,
                                left: .variable(name: "B"),
                                right: .variable(name: "C")
                            )
                        ))
                    ),
                    literal: "Z = A / B / C"
                ),
            ]
        )
    }

    func testPrint() {
        // test different print statements
        assertLines(
            from: """
            A = 5
            PRINT A
            10 PRINT "A="; A
            20 PR "A / 5 =", A / 5; "!"
            30 PRINT A, "/", 5, "=", A / 5,
            40 PR A; "/"; 5; "="; A / 5;
            """,
            equals: [
                // A = 5
                ExpectedLine(
                    number: nil,
                    statement: .assignment(
                        variable: "A",
                        value: Expression(root: .integer(value: 5))
                    ),
                    literal: "A = 5"
                ),
                // PRINT A
                ExpectedLine(
                    number: nil,
                    statement: .print(
                        items: [
                            PrintItem(
                                kind: .expression(expression: Expression(root: .variable(name: "A"))),
                                terminator: ""
                            ),
                        ]
                    ),
                    literal: "PRINT A"
                ),
                // 10 PRINT "A="; A
                ExpectedLine(
                    number: 10,
                    statement: .print(
                        items: [
                            PrintItem(
                                kind: .string(string: "A="),
                                terminator: ""
                            ),
                            PrintItem(
                                kind: .expression(expression: Expression(root: .variable(name: "A"))),
                                terminator: ""
                            ),
                        ]
                    ),
                    literal: "10 PRINT \"A=\"; A"
                ),
                // 20 PR "A / 5 =", A / 5; "!"
                ExpectedLine(
                    number: 20,
                    statement: .print(
                        items: [
                            PrintItem(
                                kind: .string(string: "A / 5 ="),
                                terminator: " "
                            ),
                            PrintItem(
                                kind: .expression(expression: Expression(root: .binaryOperator(
                                    token: .slash,
                                    left: .variable(name: "A"),
                                    right: .integer(value: 5)
                                ))),
                                terminator: ""
                            ),
                            PrintItem(
                                kind: .string(string: "!"),
                                terminator: ""
                            ),
                        ]
                    ),
                    literal: "20 PR \"A / 5 =\", A / 5; \"!\""
                ),
                // 30 PRINT A, "/", 5, "=", A / 5,
                ExpectedLine(
                    number: 30,
                    statement: .print(
                        items: [
                            PrintItem(
                                kind: .expression(expression: Expression(root: .variable(name: "A"))),
                                terminator: " "
                            ),
                            PrintItem(
                                kind: .string(string: "/"),
                                terminator: " "
                            ),
                            PrintItem(
                                kind: .expression(expression: Expression(root: .integer(value: 5))),
                                terminator: " "
                            ),
                            PrintItem(
                                kind: .string(string: "="),
                                terminator: " "
                            ),
                            PrintItem(
                                kind: .expression(expression: Expression(root: .binaryOperator(
                                    token: .slash,
                                    left: .variable(name: "A"),
                                    right: .integer(value: 5)
                                ))),
                                terminator: " "
                            ),
                        ]
                    ),
                    literal: "30 PRINT A, \"/\", 5, \"=\", A / 5,"
                ),
                // 40 PR A; "/"; 5; "="; A / 5;
                ExpectedLine(
                    number: 40,
                    statement: .print(
                        items: [
                            PrintItem(
                                kind: .expression(expression: Expression(root: .variable(name: "A"))),
                                terminator: ""
                            ),
                            PrintItem(
                                kind: .string(string: "/"),
                                terminator: ""
                            ),
                            PrintItem(
                                kind: .expression(expression: Expression(root: .integer(value: 5))),
                                terminator: ""
                            ),
                            PrintItem(
                                kind: .string(string: "="),
                                terminator: ""
                            ),
                            PrintItem(
                                kind: .expression(expression: Expression(root: .binaryOperator(
                                    token: .slash,
                                    left: .variable(name: "A"),
                                    right: .integer(value: 5)
                                ))),
                                terminator: ""
                            ),
                        ]
                    ),
                    literal: "40 PR A; \"/\"; 5; \"=\"; A / 5;"
                ),
            ]
        )
    }

    func testComments() {
        // test different comments
        assertLines(
            from: """
            REM Comment one.
            REM Comment two.
            10 REM Comment three.
            """,
            equals: [
                ExpectedLine(
                    number: nil,
                    statement: .none,
                    literal: "REM Comment one."
                ),
                ExpectedLine(
                    number: nil,
                    statement: .none,
                    literal: "REM Comment two."
                ),
                ExpectedLine(
                    number: 10,
                    statement: .none,
                    literal: "10 REM Comment three."
                ),
            ]
        )
    }

    func testSequence() {
        // test sequence related keywords
        assertLines(
            from: """
            PR "Start."
            CLEAR
            10 END
            GOTO 10
            """,
            equals: [
                ExpectedLine(
                    number: nil,
                    statement: .print(items: [
                        PrintItem(kind: .string(string: "Start."), terminator: ""),
                    ]),
                    literal: "PR \"Start.\""
                ),
                ExpectedLine(
                    number: nil,
                    statement: .clear,
                    literal: "CLEAR"
                ),
                ExpectedLine(
                    number: 10,
                    statement: .end,
                    literal: "10 END"
                ),
                ExpectedLine(
                    number: nil,
                    statement: .goto(line: Expression(root: .integer(value: 10))),
                    literal: "GOTO 10"
                ),
            ]
        )
    }

    func testFunctions() {
        // test different functions
        assertLines(
            from: """
            LET N = RND(50)
            C = RND(4 + 2)
            """,
            equals: [
                // LET N = RND(50)
                ExpectedLine(
                    number: nil,
                    statement: .assignment(
                        variable: "N",
                        value: Expression(root: .random(
                            range: .wrappedExpression(expression: Expression(root: .integer(value: 50)))
                        ))
                    ),
                    literal: "LET N = RND(50)"
                ),
                // C = RND(4 + 2)
                ExpectedLine(
                    number: nil,
                    statement: .assignment(
                        variable: "C",
                        value: Expression(root: .random(
                            range: .wrappedExpression(expression: Expression(root: .binaryOperator(
                                token: .plus,
                                left: .integer(value: 4),
                                right: .integer(value: 2)
                            )))
                        ))
                    ),
                    literal: "C = RND(4 + 2)"
                ),
            ]
        )
    }

    // MARK: Private Methods

    /// Assert that the lines parsed from the given input match the given lines.
    /// - Parameter input: The input to parse the lines of.
    /// - Parameter expected: The lines that are expected to be parsed.
    private func assertLines(from input: String, equals expected: [ExpectedLine]) {
        let lexer = Lexer(input: input)
        let parser = Parser(lexer: lexer)
        var lines = [Line]()
        XCTAssertNoThrow(lines = try parser.parse())

        let got = lines.map {
            ExpectedLine(
                number: $0.number,
                statement: $0.statement,
                literal: String(input[$0.range])
            )
        }

        XCTAssertEqual(got, expected)
    }
}

// MARK: ExpectedLine

extension ParserTests {
    /// The data structure for defining an expected line result when asserting parsed lines.
    ///
    /// This is simply because manually entering the string ranges would be terrible and prone to error.
    private struct ExpectedLine: Equatable {

        // MARK: Public Properties

        /// The expected number of the line.
        let number: Int?

        /// The expected statement of the line.
        let statement: Statement

        /// The expected string in the range of the line.
        let literal: String
    }
}
