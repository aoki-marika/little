//
//  Expression.Node.swift
//  Little
//
//  Created by Marika on 2019-11-07.
//  Copyright © 2019 Marika. All rights reserved.
//

import Foundation

/// The data structure for an expression that can be evaluated.
struct Expression {

    // MARK: Public Properties

    /// The root node of this expression.
    let root: Node
}

// MARK: Node

extension Expression {
    /// A node within an expression's abstract syntax tree.
    indirect enum Node {

        // MARK: Cases

        /// An unary operator.
        /// - Parameter token: The token kind to infer the operation from. Must belong to the unary operations category.
        case unaryOperator(token: Token.Kind, operand: Expression.Node)

        /// A binary operator.
        /// - Parameter token: The token kind to infer the operation from. Must belong to the binary operations category.
        case binaryOperator(token: Token.Kind, left: Expression.Node, right: Expression.Node)

        /// An integer literal.
        /// - Parameter value: The integer value of this node.
        case integer(value: Int)

        /// Another expression.
        case wrappedExpression(expression: Expression)
    }
}
