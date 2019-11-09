//
//  SplitController.swift
//  Demo
//
//  Created by Marika on 2019-11-09.
//  Copyright © 2019 Marika. All rights reserved.
//

import UIKit

class SplitController: UISplitViewController, UISplitViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self

        maximumPrimaryColumnWidth = .greatestFiniteMagnitude
        preferredPrimaryColumnWidthFraction = 0.5
    }
}
