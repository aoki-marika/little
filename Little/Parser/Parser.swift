//
//  Parser.swift
//  Little
//
//  Created by Marika on 2019-11-07.
//  Copyright © 2019 Marika. All rights reserved.
//

import Foundation

/// The object for parsing analyzed tokens into lines.
///
/// This is implementing accoring to the Tiny BASIC definition available at [http://users.telenet.be/kim1-6502/tinybasic/tbum.html#appb](here).
class Parser {

    // MARK: Private Properties

    /// The lexer for this parser to parse the tokens of.
    private let lexer: Lexer

    /// The current token that this parser is parsing, if any.
    private var currentToken: Token!

    // MARK: Initializers

    /// - Parameter lexer: The lexer for this parser to parse the tokens of.
    init(lexer: Lexer) {
        self.lexer = lexer
    }

    // MARK: Public Methods

    /// Analyze and parse the tokens from this parser's lexer into lines.
    /// - Returns: The lines from the tokens of this parser's lexer.
    func parse() throws -> [Line] {
        // reset state and get the first token
        lexer.reset()
        currentToken = try lexer.analyzeNext()

        // parse all the tokens from the lexer into lines
        // wrap any errors in source errors if they arent already
        var lines = [Line]()
        do {
            repeat {
                lines.append(try line())
            } while currentToken.kind != .endOfFile
        }
        catch {
            guard !(error is SourceError) else {
                throw error
            }

            let range = currentToken.range
            throw SourceError(range: range, wrapped: error)
        }

        // return the new lines
        return lines
    }

    // MARK: Private Methods

    /// Ensure that the current token of this parser matches the given kind, then advance the current token.
    /// - Parameter kind: The kind to ensure that the current token is.
    private func eat(kind: Token.Kind) throws {
        guard currentToken.kind == kind else {
            let got = currentToken.kind
            throw ParserError.unexpectedTokenKind(expected: kind, got: got)
        }

        currentToken = try lexer.analyzeNext()
    }

    // MARK: Grammar

    /// ```
    /// line ::= number statement CR
    ///          statement CR
    /// ```
    private func line() throws -> Line {
        let lineNumber: Int?
        switch currentToken.kind {
        case .integer(let value):
            lineNumber = value
            try eat(kind: currentToken.kind)
        default:
            // if there is no line number then this could be a blank line
            // only lines without numbers can be blank, if there is a line number then there must be a statement
            if currentToken.kind == .endOfLine || currentToken.kind == .endOfLine {
                try eat(kind: currentToken.kind)
                let line = Line(number: nil, statement: .none)
                return line
            }

            lineNumber = nil
        }

        let lineStatement = try statement()

        switch currentToken.kind {
        case .endOfLine, .endOfFile:
            try eat(kind: currentToken.kind)
        default:
            throw ParserError.expectedLineEnd(kind: currentToken.kind)
        }

        let line = Line(number: lineNumber, statement: lineStatement)
        return line
    }

    /// ```
    /// statement ::= PRINT printlist
    ///               PR printlist
    ///               INPUT varlist
    ///               LET var = expression
    ///               var = expression
    ///               GOTO expression
    ///               GOSUB expression
    ///               RETURN
    ///               IF expression relop expression THEN statement
    ///               IF expression relop expression statement
    ///               REM commentstring
    ///               CLEAR
    ///               RUN
    ///               RUN exprlist
    ///               LIST
    ///               LIST exprlist
    /// ```
    private func statement() throws -> Statement {
        switch currentToken.kind {
        case .keywordPrint:
            try eat(kind: .keywordPrint)
            return .print(items: try printlist())
        case .keywordLet:
            return try assignment()
        default:
            return try assignment()
        }
    }

