//
//  PositionError.swift
//  FischerCore
//
//  Created by Omar Megdadi on 12/4/25.
//

import Foundation

public enum PositionError: Error {
    case wrongKingCount(PlayerColor)
    case missingKing(CastlingRights.Right)
    case missingRook(CastlingRights.Right)
    case wrongEnPassantTargetRank(Rank)
    case nonEmptyEnPassantTarget(Square, Piece)
    case missingEnPassantPawn(Square)
    case nonEmptyEnPassantSquare(Square, Piece)
    case fenMalformed
}
