//
//  String.swift
//  Little
//
//  Created by Marika on 2019-11-07.
//  Copyright © 2019 Marika. All rights reserved.
//

import Foundation

extension Character {
    /// A Boolean value indicating whether this character represents a digit.
    ///
    /// For example, the following characters all represent digits:
    /// - "1"
    /// - "0"
    /// - "9"
    var isDigit: Bool {
        return self == "0" ||
               self == "1" ||
               self == "2" ||
               self == "3" ||
               self == "4" ||
               self == "5" ||
               self == "6" ||
               self == "7" ||
               self == "8" ||
               self == "9"
    }
}
