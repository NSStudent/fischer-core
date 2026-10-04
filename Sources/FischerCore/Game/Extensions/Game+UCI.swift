//
//  Game+UCI.swift
//  FischerCore
//
//  Created by Omar Megdadi on 14/11/25.
//
import Foundation

enum FischerCoreError: Error {
    case illegalMove
}

public extension Game {
    /// Returns the SAN for a UCI move in the current position.
    ///
    /// The check and mate markers are computed with the actual promotion
    /// piece, so underpromotions report check correctly. Castling may also be
    /// written king-takes-rook (`e1h1`), as some servers do.
    func sanMove(from uci: String) throws -> SANMove {
        guard let resolved = resolvedMove(uci: uci) else {
            throw FischerCoreError.illegalMove
        }
        do {
            return try san(for: resolved)
        } catch {
            throw FischerCoreError.illegalMove
        }
    }

    /// Converts a list of UCI moves played from the current position into SAN.
    func sanMoveList(from uciArray: [String]) throws -> [SANMove] {
        var sanMoves: [SANMove] = []
        var currentGame = self
        for uci in uciArray {
            guard let resolved = currentGame.resolvedMove(uci: uci) else {
                throw FischerCoreError.illegalMove
            }
            let sanMove = try currentGame.sanMove(from: resolved.uci)
            try currentGame.execute(resolvedMove: resolved, considerHalfmoves: false)
            sanMoves.append(sanMove)
        }
        return sanMoves
    }

    /// Resolves a UCI move against the current position.
    ///
    /// Accepts castling written as the king moving onto its own rook
    /// (`e1h1`, `e8a8`), as sent by some servers, and converts it to the
    /// standard king move. A pawn move to the last rank without a promotion
    /// letter promotes to a queen.
    ///
    /// - Returns: The legal move, or `nil` when the text is malformed or the
    ///   move is illegal. The halfmove clock is ignored.
    func resolvedMove(uci: String) -> ResolvedMove? {
        guard var resolved = ResolvedMove(uci: uci) else { return nil }
        let move = resolved.move
        if let piece = board[move.start], piece.kind.isKing, piece.color == playerTurn,
           board[move.end] == Piece(rook: playerTurn),
           move.start.file == .e, move.start.rank == move.end.rank,
           move.start.rank == Rank(startFor: playerTurn),
           move.end.file == .h || move.end.file == .a {
            let end = Square(file: move.end.file == .h ? .g : .c, rank: move.start.rank)
            resolved = ResolvedMove(move: move.start >>> end)
        }
        guard isLegal(move: resolved.move, considerHalfmoves: false) else { return nil }
        if requiresPromotion(move: resolved.move) {
            return ResolvedMove(move: resolved.move, promotion: resolved.promotion ?? .queen)
        }
        return ResolvedMove(move: resolved.move)
    }
}
