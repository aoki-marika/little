//
//  Subroutine.swift
//  Little
//
//  Created by Marika on 2019-11-11.
//  Copyright © 2019 Marika. All rights reserved.
//

import Foundation

/// The data structure for a subroutine within a program.
class Subroutine {

    // MARK: Public Properties

    /// The offset of the line that began this subroutine in the interpreter's lines.
    let callingLineOffset: Int

    /// The subroutine that this subroutine was started from, if any.
    let parent: Subroutine?

    // MARK: Initializers

    /// - Parameter callingLineOffset: The offset of the line that began this subroutine in the interpreter's lines.
    /// - Parameter parent: The subroutine that this subroutine was started from, if any.
    init(callingLineOffset: Int, parent: Subroutine?) {
        self.callingLineOffset = callingLineOffset
        self.parent = parent
    }
}
