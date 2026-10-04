//
//  AnnotatedMoveNode.swift
//  FischerCore
//

/// One move of an ``AnnotatedMoveTree`` with its annotations and the moves
/// that can follow it.
///
/// `children[0]` is the main continuation and the remaining children are
/// variations (alternatives to `children[0]`).
public struct AnnotatedMoveNode: Equatable, Sendable {
    /// The fullmove number of the move (`1` for `1. e4` and `1... e5`).
    public let moveNumber: UInt

    /// The side that played the move.
    public let color: PlayerColor

    /// The move in canonical SAN, computed from the position (minimal
    /// disambiguation and correct check and mate markers).
    public let san: SANMove

    /// The move resolved against the position before it.
    public let move: ResolvedMove

    /// NAGs, comments and comment commands.
    public var annotations: MoveAnnotations

    /// The moves that can follow this one. The first child is the main
    /// continuation.
    public var children: [AnnotatedMoveNode]

    public init(
        moveNumber: UInt,
        color: PlayerColor,
        san: SANMove,
        move: ResolvedMove,
        annotations: MoveAnnotations = MoveAnnotations(),
        children: [AnnotatedMoveNode] = []
    ) {
        self.moveNumber = moveNumber
        self.color = color
        self.san = san
        self.move = move
        self.annotations = annotations
        self.children = children
    }

    /// The main continuation, if any.
    public var mainContinuation: AnnotatedMoveNode? { children.first }

    /// The alternatives to the main continuation.
    public var variations: ArraySlice<AnnotatedMoveNode> { children.dropFirst() }

    /// The move in UCI notation.
    public var uci: String { move.uci }

    /// The SAN text with the move number prefix, for example `"12. Nf3"` or
    /// `"12... Nf6"`.
    public var numberedSAN: String {
        "\(moveNumber)\(color == .white ? "." : "...") \(san)"
    }
}

/// A node of an ``AnnotatedMoveTree`` together with its path.
public struct AnnotatedMoveReference: Equatable, Identifiable, Sendable {
    /// The location of the node.
    public let path: MovePath
    /// The node, including its subtree.
    public let node: AnnotatedMoveNode

    public init(path: MovePath, node: AnnotatedMoveNode) {
        self.path = path
        self.node = node
    }

    public var id: MovePath { path }
}

/// Errors raised while editing an ``AnnotatedMoveTree``.
public enum AnnotatedMoveTreeError: Error, Equatable, Sendable {
    /// The path does not exist in the tree.
    case invalidPath(MovePath)
    /// The move cannot be played at that path.
    case illegalMove(SANResolutionError)
    /// The trees start from different positions.
    case differentInitialPosition
}
