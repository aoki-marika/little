//
//  EditorController.swift
//  Demo
//
//  Created by Marika on 2019-11-09.
//  Copyright © 2019 Marika. All rights reserved.
//

import UIKit
import Little

/// The controller for the editor half of the application split view.
class EditorController: UIViewController {

    // MARK: Private Properties

    /// The editor of this controller.
    private var editor: EditorTextView!

    /// The console controller that this editor is outputting to.
    private weak var consoleController: ConsoleController!

    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(input: "r", modifierFlags: .command, action: #selector(run), discoverabilityTitle: "Run"),
        ]
    }

    // MARK: Public Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        // create the editor
        editor = EditorTextView()
        view.addSubview(editor)
        editor.translatesAutoresizingMaskIntoConstraints = false
        editor.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        editor.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        editor.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        editor.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true

        // get the console
        guard let split = splitViewController else {
            fatalError("unable to get parent split controller")
        }

        guard let navigation = split.viewControllers.last as? UINavigationController else {
            fatalError("unable to get console navigation controller")
        }

        guard let console = navigation.topViewController as? ConsoleController else {
            fatalError("unable to get console controller")
        }

        consoleController = console

        // insert a demo program
        editor.text = """
        PRINT "Hello, world!"
        PR "The PRINT keyword (shorthand PR) can be used to display text in the console."
        PR

        PR
        PR "It can also be used with no items to display a newline."
        PR "Or you can use the newline literal \\n to do the same in the middle of a print."
        PR

        PR "Hello,", "world!"
        PR "The comma separator can be used to print multiple items with a space between them."
        PR

        PR "Hello, "; "world!"
        PR "And the semicolon separator can be used to do the same, but with no separator."
        PR

        PR "Hello"; ",", "world!"
        PR "You can even combine them to get more complex outputs, but I'll just print hello world again."
        PR

        LET A = 10
        B = 20
        PR "A =", A; ",", "B =", B
        PR "The assignment statement (optionally beginning with the LET keyword) can be used to assign whole numbers to named variables."
        PR "These variables can then be referenced by the same name anywhere else in the program, like in a PRINT statement."
        PR

        PR "("; B, "/", A; ")", "*", 10, "=", (B / A) * 10
        PR "You can then also use arithmetic in these assignments, or anywhere else that you can use a number or variable, again like in a PRINT statement."
        PR

        LET D = -(200 * 30) - A
        PR "D =", D; ",", "-(3 * 5) =", -(3 * 5)
        PR "Positive and negative numbers work differently here then in most languages. The expression must begin with the +/- operator to use positive/negative numbers. An expression is something like the right hand side of an assignment statement, or the text inside of parentheses."
        """
    }

    /// Run the program currently entered into this editor.
    @IBAction func run(_ sender: Any) {
        // escape input as uitextview does not
        var input = editor.text!
        input = input.replacingOccurrences(of: "\\r", with: "\r")
        input = input.replacingOccurrences(of: "\\n", with: "\n")

        // step the program until completion
        // run in a background thread so recursion doesnt freeze the interface
        let interpreter = Interpreter(input: input, output: consoleController)
        DispatchQueue.global(qos: .background).async {
            do {
                try interpreter.start()
                while true {
                    let isComplete = try interpreter.step()

                    if isComplete {
                        break
                    }
                }
            }
            catch let error as SourceError {
                // print the error to the console
                #warning("TODO: Proper error handling.")
                let range = error.range
                let substring = input[range]
                self.consoleController.receive(string: "'\(substring)': \(error.wrapped)\n")
            }
            catch {
                #warning("TODO: Doesn't catch interpreter errors, need a RuntimeError wrapper type with line ranges.")
                self.consoleController.receive(string: "program error: \(error)\n")
            }
        }
    }
}
