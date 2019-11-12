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

        REM This is a comment.
        REM You can use the REM keyword followed by any text to create a comment.
        REM Comments extend from the REM keyword to the end of the line.
        REM These do nothing when the program is run, but allow documentation within the source.
        10 REM You can even number REM lines and GOTO them if you really want to.
        20 REM Note that you cannot place these at the end of an existing line, they must be on their own line.

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
            /// Show the given error with formatting in the console.
            /// - Parameter error: The error that occured.
            /// - Parameter range: The range in the original source of which the error occured.
            func showError(_ error: Error, inRange range: Range<String.Index>) {
                // get the distance from the beginning of the line to the column
                let lineRange = input.lineRange(for: range)
                let columnDistance = input.distance(from: lineRange.lowerBound, to: range.lowerBound)

                // output the error
                // format the error with the line, then a carat pointing to the offending range with the error below
                // need to trim whitespace from the line as String.lineRange(for:) has a tendency to include the newline character
                self.consoleController.receive(string: """
                \(input[lineRange].trimmingCharacters(in: .newlines))
                \(String(repeating: " ", count: columnDistance))^
                error: \(error)

                """)
            }

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
                showError(error.wrapped, inRange: error.range)
            }
            catch let error as RuntimeError {
                showError(error.wrapped, inRange: error.range)
            }
            catch {
                fatalError("unable to interpret program: \(error)")
            }
        }
    }
}
