//
//  ExpressionNode.swift
//  Little
//
//  Created by Marika on 2019-11-07.
//  Copyright © 2019 Marika. All rights reserved.
//

import Foundation

/// A node within an expression's abstract syntax tree.
indirect enum ExpressionNode {

    // MARK: Cases

    /// An unary operator.
    /// - Parameter token: The token kind to infer the operation from. Must belong to the unary operations category.
    case unaryOperator(token: Token.Kind, operand: ExpressionNode)

    /// A binary operator.
    /// - Parameter token: The token kind to infer the operation from. Must belong to the binary operations category.
    case binaryOperator(token: Token.Kind, left: ExpressionNode, right: ExpressionNode)

    /// An integer literal.
    /// - Parameter value: The integer value of this node.
    case integer(value: Int)
}
