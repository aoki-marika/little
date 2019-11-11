//
//  Token.swift
//  Little
//
//  Created by Marika on 2019-11-07.
//  Copyright © 2019 Marika. All rights reserved.
//

import Foundation

/// The data structure for an analyzed token from a lexer.
public struct Token {

    // MARK: Properties

    /// The kind of this token.
    public let kind: Kind

    /// The range of this token in the original source code.
    public let range: Range<String.Index>
}

// MARK: Kind

extension Token {
    /// The different kinds that a token can be.
    public enum Kind: Equatable {

        // MARK: Operators

        /// Either the binary or unary `+` operator
        case plus

        /// Either the binary or unary `-` operator.
        case minus

        /// The binary `*` operator.
        case asterisk

        /// The binary `/` operator.
        case slash

        /// The binary `=` operator.
        case equals

        /// The `<` relational operator, compares if the left operand is less than the right operand.
        case lessThan

        /// The `>` relational operator, compares if the left operand is greater than the right operand.
        case greaterThan

        /// The `<=` relational operator, compares if the left operand is less than or equal to the right operand.
        case lessOrEqual

        /// The `>=` relational operator, compares if the left operand is greater than or equal to the right operand.
        case greaterOrEqual

        /// The `<>` and `><` relational operators, compares if the left operand and the right operand are not equal.
        case notEqual

        // MARK: Punctuators

        /// The left part of the `(...)` punctuator.
        case leftParentheses

        /// The right part of the `(...)` punctuator.
        case rightParentheses

        // MARK: Separators

        /// The `,` separator, used for lists and print items with spaces.
        case comma

        /// The `;` separator, used for print items without spaces.
        case semicolon

        // MARK: Keywords

        /// The `PRINT` keyword, used for printing to the interpreter's output.
        case keywordPrint

        /// The `LET` keyword, being an optional prefix for an assignment statement.
        case keywordLet

        /// The `GOTO` keyword, used for changing the sequence in which the program executes.
        case keywordGoto

        /// The `GOSUB` keyword, functions like `GOTO` except the `RETURN` keyword can be used to return to the line that performed the `GOSUB`.
        case keywordGoSub

        /// The `RETURN` keyword, used to return to the last line that performed a `GOSUB` statement.
        case keywordReturn

        /// The `IF` keyword, used to begin an if statement.
        case keywordIf

        /// The `THEN` keyword, optionally used at the end of an if statement.
        case keywordThen

        /// The `REM` keyword, used for inserting comments into a program's source.
        case keywordRem

        /// The `CLEAR` keyword, used to clear the interpreter's output.
        case keywordClear

        /// The `END` keyword, used to terminate a program before completion.
        case keywordEnd

        // MARK: Values

        /// An integer literal.
        /// - Parameter value: The integer value of the literal.
        case integer(value: Int)

        /// A string literal.
        /// - Parameter value: The string value of the literal.
        case string(value: String)

        /// A named variable referencce.
        /// - Parameter name: The name of the variable to reference.
        case variable(name: String)

        // MARK: Special

        /// A comment literal from a `REM` statement.
        ///
        /// This should only be used for syntax highlighting, and never interpreting.
        /// - Parameter literal: The literal contents of this comment.
        case comment(literal: String)

        /// The end of line marker.
        ///
        /// This, or for the last line `endOfFile`, should always be at the end of a line's statement.
        /// If it's not then an error should be thrown.
        case endOfLine

        /// The end of file marker.
        ///
        /// This should always be at the end of an input's analyzed tokens.
        /// If it is not then an error should be thrown.
        case endOfFile

        // MARK: Public Properties

        /// The categories that this kind belongs to.
        public var categories: [Category] {
            switch self {
            case .plus, .minus, .asterisk, .slash:
                return [.operator]
            case .equals, .lessThan, .greaterThan, .lessOrEqual, .greaterOrEqual, .notEqual:
                return [.operator, .relationalOperator]
            case .keywordPrint, .keywordLet, .keywordGoto, .keywordGoSub, .keywordReturn, .keywordIf, .keywordThen, .keywordRem, .keywordClear, .keywordEnd:
                return [.keyword]
            case .integer(_):
                return [.number]
            case .string(_):
                return [.string]
            case .variable(_):
                return [.variable]
            case .comment(_):
                return [.comment]
            default:
                return []
            }
        }
    }
}

// MARK: Kind.Category

extension Token.Kind {
    /// The different categories a token kind can conform to.
    ///
    /// This is to allow match token kinds without dealing with parameters, and to allow easier implementation of syntax highlighting.
    public enum Category {

        // MARK: Cases

        /// A mathematical operator, typically `+`, `-`, `*`, or `/`.
        case `operator`

        /// An operator which compares two operands.
        case relationalOperator

        /// An identifier which has special meaning in the grammar.
        case keyword

        /// A number literal, either integer or floating point.
        case number

        /// A string literal.
        case string

        /// A named variable reference.
        case variable

        /// A comment literal.
        case comment
    }
}
