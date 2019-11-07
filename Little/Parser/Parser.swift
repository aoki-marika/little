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
/// This is implementing accoring to the Tiny BASIC definition available at http://users.telenet.be/kim1-6502/tinybasic/tbum.html#appb
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

    /// Analyze and parse the tokens from this parser's lexer.
    func parse() throws {
        // reset state and get the first token
        lexer.reset()
        currentToken = try lexer.analyzeNext()

        // parse all the tokens from the lexer
        // wrap any errors in source errors
        do {
            try expression()
        }
        catch {
            let range = currentToken.range
            throw SourceError(range: range, wrapped: error)
        }
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

    /// Ensure that the current token of this parser matches the given category, then advance the current token.
    /// - Parameter category: The category to ensure that the current token is.
    private func eat(category: Token.Kind.Category) throws {
        guard currentToken.kind.category == category else {
            let got = currentToken.kind.category
            throw ParserError.unexpectedTokenCategory(expected: category, got: got)
        }

        currentToken = try lexer.analyzeNext()
    }

    // MARK: Grammar

    /// ```
    /// expression ::= unsignedexpr
    ///                + unsignedexpr
    ///                - unsignedexpr
    /// ```
    private func expression() throws -> ExpressionNode {
        let kind = currentToken.kind

        switch kind {
        case .plus, .minus:
            try eat(kind: kind)
            return .unaryOperator(
                token: kind,
                operand: try unsignedexpr()
            )
        default:
            return try unsignedexpr()
        }
    }

    /// ```
    /// unsignedexpr ::= term
    ///                  term + unsignedexpr
    ///                  term - unsignedexpr
    /// ```
    private func unsignedexpr() throws -> ExpressionNode {
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
    private func term() throws -> ExpressionNode {
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
    private func factor() throws -> ExpressionNode {
        let token = currentToken!

        switch token.kind.category {
        case .number:
            return try number()
        default:
            break
        }

        switch token.kind {
        case .leftParentheses:
            try eat(kind: .leftParentheses)
            let node = try expression()
            try eat(kind: .rightParentheses)
            return node
        default:
            break
        }

        fatalError("invalid factor token: \(token.kind)")
    }

    /// ```
    /// number ::= digit
    ///            digit number
    /// ```
    /// ```
    /// digit ::= 0 ! 1 2 ! ... ! 9
    /// ```
    private func number() throws -> ExpressionNode {
        let kind = currentToken!.kind

        switch kind {
        case .integer(let value):
            try eat(kind: kind)
            return .integer(value: value)
        default:
            fatalError("invalid number token: \(kind)")
        }
    }
}
