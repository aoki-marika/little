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

        // MARK: Cases

        /// Either the binary or unary `+` operator
        case plus

        /// Either the binary or unary `-` operator.
        case minus

        /// Either the binary or unary `*` operator.
        case asterisk

        /// Either the binary or unary `/` operator.
        case slash

        /// An integer literal.
        /// - Parameter value: The integer value of the literal.
        case integer(value: Int)

        /// The end of file marker.
        ///
        /// This should always be at the end of an input's analyzed tokens.
        /// If it is not then an error should be thrown.
        case endOfFile
    }
}
