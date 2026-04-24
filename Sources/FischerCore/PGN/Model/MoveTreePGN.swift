//
//  MoveTreePGN.swift
//  FischerCore
//
//  Created by Omar Megdadi on 21/3/26.
//

/// A PGN parsed directly into metadata plus a move tree.
public struct MoveTreePGN: Equatable {
    public var tags: [PGNTag: String]
    public var initialComment: [PGNComment]?
    public var tree: MoveTree?
    public var result: PGNOutcome?

    public init(
        tags: [PGNTag: String],
        initialComment: [PGNComment]? = nil,
        tree: MoveTree? = nil,
        result: PGNOutcome? = nil
    ) {
        self.tags = tags
        self.initialComment = initialComment
        self.tree = tree
        self.result = result
    }

    init(
        tags: [PGNTag: String],
        initialComment: [PGNComment]?,
        elements: [PGNElement],
        result: PGNOutcome?
    ) {
        self.init(
            tags: tags,
            initialComment: initialComment,
            tree: MoveTree.buildLine(from: elements),
            result: result
        )
    }

    public func fen() -> String? {
        tags[.fen]
    }

    public func initialBoard() -> Board {
        fen().flatMap(Board.init(fen:)) ?? Board()
    }
}

public extension PGNGame {
    var moveTreePGN: MoveTreePGN {
        MoveTreePGN(
            tags: tags,
            initialComment: initialComment,
            tree: moveTree,
            result: result
        )
    }
}
