//
//  ParserError.swift
//  Little
//
//  Created by Marika on 2019-11-07.
//  Copyright © 2019 Marika. All rights reserved.
//

import Foundation

/// The different errors that can occur when a parser is parsing.
enum ParserError: Error {

    /// The parser expected one token kind, but found another.
    /// - Parameter expected: The token kind that was expected.
    /// - Parameter got: The token kind that was found.
    case unexpectedTokenKind(expected: Token.Kind, got: Token.Kind)

    /// The parser expected one token category, but found another.
    /// - Parameter expected: The token category that was expected.
    /// - Parameter got: The token categories that were found.
    case unexpectedTokenCategories(expected: Token.Kind.Category, got: [Token.Kind.Category])

    /// The parser expected to find the beginning of a factor, but found something else.
    /// - Parameter got: The kind of the token that was found instead.
    case expectedFactor(got: Token.Kind)

    /// The parser expected to find a number literal, but found something else.
    /// - Parameter got: The kind of the token that was found instead.
    case expectedNumber(got: Token.Kind)

    /// The parser expected to find a string literal, but found something else.
    /// - Parameter got: The kind of the token that was found instead.
    case expectedString(got: Token.Kind)

    /// The parser expected to find a variable reference, but found something else.
    /// - Parameter got: The kind of the token that was found instead.
    case expectedVariable(got: Token.Kind)

    /// The parser expected to find a line end, but found something else.
    /// - Parameter kind: The kind of the token that was found instead.
    case expectedLineEnd(kind: Token.Kind)
}
