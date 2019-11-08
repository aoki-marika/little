//
//  String.swift
//  Little
//
//  Created by Marika on 2019-11-07.
//  Copyright © 2019 Marika. All rights reserved.
//

import Foundation

extension Character {
    /// A Boolean value indicating whether this character represents a digit (0-9).
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

    /// A Boolean value indicating whether this character is valid within an identifier (A-Z).
    var isValidIdentifier: Bool {
        return self == "A" ||
               self == "B" ||
               self == "C" ||
               self == "D" ||
               self == "E" ||
               self == "F" ||
               self == "G" ||
               self == "H" ||
               self == "I" ||
               self == "J" ||
               self == "K" ||
               self == "L" ||
               self == "M" ||
               self == "N" ||
               self == "O" ||
               self == "P" ||
               self == "Q" ||
               self == "R" ||
               self == "S" ||
               self == "T" ||
               self == "U" ||
               self == "V" ||
               self == "W" ||
               self == "X" ||
               self == "Y" ||
               self == "Z"
    }
}
