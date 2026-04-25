//
//  Game+Convenience.swift
//  FischerCore
//

/// A legal move resolved against a concrete game state, including the promotion
/// choice needed to reproduce the resulting position.
public struct ResolvedMove: Equatable, Sendable {
    /// The legal move to execute in the game state where it was resolved.
    public let move: Move

    /// The promotion piece required by `move`, or `nil` when the move is not a
    /// promotion.
    public let promotion: PromotionPiece?

    /// Creates a resolved move.
    ///
    /// - Parameters:
    ///   - move: The legal move to execute.
    ///   - promotion: The promotion piece to apply when the move promotes a
    ///     pawn.
    public init(move: Move, promotion: PromotionPiece? = nil) {
        self.move = move
        self.promotion = promotion
    }
}

/// A structured SAN entry for one move that has already been played.
public struct PlayedSANMove: Equatable, Identifiable, Sendable {
    /// The stable identifier for this row, equal to `index`.
    public var id: Int { index }

    /// The zero-based index of the move in `Game.moveHistory`.
    public let index: Int

    /// The human chess move number for this move.
    public let moveNumber: Int

    /// The side that played the move.
    public let color: PlayerColor

    /// The SAN text for the move in its original game context.
    public let san: String

    /// The underlying coordinate move.
    public let move: Move

    /// The promotion piece used by the move, or `nil` when the move did not
    /// promote a pawn.
    public let promotion: PromotionPiece?

    /// Whether the SAN move ended the game by checkmate.
    public let isCheckmate: Bool

    /// Creates a structured SAN entry for a played move.
    ///
    /// - Parameters:
    ///   - index: The zero-based index in `Game.moveHistory`.
    ///   - moveNumber: The human chess move number.
    ///   - color: The side that played the move.
    ///   - san: The SAN text for the move.
    ///   - move: The underlying coordinate move.
    ///   - promotion: The promotion piece, if any.
    ///   - isCheckmate: Whether the move ended the game by checkmate.
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

    /// Executes a previously resolved move.
    ///
    /// Use this when a move has already been resolved with
    /// `resolvedMove(toPlacement:)` or another workflow that produces a
    /// `ResolvedMove`.
    ///
    /// - Parameters:
    ///   - resolvedMove: The move and optional promotion piece to execute.
    ///   - considerHalfmoves: Whether to apply halfmove-clock validation.
    mutating func execute(resolvedMove: ResolvedMove, considerHalfmoves: Bool = true) throws {
        if let promotion = resolvedMove.promotion {
            try execute(move: resolvedMove.move, considerHalfmoves: considerHalfmoves, promotion: promotion)
        } else {
            try execute(move: resolvedMove.move, considerHalfmoves: considerHalfmoves)
        }
    }

    /// Parses and executes a UCI move in the current game state.
    ///
    /// The method supports standard UCI moves such as `"e2e4"` and promotion
    /// moves such as `"h7h8q"`. Null moves and malformed UCI strings throw an
    /// error.
    ///
    /// - Parameters:
    ///   - uci: The UCI move string to execute.
    ///   - considerHalfmoves: Whether to apply halfmove-clock validation.
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

    /// Undoes moves until the game reaches its initial position.
    mutating func rewindToStart() {
        while undoMove() != nil {}
    }

    /// Redoes moves until no undone move remains.
    ///
    /// - Parameter considerHalfmoves: Whether to apply halfmove-clock
    ///   validation while replaying moves.
    mutating func fastForward(considerHalfmoves: Bool = false) {
        while redoMove(considerHalfmoves: considerHalfmoves) {}
    }

    /// Moves the game history cursor to a specific move index.
    ///
    /// Values below zero rewind to the start. Values past the available redo
    /// history fast-forward as far as possible.
    ///
    /// - Parameters:
    ///   - index: The target number of played moves to keep in `moveHistory`.
    ///   - considerHalfmoves: Whether to apply halfmove-clock validation while
    ///     replaying moves.
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
