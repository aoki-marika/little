//
//  HighlightingTextStorage.swift
//  Demo
//
//  Created by Marika on 2019-11-10.
//  Copyright © 2019 Marika. All rights reserved.
//

import UIKit
import Little

/// A text storage object that automatically applies Little BASIC syntax highlighting.
class HighlightingTextStorage: NSTextStorage {

    // MARK: Private Properties

    /// The backing attributed string for this text storage.
    private let backing = NSMutableAttributedString()

    /// The regular font for text, used for most tokens and plain text.
    private let regularFont = UIFont.sourceFont()

    /// The bold font for text, used for special tokens like keywords.
    private let boldFont = UIFont.sourceFont(bold: true)

    /// The attributes for plain foreground text.
    private var foregroundAttributes = [NSAttributedString.Key : Any]()

    /// The attributes for text that is producing an error.
    private var errorAttributes = [NSAttributedString.Key : Any]()

    /// The attributes for the text of different token categories.
    private var tokenCategoryAttributes = [Token.Kind.Category: [NSAttributedString.Key : Any]]()

    // MARK: Initializers

    override init() {
        super.init()

        // set attributes
        // have to be done here instead of the property initializer as it needs self for fonts
        foregroundAttributes = [
            .font: regularFont,
            .foregroundColor: UIColor(named: "EditorForeground")!,
        ]

        errorAttributes = [
            .font: regularFont,
            .foregroundColor: UIColor.systemRed,
            .underlineColor: UIColor.systemRed,
            .underlineStyle: NSUnderlineStyle.thick.rawValue,
        ]

        tokenCategoryAttributes = [
            .operator: [
                .font: regularFont,
                .foregroundColor: UIColor(named: "EditorOperator")!,
            ],
            .keyword: [
                .font: boldFont,
                .foregroundColor: UIColor(named: "EditorKeyword")!,
            ],
            .number: [
                .font: regularFont,
                .foregroundColor: UIColor(named: "EditorNumber")!,
            ],
            .string: [
                .font: regularFont,
                .foregroundColor: UIColor(named: "EditorString")!,
            ],
            .variable: [
                .font: regularFont,
                .foregroundColor: UIColor(named: "EditorVariable")!,
            ]
        ]
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public Properties

    override var string: String {
        return backing.string
    }

    override func attributes(at location: Int, effectiveRange range: NSRangePointer?) -> [NSAttributedString.Key : Any] {
        return backing.attributes(at: location, effectiveRange: range)
    }

    // MARK: Public Methods

    override func replaceCharacters(in range: NSRange, with str: String) {
        beginEditing()
        backing.replaceCharacters(in: range, with: str)
        edited(.editedCharacters, range: range, changeInLength: (str as NSString).length - range.length)
        endEditing()
    }

    override func setAttributes(_ attrs: [NSAttributedString.Key : Any]?, range: NSRange) {
        beginEditing()
        backing.setAttributes(attrs, range: range)
        edited(.editedAttributes, range: range, changeInLength: 0)
        endEditing()
    }

    override func processEditing() {
        // only update the lines that were edited
        let editedRange = Range(self.editedRange, in: string)!
        let updateRange = string.lineRange(for: editedRange)
        applyAttributes(in: updateRange)

        super.processEditing()
    }

    // MARK: Private Methods

    /// Analyze and apply syntax highlighting to the tokens in the given range in this storage's text.
    /// - Parameter range: The range of the text to analyze and apply attributes to. Must be within `string`'s range.
    private func applyAttributes(in range: Range<String.Index>) {
        // get the text to analyze
        let input = string[range]

        // reset attributes for the text
        let fullRange = NSRange(range, in: string)
        setAttributes(foregroundAttributes, range: fullRange)

        // analyze all the input tokens and add the attributes
        // the catch is inside the loop so that if an error occurs then it still continues
        // analyzing, allowing syntax highlighting after an invalid token
        let lexer = Lexer(input: String(input))

        // get the range of the given input range in string
        // this is for ranges returned from the lexer that are relative to input, not string
        func getRange(of subrange: Range<String.Index>) -> NSRange {
            let offset = string.distance(from: string.startIndex, to: range.lowerBound)
            let startIndex = string.index(subrange.lowerBound, offsetBy: offset)
            let endIndex = string.index(subrange.upperBound, offsetBy: offset)
            return NSRange(startIndex..<endIndex, in: string)
        }

        while true {
            do {
                let token = try lexer.analyzeNext()

                for category in token.kind.categories {
                    guard let attributes = tokenCategoryAttributes[category] else {
                        continue
                    }

                    let range = getRange(of: token.range)
                    setAttributes(attributes, range: range)
                    break
                }

                guard token.kind != .endOfFile else {
                    break
                }
            }
            catch let error as SourceError {
                let range = getRange(of: error.range)
                setAttributes(errorAttributes, range: range)

                #warning("TOOD: Proper error display.")
                print(error.wrapped)
            }
            catch {
                fatalError("error analyzing input '\(input)': \(error)")
            }
        }
    }
}
