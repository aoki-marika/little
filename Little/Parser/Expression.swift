//
//  Expression.Node.swift
//  Little
//
//  Created by Marika on 2019-11-07.
//  Copyright © 2019 Marika. All rights reserved.
//

import Foundation

/// The data structure for an expression that can be evaluated.
/// - Note: Although this conforms to `Equatable`, only `root` is compared.
/// This, although it feels cheap, is to allow equality comparisons in unit tests where ranges cannot be obtained, and a wrapper type can't be created.
struct Expression {

    // MARK: Public Properties

    /// The root node of this expression.
    let root: Node

    /// The range of this expression in the original source.
    ///
    /// Although this is a force unwrapped optional, it should never be nil outside of unit tests.
    let range: Range<String.Index>!

    // MARK: Initializers

    /// - Parameter root: The root node of this expression.
    /// - Parameter range: The range of this expression in the original source.
    init(root: Node, range: Range<String.Index>? = nil) {
        self.root = root
        self.range = range
    }
}

// MARK: Equatable

extension Expression: Equatable {
    static func ==(lhs: Expression, rhs: Expression) -> Bool {
        return lhs.root == rhs.root
    }
}

// MARK: Node

extension Expression {
    /// A node within an expression's abstract syntax tree.
    indirect enum Node: Equatable {

        // MARK: Cases

        /// An unary operator.
        /// - Parameter token: The token kind to infer the operation from. Must belong to the unary operations category.
        case unaryOperator(token: Token.Kind, operand: Expression.Node)

        /// A binary operator.
        /// - Parameter token: The token kind to infer the operation from. Must belong to the binary operations category.
        case binaryOperator(token: Token.Kind, left: Expression.Node, right: Expression.Node)

        /// Generate a random number from zero to the given upper bound.
        /// - Parameter range: The expression to evaulate to get the upper bound of the range for the random number.
        /// Numbers can be from zero to `range - 1`, so this value must be greater than zero.
        case random(range: Expression.Node)

        /// An integer literal.
        /// - Parameter value: The integer value of this node.
        case integer(value: Int)

        /// A variable reference.
        /// - Parameter name: The name of the variable this node is referencing.
        case variable(name: String)

        /// Another expression.
        case wrappedExpression(expression: Expression)
    }
}
