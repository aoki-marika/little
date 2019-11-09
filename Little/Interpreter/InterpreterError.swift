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

    /// The interpreter attemped to read a variable that was not assigned.
    /// - Parameter name: The name of the variable that was attempted to be read.
    case readingUnassignedVariable(name: String)
}
