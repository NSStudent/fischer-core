//
//  MoveTree.swift
//  FischerCore
//
//  Created by Omar Megdadi on 21/3/26.
//

/// A move tree where each node represents a SAN ply in the main line.
///
/// The tree models a linked main line through `next`, while `variants`
/// stores alternative continuations that branch from the same position as
/// the current move.
public final class MoveTree: Equatable {
    /// The turn number of the SAN move represented by the node.
    public let turn: UInt

    /// The side to move for the SAN move represented by the node.
    public let color: PlayerColor

    /// The SAN move represented by the current node.
    public let node: SANMove

    /// The next move in the main line.
    public let next: MoveTree?

    /// All alternative branches attached to this move.
    public let variants: [MoveTree]

    /// Convenience access to the first variation, when only one is needed.
    public var variant: MoveTree? {
        variants.first
    }

    /// Alias that makes the node payload explicit at call sites.
    public var sanMove: SANMove {
        node
    }

    public init(
        turn: UInt,
        color: PlayerColor,
        node: SANMove,
        next: MoveTree? = nil,
        variants: [MoveTree] = []
    ) {
        self.turn = turn
        self.color = color
        self.node = node
        self.next = next
        self.variants = variants
    }

    public static func == (lhs: MoveTree, rhs: MoveTree) -> Bool {
        lhs.turn == rhs.turn
            && lhs.color == rhs.color
            && lhs.node == rhs.node
            && lhs.next == rhs.next
            && lhs.variants == rhs.variants
    }
}

public extension PGNGame {
    /// Builds a move tree using the parsed PGN plies as the main line and
    /// attaching PGN variations to the move where they are declared.
    var moveTree: MoveTree? {
        MoveTree.buildLine(from: elements)
    }
}

extension MoveTree {
    static func buildLine(from elements: [PGNElement]) -> MoveTree? {
        buildLine(from: elements[...])
    }

    static func buildLine(from elements: ArraySlice<PGNElement>) -> MoveTree? {
        guard let current = elements.first else {
            return nil
        }

        if let whiteMove = current.whiteMove {
            let next: MoveTree?
            if let blackMove = current.blackMove {
                next = MoveTree(
                    turn: current.turn,
                    color: .black,
                    node: blackMove,
                    next: buildLine(from: elements.dropFirst()),
                    variants: current.postBlackVariation?.compactMap(buildLine(from:)) ?? []
                )
            } else {
                next = buildLine(from: elements.dropFirst())
            }

            return MoveTree(
                turn: current.turn,
                color: .white,
                node: whiteMove,
                next: next,
                variants: current.postWhiteVariation?.compactMap(buildLine(from:)) ?? []
            )
        }

        if let blackMove = current.blackMove {
            return MoveTree(
                turn: current.turn,
                color: .black,
                node: blackMove,
                next: buildLine(from: elements.dropFirst()),
                variants: current.postBlackVariation?.compactMap(buildLine(from:)) ?? []
            )
        }

        return buildLine(from: elements.dropFirst())
    }
}
