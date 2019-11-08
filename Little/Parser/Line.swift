//
//  Line.swift
//  Little
//
//  Created by Marika on 2019-11-08.
//  Copyright © 2019 Marika. All rights reserved.
//

import Foundation

/// The data structure for a single line within a program.
struct Line {

    // MARK: Public Properties

    /// The program defined number of this line, if any.
    ///
    /// If a line with this number has already been declared then the new line takes precedence and overwrites the previous.
    let number: Int?

    /// The statement for this line to perform.
    let statement: Statement
}

// MARK: Statement

extension Line {
    /// The different statements that a line can perform.
    enum Statement {

        // MARK: Cases

        /// Does nothing, used to indicate empty lines with line numbers.
        case none

        /// Assign the given expression's value to the given named variable.
        /// - Parameter variable: The name of the variable to assign.
        /// - Parameter value: The expression to evaluate to get the value to assign.
        case assignment(variable: String, value: Expression)
    }
}
