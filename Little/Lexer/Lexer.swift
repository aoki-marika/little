//
//  Lexer.swift
//  Little
//
//  Created by Marika on 2019-11-07.
//  Copyright © 2019 Marika. All rights reserved.
//

import Foundation

#warning("TODO: Implement the line number parsing as described in http://users.telenet.be/kim1-6502/tinybasic/tbum.html#statements")

/// An object for performing lexical analysis on source code.
class Lexer {

    // MARK: Private Properties

    /// The mapping of single characters to token kinds when analyzing source code characters.
    private let singleCharacterMapping: [Character : Token.Kind] = [
        "+": .plus,
        "-": .minus,
        "*": .asterisk,
        "/": .slash,
        "=": .assignment,
        "(": .leftParentheses,
        ")": .rightParentheses,
    ]

    /// The mapping of multiple character identifiers to keyword token kinds when analyzing source code.
    /// - Note: These cannot be a single character, as variables take up all available single character identifiers.
    private let keywordMapping: [String : Token.Kind] = [
        "PRINT": .keywordPrint,
        "LET": .keywordLet,
    ]

    /// The source code for this lexer to analyze.
    private let input: String

    /// The position of the current character of this lexer in it's input, if any.
    ///
    /// If this is nil then that means there is no more source code to analyze, and analysis should be terminated with an end of file token.
    private var currentPosition: String.Index?

    /// Get the position of the next character this lexer will read in it's input, if any.
    ///
    /// If the next position is out of range or the current position is nil, then this is nil.
    private var readingPosition: String.Index? {
        guard let currentPosition = currentPosition else {
            return nil
        }

        let nextPosition = input.index(after: currentPosition)
        guard nextPosition < input.endIndex else {
            return nil
        }

        return nextPosition
    }

    /// Get the current character that this lexer is analyzing, if any.
    private var currentCharacter: Character? {
        guard let currentPosition = currentPosition else {
            return nil
        }

        return input[currentPosition]
    }

    // MARK: Initializers

    /// - Parameter input: The source code for this lexer to analyze.
    init(input: String) {
        self.input = input

        // set initial state
        reset()
    }

    // MARK: Public Methods

    /// Reset this analyzer's state.
    ///
    /// This is used only if the source should be reanalyzed.
    func reset() {
        currentPosition = input.startIndex
    }

    /// Analyze and return the next token in this lexer's source.
    /// - Note: Analysis should be terminated once an end of file token is analyzed.
    /// Once one is analyzed then every subsequent call to this method will return the same.
    /// - Returns: The analyzed token.
    func analyzeNext() throws -> Token {
        skipWhitespace()

        // get the new character to analyze
        // if there is none then the input has been completely analyzed
        guard let startIndex = currentPosition, let currentCharacter = currentCharacter else {
            let token = createToken(kind: .endOfFile, startIndex: input.endIndex)
            return token
        }

        // attempt to translate the current character to a token
        // catch any errors that occur and wrap them in a source error
        do {
            // single character mapping
            if let kind = singleCharacterMapping[currentCharacter] {
                // consume the character
                readCharacter()

                // return the token
                let token = createToken(kind: kind, startIndex: startIndex)
                return token
            }
            // number literals
            else if currentCharacter.isDigit {
                let token = try readNumber()
                return token
            }
            // string literals
            else if currentCharacter == "\"" {
                let token = try readString()
                return token
            }
            // end of line
            else if currentCharacter.isNewline {
                // consume the character
                readCharacter()

                // return the token
                let token = createToken(kind: .endOfLine, startIndex: startIndex)
                return token
            }
            else {
                // try an identifier as a last resort
                if currentCharacter.isValidIdentifier {
                    let token = try readIdentifier()
                    return token
                }

                // if there is still nothing matched then this is an invalid character
                throw LexerError.invalidCharacter(character: currentCharacter)
            }
        }
        catch {
            let errorRange = range(from: startIndex)
            throw SourceError(range: errorRange, wrapped: error)
        }
    }

    /// Reset this lexer's state and analyze all of the tokens in it's source.
    /// - Returns: The analyzed tokens.
    func analyze() throws -> [Token] {
        // reset state
        reset()

        // analyze all the tokens and return them
        var tokens = [Token]()
        while true {
            let token = try analyzeNext()
            tokens.append(token)

            guard token.kind != .endOfFile else {
                break
            }
        }

        return tokens
    }

    // MARK: Private Methods

