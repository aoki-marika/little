//
//  Output.swift
//  Little
//
//  Created by Marika on 2019-11-09.
//  Copyright © 2019 Marika. All rights reserved.
//

import Foundation

/// The protocol for an object that can handle text outputted from an interpreter, such as from a `PRINT` statement.
public protocol Output {

    // MARK: Public Methods

    /// Receive and the given output text from an interpreter.
    /// - Parameter string: The text that was output.
    func receive(string: String)
}
