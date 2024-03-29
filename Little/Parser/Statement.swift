//
//  Statement.swift
//  Little
//
//  Created by Marika on 2019-11-09.
//  Copyright © 2019 Marika. All rights reserved.
//

import Foundation

/// The different statements that a line can perform.
indirect enum Statement: Equatable {

    // MARK: Cases

    /// A statement which does nothing, used for empty lines and comments.
    case none

    /// Prints the given items to the interpreter's output.
    /// - Note: A print statement always outputs a trailing newline, regardless of it's items.
    /// - Parameter items: The items to print.
    case print(items: [PrintItem])

    /// Assign the given expression's value to the given named variable.
    /// - Parameter variable: The name of the variable to assign.
    /// - Parameter value: The expression to evaluate to get the value to assign.
    case assignment(variable: String, value: Expression)

    /// Change the sequence in which the program executes by moving to the line of the given number.
    /// - Parameter line: The expression to evaluate to get the line number to go to.
    case goto(line: Expression)

    /// Change the sequence in which the program executes by moving to the subroutine at the given number.
    /// - Parameter line: The expression to evaluate to get the line number of the subroutine.
    case goSub(line: Expression)

    /// Return from the current subroutine to the line that began it.
    case `return`

    /// If the given left and right operands compare true using the given relational operator, then execute the given statement.
    /// - Parameter token: The token kind to infer the operation from. Must belong to the relational operations category.
    /// - Parameter left: The left operand.
    /// - Parameter right: The right operand.
    /// - Parameter statement: The statement to execute if the operands compare true.
    case `if`(token: Token.Kind, left: Expression, right: Expression, statement: Statement)

    /// Clear the interpreter's output.
    case clear

    /// Terminate the program.
    case end
}
