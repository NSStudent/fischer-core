//
//  MoveHistoryElement.swift
//  FischerCore
//
//  Created by Omar Megdadi on 14/11/25.
//

import Foundation

public struct MoveHistoryElement: Equatable, Sendable {
    public let move: Move
    public let piece: Piece
    public let capture: Piece?
    public let enPassantTarget: Square?
    public let kingAttackers: Bitboard
    public let halfmoves: UInt
    public let rights: CastlingRights
    public let promotionPiece: PromotionPiece?
    
    public init(
        move: Move,
        piece: Piece,
        capture: Piece?,
        enPassantTarget: Square?,
        kingAttackers: Bitboard,
        halfmoves: UInt,
        rights: CastlingRights,
        promotionPiece: PromotionPiece? = nil
    ) {
        self.move = move
        self.piece = piece
        self.capture = capture
        self.enPassantTarget = enPassantTarget
        self.kingAttackers = kingAttackers
        self.halfmoves = halfmoves
        self.rights = rights
        self.promotionPiece = promotionPiece
    }
}

extension MoveHistoryElement {
    func asUCIMove() -> String {
        return "\(move.start)\(move.end)\(promotionPiece?.uciValue ?? "")"
    }
}
