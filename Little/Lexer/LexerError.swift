//
//  LexerError.swift
//  Little
//
//  Created by Marika on 2019-11-07.
//  Copyright © 2019 Marika. All rights reserved.
//

import Foundation

/// The different errors that can occur when a lexer is analyzing.
enum LexerError: Error {

    // MARK: Cases

    /// The lexer found an invalid character in the source code.
    /// - Parameter character: The invalid character that was found.
    case invalidCharacter(character: Character)

    /// The lexer attempted to read an invalid number literal.
    /// - Parameter literal: The invalid number literal.
    case invalidNumberLiteral(literal: String)

    /// The lexer attempted to read an invalid keyword.
    /// - Parameter keyword: The invalid keyword.
    case invalidKeyword(keyword: String)
}
