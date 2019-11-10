//
//  EditorController.swift
//  Demo
//
//  Created by Marika on 2019-11-09.
//  Copyright © 2019 Marika. All rights reserved.
//

import UIKit

/// The controller for the editor half of the application split view.
class EditorController: UIViewController {

    // MARK: Public Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        let editor = EditorTextView()
        view.addSubview(editor)
        editor.translatesAutoresizingMaskIntoConstraints = false
        editor.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        editor.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        editor.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        editor.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
    }
}
