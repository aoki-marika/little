//
//  InterpreterError.swift
//  Little
//
//  Created by Marika on 2019-11-09.
//  Copyright © 2019 Marika. All rights reserved.
//

import Foundation

/// The different errors that can occur when an interpreter is interpreting.
enum InterpreterError: Error {

    /// The interpreter attempted to perform division with a right operand of zero.
    case divisionByZero

    /// The interpreter attempted to reference a line by number that was not assigned yet, such as in a `GOTO`.
    /// - Parameter number: The invalid line number that was referenced.
    case referencingUnassignedLine(number: Int)

    /// The interpreter attempted to execute a `RETURN` statement outside of a subroutine.
    case returnOutsideSubroutine
}
