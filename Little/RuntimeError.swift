//
//  RuntimeError.swift
//  Little
//
//  Created by Marika on 2019-11-11.
//  Copyright © 2019 Marika. All rights reserved.
//

import Foundation

/// An error that wraps an error that occured while interpreting source code, such as accessing an unassigned variable.
public struct RuntimeError: Error {

    // MARK: Properties

    /// The range of the line that caused this error in the original source code.
    public let range: Range<String.Index>

    /// The error that this error is wrapping.
    public let wrapped: Error
}
