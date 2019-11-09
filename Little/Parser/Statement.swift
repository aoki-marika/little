//
//  Statement.swift
//  Little
//
//  Created by Marika on 2019-11-09.
//  Copyright © 2019 Marika. All rights reserved.
//

import Foundation

/// The different statements that a line can perform.
enum Statement {

    // MARK: Cases

    /// Prints the given items to the standard output.
    /// - Parameter items: The items to print.
    case print(items: [PrintItem])

    /// Assign the given expression's value to the given named variable.
    /// - Parameter variable: The name of the variable to assign.
    /// - Parameter value: The expression to evaluate to get the value to assign.
    case assignment(variable: String, value: Expression)
}
