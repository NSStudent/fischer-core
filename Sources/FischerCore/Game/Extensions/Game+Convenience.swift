//
//  Game+Convenience.swift
//  FischerCore
//

/// A legal move resolved against a concrete game state, including the promotion
/// choice needed to reproduce the resulting position.
public struct ResolvedMove: Equatable, Sendable {
    public let move: Move
    public let promotion: PromotionPiece?

    public init(move: Move, promotion: PromotionPiece? = nil) {
        self.move = move
        self.promotion = promotion
    }
}

/// A structured SAN entry for one move that has already been played.
public struct PlayedSANMove: Equatable, Identifiable, Sendable {
    public var id: Int { index }

    public let index: Int
    public let moveNumber: Int
    public let color: PlayerColor
    public let san: String
    public let move: Move
    public let promotion: PromotionPiece?
    public let isCheckmate: Bool

    public init(
        index: Int,
        moveNumber: Int,
        color: PlayerColor,
        san: String,
        move: Move,
        promotion: PromotionPiece?,
        isCheckmate: Bool
    ) {
        self.index = index
        self.moveNumber = moveNumber
        self.color = color
        self.san = san
        self.move = move
        self.promotion = promotion
        self.isCheckmate = isCheckmate
    }
}

public extension Game {
    /// The game result if the side to move has no legal moves.
    var outcome: Outcome? {
        guard isFinished else { return nil }
        return kingIsChecked ? .win(playerTurn.inverse()) : .draw
    }

    /// Returns true when the move is a pawn move to the promotion rank.
    func requiresPromotion(move: Move) -> Bool {
        guard let piece = board[move.start] else { return false }
        return piece.kind.isPawn && move.end.rank == Rank(endFor: piece.color)
    }

    /// Finds the legal move that transforms the current board placement into
    /// `placement`. The input may be either a full FEN string or the placement
    /// field only.
    func resolvedMove(toPlacement placement: String) -> ResolvedMove? {
        let targetPlacement = FEN.placement(from: placement)
        guard Board(fen: targetPlacement) != nil else { return nil }
        guard targetPlacement != position.board.fen() else { return nil }

        for move in availableMoves() {
            if requiresPromotion(move: move) {
                for promotion in PromotionPiece.allCases {
                    var next = self
                    try? next.execute(move: move, promotion: promotion)
                    if next.position.board.fen() == targetPlacement {
                        return ResolvedMove(move: move, promotion: promotion)
                    }
                }
            } else {
                var next = self
                try? next.execute(move: move)
                if next.position.board.fen() == targetPlacement {
                    return ResolvedMove(move: move)
                }
            }
        }
        return nil
    }

    mutating func execute(resolvedMove: ResolvedMove, considerHalfmoves: Bool = true) throws {
        if let promotion = resolvedMove.promotion {
            try execute(move: resolvedMove.move, considerHalfmoves: considerHalfmoves, promotion: promotion)
        } else {
            try execute(move: resolvedMove.move, considerHalfmoves: considerHalfmoves)
        }
    }

    mutating func execute(uci: String, considerHalfmoves: Bool = true) throws {
        let parser = UCIMoveParser()
        let parsedMove: UCIMove
        do {
            parsedMove = try parser.parse(uci)
        } catch {
            throw FischerCoreError.illegalMove
        }

        switch parsedMove {
        case .nullMove:
            throw FischerCoreError.illegalMove
        case let .move(value):
            try execute(
                resolvedMove: ResolvedMove(move: value.asMove(), promotion: value.promotion),
                considerHalfmoves: considerHalfmoves
            )
        }
    }

    mutating func rewindToStart() {
        while undoMove() != nil {}
    }

    mutating func fastForward(considerHalfmoves: Bool = false) {
        while redoMove(considerHalfmoves: considerHalfmoves) {}
    }

    mutating func jumpToMove(_ index: Int, considerHalfmoves: Bool = false) {
        let target = max(0, index)
        if target < moveHistory.count {
            while moveHistory.count > target {
                _ = undoMove()
            }
        } else if target > moveHistory.count {
            while moveHistory.count < target {
                guard redoMove(considerHalfmoves: considerHalfmoves) else { break }
            }
        }
    }

    /// Returns the played moves as structured SAN entries, preserving move
    /// number, color, move index, UCI-resolved move, promotion, and mate flag.
    func playedSANMoves() throws -> [PlayedSANMove] {
        var replay = try Game(with: initialFen)
        let extraIndex = replay.playerTurn == .white ? 0 : 1
        let initialFullmove = Int(replay.initalFullmoves)

        return try moveHistory.enumerated().map { index, element in
            let sanMove = try replay.sanMove(from: element.asUCIMove())
            let color = replay.playerTurn
            let playedMove = PlayedSANMove(
                index: index,
                moveNumber: initialFullmove + ((index + extraIndex) / 2),
                color: color,
                san: sanMove.description,
                move: element.move,
                promotion: element.promotionPiece,
                isCheckmate: sanMove.isCheckmate
            )

            if let promotion = element.promotionPiece {
                try replay.execute(move: element.move, promotion: promotion)
            } else {
                try replay.execute(move: element.move)
            }
            return playedMove
        }
    }
}

private extension SANMove {
    var isCheckmate: Bool {
        switch self {
        case let .san(move):
            return move.isCheckmate
        case let .kingsideCastling(_, isCheckMate):
            return isCheckMate
        case let .queensideCastling(_, isCheckMate):
            return isCheckMate
        }
    }
}