    /// Advance this lexer's current position to the current reading position.
    private func readCharacter() {
        guard let readingPosition = readingPosition else {
            currentPosition = nil
            return
        }

        currentPosition = readingPosition
    }

    /// Continuously read characters until the next non-whitespace character.
    /// - Note: Newlines do not count as whitespace.
    private func skipWhitespace() {
        // swift thinks newlines are whitespace, which they arent here
        while (currentCharacter?.isWhitespace ?? false) && !(currentCharacter?.isNewline ?? true) {
            readCharacter()
        }
    }

    /// Create a string range in this lexer's input from the given start index to the current position.
    /// - Note: If the current position is nil, then `input.endIndex` is used instead.
    /// - Parameter startIndex: The start index of the range in this lexer's input.
    /// - Returns: The new range in this lexer's input.
    private func range(from startIndex: String.Index) -> Range<String.Index> {
        let endIndex = currentPosition ?? input.endIndex
        let range = startIndex..<endIndex

        return range
    }

    /// Create a token of the given kind, ranging from the given start index to the current position.
    /// - Parameter kind: The kind of the token to create.
    /// - Parameter startIndex: The start index of the token's range. See `range(from:)` for details.
    /// - Returns: The new token.
    private func createToken(kind: Token.Kind, startIndex: String.Index) -> Token {
        let tokenRange = range(from: startIndex)
        let token = Token(kind: kind, range: tokenRange)

        return token
    }

    /// Read the number token from the current position of this lexer.
    ///
    /// This can read both integer or floating point, and uses the respective kind for each.
    /// - Returns: The new number token.
    private func readNumber() throws -> Token {
        // get the start index of the literal
        // this should never happen, but just in case
        guard let startIndex = currentPosition else {
            fatalError("attempted to read number literal with no start index")
        }

        // read the full literal of the number
        var literal = ""
        repeat {
            guard let currentCharacter = currentCharacter else {
                break
            }

            literal.append(currentCharacter)
            readCharacter()
        } while currentCharacter?.isDigit ?? false

        // get the proper value type
        // note: currently only processes integers, floating point will be added later
        guard let value = Int(literal) else {
            throw LexerError.invalidNumberLiteral(literal: literal)
        }

        // return the new number token
        return createToken(kind: .integer(value: value), startIndex: startIndex)
    }

    /// Read the string token from the current position of this lexer.
    /// - Returns: The new string token.
    private func readString() throws -> Token {
        // get the start index of the string
        // this should never happen, but just in case
        guard let startIndex = currentPosition else {
            fatalError("attempted to read string literal with no start index")
        }

        // read the entire string literal, with quotes
        var literal = ""
        var foundStart = false
        while let currentCharacter = currentCharacter {
            literal.append(currentCharacter)
            readCharacter()

            // break once a terminating quote is found
            if currentCharacter == "\"" {
                if foundStart {
                    break
                }

                foundStart = true
            }
        }

        // ensure the literal is valid
        // must have individual beginning and terminating quotes
        guard literal.hasPrefix("\"") && literal.hasSuffix("\"") && literal.count >= 2 else {
            throw LexerError.unterminatedStringLiteral(literal: literal)
        }

        // drop the quotes from the literal and return the new token
        literal = String(literal.dropFirst().dropLast())
        let token = createToken(kind: .string(value: literal), startIndex: startIndex)
        return token
    }

    /// Read the identifier token from the current position of this lexer.
    /// - Returns: The new identifier token.
    private func readIdentifier() throws -> Token {
        // get the start index of the identifier
        // this should never happen, but just in case
        guard let startIndex = currentPosition else {
            fatalError("attempted to read identifier with no start index")
        }

        // read the entire name of the identifier
        var name = ""
        repeat {
            guard let currentCharacter = currentCharacter else {
                break
            }

            name.append(currentCharacter)
            readCharacter()
        } while currentCharacter?.isValidIdentifier ?? false

        // ensure the name is not empty
        guard name.count > 0 else {
            throw LexerError.invalidKeyword(keyword: name)
        }

        // return the proper type depending on the name
        // variables use all 24 single characters from a-z
        // and anything else can be a keyword
        if name.count == 1 {
            return createToken(kind: .variable(name: name), startIndex: startIndex)
        }
        else {
            guard let kind = keywordMapping[name] else {
                throw LexerError.invalidKeyword(keyword: name)
            }

            return createToken(kind: kind, startIndex: startIndex)
        }
    }
}
