//
//  Token.swift
//  Little
//
//  Created by Marika on 2019-11-07.
//  Copyright © 2019 Marika. All rights reserved.
//

import Foundation

/// The data structure for an analyzed token from a lexer.
struct Token {

    // MARK: Properties

    /// The kind of this token.
    let kind: Kind

    /// The range of this token in the original source code.
    let range: Range<String.Index>
}

// MARK: Kind

extension Token {
    /// The different kinds that a token can be.
    enum Kind: Equatable {

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
        case assignment

        // MARK: Punctuators

        /// The left part of the `(...)` punctuator.
        case leftParentheses

        /// The right part of the `(...)` punctuator.
        case rightParentheses

        // MARK: Keywords

        /// The `PRINT` keyword, used for printing to standard output.
        case keywordPrint

        // MARK: Values

        /// An integer literal.
        /// - Parameter value: The integer value of the literal.
        case integer(value: Int)

        /// A named variable referencce.
        /// - Parameter name: The name of the variable to reference.
        case variable(name: String)

        // MARK: Special

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

        #warning("TODO: Need to communicate when a token kind conforms to multiple categories, such as - which is both an unary and binary operator.")

        /// The category that this kind belongs to.
        var category: Category {
            switch self {
            case .plus, .minus, .asterisk, .slash, .assignment:
                return .binaryOperator
            case .leftParentheses, .rightParentheses:
                return .punctuator
            case .keywordPrint, .variable(_):
                return .keyword
            case .integer(_):
                return .number
            case .endOfLine, .endOfFile:
                return .special
            }
        }
    }
}

// MARK: Kind.Category

extension Token.Kind {
    /// The different categories of token kinds.
    ///
    /// This is to allow matching multiple pre-defined types, without dealing with enum parameters.
    enum Category {

        // MARK: Cases

        /// An operator which takes a left and right operand.
        case binaryOperator

        /// An operator which changes it's meaning depending on the context.
        case punctuator

        /// A token which has special meaning in the grammar.
        case keyword

        /// A number literal, either integer or floating point.
        case number

        /// A special token that is not generally presented to the user.
        case special
    }
}
