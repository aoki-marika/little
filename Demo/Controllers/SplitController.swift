//
//  SplitController.swift
//  Demo
//
//  Created by Marika on 2019-11-09.
//  Copyright © 2019 Marika. All rights reserved.
//

import UIKit

/// The controller for the root split view of the application.
class SplitController: UISplitViewController {

    // MARK: Public Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        // make the split 50/50
        // need to increase maximum width to allow this
        maximumPrimaryColumnWidth = .greatestFiniteMagnitude
        preferredPrimaryColumnWidthFraction = 0.5
    }
}
