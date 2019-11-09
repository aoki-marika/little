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
