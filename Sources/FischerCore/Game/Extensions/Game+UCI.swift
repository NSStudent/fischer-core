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
    func sanMove(from uci: String) throws -> SANMove {
        guard uci.count >= 4 else { throw FischerCoreError.illegalMove }
        
        let fromString = String(uci.prefix(2))
        let toString = String(uci.dropFirst(2).prefix(2))
        let promotionChar = uci.count == 5 ? uci.last : nil
        
        guard
            let from = Square(fromString),
            let to = Square(toString),
            let piece = board[from]
        else {
            throw FischerCoreError.illegalMove
        }
        
        guard isLegal(move: from >>> to) else { throw FischerCoreError.illegalMove }
        
        if piece.kind == .king && from.file == .e {
            if to.file == .g {
                return .kingsideCastling
            } else if to.file == .c {
                return .queensideCastling
            }
        }

        let isCapture = self.board[to] != nil || (piece.kind == .pawn && to == enPassantTarget)

        let promotionTo: PromotionPiece? = {
            guard let char = promotionChar else { return nil }
            return PromotionPiece(rawValue: String(char).uppercased())
        }()

        let possibleDisambiguations = self.board.bitboard(for: piece)
            .filter { $0 != from }
            .filter {
                self.isLegal(move: $0 >>> to)
            }

        let disambiguation: SANMove.FromPosition? = {
            if isCapture && piece.kind == .pawn { return .file(from.file) }
            guard !possibleDisambiguations.isEmpty else { return nil }
            let fileUnique = !possibleDisambiguations.contains(where: { $0.file == from.file && $0 != from })
            let rankUnique = !possibleDisambiguations.contains(where: { $0.rank == from.rank && $0 != from })

            if fileUnique {
                return .file(from.file)
            } else if rankUnique {
                return .rank(from.rank)
            } else {
                return .square(from)
            }
        }()

        var gameAfterMove = self
        try gameAfterMove.execute(move: Move(start: from, end: to))

        let sanDefault = SANMove.SANDefaultMove(
            piece: piece.kind,
            from: disambiguation,
            isCapture: isCapture,
            toSquare: to,
            promotionTo: promotionTo,
            isCheck: gameAfterMove.kingIsChecked,
            isCheckmate: gameAfterMove.isFinished
        )
        return .san(sanDefault)
    }
    
    func sanMoveList(from uciArray: [String]) throws -> [SANMove] {
        var sanMoves: [SANMove] = []
        var currentGame = self
        for uci in uciArray {
            let sanMove = try currentGame.sanMove(from: uci)
            try currentGame.execute(move: Move.init(game: currentGame, sanMove: sanMove))
            sanMoves.append(sanMove)
        }
        return sanMoves
    }
}
