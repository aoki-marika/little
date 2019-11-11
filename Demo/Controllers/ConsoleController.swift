//
//  ConsoleController.swift
//  Demo
//
//  Created by Marika on 2019-11-09.
//  Copyright © 2019 Marika. All rights reserved.
//

import UIKit
import Little

/// The controller for the console half of the application split view.
class ConsoleController: UIViewController {

    // MARK: Outlets

    @IBOutlet private weak var textView: UITextView!

    // MARK: Public Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        // setup the text view
        textView.font = UIFont.sourceFont()
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        textView.textContainer.lineFragmentPadding = 0
    }

    /// Clear this console's output.
    @IBAction func clear(_ sender: Any) {
        textView.text.removeAll()
    }
}

// MARK: Output

extension ConsoleController: Output {

    func receive(string: String) {
        // ensure this is called on the main thread
        DispatchQueue.main.async {
            self.textView.text += string
        }
    }
}
