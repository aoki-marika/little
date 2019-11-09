//
//  PrintItem.swift
//  Little
//
//  Created by Marika on 2019-11-09.
//  Copyright © 2019 Marika. All rights reserved.
//

import Foundation

/// The data structure for an item that can be printed to the interpreter's output.
struct PrintItem: Equatable {

    // MARK: Public Properties

    /// The kind of this item.
    let kind: Kind

    /// The string to append to the end of this item's print output.
    let terminator: String
}

// MARK: Kind

extension PrintItem {
    /// The different kinds of data that a print item can contain.
    enum Kind: Equatable {

        // MARK: Cases

        /// Evaluates the given expression and prints it's result.
        /// - Parameter expression: The expression to print.
        case expression(expression: Expression)

        /// Prints the given string as is.
        /// - Parameter string: The string to print.
        case string(string: String)
    }
}
