//
//  UndoMoveElement.swift
//  FischerCore
//
//  Created by Omar Megdadi on 14/11/25.
//

import Foundation

struct UndoMoveElement: Equatable, Sendable {
    let move: Move
    let promotion: PromotionPiece?
    let kingAttackers: Bitboard
    
    public init (
        move: Move,
        promotion: PromotionPiece?,
        kingAttackers: Bitboard
    ) {
        self.move = move
        self.promotion = promotion
        self.kingAttackers = kingAttackers
    }
}
