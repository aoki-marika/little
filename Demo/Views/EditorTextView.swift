//
//  EditorTextView.swift
//  Demo
//
//  Created by Marika on 2019-11-09.
//  Copyright © 2019 Marika. All rights reserved.
//

import UIKit

/// A text view configured as a Little BASIC editor.
class EditorTextView: UITextView {

    // MARK: Initializers

    init() {
        // create the storage and layout
        let storage = HighlightingTextStorage()
        let container = NSTextContainer()
        container.widthTracksTextView = true
        container.lineFragmentPadding = 0

        let layoutManager = NSLayoutManager()
        layoutManager.addTextContainer(container)
        storage.addLayoutManager(layoutManager)

        super.init(frame: .zero, textContainer: container)

        // setup the text view
        backgroundColor = UIColor(named: "EditorBackground")!
        textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        autocapitalizationType = .none
        autocorrectionType = .no
        smartDashesType = .no
        smartInsertDeleteType = .no
        smartQuotesType = .no
        spellCheckingType = .no
        keyboardType = .asciiCapable
        alwaysBounceVertical = true

        // insert a demo program
        storage.replaceCharacters(in: NSRange(location: 0, length: 0), with: "PRINT \"Hello, world!\"")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
