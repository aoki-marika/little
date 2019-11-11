//
//  Interpreter.swift
//  Little
//
//  Created by Marika on 2019-11-09.
//  Copyright © 2019 Marika. All rights reserved.
//

import Foundation

/// The object for interpreting lines from a parser.
public class Interpreter {

    // MARK: Private Properties

    /// The parser for this interpreter to interpret the lines of.
    private let parser: Parser

    /// The output for this interpreter to output text to.
    private let output: Output

    /// The current lines in this interpreter.
    private var lines = [Line]()

    /// The offset of the current line that this interpreter is executing in `lines`.
    private var currentOffset = 0

    /// The current mapping of line numbers to offsets in this interpreter.
    private var lineNumbers = [Int : Int]()

    /// The current values of the variables assigned in this interpreter.
    /// Maps variable name to value.
    private var variables = [String : Int]()

    // MARK: Initializers

    /// - Parameter parser: The parser for this interpreter to interpret the lines of.
    /// - Parameter output: The output for this interpreter to output text to.
    init(parser: Parser, output: Output) {
        self.parser = parser
        self.output = output
    }

    /// - Parameter input: The program for this interpreter to interpret.
    /// - Parameter output: The output for this interpreter to output text to.
    public convenience init(input: String, output: Output) {
        let lexer = Lexer(input: input)
        let parser = Parser(lexer: lexer)
        self.init(parser: parser, output: output)
    }

    // MARK: Public Methods

    /// Reset this interpreter's state and parse the lines again.
    public func start() throws {
        lines = try parser.parse()
        currentOffset = 0
        lineNumbers = [:]
        variables = [:]
    }

    /// Execute the next line in this interpreter.
    /// - Returns: Whether or not this interpreter has reached the end of it's program.
    /// If it has, then execution should complete and this method should not be called again without first calling `start()`.
    public func step() throws -> Bool {
        guard currentOffset < lines.count else {
            return true
        }

        let line = lines[currentOffset]
        try execute(line: line, offset: currentOffset)
        currentOffset += 1
        return false
    }

    // MARK: Private Methods

    /// Execute the given line in this interpreter.
    /// - Parameter line: The line to execute.
    /// - Parameter offset: The offset of the given line in this interpreter's lines.
    private func execute(line: Line, offset: Int) throws {
        // assign the line number if one was given
        if let number = line.number {
            lineNumbers[number] = offset
        }

        // execute the lines statement
        switch line.statement {
        case .none:
            break
        case .print(let items):
            try executePrint(items: items)
        case .assignment(let variable, let value):
            try executeAssignment(variable: variable, value: value)
        }
    }

    /// Calls `evaluate(node:)` with `expression.root`.
    private func evaluate(expression: Expression) throws -> Int {
        return try evaluate(node: expression.root)
    }

    /// Evaluate the given expression node and return it's result.
    /// - Parameter node: The node to evaluate.
    /// - Returns: The resulting value of evaluating the given node.
    private func evaluate(node: Expression.Node) throws -> Int {
        // fatal errors are allowed on operator tokens as they should never
        // be created from invalid tokens, if they are then its a parser error,
        // not a program error

        switch node {
        case .unaryOperator(let token, let operandNode):
            let operand = try evaluate(node: operandNode)

            switch token {
            case .plus:
                return +operand
            case .minus:
                return -operand
            default:
                fatalError("invalid unary operator: \(token)")
            }
        case .binaryOperator(let token, let leftNode, let rightNode):
            let left = try evaluate(node: leftNode)
            let right = try evaluate(node: rightNode)

            switch token {
            case .plus:
                return left + right
            case .minus:
                return left - right
            case .slash:
                guard right != 0 else {
                    throw InterpreterError.divisionByZero
                }

                return left / right
            case .asterisk:
                return left * right
            default:
                fatalError("invalid binary operator: \(token)")
            }
        case .integer(let value):
            return value
        case .variable(let name):
            guard let value = variables[name] else {
                throw InterpreterError.readingUnassignedVariable(name: name)
            }

            return value
        case .wrappedExpression(let expression):
            return try evaluate(expression: expression)
        }
    }

    // MARK: Statements

    // see the corresponding statement of each for docs on parameters
    // as they all take in the parameters of the same names and types

    private func executePrint(items: [PrintItem]) throws {
        for item in items {
            switch item.kind {
            case .expression(let expression):
                let value = try evaluate(expression: expression)
                output.receive(string: String(value))
            case .string(let string):
                output.receive(string: string)
            }

            output.receive(string: item.terminator)
        }

        output.receive(string: "\n")
    }

    private func executeAssignment(variable: String, value: Expression) throws {
        variables[variable] = try evaluate(expression: value)
    }
}
