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
    /// - Parameter got: The token category that was found.
    case unexpectedTokenCategory(expected: Token.Kind.Category, got: Token.Kind.Category)
}
