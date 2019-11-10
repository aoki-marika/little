//
//  UIFont.swift
//  Demo
//
//  Created by Marika on 2019-11-10.
//  Copyright © 2019 Marika. All rights reserved.
//

import UIKit

extension UIFont {
    /// Get the font used for displaying Little BASIC source code.
    /// - Parameter bold: Whether or not to return the bold variant.
    /// - Returns: A new instance of the source code font for the given parameters.
    class func sourceFont(bold: Bool = false) -> UIFont {
        if #available(iOS 13.0, *) {
            let descriptor = UIFontDescriptor
                .preferredFontDescriptor(withTextStyle: .body)
                .withDesign(.monospaced)!
                .withSymbolicTraits(bold ? .traitBold : [])!

            let font = UIFont(descriptor: descriptor, size: 0)
            return font
        } else {
            // ios 12 was very picky about letting developers access sf mono
            let size = UIFont.labelFontSize
            let weight = bold ? UIFont.Weight.bold : .regular
            let font = UIFont.monospacedSystemFont(ofSize: size, weight: weight)
            return font
        }
    }
}
