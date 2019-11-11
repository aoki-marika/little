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
    private var lineNumberOffsets = [Int : Int]()

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
        lineNumberOffsets = [:]
        variables = [:]

        // read in all the line number offsets
        for (offset, line) in lines.enumerated() {
            guard let number = line.number else {
                continue
            }

            lineNumberOffsets[number] = offset
        }
    }

    /// Execute the next line in this interpreter.
    /// - Returns: Whether or not this interpreter has reached the end of it's program.
    /// If it has, then execution should complete and this method should not be called again without first calling `start()`.
    public func step() throws -> Bool {
        guard currentOffset < lines.count else {
            return true
        }

        // execute the next line and wrap any errors it produces in a runtime error
        let line = lines[currentOffset]
        do {
            if try execute(statement: line.statement) {
                return true
            }
        }
        catch {
            // dont rewrap existing runtime errors
            guard !(error is RuntimeError) else {
                throw error
            }

            let range = line.range
            throw RuntimeError(range: range, wrapped: error)
        }

        currentOffset += 1
        return false
    }

    // MARK: Private Methods

    /// Execute the given statement in this interpreter.
    /// - Returns: Whether or not the given statement terminated the program.
    private func execute(statement: Statement) throws -> Bool {
        switch statement {
        case .none:
            break
        case .print(let items):
            try executePrint(items: items)
        case .assignment(let variable, let value):
            try executeAssignment(variable: variable, value: value)
        case .goto(let line):
            try executeGoto(line: line)
        case .goSub(let line):
            try executeGoSub(line: line)
        case .return:
            try executeReturn()
        case .if(let token, let left, let right, let statement):
            return try executeIf(token: token, left: left, right: right, statement: statement)
        case .clear:
            executeClear()
        case .end:
            return true
        }

        return false
    }

    /// Calls `evaluate(node:)` with `expression.root`, wrapping any errors in a runtime error with the given expression's range.
    private func evaluate(expression: Expression) throws -> Int {
        do {
            return try evaluate(node: expression.root)
        }
        catch {
            // dont rewrap sub-expressions
            guard !(error is RuntimeError) else {
                throw error
            }

            let range = expression.range!
            throw RuntimeError(range: range, wrapped: error)
        }
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

    private func executeGoto(line: Expression) throws {
        let number = try evaluate(expression: line)
        guard let offset = lineNumberOffsets[number] else {
            throw InterpreterError.referencingUnassignedLine(number: number)
        }

        // need to decrement by one to account for the increment after this statement is executed
        // if this isnt done then the line that is gotod is not executed, only the lines after it
        currentOffset = offset - 1
    }

    private func executeGoSub(line: Expression) throws {
        let number = try evaluate(expression: line)
        print("GOSUB", number)
    }

    private func executeReturn() {
        print("RETURN")
    }

    /// - Returns: Whether or not the given statement terminated the program.
    private func executeIf(token: Token.Kind, left: Expression, right: Expression, statement: Statement) throws -> Bool {
        let leftValue = try evaluate(expression: left)
        let rightValue = try evaluate(expression: right)

        let matched: Bool
        switch token {
        case .equals:
            matched = leftValue == rightValue
        case .lessThan:
            matched = leftValue < rightValue
        case .greaterThan:
            matched = leftValue > rightValue
        case .lessOrEqual:
            matched = leftValue <= rightValue
        case .greaterOrEqual:
            matched = leftValue >= rightValue
        case .notEqual:
            matched = leftValue != rightValue
        default:
            fatalError("invalid relational operator: \(token)")
        }

        if matched {
            return try execute(statement: statement)
        }

        return false
    }

    private func executeClear() {
        output.clear()
    }
}