    /// ```
    /// printlist ::=
    ///               printitem
    ///               printitem separator
    ///               printitem separator printlist
    /// ```
    ///
    /// - Note: This is implemented slightly different from the standard in that `,` terminates with a space and `;` terminates with nothing.
    ///
    /// If the statement ends with a separator then that separator is still printed.
    /// If there is no separator then no separator is printed.
    private func printlist() throws -> [PrintItem] {
        var items = [PrintItem]()

        // ensure there is a print item to read
        if currentToken.kind != .endOfLine && currentToken.kind != .endOfFile {
            let kind = try printitem()
            let terminator: String

            // read the terminator
            switch currentToken.kind {
            case .comma:
                try eat(kind: .comma)
                terminator = " "
            case .semicolon:
                try eat(kind: .semicolon)
                terminator = ""
            default:
                terminator = ""
                break
            }

            items.append(PrintItem(kind: kind, terminator: terminator))
            items.append(contentsOf: try printlist())
        }

        return items
    }

    /// ```
    /// printitem ::= expression
    ///               "characterstring"
    /// ```
    private func printitem() throws -> PrintItem.Kind {
        let kind = currentToken.kind

        switch kind {
        case .string(_):
            return .string(string: try string())
        default:
            return .expression(expression: try expression())
        }
    }

    /// ```
    /// assignment ::= LET var = expression
    ///                var = expression
    /// ```
    private func assignment() throws -> Statement {
        if currentToken.kind == .keywordLet {
            try eat(kind: .keywordLet)
        }

        let name = try variable()
        try eat(kind: .equals)
        let value = try expression()

        return .assignment(variable: name, value: value)
    }

    /// ```
    /// expression ::= unsignedexpr
    ///                + unsignedexpr
    ///                - unsignedexpr
    /// ```
    private func expression() throws -> Expression {
        let kind = currentToken.kind
        let root: Expression.Node

        switch kind {
        case .plus, .minus:
            try eat(kind: kind)
            root = .unaryOperator(
                token: kind,
                operand: try unsignedexpr()
            )
        default:
            root = try unsignedexpr()
        }

        return Expression(root: root)
    }

    /// ```
    /// unsignedexpr ::= term
    ///                  term + unsignedexpr
    ///                  term - unsignedexpr
    /// ```
    private func unsignedexpr() throws -> Expression.Node {
        let node = try term()
        let kind = currentToken.kind

        switch kind {
        case .plus, .minus:
            try eat(kind: kind)
            return .binaryOperator(
                token: kind,
                left: node,
                right: try unsignedexpr()
            )
        default:
            return node
        }
    }

    /// ```
    /// term ::= factor
    ///          factor * term
    ///          factor / term
    /// ```
    private func term() throws -> Expression.Node {
        let node = try factor()
        let kind = currentToken.kind

        switch kind {
        case .asterisk, .slash:
            try eat(kind: kind)
            return .binaryOperator(
                token: kind,
                left: node,
                right: try term()
            )
        default:
            return node
        }
    }

    /// ```
    /// factor ::= var
    ///            number
    ///            ( expression )
    ///            function
    /// ```
    private func factor() throws -> Expression.Node {
        let token = currentToken!

        for category in token.kind.categories {
            switch category {
            case .number:
                return try number()
            default:
                break
            }
        }

        switch token.kind {
        case .variable(_):
            return .variable(name: try variable())
        case .leftParentheses:
            try eat(kind: .leftParentheses)
            let inner = try expression()
            try eat(kind: .rightParentheses)
            return .wrappedExpression(
                expression: inner
            )
        default:
            break
        }

        throw ParserError.expectedFactor(got: token.kind)
    }

    /// ```
    /// number ::= digit
    ///            digit number
    /// ```
    /// ```
    /// digit ::= 0 ! 1 2 ! ... ! 9
    /// ```
    private func number() throws -> Expression.Node {
        let kind = currentToken.kind

        switch kind {
        case .integer(let value):
            try eat(kind: kind)
            return .integer(value: value)
        default:
            throw ParserError.expectedNumber(got: kind)
        }
    }

    /// ```
    /// "characterstring"
    /// ```
    private func string() throws -> String {
        let kind = currentToken.kind

        switch kind {
        case .string(let value):
            try eat(kind: kind)
            return value
        default:
            throw ParserError.expectedString(got: kind)
        }
    }

    /// ```
    /// var ::= A ! B ! ... ! Y ! Z
    /// ```
    private func variable() throws -> String {
        let kind = currentToken.kind

        switch kind {
        case .variable(let name):
            try eat(kind: kind)
            return name
        default:
            throw ParserError.expectedVariable(got: kind)
        }
    }
}
