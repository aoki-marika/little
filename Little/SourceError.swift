//
//  SourceError.swift
//  Little
//
//  Created by Marika on 2019-11-07.
//  Copyright © 2019 Marika. All rights reserved.
//

import Foundation

/// An error that wraps an error that occured from source code, such as an invalid character or keyword.
struct SourceError: Error {

    // MARK: Properties

    /// The range of the text that caused this error in the original source code.
    let range: Range<String.Index>

    /// The error that this error is wrapping.
    let wrapped: Error
}
