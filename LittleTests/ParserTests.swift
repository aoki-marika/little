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
                Line(
                    number: nil,
                    statement: .assignment(
                        variable: "A",
                        value: Expression(root: .integer(value: 5))
                    )
                ),
                // 10 B = A / 2
                Line(
                    number: 10,
                    statement: .assignment(
                        variable: "B",
                        value: Expression(root: .binaryOperator(
                            token: .slash,
                            left: .variable(name: "A"),
                            right: .integer(value: 2)
                        ))
                    )
                ),
                // 20 C = B * 25 - A
                Line(
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
                    )
                ),
                // Z = A / B / C
                Line(
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
                    )
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
            20 PRINT "A / 5 =", A / 5; "!"
            30 PRINT A, "/", 5, "=", A / 5,
            40 PRINT A; "/"; 5; "="; A / 5;
            """,
            equals: [
                // A = 5
                Line(
                    number: nil,
                    statement: .assignment(
                        variable: "A",
                        value: Expression(root: .integer(value: 5))
                    )
                ),
                // PRINT A
                Line(
                    number: nil,
                    statement: .print(
                        items: [
                            PrintItem(
                                kind: .expression(expression: Expression(root: .variable(name: "A"))),
                                terminator: ""
                            ),
                        ]
                    )
                ),
                // 10 PRINT "A="; A
                Line(
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
                    )
                ),
                // 20 PRINT "A / 5 =", A / 5; "!"
                Line(
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
                    )
                ),
                // 30 PRINT A, "/", 5, "=", A / 5,
                Line(
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
                    )
                ),
                // 40 PRINT A; "/"; 5; "="; A / 5;
                Line(
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
                    )
                ),
            ]
        )
    }

    // MARK: Private Methods

    /// Assert that the lines parsed from the given input match the given lines.
    /// - Parameter input: The input to parse the lines of.
    /// - Parameter expected: The lines that are expected to be parsed.
    private func assertLines(from input: String, equals expected: [Line]) {
        let lexer = Lexer(input: input)
        let parser = Parser(lexer: lexer)
        var got = [Line]()
        XCTAssertNoThrow(got = try parser.parse())
        XCTAssertEqual(got, expected)
    }
}
